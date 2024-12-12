`include "defines.svh"

module uart_command_decoder (
    input                     Clk,
    input                     Rst,

    input                     Rx,
    output                    Tx,

    output [`ADDR_SIZE-1 : 0] Wb_addr,
    output                    Wb_cs,
    output                    Wb_we,
    output [`WORD_SIZE-1 : 0] Wb_wdata,
    input  [`WORD_SIZE-1 : 0] Wb_rdata,
    input                     Wb_ack,

    output                    Irq,
    output                    Core_rst
);
    wire       axis_tx_tvalid;
    wire [7:0] axis_tx_tdata;
    wire       axis_tx_tready;

    wire       axis_rx_tvalid;
    wire [7:0] axis_rx_tdata;
    wire       axis_rx_tready;

    uart_rx uart_rx_inst (
        .Clk(Clk),
        .Rst(Rst),
        .Rx(Rx),
        .M_axis_tdata(axis_rx_tdata),
        .M_axis_tvalid(axis_rx_tvalid),
        .M_axis_tready(axis_rx_tready)
    );

    uart_tx uart_tx_inst (
        .Clk(Clk),
        .Rst(Rst),
        .Tx(Tx),
        .S_axis_tdata(axis_tx_tdata),
        .S_axis_tvalid(axis_tx_tvalid),
        .S_axis_tready(axis_tx_tready)
    );

    ascii_command_decoder ascii_command_decoder_inst (
        .clk(Clk),
        .Rst(Rst),
	    .Core_rst(Core_rst),
        .tvalid(axis_rx_tvalid),
        .tdata(axis_rx_tdata),
        .tready(axis_rx_tready),
        .addr(Wb_addr),
        .wdata(Wb_wdata),
        .we(Wb_we),
        .cs(Wb_cs),
        .irq(Irq),
        .ack(Wb_ack)
    );

    command_ascii_coder command_ascii_coder_inst (
        .clk(Clk),
        .reset(Rst),
        .tvalid(axis_tx_tvalid),
        .tready(axis_tx_tready),
        .tdata(axis_tx_tdata),
        .rdata(Wb_rdata),
        .ack(Wb_ack)
    );

endmodule