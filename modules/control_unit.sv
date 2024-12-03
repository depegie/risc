`include "defines.vh"

module control_unit(
    input wire                               Clk,
    input wire                               Rst,
    output reg [$clog2(`RAM_CAPACITY)-1 : 0] Addr,
    output reg                               Cs,
    output reg                               We,
    output reg [8*`WORD_SIZE_B-1 : 0]        Wdata,
    input wire [8*`WORD_SIZE_B-1 : 0]        Rdata,
    input wire                               Ack,

    output reg [4 : 0]                       rs1_id,
    input wire [8*`WORD_SIZE_B-1 : 0]        rs1_data,

    output reg [4 : 0]                       rs2_id,
    input wire [8*`WORD_SIZE_B-1 : 0]        rs2_data,

    output reg [4 : 0]                       rd_id,
    output reg [8*`WORD_SIZE_B-1 : 0]        rd_data,
    output reg                               rd_valid,
    
    output reg [3 : 0]                       alu_control,
    output reg                               alu_enable,

    output reg [11 : 0]                      imm,
    output reg                               imm_enable
);
    localparam [6:0] SW_INSTR_OPCODE   = 7'b0100011;
    localparam [6:0] LW_INSTR_OPCODE   = 7'b0000011;
    localparam [6:0] ADD_INSTR_OPCODE  = 7'b0110011;
    localparam [6:0] ADDI_INSTR_OPCODE = 7'b0010011;

    enum reg [7:0] {
        ST_RESET,
        ST_FETCH,
        ST_DECODE,
        ST_EXECUTE_SW,
        ST_EXECUTE_LW,
        ST_EXECUTE_ADD,
        ST_EXECUTE_ADDI
    } state, next_state;

    reg [8*`WORD_SIZE_B-1 : 0] address;
    reg [8*`WORD_SIZE_B-1 : 0] instruction;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            address <= 32'b0;
        end
        else if (state == ST_EXECUTE_SW & Cs & Ack ||
                 state == ST_EXECUTE_LW & Cs & Ack ||
                 state == ST_EXECUTE_ADD) begin
            address <= address + 'd4;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            state <= ST_RESET;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
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
                    SW_INSTR_OPCODE:  next_state = ST_EXECUTE_SW;
                    LW_INSTR_OPCODE:  next_state = ST_EXECUTE_LW;
                    ADD_INSTR_OPCODE: next_state = ST_EXECUTE_ADD;
                    default:          next_state = ST_DECODE;
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

            ST_EXECUTE_LW: begin
                if (Cs & Ack) begin
                    next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_LW;
                end
            end

            ST_EXECUTE_ADD: begin
                next_state = ST_FETCH;
            end
            
        endcase
    end

    always_comb begin
        case (state)
            ST_RESET: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = 5'b00000;
                rs2_id = 5'b00000;
                rd_id = 5'b00000;
                rd_data = 'b0;
                rd_valid = 1'b0;
                alu_control = 4'b0000;
                alu_enable = 1'b0;
            end

            ST_FETCH: begin
                Addr = address;
                Cs = 1'b1;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = 5'b00000;
                rs2_id = 5'b00000;
                rd_id = 5'b00000;
                rd_data = 'b0;
                rd_valid = 1'b0;
                alu_control = 4'b0000;
                alu_enable = 1'b0;
            end

            ST_DECODE: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = 5'b00000;
                rs2_id = 5'b00000;
                rd_id = 5'b00000;
                rd_data = 'b0;
                rd_valid = 1'b0;
                alu_control = 4'b0000;
                alu_enable = 1'b0;
            end

            ST_EXECUTE_SW: begin
                Addr = rs1_data + {instruction[31:25], instruction[11:7]};
                Cs = 1'b1;
                We = 1'b1;
                Wdata = rs2_data;
                rs1_id = instruction[19:15];
                rs2_id = instruction[24:20];
                rd_id = 5'b00000;
                rd_data = 'b0;
                rd_valid = 1'b0;
                alu_control = 4'b0000;
                alu_enable = 1'b0;
            end

            ST_EXECUTE_LW: begin
                Addr = rs1_data + instruction[31:20];
                Cs = 1'b1;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = instruction[19:15];
                rs2_id = 5'b00000;
                rd_id = instruction[11:7];
                rd_data = Rdata;
                rd_valid = Ack;
                alu_control = 4'b0000;
                alu_enable = 1'b0;
            end

            ST_EXECUTE_ADD: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = instruction[19:15];
                rs2_id = instruction[24:20];
                rd_id = instruction[11:7];
                rd_data = 'b0;
                rd_valid = 1'b1;
                alu_control = 4'b0000;
                alu_enable = 1'b1;
            end

            default: begin
                Addr = 'b0;
                Cs = 1'b0;
                We = 1'b0;
                Wdata = 'b0;
                rs1_id = 5'b00000;
                rs2_id = 5'b00000;
                rd_id = 5'b00000;
                rd_data = 'b0;
                rd_valid = 1'b0;
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            instruction <= 'h0;
        end
        else if (state == ST_FETCH & Ack) begin
            instruction <= Rdata;
        end
    end

endmodule