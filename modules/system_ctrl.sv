`include "defines.svh"

module system_ctrl (
    input                     Clk,
    input                     Rst,
    input                     Uart_rx,
    output                    Uart_tx,
    output [`ADDR_SIZE-1 : 0] M_wb_addr,
    output                    M_wb_cs,
    output                    M_wb_we,
    output [`WORD_SIZE-1 : 0] M_wb_wdata,
    input  [`WORD_SIZE-1 : 0] M_wb_rdata,
    input                     M_wb_ack,
    output                    Irq,
    output                    Req_rst
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
        .Addr          ( M_wb_addr ),
        .Wdata         ( M_wb_wdata ),
        .We            ( M_wb_we ),
        .Cs            ( M_wb_cs ),
        .Ack           ( M_wb_ack ),
        .Irq           ( Irq ),
	    .Req_rst       ( Req_rst )
    );

    response_coder response_coder_inst (
        .Clk           ( Clk ),
        .Rst           ( Rst ),
        .M_axis_tvalid ( axis_tx_tvalid ),
        .M_axis_tready ( axis_tx_tready ),
        .M_axis_tdata  ( axis_tx_tdata ),
        .Cs            ( M_wb_cs ),
        .We            ( M_wb_we ),
        .Rdata         ( M_wb_rdata ),
        .Ack           ( M_wb_ack )
    );

endmodule