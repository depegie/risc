`include "defines.vh"

module ram (
    input wire                               Clk,
    input wire                               Rst,
    input wire [$clog2(`RAM_CAPACITY)-1 : 0] Addr,
    input wire                               Cs,
    input wire                               We,
    input wire [8*`WORD_SIZE-1 : 0]          Wdata,
    output reg [8*`WORD_SIZE-1 : 0]          Rdata = 'h0,
    output reg                               Ack = 1'b0
);
    reg [8*`RAM_CAPACITY-1 : 0] memory = 'h0;
    
    always @(posedge Clk) begin
        if (Rst) begin
            Rdata <= 'h0;
        end
        else if (Cs & Ack) begin
            Rdata <= 'h0;
        end
        else if (Cs & ~We) begin
            Rdata <= memory[8*Addr +: 8*`WORD_SIZE];
        end
    end
    
    always @(posedge Clk) begin
        if (Rst) begin
            Ack <= 1'b0;
        end
        else if (Ack) begin
            Ack <= 1'b0;
        end
        else if (Cs) begin
            Ack <= 1'b1;
        end
    end
    
    always @(posedge Clk) begin
        if (Rst) begin
            memory <= 'b0;
        end
        else if (Cs & We & ~Ack) begin
            memory[8*Addr +: 8*`WORD_SIZE] <= Wdata;
        end
    end
    
endmodule