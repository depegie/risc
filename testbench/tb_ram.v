`timescale 1ns/1ps

`include "defines.vh"

module tb_ram();
    parameter CLK_PERIOD = 10;
    reg                                Clk;
    reg                                Rst;
    reg  [$clog2(`RAM_CAPACITY)-1 : 0] Addr;
    reg                                Cs;
    reg                                We;
    reg  [8*`WORD_SIZE-1 : 0]          Wdata;
    wire [8*`WORD_SIZE-1 : 0]          Rdata;
    wire                               Ack;

    ram dut (
        .Clk   ( Clk ),
        .Rst   ( Rst ),
        .Addr  ( Addr ),
        .Cs    ( Cs ),
        .We    ( We ),
        .Wdata ( Wdata ),
        .Rdata ( Rdata ),
        .Ack   ( Ack )
    );

    always #(CLK_PERIOD/2) Clk = !Clk;
    
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
        @(posedge Clk);
        $finish();
    end

    task init_sim();
    begin
        Clk = 1'b0;
        Rst = 1'b1;
        Addr = 'b0;
        Cs = 1'b0;
        We = 1'b0;
        Wdata = 'b0;
    end
    endtask

    task deassert_reset();
    begin
        #(2*CLK_PERIOD) Rst = 1'b0;
        @(negedge Clk);
    end
    endtask

    task write(input [$clog2(`RAM_CAPACITY)-1 : 0] addr, input [8*`WORD_SIZE-1 : 0] data);
    begin
        Addr = addr;
        Cs = 1'b1;
        We = 1'b1;
        Wdata = data;
        @(negedge Clk);
        @(negedge Clk);
        Addr = 'b0;
        Cs = 1'b0;
        We = 1'b0;
        Wdata = 'b0;
    end
    endtask

    task read(input [$clog2(`RAM_CAPACITY)-1 : 0] addr);
    begin
        Addr = addr;
        Cs = 1'b1;
        We = 1'b0;
        @(negedge Clk);
        @(negedge Clk);
        Addr = 'b0;
        Cs = 1'b0;
        We = 1'b0;
    end
    endtask

    // task idle();
    // begin
    //     Addr = 'h0;
    //     Cs = 1'b0;
    //     We = 1'b0;
    //     @(negedge Clk);
    // end
    // endtask

endmodule