`timescale 1ns/1ps

`include "defines.svh"
`include "generator.svh"
`include "driver.svh"
`include "monitor.svh"
`include "scoreboard.svh"

module tb;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    uart_if uart();
    mailbox #(string) gen2drv_mbx;
    mailbox #(string) gen2scb_mbx;
    mailbox #(string) mon2scb_mbx;
    event drv2gen_trans_ev;
    event scb2gen_trans_ev;
    event mon2scb_trans_ev;
    event gen2drv_eof_ev;
    event gen2scb_eof_ev;
    event scb2mon_finish_ev;

    logic tb_clk;
    logic tb_rst;

    wire [`ADDR_SIZE-1 : 0] tb_wb_addr;
    wire                    tb_wb_cs;
    wire                    tb_wb_we;
    wire [`WORD_SIZE-1 : 0] tb_wb_wdata;
    wire [`WORD_SIZE-1 : 0] tb_wb_rdata;
    wire                    tb_wb_ack;

    initial begin
        gen2drv_mbx = new();
        gen2scb_mbx = new();
        mon2scb_mbx = new();
        gen = new();
        drv = new(uart, gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev);
        mon = new(uart, mon2scb_mbx, mon2scb_trans_ev, scb2mon_finish_ev);
        scb = new(gen2scb_mbx, mon2scb_mbx, scb2gen_trans_ev, mon2scb_trans_ev, gen2scb_eof_ev, scb2mon_finish_ev);

        drv.init();

        tb_clk = 0;
        tb_rst = 1;

        #(16*`CLK_PERIOD) tb_rst = 0;
        #(16*`CLK_PERIOD);

        fork
            gen.run("tx.txt", gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev);
            gen.run("rx.txt", gen2scb_mbx, scb2gen_trans_ev, gen2scb_eof_ev);
            drv.run();
            mon.run();
            scb.run();
        join

        $display("Test passed");

        $finish();
    end

    always #(`CLK_PERIOD/2) tb_clk = !tb_clk;

    uart_system_ctrl uart_system_ctrl_inst (
        .Clk(tb_clk),
        .Rst(tb_rst),
        .Uart_rx(uart.tx),
        .Uart_tx(uart.rx),
        .S_wb_addr(tb_wb_addr),
        .S_wb_cs(tb_wb_cs),
        .S_wb_we(tb_wb_we),
        .S_wb_wdata(tb_wb_wdata),
        .S_wb_rdata(tb_wb_rdata),
        .S_wb_ack(tb_wb_ack),
        .Irq(),
        .Rst_req()
    );

    ram ram_inst (
        .Clk      ( tb_clk ),
        .Rst      ( tb_rst ),
        .Wb_addr  ( tb_wb_addr ),
        .Wb_cs    ( tb_wb_cs ),
        .Wb_we    ( tb_wb_we ),
        .Wb_wdata ( tb_wb_wdata ),
        .Wb_rdata ( tb_wb_rdata ),
        .Wb_ack   ( tb_wb_ack )
    );

endmodule