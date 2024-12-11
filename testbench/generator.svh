`ifndef GENERATOR_SVH
`define GENERATOR_SVH

class generator;

    task run(string name, ref mailbox #(string) mbx, ref event finish_ev, ref event eof_ev);
        int file = $fopen(name, "r");
        string request;

        while (!$feof(file)) begin
            $fgets(request, file);

            mbx.put(request);
            @(finish_ev);
        end

        ->eof_ev;
    endtask

endclass

`endif