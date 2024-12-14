`include "defines.svh"

module ram (
    input                         Clk,
    input                         Rst,
    
    input      [`ADDR_SIZE-1 : 0] S_wb_addr,
    input                         S_wb_cs,
    input                         S_wb_we,
    input      [`WORD_SIZE-1 : 0] S_wb_wdata,
    output reg [`WORD_SIZE-1 : 0] S_wb_rdata,
    output reg                    S_wb_ack
);
    reg [7 : 0] memory[`RAM_CAPACITY_B];
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            S_wb_rdata <= 'h0;
        end
        else if (S_wb_cs & S_wb_ack) begin
            S_wb_rdata <= 'h0;
        end
        else if (S_wb_cs & ~S_wb_we) begin
            S_wb_rdata <= {
                memory[S_wb_addr+3],
                memory[S_wb_addr+2],
                memory[S_wb_addr+1],
                memory[S_wb_addr+0]
            };
        end
    end
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            S_wb_ack <= 1'b0;
        end
        else if (S_wb_ack) begin
            S_wb_ack <= 1'b0;
        end
        else if (S_wb_cs) begin
            S_wb_ack <= 1'b1;
        end
    end
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            for (int b=0; b<`RAM_CAPACITY_B; b++) begin
                memory[b] <= 8'hff;
            end
        end
        else if (S_wb_cs & S_wb_we & ~S_wb_ack) begin
            {memory[S_wb_addr+3], memory[S_wb_addr+2], memory[S_wb_addr+1], memory[S_wb_addr]} <= S_wb_wdata;
        end
    end
    
endmodule