`include "defines.svh"

module response_coder (
    input  logic                    Clk,
    input  logic                    Rst,
    output logic                    M_axis_tvalid,
    output logic            [7 : 0] M_axis_tdata,
    input  logic                    M_axis_tready,
    input  logic                    Cs,
    input  logic                    We,
    input  logic [`WORD_SIZE-1 : 0] Rdata,
    input  logic                    Ack
);

    enum logic [1:0] {
        IDLE,
        SEND_BYTE,
        SEND_LF
    } state, next_state;

    logic [7:0] resp_reg[8]; 
    logic [2:0] byte_index; 

    function logic [7:0] nibble_to_ascii(input logic [3:0] nibble);
        if (nibble < 4'd10)
            return "0" + nibble; // '0'-'9'
        else
            return "a" + (nibble - 4'd10); // 'a'-'f'
    endfunction

    always_ff @(posedge Clk) begin
        if (Rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (Cs & ~We & Ack) next_state = SEND_BYTE;
            end
            
            SEND_BYTE: begin
                if (M_axis_tvalid & M_axis_tready & byte_index == 3'd7) begin
                    next_state = SEND_LF;
                end
            end

            SEND_LF: begin
                if (M_axis_tvalid & M_axis_tready) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            byte_index <= 0;
        end
        else if (state == IDLE) begin
            byte_index <= 0;
        end
        else if (M_axis_tvalid & M_axis_tready) begin
            byte_index <= byte_index + 1;
        end
    end

    always_comb begin
        case (state)
            IDLE: begin
                M_axis_tvalid = 0;
                M_axis_tdata = 8'h0;
            end

            SEND_BYTE: begin
                M_axis_tvalid = 1;
                M_axis_tdata = resp_reg[byte_index];
            end

            SEND_LF: begin
                M_axis_tvalid = 1;
                M_axis_tdata = 8'h0a;
            end

            default: begin
                M_axis_tvalid = 0;
                M_axis_tdata = 8'h0;
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            resp_reg[0] <= 'h0;
            resp_reg[1] <= 'h0;
            resp_reg[2] <= 'h0;
            resp_reg[3] <= 'h0;
            resp_reg[4] <= 'h0;
            resp_reg[5] <= 'h0;
            resp_reg[6] <= 'h0;
            resp_reg[7] <= 'h0;
        end
        else if (state == IDLE & Cs & ~We & Ack) begin
            resp_reg[0] <= nibble_to_ascii(Rdata[31:28]);
            resp_reg[1] <= nibble_to_ascii(Rdata[27:24]);
            resp_reg[2] <= nibble_to_ascii(Rdata[23:20]);
            resp_reg[3] <= nibble_to_ascii(Rdata[19:16]);
            resp_reg[4] <= nibble_to_ascii(Rdata[15:12]);
            resp_reg[5] <= nibble_to_ascii(Rdata[11:8]);
            resp_reg[6] <= nibble_to_ascii(Rdata[7:4]);
            resp_reg[7] <= nibble_to_ascii(Rdata[3:0]);
        end
    end

endmodule
