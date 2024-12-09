module synchronizer (
    input  Clk,
    input  Async_in,
    output Sync_out
);
    reg Q1 = 1'b0;
    reg Q2 = 1'b0;

    always_ff @(posedge Clk) begin
        Q1 <= Async_in;
        Q2 <= Q1;
    end

    assign Sync_out = Q2;

endmodule