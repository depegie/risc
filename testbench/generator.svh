`ifndef GENERATOR_SVH
`define GENERATOR_SVH

class generator;

    task run(string name, ref mailbox #(string) mbx, ref event drv2gen_finish_ev, ref event gen2drv_eof_ev);
        int file = $fopen(name, "r");
        string request;

        while (!$feof(file)) begin
            $fgets(request, file);

            mbx.put(request);
            @(drv2gen_finish_ev);
        end

        ->gen2drv_eof_ev;
    endtask

endclass

`endif