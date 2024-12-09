module ascii_to_hex_converter (
    input      [7 : 0] Ascii,
    output reg [3 : 0] Hex
);
    always_comb begin
        if (Ascii >= 8'd48 & Ascii <= 8'd57) begin       // '0' - '9'
            Hex = Ascii - 'd48;
        end
        else if (Ascii >= 8'd65 & Ascii <= 8'd70) begin  // 'A' - 'F'
            Hex = Ascii - 'd55;
        end
        else if (Ascii >= 8'd97 & Ascii <= 8'd102) begin // 'a' - 'f'
            Hex = Ascii - 'd87;
        end
        else begin
            Hex = 4'd0;
        end
    end

endmodule