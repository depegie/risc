`include "defines.vh"

module control_unit(
    input wire                               Clk,
    input wire                               Rst,
    output reg [$clog2(`RAM_CAPACITY)-1 : 0] Addr,
    output reg                               Cs,
    output reg                               We,
    output reg [8*`WORD_SIZE-1 : 0]          Wdata,
    input wire [8*`WORD_SIZE-1 : 0]          Rdata,
    input wire                               Ack,

    output reg [4 : 0]                       rs1_id,
    output reg                               rs1_valid,
    input wire [8*`WORD_SIZE-1 : 0]          rs1_data_in,

    output reg [4 : 0]                       rs2_id,
    output reg                               rs2_valid,
    input wire [8*`WORD_SIZE-1 : 0]          rs2_data_in,

    output reg [4 : 0]                       rd_id,
    output reg                               rd_valid,
    output reg [8*`WORD_SIZE-1 : 0]          rd_data_out
);
    localparam ST_RESET      = 'd0;
    localparam ST_FETCH      = 'd1;
    localparam ST_DECODE     = 'd2;
    localparam ST_EXECUTE_SW = 'd3;
    localparam ST_EXECUTE_LW = 'd4;

    localparam [6:0] SW_INSTR_OPCODE = 7'b0100011;
    localparam [6:0] LW_INSTR_OPCODE = 7'b0000011;

    reg [7:0]  state;
    reg [7:0]  next_state;
    reg [31:0] addr;
    reg [31:0] instruction;

    always @(posedge Clk) begin
        if (Rst) begin
            addr <= 32'b0;
        end
        else if (state == ST_EXECUTE_SW) begin
            addr <= addr + 'd4;
        end
    end

    always @(posedge Clk) begin
        if (Rst) begin
            state <= ST_RESET;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            ST_RESET: begin
                next_state = ST_FETCH;
            end

            ST_FETCH: begin
                if (Cs & Ack) begin
                    next_state = ST_DECODE;
                end
                else begin
                    next_state = ST_FETCH;
                end
            end

            ST_DECODE: begin
                case (instruction[6:0])
                    SW_INSTR_OPCODE: next_state = ST_EXECUTE_SW;
                    LW_INSTR_OPCODE: next_state = ST_EXECUTE_LW;
                    default:         next_state = ST_DECODE;
                endcase
            end

            ST_EXECUTE_SW: begin
                if (Cs & Ack) begin
                    next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_SW;
                end
            end

            // ST_EXECUTE_LW: begin
            // end

            

        endcase
    end

    always @(*) begin
        case (state)
            ST_RESET: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                
                rs1_id = 5'b00000;
                rs1_valid = 1'b0;
                
                rs2_id = 5'b00000;
                rs2_valid = 1'b0;
            end

            ST_FETCH: begin
                Addr = addr;
                Cs = 1'b1;
                We = 1'b0;
                Wdata = 'b0;
                
                rs1_id = 5'b00000;
                rs1_valid = 1'b0;
                
                rs2_id = 5'b00000;
                rs2_valid = 1'b0;
            end

            ST_DECODE: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                
                rs1_id = 5'b00000;
                rs1_valid = 1'b0;
                
                rs2_id = 5'b00000;
                rs2_valid = 1'b0;
            end

            ST_EXECUTE_SW: begin
                Addr = rs1_data_in + {instruction[31:25], instruction[11:7]};
                Cs = 1'b1;
                We = 1'b1;
                Wdata = rs2_data_in;
                
                rs1_id = instruction[19:15];
                rs1_valid = 1'b1;
                
                rs2_id = instruction[24:20];
                rs2_valid = 1'b1;
            end

            default: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                
                rs1_id = 5'b00000;
                rs1_valid = 1'b0;
                
                rs2_id = 5'b00000;
                rs2_valid = 1'b0;
            end
        endcase
    end

    always @(posedge Clk) begin
        if (Rst) begin
            instruction <= 'h0;
        end
        else if (state == ST_FETCH & Ack) begin
            instruction <= Rdata;
        end
    end

endmodule