`include "defines.svh"

module risc_logic (
    input  Clk,
    input  Rst,
    input  Uart_rx,
    output Uart_tx
);
    wire                    irq;
    wire                    irq_pending;
    wire                    req_rst;

    wire [`ADDR_SIZE-1 : 0] wb_ctrl_addr;
    wire                    wb_ctrl_cs;
    wire                    wb_ctrl_we;
    wire [`WORD_SIZE-1 : 0] wb_ctrl_wdata;
    wire [`WORD_SIZE-1 : 0] wb_ctrl_rdata;
    wire                    wb_ctrl_ack;

    wire [`ADDR_SIZE-1 : 0] wb_core_addr;
    wire                    wb_core_cs;
    wire                    wb_core_we;
    wire [`WORD_SIZE-1 : 0] wb_core_wdata;
    wire [`WORD_SIZE-1 : 0] wb_core_rdata;
    wire                    wb_core_ack;

    wire [`ADDR_SIZE-1 : 0] wb_ram_addr;
    wire                    wb_ram_cs;
    wire                    wb_ram_we;
    wire [`WORD_SIZE-1 : 0] wb_ram_wdata;
    wire [`WORD_SIZE-1 : 0] wb_ram_rdata;
    wire                    wb_ram_ack;

    system_ctrl system_ctrl_inst (
        .Clk        ( Clk ),
        .Rst        ( Rst ),
        .Uart_rx    ( Uart_rx ),
        .Uart_tx    ( Uart_tx ),
        .M_wb_addr  ( wb_ctrl_addr ),
        .M_wb_cs    ( wb_ctrl_cs ),
        .M_wb_we    ( wb_ctrl_we ),
        .M_wb_wdata ( wb_ctrl_wdata ),
        .M_wb_rdata ( wb_ctrl_rdata ),
        .M_wb_ack   ( wb_ctrl_ack ),
        .Irq        ( irq ),
        .Req_rst    ( req_rst )
    );

    wb_arbiter wb_arbiter_inst (
        .Irq_pending     ( irq_pending ),
        .S_wb_ctrl_addr  ( wb_ctrl_addr ),
        .S_wb_ctrl_cs    ( wb_ctrl_cs ),
        .S_wb_ctrl_we    ( wb_ctrl_we ),
        .S_wb_ctrl_wdata ( wb_ctrl_wdata ),
        .S_wb_ctrl_rdata ( wb_ctrl_rdata ),
        .S_wb_ctrl_ack   ( wb_ctrl_ack ),
        .S_wb_core_addr  ( wb_core_addr ),
        .S_wb_core_cs    ( wb_core_cs ),
        .S_wb_core_we    ( wb_core_we ),
        .S_wb_core_wdata ( wb_core_wdata ),
        .S_wb_core_rdata ( wb_core_rdata ),
        .S_wb_core_ack   ( wb_core_ack ),
        .M_wb_ram_addr   ( wb_ram_addr ),
        .M_wb_ram_cs     ( wb_ram_cs ),
        .M_wb_ram_we     ( wb_ram_we ),
        .M_wb_ram_wdata  ( wb_ram_wdata ),
        .M_wb_ram_rdata  ( wb_ram_rdata ),
        .M_wb_ram_ack    ( wb_ram_ack )
    );

    core core_inst (
        .Clk         ( Clk ),
        .Rst         ( Rst | req_rst),
        .Irq         ( irq ),
        .Irq_pending ( irq_pending ),
        .M_wb_addr   ( wb_core_addr ),
        .M_wb_cs     ( wb_core_cs ),
        .M_wb_we     ( wb_core_we ),
        .M_wb_wdata  ( wb_core_wdata ),
        .M_wb_rdata  ( wb_core_rdata ),
        .M_wb_ack    ( wb_core_ack )
    );

    ram ram_inst (
        .Clk        ( Clk ),
        .Rst        ( Rst | req_rst ),
        .S_wb_addr  ( wb_ram_addr ),
        .S_wb_cs    ( wb_ram_cs ),
        .S_wb_we    ( wb_ram_we ),
        .S_wb_wdata ( wb_ram_wdata ),
        .S_wb_rdata ( wb_ram_rdata ),
        .S_wb_ack   ( wb_ram_ack )
    );

endmodule