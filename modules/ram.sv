`include "defines.svh"

module ram (
    input                         Clk,
    input                         Rst,
    
    input      [`ADDR_SIZE-1 : 0] Wb_addr,
    input                         Wb_cs,
    input                         Wb_we,
    input      [`WORD_SIZE-1 : 0] Wb_wdata,
    output reg [`WORD_SIZE-1 : 0] Wb_rdata,
    output reg                    Wb_ack
);
    reg [7 : 0] memory[`RAM_CAPACITY_B];
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            Wb_rdata <= 'h0;
        end
        else if (Wb_cs & Wb_ack) begin
            Wb_rdata <= 'h0;
        end
        else if (Wb_cs & ~Wb_we) begin
            Wb_rdata <= {memory[Wb_addr+3], memory[Wb_addr+2], memory[Wb_addr+1], memory[Wb_addr]};
        end
    end
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            Wb_ack <= 1'b0;
        end
        else if (Wb_ack) begin
            Wb_ack <= 1'b0;
        end
        else if (Wb_cs) begin
            Wb_ack <= 1'b1;
        end
    end
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            for (int b=0; b<`RAM_CAPACITY_B; b++) begin
                memory[b] <= 8'hff;
            end
        end
        else if (Wb_cs & Wb_we & ~Wb_ack) begin
            {memory[Wb_addr+3], memory[Wb_addr+2], memory[Wb_addr+1], memory[Wb_addr]} <= Wb_wdata;
        end
    end
    
endmodule