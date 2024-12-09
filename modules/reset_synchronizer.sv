module reset_synchronizer (
    input Clk,
    input Arstn,
    output Rst 
);
    reg Q1 = 1'b1;
    reg Q2 = 1'b1;

    always_ff @(posedge Clk, negedge Arstn) begin
        if (~Arstn) begin
            Q1 <= 1'b1;
            Q2 <= 1'b1;
        end
        else begin
            Q1 <= 1'b0;
            Q2 <= Q1;
        end
    end

    assign Rst = Q2;

endmodule