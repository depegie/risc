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

    driver_if driver_iface();
    monitor_if monitor_iface();
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

    assign monitor_iface.rx = driver_iface.tx;
    
    initial begin
        gen2drv_mbx = new();
        gen2scb_mbx = new();
        mon2scb_mbx = new();
        gen = new();
        drv = new(driver_iface, gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev);
        mon = new(monitor_iface, mon2scb_mbx, mon2scb_trans_ev, scb2mon_finish_ev);
        scb = new(gen2scb_mbx, mon2scb_mbx, scb2gen_trans_ev, mon2scb_trans_ev, gen2scb_eof_ev, scb2mon_finish_ev);

        drv.init();

        tb_clk = 0;
        tb_rst = 1;

        #(16*`CLK_PERIOD) tb_rst = 0;
        #(16*`CLK_PERIOD);

        fork
            gen.run("tx.txt", gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev); //todo
            // gen.run("rx.txt", gen2scb_mbx, scb2gen_trans_ev, gen2scb_eof_ev);
            drv.run();
            mon.run();
            // scb.run();
        join

        $finish();
    end

    always #(`CLK_PERIOD/2) tb_clk = !tb_clk;

    uart_command_decoder uart_command_decoder_inst (
        .Clk(tb_clk),
        .Rst(tb_rst),
        .Rx(driver_iface.tx),
        .Tx(monitor_iface.rx),
        .Wb_addr(tb_wb_addr),
        .Wb_cs(tb_wb_cs),
        .Wb_we(tb_wb_we),
        .Wb_wdata(tb_wb_wdata),
        .Wb_rdata(tb_wb_rdata),
        .Wb_ack(tb_wb_ack),
        .Irq(),
        .Core_rst()
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

    wire [`ADDR_SIZE-1 : 0] tb_wb_addr;
    wire                    tb_wb_cs;
    wire                    tb_wb_we;
    wire [`WORD_SIZE-1 : 0] tb_wb_wdata;
    wire [`WORD_SIZE-1 : 0] tb_wb_rdata;
    wire                    tb_wb_ack;

endmodule