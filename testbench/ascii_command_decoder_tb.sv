module ascii_command_decoder_tb;

    // Testbench sygnały
    logic clk;
    logic reset;
    logic tvalid;
    logic [7:0] tdata;
    logic tready;
    logic [15:0] addr;
    logic [31:0] wdata;
    logic we;
    logic cs;
    logic irq;
    logic ack;

    // Instancja testowanego modułu
    ascii_command_decoder uut (
        .clk(clk),
        .reset(reset),
        .tvalid(tvalid),
        .tdata(tdata),
        .tready(tready),
        .addr(addr),
        .wdata(wdata),
        .we(we),
        .cs(cs),
        .irq(irq),
        .ack(ack)
    );

    // Generowanie zegara
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Symulacja
    initial begin
        // Resetowanie układu
        reset = 1;
        tvalid = 0;
        tdata = 8'b0;
        ack = 0;
        #20;
        reset = 0;

        // Wysyłanie komendy "write 1f deadbeef"
        send_command("write 1f deadbeef\n");

        // Czekanie na zakończenie przetwarzania
        #100;

        // Zatrzymanie symulacji
        $stop;
    end

    // Task do wysyłania komendy znak po znaku
    task send_command(input string command);
        int i;
        for (i = 0; i < command.len(); i++) begin
            tdata = command[i];
            tvalid = 1;
            #10;
            tvalid = 0;
            #10;
        end
    endtask

endmodule
