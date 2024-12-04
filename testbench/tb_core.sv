`timescale 1ns/1ps

`include "defines.svh"

module tb_core();
    parameter CLK_PERIOD = 10;
    logic                    tb_clk;
    logic                    tb_rst;
    logic [`ADDR_SIZE-1 : 0] tb_wb_addr;
    logic                    tb_wb_cs;
    logic                    tb_wb_we;
    logic [`WORD_SIZE-1 : 0] tb_wb_wdata;
    logic [`WORD_SIZE-1 : 0] tb_wb_rdata;
    logic                    tb_wb_ack;

    localparam [6 : 0] SW_INSTR_OPCODE   = 7'b0100011;
    localparam [6 : 0] LW_INSTR_OPCODE   = 7'b0000011;
    localparam [6 : 0] ADD_INSTR_OPCODE  = 7'b0110011;
    localparam [6 : 0] ADDI_INSTR_OPCODE = 7'b0010011;

    always #(CLK_PERIOD/2) tb_clk = !tb_clk;

    initial begin
        init_sim();
        deassert_reset();

        lw(5'b00000, 5'b00001, 12'b0000_0111_1111);
        read_ack(32'hfffff000);
        // lw(5'b00000, 5'b00010, 12'b0000_0111_1110);
        // read_ack(32'h00000fff);
        addi(5'b00001, 5'b00010, 12'hfff);

        // $finish();
    end

    task init_sim();
        tb_clk = 0;
        tb_rst = 1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
    endtask

    task deassert_reset();
        #(2*CLK_PERIOD) tb_rst = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task sw(bit[4:0] rs1, bit[4:0] rs2, bit[11:0] offset);
        tb_wb_rdata = {offset[11:5], rs2, rs1, 3'b010, offset[4:0], SW_INSTR_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task lw(bit[4:0] rs1, bit[4:0] rd, bit[11:0] offset);
        tb_wb_rdata = {offset, rs1, 3'b010, rd, LW_INSTR_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task add(bit[4:0] rs1, bit[4:0] rs2, bit[4:0] rd);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b000, rd, ADD_INSTR_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task addi(bit[4:0] rs1, bit[4:0] rd, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b000, rd, ADDI_INSTR_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task read_ack(bit[31:0] data);
        tb_wb_rdata = data;
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task write_ack();
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    core dut (
        .Clk      ( tb_clk ),
        .Rst      ( tb_rst ),
        .Wb_addr  ( tb_wb_addr ),
        .Wb_cs    ( tb_wb_cs ),
        .Wb_we    ( tb_wb_we ),
        .Wb_wdata ( tb_wb_wdata ),
        .Wb_rdata ( tb_wb_rdata ),
        .Wb_ack   ( tb_wb_ack )
    );

endmodule