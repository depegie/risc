module risc_top (
    input  CLK125,
    input  UART_RXD,
    output UART_TXD
);
    wire clk7M3728;
    wire locked;
    wire rst;
    
    mmcm mmcm_inst (
        .clk125M_in    ( CLK125 ),
        .clk7M3728_out ( clk7M3728_out ),
        .locked        ( locked )
    );
    
    reset_synchronizer reset_synchronizer_inst (
        .Clk   ( clk7M3728_out ),
        .Arstn ( locked ),
        .Rst   ( rst )
    );
    
    risc_logic risc_logic_inst (
        .Clk     ( clk7M3728_out ),
        .Rst     ( rst ),
        .Uart_rx ( UART_RXD ),
        .Uart_tx ( UART_TXD )
    );

endmodule
