module ascii_command_decoder (
    input  logic        clk,
    input  logic       reset,
	output logic 		rst,
    input  logic        tvalid,
    input  logic [7:0]  tdata,
    output logic        tready,
    output logic [7:0] addr,
    output logic [31:0] wdata,
    output logic        we,
    output logic        cs,
    output logic        irq,
    input  logic        ack
);

    logic [7:0] command_reg [17:0];
    logic [4:0] write_ptr;

    assign tready = 1'b1;

    logic decoding;

    typedef enum logic [2:0] {
        IDLE,
        CHECK_CMD,
        PARSE_WRITE_ADDR,
        PARSE_READ_ADDR,
        PARSE_WRITE_DATA,
        WAIT_FOR_ACK,
        START,
        STOP,
        READ,
        OUTPUT
    } state_t;
    state_t state, next_state;

    logic [7:0] parsed_addr;
    logic [31:0] parsed_data;

    function logic is_hex_char(input logic [7:0] char);
        return (char >= "0" && char <= "9") || (char >= "a" && char <= "f") || (char >= "A" && char <= "F");
    endfunction

    function logic [3:0] hex_to_bin(input logic [7:0] char);
        if (char >= "0" && char <= "9")
            return char - "0";
        else if (char >= "a" && char <= "f")
            return char - "a" + 4'd10; // zastanowic sie
        else if (char >= "A" && char <= "F")
            return char - "A" + 4'd10;
        else
            return 4'd0;
    endfunction

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            write_ptr <= 0;
            decoding <= 0;
            we <= 0;
            cs <= 0;
            addr <= 16'd0;
            wdata <= 32'd0;
            irq <= 1; //czy tu wystarczy?
        end else begin
            state <= next_state;

            if (tvalid && tready && !decoding) begin

                command_reg[write_ptr] <= tdata;
                write_ptr <= (write_ptr == 17) ? 0 : write_ptr + 1;

                if (tdata == 8'h0A)  
                    decoding <= 1;
            end

            case (state)
                IDLE: begin
                    if (decoding) begin
                        decoding <= 0;
                        next_state <= CHECK_CMD;
                    end
                end

                CHECK_CMD: begin
                    if (command_reg[0] == "s" &&
                        command_reg[1] == "t" &&
                        command_reg[2] == "a" &&
                        command_reg[3] == "r" &&
                        command_reg[4] == "t") begin
                        next_state <= START;
                    end
                    else if (command_reg[0] == "s" &&
                        command_reg[1] == "t" &&
                        command_reg[2] == "o" &&
                        command_reg[3] == "p") begin
                        next_state <= STOP;
                    end
                    else if (command_reg[0] == "w" &&
                        command_reg[1] == "r" &&
                        command_reg[2] == "i" &&
                        command_reg[3] == "t" &&
                        command_reg[4] == "e" &&
                        command_reg[5] == " ") begin
                        next_state <= PARSE_WRITE_ADDR;
                    end
                    else if (command_reg[0] == "r" &&
                             command_reg[1] == "e" &&
                             command_reg[2] == "a" &&
                             command_reg[3] == "d" &&
                             command_reg[4] == " ") begin
                             next_state <= PARSE_READ_ADDR; //parse read addr !
                    end else begin
                        next_state <= IDLE; 
                    end
                end

                START: begin
                    irq <= 0;
                    next_state <= IDLE;
                end
                
                STOP: begin
                    irq <= 1;
                    next_state <= IDLE;
                end

                PARSE_WRITE_ADDR: begin
                    if (is_hex_char(command_reg[6]) && is_hex_char(command_reg[7])) begin //tu jakas zmienna, [6] jest tylko dla write
                        parsed_addr <= {hex_to_bin(command_reg[6]), hex_to_bin(command_reg[7])};
                        next_state <= PARSE_WRITE_DATA;
                    end else begin
                        next_state <= IDLE;  
                    end
                end
                
                PARSE_READ_ADDR: begin
                    if (is_hex_char(command_reg[5]) && is_hex_char(command_reg[6])) begin //tu jakas zmienna, [6] jest tylko dla write
                        parsed_addr <= {hex_to_bin(command_reg[5]), hex_to_bin(command_reg[6])};
                        next_state <= READ;
                    end else begin
                        next_state <= IDLE;  
                    end
                end

                PARSE_WRITE_DATA: begin
                    if (is_hex_char(command_reg[9]) && is_hex_char(command_reg[10]) &&
                        is_hex_char(command_reg[11]) && is_hex_char(command_reg[12]) &&
                        is_hex_char(command_reg[13]) && is_hex_char(command_reg[14]) &&
                        is_hex_char(command_reg[15]) && is_hex_char(command_reg[16])) begin
                        parsed_data <= {
                            hex_to_bin(command_reg[9]), hex_to_bin(command_reg[10]),
                            hex_to_bin(command_reg[11]), hex_to_bin(command_reg[12]),
                            hex_to_bin(command_reg[13]), hex_to_bin(command_reg[14]),
                            hex_to_bin(command_reg[15]), hex_to_bin(command_reg[16])
                        };
                        next_state <= OUTPUT;
                    end else begin
                        next_state <= IDLE;  // Niepoprawne dane\n
                    end
                end
                
                WAIT_FOR_ACK: begin
                    if (ack == 1) begin
                        next_state <= IDLE;  // Transition to IDLE on ACK
                    end else begin
                        next_state <= WAIT_FOR_ACK;  // Stay in this state until ACK is received
                    end
                end

                OUTPUT: begin
                    addr <= parsed_addr;
                    wdata <= parsed_data;
                    we <= 1;
                    cs <= 1;
                    next_state <= IDLE;
                end
                
                READ: begin
                    addr <= parsed_addr;
                    wdata <= 32'd0;
                    we <= 0;
                    cs <= 1;
                    next_state <= WAIT_FOR_ACK;
                end

                default: next_state <= IDLE;
            endcase
        end
    end
endmodule
