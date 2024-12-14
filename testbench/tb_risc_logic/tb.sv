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

    logic clk;
    logic rst;

    initial begin
        gen2drv_mbx = new();
        gen2scb_mbx = new();
        mon2scb_mbx = new();
        gen = new();
        drv = new(uart, gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev);
        mon = new(uart, mon2scb_mbx, mon2scb_trans_ev, scb2mon_finish_ev);
        scb = new(gen2scb_mbx, mon2scb_mbx, scb2gen_trans_ev, mon2scb_trans_ev, gen2scb_eof_ev, scb2mon_finish_ev);

        drv.init();

        clk = 0;
        rst = 1;

        #(16*`CLK_PERIOD) rst = 0;
        #(16*`CLK_PERIOD);

        fork
            gen.run("tx.txt", gen2drv_mbx, drv2gen_trans_ev, gen2drv_eof_ev);
            gen.run("rx.txt", gen2scb_mbx, scb2gen_trans_ev, gen2scb_eof_ev);
            drv.run();
            mon.run();
            scb.run();
        join

        $display("Test completed");

        $finish();
    end

    always #(`CLK_PERIOD/2) clk = !clk;

    risc_logic risc_logic_inst (
        .Clk     ( clk ),
        .Rst     ( rst ),
        .Uart_rx ( uart.tx ),
        .Uart_tx ( uart.rx )
    );

endmodule