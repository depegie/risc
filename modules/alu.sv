`include "defines.vh"

module alu (
    input  wire [8*`WORD_SIZE_B-1 : 0] rs1,
    input  wire [8*`WORD_SIZE_B-1 : 0] rs2,
    output reg  [8*`WORD_SIZE_B-1 : 0] rd,
    input  wire [3 : 0]                control
);
    always_comb begin
        case (control)
            4'b0000: begin
                rd = rs1 + rs2;
            end
            default: begin
                rd = 'b0;
            end
        endcase
    end
    
endmodule