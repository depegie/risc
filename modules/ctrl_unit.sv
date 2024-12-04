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
    // localparam [6 : 0] SW_INSTR_OPCODE   = 7'b0100011;
    // localparam [6 : 0] LW_INSTR_OPCODE   = 7'b0000011;
    // localparam [6 : 0] ADD_INSTR_OPCODE  = 7'b0110011;
    // localparam [6 : 0] SUB_INSTR_OPCODE  = 7'b0110011;
    // localparam [6 : 0] ADDI_INSTR_OPCODE = 7'b0010011;

    localparam [6 : 0] R_TYPE_OPCODE = 7'b0110011;
    localparam [6 : 0] I_TYPE_OPCODE = 7'b0010011;
    localparam [6 : 0] L_TYPE_OPCODE = 7'b0000011;
    localparam [6 : 0] S_TYPE_OPCODE = 7'b0100011;
    localparam [6 : 0] J_TYPE_OPCODE = 7'b1101111;

    wire [3 : 0] alu_ctrl;
    wire [4 : 0] instr_id;

    enum reg [7 : 0] {
        ST_IDLE,
        ST_FETCH,
        ST_DECODE,
        ST_EXECUTE_R_TYPE,
        ST_EXECUTE_I_TYPE,
        ST_EXECUTE_L_TYPE,
        ST_EXECUTE_S_TYPE,
        ST_EXECUTE_J_TYPE
        // ST_EXECUTE_ADD,
        // ST_EXECUTE_SUB,
        // ST_EXECUTE_XOR,
        // ST_EXECUTE_OR,
        // ST_EXECUTE_AND,
        // ST_EXECUTE_SLL,
        // ST_EXECUTE_SRL,
        // ST_EXECUTE_SRA,
        // ST_EXECUTE_SLT,
        // ST_EXECUTE_ADDI,
        // ST_EXECUTE_XORI,
        // ST_EXECUTE_ORI,
        // ST_EXECUTE_ANDI,
        // ST_EXECUTE_SLLI,
        // ST_EXECUTE_SRLI,
        // ST_EXECUTE_SRAI,
        // ST_EXECUTE_SW,
        // ST_EXECUTE_LW,
        // ST_EXECUTE_JAL
    } state, next_state;

    reg [`WORD_SIZE-1 : 0] addr;
    reg [`WORD_SIZE-1 : 0] instr;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            addr <= 32'b0;
        end
        else if (state == ST_EXECUTE_SW & Wb_cs & Wb_ack |
                 state == ST_EXECUTE_LW & Wb_cs & Wb_ack |
                 state == ST_EXECUTE_ADD                 |
                 state == ST_EXECUTE_ADDI) begin
            addr <= addr + 'd4;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            instr <= 'h0;
        end
        else if (state == ST_FETCH & Wb_ack) begin
            instr <= Wb_rdata;
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
                if (Wb_cs & Wb_ack)
                    next_state = ST_DECODE;
                else
                    next_state = ST_FETCH;
            end

            ST_DECODE: begin
                case (`INSTR_OPCODE)
                    R_TYPE_OPCODE: next_state = ST_EXECUTE_R_TYPE;
                    I_TYPE_OPCODE: next_state = ST_EXECUTE_I_TYPE;
                    L_TYPE_OPCODE: next_state = ST_EXECUTE_L_TYPE;
                    S_TYPE_OPCODE: next_state = ST_EXECUTE_S_TYPE;
                    J_TYPE_OPCODE: next_state = ST_EXECUTE_J_TYPE;
                    default:       next_state = ST_FETCH;
                endcase
            end

            ST_EXECUTE_R_TYPE: begin
                next_state = ST_FETCH;
            end

            ST_EXECUTE_I_TYPE: begin
                next_state = ST_FETCH;
            end

            ST_EXECUTE_L_TYPE: begin
                if (Wb_cs & Wb_ack)
                    next_state = ST_FETCH;
                else
                    next_state = ST_EXECUTE_L_TYPE;
            end

            ST_EXECUTE_S_TYPE: begin
                if (Wb_cs & Wb_ack)
                    next_state = ST_FETCH;
                else
                    next_state = ST_EXECUTE_S_TYPE;
            end

            ST_EXECUTE_J_TYPE: begin end

            // ST_EXECUTE_SW: begin
            //     if (Wb_cs & Wb_ack)
            //         next_state = ST_FETCH;
            //     else
            //         next_state = ST_EXECUTE_SW;
            // end

            // ST_EXECUTE_LW: begin
            //     if (Wb_cs & Wb_ack)
            //         next_state = ST_FETCH;
            //     else
            //         next_state = ST_EXECUTE_LW;
            // end

            // ST_EXECUTE_ADD: begin
            //     next_state = ST_FETCH;
            // end

            // ST_EXECUTE_ADDI: begin
            //     next_state = ST_FETCH;
            // end
            
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
                Wb_addr = addr;
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

            ST_EXECUTE_R_TYPE: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = `INSTR_RS2;
                Rd_id = `INSTR_RD;
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = alu_ctrl;
                Alu_enable = 1'b1;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_I_TYPE: begin
                Wb_addr = 'b0;
                Wb_cs = 1'b0;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = 5'b00000;
                Rd_id = `INSTR_RD;;
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = alu_ctrl;
                Alu_enable = 1'b1;
                Imm_data = `INSTR_I_TYPE_IMM;
                Imm_enable = 1'b1;
            end

            ST_EXECUTE_L_TYPE: begin
                Wb_addr = Rs1_data + `INSTR_L_TYPE_IMM;
                Wb_cs = 1'b1;
                Wb_we = 1'b0;
                Wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = 5'b00000;
                Rd_id = `INSTR_RD;
                Rd_data = Wb_rdata;
                Rd_write = Wb_ack;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_S_TYPE: begin
                Wb_addr = Rs1_data + `INSTR_S_TYPE_IMM;
                Wb_cs = 1'b1;
                Wb_we = 1'b1;
                Wb_wdata = Rs2_data;
                Rs1_id = `INSTR_RS1;
                Rs2_id = `INSTR_RS2;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
            end

            ST_EXECUTE_J_TYPE: begin

            end

            // ST_EXECUTE_SW: begin
            //     Wb_addr = Rs1_data + `INSTR_S_TYPE_IMM;
            //     Wb_cs = 1'b1;
            //     Wb_we = 1'b1;
            //     Wb_wdata = Rs2_data;
            //     Rs1_id = `INSTR_RS1;
            //     Rs2_id = `INSTR_RS2;
            //     Rd_id = 5'b00000;
            //     Rd_data = 'b0;
            //     Rd_write = 1'b0;
            //     Alu_control = 4'b0000;
            //     Alu_enable = 1'b0;
            //     Imm_data = 12'h000;
            //     Imm_enable = 1'b0;
            // end

            // ST_EXECUTE_LW: begin
            //     Wb_addr = Rs1_data + instr[31:20];
            //     Wb_cs = 1'b1;
            //     Wb_we = 1'b0;
            //     Wb_wdata = 'b0;
            //     Rs1_id = `INSTR_RS1;
            //     Rs2_id = 5'b00000;
            //     Rd_id = `INSTR_RD;
            //     Rd_data = Wb_rdata;
            //     Rd_write = Wb_ack;
            //     Alu_control = 4'b0000;
            //     Alu_enable = 1'b0;
            //     Imm_data = 12'h000;
            //     Imm_enable = 1'b0;
            // end

            // ST_EXECUTE_ADD: begin
            //     Wb_addr = 'b0;
            //     Wb_cs = 1'b0;
            //     Wb_we = 1'b0;
            //     Wb_wdata = 'b0;
            //     Rs1_id = `INSTR_RS1;
            //     Rs2_id = `INSTR_RS2;
            //     Rd_id = `INSTR_RD;
            //     Rd_data = 'b0;
            //     Rd_write = 1'b1;
            //     Alu_control = 4'b0000;
            //     Alu_enable = 1'b1;
            //     Imm_data = 12'h000;
            //     Imm_enable = 1'b0;
            // end

            // ST_EXECUTE_ADDI: begin
            //     Wb_addr = 'b0;
            //     Wb_cs = 1'b0;
            //     Wb_we = 1'b0;
            //     Wb_wdata = 'b0;
            //     Rs1_id = `INSTR_RS1;
            //     Rs2_id = 5'b00000;
            //     Rd_id = `INSTR_RD;
            //     Rd_data = 'b0;
            //     Rd_write = 1'b1;
            //     Alu_control = 4'b0000;
            //     Alu_enable = 1'b1;
            //     Imm_data = `INSTR_I_TYPE_IMM;
            //     Imm_enable = 1'b1;
            // end

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

    instruction_decoder instruction_decoder_inst (
        .Instr    ( instr ),
        .Alu_ctrl ( alu_ctrl ),
        .Instr_id ( instr_id )
    );

endmodule