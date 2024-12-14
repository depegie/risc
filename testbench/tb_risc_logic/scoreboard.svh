`ifndef SCOREBOARD_SVH
`define SCOREBOARD_SVH

class scoreboard;
    mailbox #(string) gen2scb_mbx;
    mailbox #(string) mon2scb_mbx;
    event scb2gen_trans_ev;
    event mon2scb_trans_ev;
    event gen2scb_eof_ev;
    event scb2mon_finish_ev;

    function new(ref mailbox #(string) gen2scb_mbx,
                 ref mailbox #(string) mon2scb_mbx,
                 ref event scb2gen_trans_ev,
                 ref event mon2scb_trans_ev,
                 ref event gen2scb_eof_ev,
                 ref event scb2mon_finish_ev);

        this.gen2scb_mbx = gen2scb_mbx;
        this.mon2scb_mbx = mon2scb_mbx;
        this.scb2gen_trans_ev = scb2gen_trans_ev;
        this.mon2scb_trans_ev = mon2scb_trans_ev;
        this.gen2scb_eof_ev = gen2scb_eof_ev;
        this.scb2mon_finish_ev = scb2mon_finish_ev;
    endfunction

    task run();
        string response;
        string response_expected;
        
        fork
            forever begin
                gen2scb_mbx.get(response_expected);
                ->scb2gen_trans_ev;

                @(mon2scb_trans_ev);
                mon2scb_mbx.get(response);

                $display("[Scoreboard] T=%0t", $time);
                $write("[Scoreboard] Response received: %0s", response);
                $write("[Scoreboard] Response expected: %0s", response_expected);
                if (response != response_expected) begin
                    $display("[Scoreboard] Error");
                    $display("Test failed");
                    $finish();
                end
            end

            begin
                wait(gen2scb_eof_ev.triggered);
                ->scb2mon_finish_ev;
            end
        join_any
    endtask
endclass

`endif