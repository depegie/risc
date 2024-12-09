`include "defines.svh"

module wb_arbiter(
    input                         Sel,

    input      [`ADDR_SIZE-1 : 0] Wb_addr_interpreter,
    input                         Wb_cs_interpreter,
    input                         Wb_we_interpreter,
    input      [`WORD_SIZE-1 : 0] Wb_wdata_interpreter,
    output reg [`WORD_SIZE-1 : 0] Wb_rdata_interpreter,
    output reg                    Wb_ack_interpreter,

    input      [`ADDR_SIZE-1 : 0] Wb_addr_core,
    input                         Wb_cs_core,
    input                         Wb_we_core,
    input      [`WORD_SIZE-1 : 0] Wb_wdata_core,
    output reg [`WORD_SIZE-1 : 0] Wb_rdata_core,
    output reg                    Wb_ack_core,

    output reg [`ADDR_SIZE-1 : 0] Wb_addr,
    output reg                    Wb_cs,
    output reg                    Wb_we,
    output reg [`WORD_SIZE-1 : 0] Wb_wdata,
    input      [`WORD_SIZE-1 : 0] Wb_rdata,
    input                         Wb_ack
);
    always_comb begin
        if (Sel) begin
            Wb_addr = Wb_addr_core;
            Wb_cs = Wb_cs_core;
            Wb_we = Wb_we_core;
            Wb_wdata = Wb_wdata_core;
            Wb_rdata_core = Wb_rdata;
            Wb_ack_core = Wb_ack;
            Wb_rdata_interpreter = 'b0;
            Wb_ack_interpreter = 'b0;
        end
        else begin
            Wb_addr = Wb_addr_interpreter;
            Wb_cs = Wb_cs_interpreter;
            Wb_we = Wb_we_interpreter;
            Wb_wdata = Wb_wdata_interpreter;
            Wb_rdata_core = 'b0;
            Wb_ack_core = 'b0;
            Wb_rdata_interpreter = Wb_rdata;
            Wb_ack_interpreter = Wb_ack;
        end
    end

endmodule