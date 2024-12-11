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
            gen.run("rx.txt", gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev); //todo
            gen.run("rx.txt", gen2scb_mbx, scb2gen_trans_ev, gen2scb_eof_ev);
            drv.run();
            mon.run();
            scb.run();
        join

        $finish();
    end

    always #(`CLK_PERIOD/2) tb_clk = !tb_clk;

    uart_rx uart_rx_inst (
        .Clk           ( tb_clk ),
        .Rst           ( tb_rst ),
        .Rx            ( driver_iface.tx ),
        .M_axis_tdata  ( ),
        .M_axis_tvalid ( ),
        .M_axis_tready ( 1'b1 )
    ); // todo

endmodule