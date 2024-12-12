module ascii_command_decoder (
    input  logic        clk,
    input  logic       Rst,
	output logic 		Core_rst,
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

    logic [7:0] command_reg[18];
    logic [4:0] write_ptr;

    assign tready = 1'b1;

    // logic decoding;

    enum logic [7:0] {
        IDLE,
        CHECK_CMD,
        PARSE_WRITE_ARGS,
        PARSE_READ_ARGS,
        START,
        STOP,
        READ,
        WRITE,
        RESET
    } state, next_state;

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

    always_comb begin
        case (state)
            IDLE: begin
                if (tvalid && tready && tdata == 8'h0A) begin
                    next_state = CHECK_CMD;
                end
                else begin
                    next_state = IDLE;
                end
            end
            CHECK_CMD: begin
                if (command_reg[0] == "s" &&
                    command_reg[1] == "t" &&
                    command_reg[2] == "a" &&
                    command_reg[3] == "r" &&
                    command_reg[4] == "t") begin
                    next_state = START;
                end
                else if (command_reg[0] == "s" &&
                         command_reg[1] == "t" &&
                         command_reg[2] == "o" &&
                         command_reg[3] == "p") begin
                    next_state = STOP;
                end
                else if (command_reg[0] == "r" &&
                         command_reg[1] == "e" &&
                         command_reg[2] == "s" &&
                         command_reg[3] == "e" &&
                         command_reg[4] == "t") begin
                    next_state = RESET;
                end
                else if (command_reg[0] == "w" &&
                         command_reg[1] == "r" &&
                         command_reg[2] == "i" &&
                         command_reg[3] == "t" &&
                         command_reg[4] == "e" &&
                         command_reg[5] == " ") begin
                    next_state = PARSE_WRITE_ARGS;
                end
                else if (command_reg[0] == "r" &&
                         command_reg[1] == "e" &&
                         command_reg[2] == "a" &&
                         command_reg[3] == "d" &&
                         command_reg[4] == " ") begin
                    next_state = PARSE_READ_ARGS; //parse read addr !
                end
                else begin
                    next_state = IDLE; 
                end
            end
            PARSE_WRITE_ARGS: begin
                next_state = WRITE;  
            end
            PARSE_READ_ARGS: begin
                next_state = READ;
            end
            START: begin
                next_state = IDLE;
            end
            STOP: begin
                next_state = IDLE;
            end
            RESET: begin
                next_state = IDLE;
            end
            READ: begin
                if (cs & ack) next_state = IDLE;
                else          next_state = READ;
            end
            WRITE: begin
                if (cs & ack) next_state = IDLE;
                else          next_state = WRITE;
            end

            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge Rst) begin
        if (Rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            WRITE: begin
                addr = parsed_addr;
                cs = 1;
                we = 1;
                wdata = parsed_data;
                Core_rst = 1'b0;
            end
            READ: begin
                addr <= parsed_addr;
                cs <= 1;
                we <= 0;
                wdata <= 32'd0;
                Core_rst = 1'b0;
            end
            RESET: begin
                addr = 16'd0;
                we = 0;
                cs = 0;
                wdata = 32'd0;
                Core_rst = 1'b1;
            end
            default: begin
                addr = 16'd0;
                we = 0;
                cs = 0;
                wdata = 32'd0;
                Core_rst = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk or posedge Rst) begin
        if (Rst) begin
            irq <= 1;
        end
        else if (state == START) begin
            irq <= 0;
        end
        else if (state == STOP) begin
            irq <= 1;
        end
    end

    always_ff @(posedge clk or posedge Rst) begin
        if (Rst) begin
            write_ptr <= 'd0;
        end
        else if ((state == WRITE & cs & ack) || 
                 (state == READ & cs & ack)  || 
                  state == START             || 
                  state == STOP              ) begin
            write_ptr <= 'd0;
        end
        else if (tvalid && tready) begin
            write_ptr <= write_ptr + 'd1;
        end
    end

    always_ff @(posedge clk or posedge Rst) begin
        if (Rst) begin
            for (int i=0; i<18; i++) command_reg[i] <= 'b0;
        end
        if (tvalid && tready) begin
            command_reg[write_ptr] <= tdata;
        end
    end

    always_ff @(posedge clk or posedge Rst) begin
        if (Rst) begin
            parsed_addr <= 'h0;
            parsed_data <= 'h0;
        end
        else if (state == PARSE_WRITE_ARGS) begin
            if (is_hex_char(command_reg[6]) && is_hex_char(command_reg[7])) begin //tu jakas zmienna, [6] jest tylko dla write
                parsed_addr <= {hex_to_bin(command_reg[6]), hex_to_bin(command_reg[7])};
            end

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
            end
        end
        else if (state == PARSE_READ_ARGS) begin
            if (is_hex_char(command_reg[5]) && is_hex_char(command_reg[6])) begin
                parsed_addr <= {hex_to_bin(command_reg[5]), hex_to_bin(command_reg[6])};
            end
        end
    end

endmodule
