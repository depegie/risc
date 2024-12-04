`include "defines.svh"

module arith_logic_unit (
    input      [`WORD_SIZE-1 : 0] In1,
    input      [`WORD_SIZE-1 : 0] In2,
    output reg [`WORD_SIZE-1 : 0] Out,
    input                 [3 : 0] Control
);
    always_comb begin
        case (Control)
            4'b0000: begin
                Out = In1 + In2;
            end
            default: begin
                Out = 'b0;
            end
        endcase
    end
    
endmodule