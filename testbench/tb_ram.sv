`timescale 1ns/1ps

`include "defines.svh"

module tb_ram();
    parameter CLK_PERIOD = 10;

    reg                     tb_clk;
    reg                     tb_rst;
    reg  [`ADDR_SIZE-1 : 0] tb_wb_addr;
    reg                     tb_wb_cs;
    reg                     tb_wb_we;
    reg  [`WORD_SIZE-1 : 0] tb_wb_wdata;
    wire [`WORD_SIZE-1 : 0] tb_wb_rdata;
    wire                    tb_wb_ack;

    ram dut (
        .Clk      ( tb_clk ),
        .Rst      ( tb_rst ),
        .Wb_addr  ( tb_wb_addr ),
        .Wb_cs    ( tb_wb_cs ),
        .Wb_we    ( tb_wb_we ),
        .Wb_wdata ( tb_wb_wdata ),
        .Wb_rdata ( tb_wb_rdata ),
        .Wb_ack   ( tb_wb_ack )
    );

    always #(CLK_PERIOD/2) tb_clk = !tb_clk;
    
    initial begin
        init_sim();
        deassert_reset();
        write('d0,  32'haaaaaaaa);
        write('d4,  32'hbbbbbbbb);
        write('d8,  32'hcccccccc);
        write('d12, 32'hdddddddd);
        read('d0);
        read('d4);
        read('d8);
        read('d12);
        @(posedge tb_clk);
        $finish();
    end

    task init_sim();
    begin
        tb_clk = 1'b0;
        tb_rst = 1'b1;
        tb_wb_addr = 'b0;
        tb_wb_cs = 1'b0;
        tb_wb_we = 1'b0;
        tb_wb_wdata = 'b0;
    end
    endtask

    task deassert_reset();
    begin
        #(2*CLK_PERIOD) tb_rst = 1'b0;
        @(posedge tb_clk) #1;
    end
    endtask

    task write(input [`ADDR_SIZE-1 : 0] addr, input [`WORD_SIZE-1 : 0] data);
    begin
        tb_wb_addr = addr;
        tb_wb_cs = 1'b1;
        tb_wb_we = 1'b1;
        tb_wb_wdata = data;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        tb_wb_addr = 'b0;
        tb_wb_cs = 1'b0;
        tb_wb_we = 1'b0;
        tb_wb_wdata = 'b0;
    end
    endtask

    task read(input [`ADDR_SIZE-1 : 0] addr);
    begin
        tb_wb_addr = addr;
        tb_wb_cs = 1'b1;
        tb_wb_we = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        tb_wb_addr = 'b0;
        tb_wb_cs = 1'b0;
        tb_wb_we = 1'b0;
    end
    endtask

endmodule