`timescale 1ns/1ps

`include "defines.vh"

module tb_core();
    parameter CLK_PERIOD = 10;
    logic                               Clk;
    logic                               Rst;
    logic [$clog2(`RAM_CAPACITY)-1 : 0] Addr;
    logic                               Cs;
    logic                               We;
    logic [8*`WORD_SIZE_B-1 : 0]        Wdata;
    logic [8*`WORD_SIZE_B-1 : 0]        Rdata;
    logic                               Ack;

    localparam [6:0] SW_INSTR_OPCODE  = 7'b0100011;
    localparam [6:0] LW_INSTR_OPCODE  = 7'b0000011;
    localparam [6:0] ADD_INSTR_OPCODE = 7'b0110011;

    always #(CLK_PERIOD/2) Clk = !Clk;

    initial begin
        init_sim();
        deassert_reset();

        lw(5'b00000, 5'b00001, 12'b0000_0111_1111);
        read_ack(32'hfffff000);
        lw(5'b00000, 5'b00010, 12'b0000_0111_1110);
        read_ack(32'h00000fff);
        add(5'b00001, 5'b00010, 5'b00011);

        // $finish();
    end

    task init_sim();
        Clk = 0;
        Rst = 1;
        Rdata = 'b0;
        Ack = 1'b0;
    endtask

    task deassert_reset();
        #(2*CLK_PERIOD) Rst = 1'b0;
        @(posedge Clk) #1;
    endtask

    task sw(bit[4:0] rs1, bit[4:0] rs2, bit[11:0] offset);
        Rdata = {offset[11:5], rs2, rs1, 3'b010, offset[4:0], SW_INSTR_OPCODE};
        Ack = 1'b1;
        @(posedge Clk) #1;
        Rdata = 'b0;
        Ack = 1'b0;
        @(posedge Clk) #1;
    endtask

    task lw(bit[4:0] rs1, bit[4:0] rd, bit[11:0] offset);
        Rdata = {offset, rs1, 3'b010, rd, LW_INSTR_OPCODE};
        Ack = 1'b1;
        @(posedge Clk) #1;
        Rdata = 'b0;
        Ack = 1'b0;
        @(posedge Clk) #1;
    endtask

    task add(bit[4:0] rs1, bit[4:0] rs2, bit[4:0] rd);
        Rdata = {7'b0000000, rs2, rs1, 3'b000, rd, ADD_INSTR_OPCODE};
        Ack = 1'b1;
        @(posedge Clk) #1;
        Rdata = 'b0;
        Ack = 1'b0;
        @(posedge Clk) #1;
    endtask

    task read_ack(bit[31:0] data);
        Rdata = data;
        Ack = 1'b1;
        @(posedge Clk) #1;
        Rdata = 'b0;
        Ack = 1'b0;
        @(posedge Clk) #1;
    endtask

    task write_ack();
        Ack = 1'b1;
        @(posedge Clk) #1;
        Ack = 1'b0;
        @(posedge Clk) #1;
    endtask

    core dut (
        .Clk   ( Clk ),
        .Rst   ( Rst ),
        .Addr  ( Addr ),
        .Cs    ( Cs ),
        .We    ( We ),
        .Wdata ( Wdata ),
        .Rdata ( Rdata ),
        .Ack   ( Ack )
    );

endmodule