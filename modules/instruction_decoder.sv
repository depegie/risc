`include "defines.svh"

module instruction_decoder (
    input      [`WORD_SIZE-1 : 0] Instr,
    output reg            [3 : 0] Alu_ctrl,
    output reg            [4 : 0] Instr_id
);
    wire [`WORD_SIZE-1 : 0] instr;

    assign instr = Instr;

    localparam [4 : 0] INSTR_ID_NULL = 5'd00;
    localparam [4 : 0] INSTR_ID_ADD  = 5'd01;
    localparam [4 : 0] INSTR_ID_SUB  = 5'd02;
    localparam [4 : 0] INSTR_ID_MUL  = 5'd03;
    localparam [4 : 0] INSTR_ID_DIV  = 5'd04;
    localparam [4 : 0] INSTR_ID_REM  = 5'd05;
    localparam [4 : 0] INSTR_ID_AND  = 5'd06;
    localparam [4 : 0] INSTR_ID_OR   = 5'd07;
    localparam [4 : 0] INSTR_ID_XOR  = 5'd08;
    localparam [4 : 0] INSTR_ID_SLL  = 5'd09;
    localparam [4 : 0] INSTR_ID_SRL  = 5'd10;
    localparam [4 : 0] INSTR_ID_SLT  = 5'd11;
    localparam [4 : 0] INSTR_ID_ADDI = 5'd12;
    localparam [4 : 0] INSTR_ID_ANDI = 5'd13;
    localparam [4 : 0] INSTR_ID_ORI  = 5'd14;
    localparam [4 : 0] INSTR_ID_XORI = 5'd15;
    localparam [4 : 0] INSTR_ID_SLLI = 5'd16;
    localparam [4 : 0] INSTR_ID_SRLI = 5'd17;
    localparam [4 : 0] INSTR_ID_LW   = 5'd18;
    localparam [4 : 0] INSTR_ID_SW   = 5'd19;
    localparam [4 : 0] INSTR_ID_JAL  = 5'd20;

    localparam [3 : 0] ALU_CTRL_ADD = 4'd00;
    localparam [3 : 0] ALU_CTRL_SUB = 4'd01;
    localparam [3 : 0] ALU_CTRL_MUL = 4'd02;
    localparam [3 : 0] ALU_CTRL_DIV = 4'd03;
    localparam [3 : 0] ALU_CTRL_REM = 4'd04;
    localparam [3 : 0] ALU_CTRL_AND = 4'd05;
    localparam [3 : 0] ALU_CTRL_OR  = 4'd06;
    localparam [3 : 0] ALU_CTRL_XOR = 4'd07;
    localparam [3 : 0] ALU_CTRL_SLL = 4'd08;
    localparam [3 : 0] ALU_CTRL_SRL = 4'd09;
    localparam [3 : 0] ALU_CTRL_SLT = 4'd10;

    always_comb begin
        Alu_ctrl = 4'h0;
        Instr_id = 5'b0;

        case (`INSTR_OPCODE)
            7'b0110011: begin
                case (`INSTR_FUNCT3)
                    3'b000: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_ADD;
                                Instr_id = INSTR_ID_ADD;
                            end
                            7'b0000001: begin
                                Alu_ctrl = ALU_CTRL_MUL;
                                Instr_id = INSTR_ID_MUL;
                            end
                            7'b0100000: begin
                                Alu_ctrl = ALU_CTRL_SUB;
                                Instr_id = INSTR_ID_SUB;
                            end
                        endcase
                    end

                    3'b100: begin 
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_XOR;
                                Instr_id = INSTR_ID_XOR;
                            end
                            7'b0000001: begin
                                Alu_ctrl = ALU_CTRL_DIV;
                                Instr_id = INSTR_ID_DIV;
                            end
                        endcase
                    end

                    3'b110: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_OR;
                                Instr_id = INSTR_ID_OR;
                            end
                            7'b0000001: begin
                                Alu_ctrl = ALU_CTRL_REM;
                                Instr_id = INSTR_ID_REM;
                            end
                        endcase
                    end

                    3'b111: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_AND;
                                Instr_id = INSTR_ID_AND;
                            end
                        endcase
                    end

                    3'b001: begin 
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_SLL;
                                Instr_id = INSTR_ID_SLL;
                            end
                        endcase
                    end

                    3'b101: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_SRL;
                                Instr_id = INSTR_ID_SRL;
                            end
                        endcase
                    end

                    3'b010: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_SLT;
                                Instr_id = INSTR_ID_SLT;
                            end
                        endcase
                    end
                endcase
            end

            7'b0010011: begin
                case (`INSTR_FUNCT3)
                    3'b000: begin
                        Alu_ctrl = ALU_CTRL_ADD;
                        Instr_id = INSTR_ID_ADDI;
                    end

                    3'b100: begin
                        Alu_ctrl = ALU_CTRL_XOR;
                        Instr_id = INSTR_ID_XORI;
                    end

                    3'b110: begin
                        Alu_ctrl = ALU_CTRL_OR;
                        Instr_id = INSTR_ID_ORI;
                    end

                    3'b111: begin
                        Alu_ctrl = ALU_CTRL_AND;
                        Instr_id = INSTR_ID_ANDI;
                    end

                    3'b001: begin
                        Alu_ctrl = ALU_CTRL_SLL;
                        Instr_id = INSTR_ID_SLLI;
                    end
                            
                    3'b101: begin
                        Alu_ctrl = ALU_CTRL_SRL;
                        Instr_id = INSTR_ID_SRLI;
                    end
                endcase
            end

            7'b0000011: begin
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_LW;
            end
                    
            7'b0100011: begin
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_SW;
            end
                    
            7'b1101111: begin
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_JAL;
            end
        endcase
    end
endmodule