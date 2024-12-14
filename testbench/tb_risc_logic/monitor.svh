`ifndef MONITOR_SVH
`define MONITOR_SVH

class monitor;
    virtual uart_if vif;
    mailbox #(string) mon2scb_mbx;
    event mon2scb_trans_ev;
    event scb2mon_finish_ev;

    function new(virtual uart_if vif,
                 ref mailbox #(string) mon2scb_mbx,
                 ref event mon2scb_trans_ev,
                 ref event scb2mon_finish_ev);

        this.vif = vif;
        this.mon2scb_mbx = mon2scb_mbx;
        this.mon2scb_trans_ev = mon2scb_trans_ev;
        this.scb2mon_finish_ev = scb2mon_finish_ev;
    endfunction

    task run();
        string response = "deadbeef\n";
        logic [7:0] sign = 8'b0;

        fork
            forever begin
                for (int s=0; s<response.len(); s++) begin
                    @(negedge vif.rx);
                    #(16*`CLK_PERIOD);

                    for (int b=0; b<$size(sign); b++) begin
                        #(8*`CLK_PERIOD);
                        sign[b] = vif.rx;
                        #(8*`CLK_PERIOD);
                    end

                    response[s] = sign;
                end
                
                $write("[Monitor] %0s", response);
                ->mon2scb_trans_ev;
                mon2scb_mbx.put(response);
            end

            begin
                wait(scb2mon_finish_ev.triggered);
            end
        join_any
    endtask
endclass

`endif