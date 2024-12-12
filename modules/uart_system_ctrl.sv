`include "defines.svh"

module uart_system_ctrl (
    input                     Clk,
    input                     Rst,
    input                     Uart_rx,
    output                    Uart_tx,
    output [`ADDR_SIZE-1 : 0] S_wb_addr,
    output                    S_wb_cs,
    output                    S_wb_we,
    output [`WORD_SIZE-1 : 0] S_wb_wdata,
    input  [`WORD_SIZE-1 : 0] S_wb_rdata,
    input                     S_wb_ack,
    output                    Irq,
    output                    Rst_req
);
    wire       axis_tx_tvalid;
    wire [7:0] axis_tx_tdata;
    wire       axis_tx_tready;

    wire       axis_rx_tvalid;
    wire [7:0] axis_rx_tdata;
    wire       axis_rx_tready;

    uart_rx uart_rx_inst (
        .Clk           ( Clk ),
        .Rst           ( Rst ),
        .Rx            ( Uart_rx ),
        .M_axis_tdata  ( axis_rx_tdata ),
        .M_axis_tvalid ( axis_rx_tvalid ),
        .M_axis_tready ( axis_rx_tready )
    );

    uart_tx uart_tx_inst (
        .Clk           ( Clk ),
        .Rst           ( Rst ),
        .Tx            ( Uart_tx ),
        .S_axis_tdata  ( axis_tx_tdata ),
        .S_axis_tvalid ( axis_tx_tvalid ),
        .S_axis_tready ( axis_tx_tready )
    );

    request_decoder request_decoder_inst (
        .Clk           ( Clk ),
        .Rst           ( Rst ),
        .S_axis_tvalid ( axis_rx_tvalid ),
        .S_axis_tready ( axis_rx_tready ),
        .S_axis_tdata  ( axis_rx_tdata ),
        .Addr          ( S_wb_addr ),
        .Wdata         ( S_wb_wdata ),
        .We            ( S_wb_we ),
        .Cs            ( S_wb_cs ),
        .Ack           ( S_wb_ack ),
        .Irq           ( Irq ),
	    .Rst_req       ( Rst_req )
    );

    response_coder response_coder_inst (
        .Clk           ( Clk ),
        .Rst           ( Rst ),
        .M_axis_tvalid ( axis_tx_tvalid ),
        .M_axis_tready ( axis_tx_tready ),
        .M_axis_tdata  ( axis_tx_tdata ),
        .Cs            ( S_wb_cs ),
        .We            ( S_wb_we ),
        .Rdata         ( S_wb_rdata ),
        .Ack           ( S_wb_ack )
    );

endmodule