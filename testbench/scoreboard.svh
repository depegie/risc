`ifndef SCOREBOARD_SVH
`define SCOREBOARD_SVH

class scoreboard;
    mailbox #(string) gen2scb_mbx;
    mailbox #(string) mon2scb_mbx;
    event scb2gen_finish_ev;

    function new(ref mailbox #(string) gen2scb_mbx, ref mailbox #(string) mon2scb_mbx, ref event scb2gen_finish_ev);
        this.gen2scb_mbx = gen2scb_mbx;
        this.mon2scb_mbx = mon2scb_mbx;
        this.scb2gen_finish_ev = scb2gen_finish_ev;
    endfunction

    task run();
        string response;
        string response_expected;

        
    endtask
endclass

`endif