`include "defines.svh"

module wb_arbiter (
    input                         Irq_pending,

    input      [`ADDR_SIZE-1 : 0] S_wb_ctrl_addr,
    input                         S_wb_ctrl_cs,
    input                         S_wb_ctrl_we,
    input      [`WORD_SIZE-1 : 0] S_wb_ctrl_wdata,
    output reg [`WORD_SIZE-1 : 0] S_wb_ctrl_rdata,
    output reg                    S_wb_ctrl_ack,

    input      [`ADDR_SIZE-1 : 0] S_wb_core_addr,
    input                         S_wb_core_cs,
    input                         S_wb_core_we,
    input      [`WORD_SIZE-1 : 0] S_wb_core_wdata,
    output reg [`WORD_SIZE-1 : 0] S_wb_core_rdata,
    output reg                    S_wb_core_ack,

    output reg [`ADDR_SIZE-1 : 0] M_wb_ram_addr,
    output reg                    M_wb_ram_cs,
    output reg                    M_wb_ram_we,
    output reg [`WORD_SIZE-1 : 0] M_wb_ram_wdata,
    input      [`WORD_SIZE-1 : 0] M_wb_ram_rdata,
    input                         M_wb_ram_ack
);
    always_comb begin
        if (Irq_pending) begin
            M_wb_ram_addr = S_wb_ctrl_addr;
            M_wb_ram_cs = S_wb_ctrl_cs;
            M_wb_ram_we = S_wb_ctrl_we;
            M_wb_ram_wdata = S_wb_ctrl_wdata;
            S_wb_core_rdata = 'b0;
            S_wb_core_ack = 'b0;
            S_wb_ctrl_rdata = M_wb_ram_rdata;
            S_wb_ctrl_ack = M_wb_ram_ack;
        end
        else begin
            M_wb_ram_addr = S_wb_core_addr;
            M_wb_ram_cs = S_wb_core_cs;
            M_wb_ram_we = S_wb_core_we;
            M_wb_ram_wdata = S_wb_core_wdata;
            S_wb_core_rdata = M_wb_ram_rdata;
            S_wb_core_ack = M_wb_ram_ack;
            S_wb_ctrl_rdata = 'b0;
            S_wb_ctrl_ack = 'b0;
        end
    end

endmodule