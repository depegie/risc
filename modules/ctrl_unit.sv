`include "defines.svh"

module ctrl_unit (
    input                         Clk,
    input                         Rst,

    output reg [`ADDR_SIZE-1 : 0] Wb_addr,
    output reg                    Wb_cs,
    output reg                    Wb_we,
    output reg [`WORD_SIZE-1 : 0] Wb_wdata,
    input      [`WORD_SIZE-1 : 0] Wb_rdata,
    input                         Wb_ack,

    output reg            [4 : 0] Rs1_id,
    input      [`WORD_SIZE-1 : 0] Rs1_data,

    output reg            [4 : 0] Rs2_id,
    input      [`WORD_SIZE-1 : 0] Rs2_data,

    output reg            [4 : 0] Rd_id,
    output reg [`WORD_SIZE-1 : 0] Rd_data,
    output reg                    Rd_write,

    output reg            [3 : 0] Alu_control,
    output reg                    Alu_enable,

    output reg           [11 : 0] Imm_data,
    output reg                    Imm_enable
);
    localparam [6 : 0] SW_INSTR_OPCODE   = 7'b0100011;
    localparam [6 : 0] LW_INSTR_OPCODE   = 7'b0000011;
    localparam [6 : 0] ADD_INSTR_OPCODE  = 7'b0110011;
    localparam [6 : 0] ADDI_INSTR_OPCODE = 7'b0010011;

    enum reg [7 : 0] {
        ST_IDLE,
        ST_FETCH,
        ST_DECODE,
        ST_EXECUTE_SW,
        ST_EXECUTE_LW,
        ST_EXECUTE_ADD,
        ST_EXECUTE_ADDI
    } state, next_state;

    reg [`WORD_SIZE-1 : 0] address;
    reg [`WORD_SIZE-1 : 0] instruction;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            address <= 32'b0;
        end
        else if (state == ST_EXECUTE_SW & Wb_cs & Wb_ack ||
                 state == ST_EXECUTE_LW & Wb_cs & Wb_ack ||
                 state == ST_EXECUTE_ADD) begin
            address <= address + 'd4;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            state <= ST_IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                next_state = ST_FETCH;
            end

            ST_FETCH: begin
                if (Wb_cs & Wb_ack) begin
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
                    default:          next_state = ST_FETCH;
                endcase
            end

            ST_EXECUTE_SW: begin
                if (Wb_cs & Wb_ack) begin
                    next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_SW;
                end
            end

            ST_EXECUTE_LW: begin
                if (Wb_cs & Wb_ack) begin
                    next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_LW;
                end
            end

            ST_EXECUTE_ADD: begin
                next_state = ST_FETCH;
            end

            ST_EXECUTE_ADDI: begin
                next_state = ST_FETCH;
            end
            
            default: begin
                next_state = ST_FETCH;
            end
            
        endcase
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_FETCH: begin
                Wb_addr = address;
                Wb_cs = 1'b1;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_DECODE: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_SW: begin
                Wb_addr = Rs1_data + {instruction[31:25], instruction[11:7]};
                Wb_cs = 1'b1;
                Wb_we = 1'b1;
                Wb_wdata = Rs2_data;
                Rs1_id = instruction[19:15];
                Rs2_id = instruction[24:20];
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_LW: begin
                Wb_addr = Rs1_data + instruction[31:20];
                Wb_cs = 1'b1;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = instruction[19:15];
                Rs2_id = 5'b00000;
                Rd_id = instruction[11:7];
                Rd_data = Wb_rdata;
                Rd_write = Wb_ack;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_ADD: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = instruction[19:15];
                Rs2_id = instruction[24:20];
                Rd_id = instruction[11:7];
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = 4'b0000;
                Alu_enable = 1'b1;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_ADDI: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = instruction[19:15];
                Rs2_id = 5'b00000;
                Rd_id = instruction[11:7];
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = 4'b0000;
                Alu_enable = 1'b1;
                Imm_data = instruction[31:20];
                Imm_enable = 1'b1;
            end

            default: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            instruction <= 'h0;
        end
        else if (state == ST_FETCH & Wb_ack) begin
            instruction <= Wb_rdata;
        end
    end

endmodule