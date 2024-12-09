module hex_to_ascii_converter (
    input  [3 : 0] Hex,
    output [7 : 0] Ascii
);
    assign Ascii = (Hex <= 4'd9) ? (Hex + 'd48) : (Hex + 'd55);

endmodule