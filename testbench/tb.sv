`timescale 1ns/1ps

`include "defines.svh"
`include "generator.svh"
`include "driver.svh"
`include "monitor.svh"

module tb;
    generator gen;
    driver drv;
    monitor mon;

    driver_if driver_iface();
    monitor_if monitor_iface();
    mailbox #(string) gen2drv_mbx;
    mailbox #(string) gen2scb_mbx;
    event drv2gen_finish_ev;
    event scb2gen_finish_ev;
    event gen2drv_eof_ev;
    event gen2scb_eof_ev;

    logic tb_clk;
    logic tb_rst;

    // string request;
    // logic [7:0] sign;

    assign monitor_iface.rx = driver_iface.tx;
    
    initial begin
        gen2drv_mbx = new();
        gen2scb_mbx = new();
        gen = new();
        drv = new(driver_iface, gen2drv_mbx, drv2gen_finish_ev, gen2drv_eof_ev);
        mon = new(monitor_iface);

        drv.init();

        tb_clk = 0;
        tb_rst = 1;

        #(16*`CLK_PERIOD) tb_rst = 0;
        #(16*`CLK_PERIOD);

        fork
            gen.run("tx.txt", gen2drv_mbx, drv2gen_finish_ev, gen2drv_eof_ev);
            // gen.run("rx.txt", gen2scb_mbx, scb2gen_finish_ev, gen2scb_eof_ev);
            drv.run();
            // mon.run();
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
    );

endmodule