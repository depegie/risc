`include "defines.svh"

module arith_logic_unit (
    input      [`WORD_SIZE-1 : 0] In1,
    input      [`WORD_SIZE-1 : 0] In2,
    input                 [3 : 0] Control,
    output reg [`WORD_SIZE-1 : 0] Out
);
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
        case (Control)
            ALU_CTRL_ADD: Out = In1 + In2;
            ALU_CTRL_SUB: Out = In1 - In2;
            ALU_CTRL_MUL: Out = In1 * In2;
            ALU_CTRL_DIV: Out = In1 / In2;
            ALU_CTRL_REM: Out = In1 % In2;
            ALU_CTRL_AND: Out = In1 & In2;
            ALU_CTRL_OR:  Out = In1 | In2;
            ALU_CTRL_XOR: Out = In1 ^ In2;
            ALU_CTRL_SLL: Out = In1 << In2;
            ALU_CTRL_SRL: Out = In1 >> In2;
            ALU_CTRL_SLT: Out = In1 < In2;
            default:      Out = 'b0;
        endcase
    end
    
endmodule