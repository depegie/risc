`include "defines.svh"

module instruction_decoder (
    input      [`WORD_SIZE-1 : 0] Instr,
    output reg            [3 : 0] Alu_ctrl,
    output reg            [4 : 0] Instr_id

);
    wire [`WORD_SIZE-1 : 0] instr;
    
    assign instr = Instr;

    // localparam [6 : 0] 7'b0110011 = 7'b0110011;
    // localparam [6 : 0] 7'b0010011 = 7'b0010011;
    // localparam [6 : 0] 7'b0000011 = 7'b0000011;
    // localparam [6 : 0] 7'b0100011 = 7'b0100011;
    // localparam [6 : 0] 7'b1101111 = 7'b1101111;

    localparam [4 : 0] INSTR_ID_NULL = 5'd00;
    localparam [4 : 0] INSTR_ID_ADD  = 5'd01;
    localparam [4 : 0] INSTR_ID_SUB  = 5'd02;
    localparam [4 : 0] INSTR_ID_XOR  = 5'd03;
    localparam [4 : 0] INSTR_ID_OR   = 5'd04;
    localparam [4 : 0] INSTR_ID_AND  = 5'd05;
    localparam [4 : 0] INSTR_ID_SLL  = 5'd06;
    localparam [4 : 0] INSTR_ID_SRL  = 5'd07;
    localparam [4 : 0] INSTR_ID_SRA  = 5'd08;
    localparam [4 : 0] INSTR_ID_SLT  = 5'd09;
    localparam [4 : 0] INSTR_ID_ADDI = 5'd10;
    localparam [4 : 0] INSTR_ID_XORI = 5'd11;
    localparam [4 : 0] INSTR_ID_ORI  = 5'd12;
    localparam [4 : 0] INSTR_ID_ANDI = 5'd13;
    localparam [4 : 0] INSTR_ID_SLLI = 5'd14;
    localparam [4 : 0] INSTR_ID_SRLI = 5'd15;
    localparam [4 : 0] INSTR_ID_SRAI = 5'd16;
    localparam [4 : 0] INSTR_ID_LW   = 5'd17;
    localparam [4 : 0] INSTR_ID_SW   = 5'd18;
    localparam [4 : 0] INSTR_ID_JAL  = 5'd19;

    localparam [3 : 0] ALU_CTRL_ADD  = 4'd00;
    localparam [3 : 0] ALU_CTRL_SUB  = 4'd01;
    localparam [3 : 0] ALU_CTRL_XOR  = 4'd02;
    localparam [3 : 0] ALU_CTRL_OR   = 4'd03;
    localparam [3 : 0] ALU_CTRL_AND  = 4'd04;
    localparam [3 : 0] ALU_CTRL_SLL  = 4'd05;
    localparam [3 : 0] ALU_CTRL_SRL  = 4'd06;
    localparam [3 : 0] ALU_CTRL_SRA  = 4'd07;
    localparam [3 : 0] ALU_CTRL_SLT  = 4'd08;

    always_comb begin
        Alu_ctrl = 4'h0;
        Instr_id = INSTR_ID_NULL;

        case (`INSTR_OPCODE)
            7'b0110011: begin
                case (`INSTR_FUNCT3)
                    3'b000: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_ADD;
                                Alu_ctrl = ALU_CTRL_ADD;
                                Instr_id = INSTR_ID_ADD;
                            end
                            7'b0100000: begin // next_state = ST_EXECUTE_SUB;
                                Alu_ctrl = ALU_CTRL_SUB;
                                Instr_id = INSTR_ID_SUB;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b100: begin 
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_XOR;
                                Alu_ctrl = ALU_CTRL_XOR;
                                Instr_id = INSTR_ID_XOR;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b110: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_OR;
                                Alu_ctrl = ALU_CTRL_OR;
                                Instr_id = INSTR_ID_OR;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b111: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_AND;
                                Alu_ctrl = ALU_CTRL_AND;
                                Instr_id = INSTR_ID_AND;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b001: begin 
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin// next_state = ST_EXECUTE_SLL;
                                Alu_ctrl = ALU_CTRL_SLL;
                                Instr_id = INSTR_ID_SLL;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b101: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_SRL;
                                Alu_ctrl = ALU_CTRL_SRL;
                                Instr_id = INSTR_ID_SRL;
                            end
                            7'b0100000: begin // next_state = ST_EXECUTE_SRA;
                                Alu_ctrl = ALU_CTRL_SRA;
                                Instr_id = INSTR_ID_SRA;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    3'b010: begin // next_state = ST_EXECUTE_SLT;
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin
                                Alu_ctrl = ALU_CTRL_SLT;
                                Instr_id = INSTR_ID_SLT;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end

                    // default: begin // next_state = ST_FETCH;
                    //     Alu_ctrl = 4'h0;
                    //     Instr_id = INSTR_ID_NULL;
                    // end
                endcase
            end

            7'b0010011: begin
                case (`INSTR_FUNCT3)
                    3'b000: begin // next_state = ST_EXECUTE_ADDI;
                        Alu_ctrl = ALU_CTRL_ADD;
                        Instr_id = INSTR_ID_ADDI;
                    end

                    3'b100: begin // next_state = ST_EXECUTE_XORI;
                        Alu_ctrl = ALU_CTRL_XOR;
                        Instr_id = INSTR_ID_XORI;
                    end

                    3'b110: begin // next_state = ST_EXECUTE_ORI;
                        Alu_ctrl = ALU_CTRL_OR;
                        Instr_id = INSTR_ID_ORI;
                    end

                    3'b111: begin // next_state = ST_EXECUTE_ANDI;
                        Alu_ctrl = ALU_CTRL_AND;
                        Instr_id = INSTR_ID_ANDI;
                    end

                    3'b001: begin // next_state = ST_EXECUTE_SLLI;
                        Alu_ctrl = ALU_CTRL_SLL;
                        Instr_id = INSTR_ID_SLLI;
                    end
                            
                    3'b101: begin
                        case (`INSTR_FUNCT7)
                            7'b0000000: begin // next_state = ST_EXECUTE_SRLI;
                                Alu_ctrl = ALU_CTRL_SRL;
                                Instr_id = INSTR_ID_SRLI;
                            end
                            7'b0100000: begin // next_state = ST_EXECUTE_SRAI;
                                Alu_ctrl = ALU_CTRL_SRA;
                                Instr_id = INSTR_ID_SRAI;
                            end
                            // default: begin // next_state = ST_FETCH;
                            //     Alu_ctrl = 4'h0;
                            //     Instr_id = INSTR_ID_NULL;
                            // end
                        endcase
                    end
                    
                    // default: begin // next_state = ST_FETCH;
                    //     Alu_ctrl = 4'h0;
                    //     Instr_id = INSTR_ID_NULL;
                    // end
                endcase
            end

            7'b0000011: begin // next_state = ST_EXECUTE_LW;
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_LW;
            end
                    
            7'b0100011: begin // next_state = ST_EXECUTE_SW;
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_SW;
            end
                    
            7'b1101111: begin
                Alu_ctrl = 4'h0;
                Instr_id = INSTR_ID_JAL;
            end
                    
            // default: begin
            //     Alu_ctrl = 4'h0;
            //     Instr_id = INSTR_ID_NULL;
            // end
        endcase
    end
endmodule