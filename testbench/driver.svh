`ifndef DRIVER_SVH
`define DRIVER_SVH

class driver;
    virtual driver_if vif;
    mailbox #(string) mbx;
    event drv2gen_finish_ev;
    event gen2drv_eof_ev;

    function new(virtual driver_if vif, ref mailbox #(string) mbx, ref event drv2gen_finish_ev, ref event gen2drv_eof_ev);
        this.vif = vif;
        this.mbx = mbx;
        this.drv2gen_finish_ev = drv2gen_finish_ev;
        this.gen2drv_eof_ev = gen2drv_eof_ev;
    endfunction

    task init();
        vif.tx = 1'b1;
    endtask

    task run();
        string request = "";

        fork
            forever begin
                mbx.get(request);
                 $display("[Driver] %0s", request);

                foreach (request[i]) begin
                    vif.tx = 1'b0;
                    #(16*`CLK_PERIOD);
                    
                    for (int j=0; j<8; j++) begin
                        vif.tx = request[i][j];
                        #(16*`CLK_PERIOD);
                    end

                    vif.tx = 1'b1;
                    #(16*`CLK_PERIOD);
                    #(16*`CLK_PERIOD);
                end

                ->drv2gen_finish_ev;
            end
            begin
                wait(gen2drv_eof_ev.triggered);
            end
        join_any
    endtask
    
endclass

`endif