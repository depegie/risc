module command_ascii_coder (
    input  logic        clk,
    input  logic        reset,
    output logic        tvalid,
    output logic [7:0]  tdata,
    input  logic [31:0] rdata,
    input  logic        tready,
    input  logic        ack
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD_BUFFER,
        SEND_BYTE
    } state_t;

    state_t state, next_state;

    logic [7:0] resp_reg [7:0]; // Buffer to store ASCII bytes
    logic [2:0] byte_index; // Index for byte transmission

    function logic [7:0] nibble_to_ascii(input logic [3:0] nibble);
        if (nibble < 4'd10)
            return "0" + nibble; // '0'-'9'
        else
            return "a" + (nibble - 4'd10); // 'a'-'f'
    endfunction

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tvalid <= 0;
            tdata <= 8'd0;
            byte_index <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    tvalid <= 0;
                    if (ack) begin
                        resp_reg[0] <= nibble_to_ascii(rdata[31:28]);
                        resp_reg[1] <= nibble_to_ascii(rdata[27:24]);
                        resp_reg[2] <= nibble_to_ascii(rdata[23:20]);
                        resp_reg[3] <= nibble_to_ascii(rdata[19:16]);
                        resp_reg[4] <= nibble_to_ascii(rdata[15:12]);
                        resp_reg[5] <= nibble_to_ascii(rdata[11:8]);
                        resp_reg[6] <= nibble_to_ascii(rdata[7:4]);
                        resp_reg[7] <= nibble_to_ascii(rdata[3:0]);
                        byte_index <= 0;
                        next_state <= SEND_BYTE;
                    end
                end

                SEND_BYTE: begin
                    tvalid <= 1;
                    tdata <= resp_reg[byte_index];

                    if (tready) begin
                        byte_index <= byte_index + 1;
                        if (byte_index == 3'd7) begin
                            next_state <= IDLE;
                        end else begin
                            next_state <= SEND_BYTE;
                        end
                    end else begin
                        next_state <= SEND_BYTE;
                    end
                end

                default: next_state <= IDLE;
            endcase
        end
    end

endmodule
