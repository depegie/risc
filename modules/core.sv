`include "defines.svh"

module core (
    input                         Clk,
    input                         Rst,
    input                         Irq,
    output reg [`ADDR_SIZE-1 : 0] Wb_addr,
    output reg                    Wb_cs,
    output reg                    Wb_we,
    output reg [`WORD_SIZE-1 : 0] Wb_wdata,
    input      [`WORD_SIZE-1 : 0] Wb_rdata,
    input                         Wb_ack
);
    reg [`WORD_SIZE-1 : 0] register[32];

    wire [`WORD_SIZE-1 : 0] rs1;
    wire [`WORD_SIZE-1 : 0] rs2;
    wire [`WORD_SIZE-1 : 0] rd;
    wire            [4 : 0] cu_rs1_id;
    wire [`WORD_SIZE-1 : 0] cu_rs1_data;
    wire            [4 : 0] cu_rs2_id;
    wire [`WORD_SIZE-1 : 0] cu_rs2_data;
    wire            [4 : 0] cu_rd_id;
    wire [`WORD_SIZE-1 : 0] cu_rd_data;
    wire                    cu_rd_write;
    wire            [3 : 0] cu_alu_control;
    wire                    cu_alu_enable;
    wire           [11 : 0] cu_imm_data;
    wire                    cu_imm_enable;
    wire [`WORD_SIZE-1 : 0] alu_in1;
    wire [`WORD_SIZE-1 : 0] alu_in2;
    wire [`WORD_SIZE-1 : 0] alu_out;
    wire [`WORD_SIZE-1 : 0] alu_in2_val;

    assign rd          = cu_alu_enable ? alu_out : cu_rd_data;
    assign rs1         = register[cu_rs1_id];
    assign rs2         = register[cu_rs2_id];
    assign cu_rs1_data = cu_alu_enable ? 'b0 : rs1;
    assign cu_rs2_data = cu_alu_enable ? 'b0 : rs2;
    assign alu_in1     = cu_alu_enable ? rs1 : 'b0;
    assign alu_in2     = cu_alu_enable ? alu_in2_val : 'b0;
    assign alu_in2_val = cu_imm_enable ? {20'b0, cu_imm_data} : rs2;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            for (int id=0; id<32; id=id+1) begin
                register[id] <= 'b0;
            end
        end
        else if (cu_rd_write & cu_rd_id != 5'b0) begin
            register[cu_rd_id] <= rd;
        end
    end

    ctrl_unit ctrl_unit_inst (
        .Clk         ( Clk ),
        .Rst         ( Rst ),
        .Wb_addr     ( Wb_addr ),
        .Wb_cs       ( Wb_cs ),
        .Wb_we       ( Wb_we ),
        .Wb_wdata    ( Wb_wdata ),
        .Wb_rdata    ( Wb_rdata ),
        .Wb_ack      ( Wb_ack ),
        .Irq         ( Irq )
        .Rs1_id      ( cu_rs1_id ),
        .Rs1_data    ( cu_rs1_data ),
        .Rs2_id      ( cu_rs2_id ),
        .Rs2_data    ( cu_rs2_data ),
        .Rd_id       ( cu_rd_id ),
        .Rd_data     ( cu_rd_data ),
        .Rd_write    ( cu_rd_write ),
        .Alu_control ( cu_alu_control ),
        .Alu_enable  ( cu_alu_enable ),
        .Imm_data    ( cu_imm_data ),
        .Imm_enable  ( cu_imm_enable )
    );

    arith_logic_unit arith_logic_unit_inst (
        .In1     ( alu_in1 ),
        .In2     ( alu_in2 ),
        .Out     ( alu_out ),
        .Control ( cu_alu_control )
    );

endmodule