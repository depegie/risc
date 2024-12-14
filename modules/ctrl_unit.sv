`include "defines.svh"

module ctrl_unit (
    input                         Clk,
    input                         Rst,

    output reg [`ADDR_SIZE-1 : 0] M_wb_addr,
    output reg                    M_wb_cs,
    output reg                    M_wb_we,
    output reg [`WORD_SIZE-1 : 0] M_wb_wdata,
    input      [`WORD_SIZE-1 : 0] M_wb_rdata,
    input                         M_wb_ack,

    input                         Irq,
    output reg                    Irq_pending,

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
    localparam [6 : 0] R_TYPE_OPCODE = 7'b0110011;
    localparam [6 : 0] I_TYPE_OPCODE = 7'b0010011;
    localparam [6 : 0] L_TYPE_OPCODE = 7'b0000011;
    localparam [6 : 0] S_TYPE_OPCODE = 7'b0100011;
    localparam [6 : 0] J_TYPE_OPCODE = 7'b1101111;

    wire [3 : 0] alu_ctrl;
    wire [4 : 0] instr_id;

    enum reg [7 : 0] {
        ST_IDLE           = 8'b1 << 'd0,
        ST_FETCH          = 8'b1 << 'd1,
        ST_DECODE         = 8'b1 << 'd2,
        ST_EXECUTE_R_TYPE = 8'b1 << 'd3,
        ST_EXECUTE_I_TYPE = 8'b1 << 'd4,
        ST_EXECUTE_L_TYPE = 8'b1 << 'd5,
        ST_EXECUTE_S_TYPE = 8'b1 << 'd6,
        ST_EXECUTE_J_TYPE = 8'b1 << 'd7
    } state, next_state;

    reg [`ADDR_SIZE-1 : 0] addr;
    reg [`WORD_SIZE-1 : 0] instr;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            addr <= 32'b0;
        end
        else if ( state == ST_EXECUTE_R_TYPE                   |
                  state == ST_EXECUTE_I_TYPE                   |
                 (state == ST_EXECUTE_L_TYPE & M_wb_cs & M_wb_ack) |
                 (state == ST_EXECUTE_S_TYPE & M_wb_cs & M_wb_ack) ) begin
            addr <= addr + 'd4;
        end
        else if (state == ST_EXECUTE_J_TYPE) begin
            addr <= `INSTR_J_TYPE_IMM;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            instr <= 'h0;
        end
        else if (state == ST_FETCH & M_wb_ack) begin
            instr <= M_wb_rdata;
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
                if (Irq) next_state = ST_IDLE;
                else     next_state = ST_FETCH;
            end

            ST_FETCH: begin
                if (M_wb_cs & M_wb_ack)
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
                    default: begin
                        if (Irq) next_state = ST_IDLE;
                        else     next_state = ST_FETCH;
                    end
                endcase
            end

            ST_EXECUTE_R_TYPE: begin
                if (Irq) next_state = ST_IDLE;
                else     next_state = ST_FETCH;
            end

            ST_EXECUTE_I_TYPE: begin
                if (Irq) next_state = ST_IDLE;
                else     next_state = ST_FETCH;
            end

            ST_EXECUTE_L_TYPE: begin
                if (M_wb_cs & M_wb_ack) begin
                    if (Irq) next_state = ST_IDLE;
                    else     next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_L_TYPE;
                end
            end

            ST_EXECUTE_S_TYPE: begin
                if (M_wb_cs & M_wb_ack) begin
                    if (Irq) next_state = ST_IDLE;
                    else     next_state = ST_FETCH;
                end
                else begin
                    next_state = ST_EXECUTE_S_TYPE;
                end
            end

            ST_EXECUTE_J_TYPE: begin
                if (Irq) next_state = ST_IDLE;
                else     next_state = ST_FETCH;
            end
            
            default: begin
                if (Irq) next_state = ST_IDLE;
                else     next_state = ST_FETCH;
            end
            
        endcase
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b1;
            end

            ST_FETCH: begin
                M_wb_addr = addr;
                M_wb_cs = 1'b1;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            ST_DECODE: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            ST_EXECUTE_R_TYPE: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = `INSTR_RS2;
                Rd_id = `INSTR_RD;
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = alu_ctrl;
                Alu_enable = 1'b1;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            ST_EXECUTE_I_TYPE: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = 5'b00000;
                Rd_id = `INSTR_RD;
                Rd_data = 'b0;
                Rd_write = 1'b1;
                Alu_control = alu_ctrl;
                Alu_enable = 1'b1;
                Imm_data = `INSTR_I_TYPE_IMM;
                Imm_enable = 1'b1;
                Irq_pending = 1'b0;
            end

            ST_EXECUTE_L_TYPE: begin
                M_wb_addr = Rs1_data + `INSTR_L_TYPE_IMM;
                M_wb_cs = 1'b1;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = `INSTR_RS1;
                Rs2_id = 5'b00000;
                Rd_id = `INSTR_RD;
                Rd_data = M_wb_rdata;
                Rd_write = M_wb_ack;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            ST_EXECUTE_S_TYPE: begin
                M_wb_addr = Rs1_data + `INSTR_S_TYPE_IMM;
                M_wb_cs = 1'b1;
                M_wb_we = 1'b1;
                M_wb_wdata = Rs2_data;
                Rs1_id = `INSTR_RS1;
                Rs2_id = `INSTR_RS2;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            ST_EXECUTE_J_TYPE: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = `INSTR_RD;
                Rd_data = addr + 4;
                Rd_write = 1'b1;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end

            default: begin
                M_wb_addr = 'b0;
                M_wb_cs = 1'b0;
                M_wb_we = 1'b0;
                M_wb_wdata = 'b0;
                Rs1_id = 5'b00000;
                Rs2_id = 5'b00000;
                Rd_id = 5'b00000;
                Rd_data = 'b0;
                Rd_write = 1'b0;
                Alu_control = 4'b0000;
                Alu_enable = 1'b0;
                Imm_data = 12'h000;
                Imm_enable = 1'b0;
                Irq_pending = 1'b0;
            end
        endcase
    end

    instruction_decoder instruction_decoder_inst (
        .Instr    ( instr ),
        .Alu_ctrl ( alu_ctrl ),
        .Instr_id ( instr_id )
    );

endmodule