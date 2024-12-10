`ifndef MONITOR_SVH
`define MONITOR_SVH

class monitor;
    virtual monitor_if vif;

    function new(virtual monitor_if vif);
        this.vif = vif;
    endfunction

    task run();
        string response = "deadbeef\n";
        logic [7:0] sign = 8'b0;

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
            
            $display("[Monitor] %0s", response);
        end
    endtask

endclass

`endif