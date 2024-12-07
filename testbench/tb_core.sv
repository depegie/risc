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

    localparam [6 : 0] R_TYPE_OPCODE = 7'b0110011;
    localparam [6 : 0] I_TYPE_OPCODE = 7'b0010011;
    localparam [6 : 0] L_TYPE_OPCODE = 7'b0000011;
    localparam [6 : 0] S_TYPE_OPCODE = 7'b0100011;
    localparam [6 : 0] J_TYPE_OPCODE = 7'b1101111;

    always #(CLK_PERIOD/2) tb_clk = !tb_clk;

    initial begin
        init_sim();
        deassert_reset();
        read_lw(5'd1, 5'd0, 12'hfff);
        read_data_ack('d101);
        read_lw(5'd2, 5'd0, 12'hfff);
        read_data_ack('d5);
        read_add(5'd3, 5'd1, 5'd2);
        read_sub(5'd4, 5'd1, 5'd2);
        read_mul(5'd5, 5'd1, 5'd2);
        read_div(5'd6, 5'd1, 5'd2);
        read_rem(5'd7, 5'd1, 5'd2);
        read_and(5'd8, 5'd1, 5'd2);
        read_or(5'd9, 5'd1, 5'd2);
        read_xor(5'd10, 5'd1, 5'd2);
        read_sll(5'd11, 5'd1, 5'd2);
        read_srl(5'd12, 5'd1, 5'd2);
        read_slt(5'd13, 5'd1, 5'd2);
        read_addi(5'd14, 5'd1, 12'd20);
        read_andi(5'd15, 5'd1, 12'd20);
        read_ori(5'd16, 5'd1, 12'd20);
        read_xori(5'd17, 5'd1, 12'd20);
        read_slli(5'd18, 5'd1, 12'd1);
        read_srli(5'd19, 5'd1, 12'd1);
        read_jal(5'd20, 20'd0);
        read_sw(5'd0, 5'd3, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd4, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd5, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd6, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd7, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd8, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd9, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd10, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd11, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd12, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd13, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd14, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd15, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd16, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd17, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd18, 12'hfff);
        write_data_ack();
        read_sw(5'd0, 5'd19, 12'hfff);
        write_data_ack();
        $finish();
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

    task read_add(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b000, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_sub(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0100000, rs2, rs1, 3'b000, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_mul(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000001, rs2, rs1, 3'b000, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_div(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000001, rs2, rs1, 3'b100, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_rem(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000001, rs2, rs1, 3'b110, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_and(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b111, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_or(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b110, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_xor(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b100, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_sll(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b001, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_srl(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b101, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_slt(bit[4:0] rd, bit[4:0] rs1, bit[4:0] rs2);
        tb_wb_rdata = {7'b0000000, rs2, rs1, 3'b010, rd, R_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask
    
    task read_addi(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b000, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_andi(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b111, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_ori(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b110, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_xori(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b100, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_slli(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b001, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_srli(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b101, rd, I_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_lw(bit[4:0] rd, bit[4:0] rs1, bit[11:0] imm);
        tb_wb_rdata = {imm, rs1, 3'b010, rd, L_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_sw(bit[4:0] rs1, bit[4:0] rs2, bit[11:0] imm);
        tb_wb_rdata = {imm[11:5], rs2, rs1, 3'b010, imm[4:0], S_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_jal(bit[4:0] rd, bit[19:0] imm);
        tb_wb_rdata = {imm, rd, J_TYPE_OPCODE};
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
        @(posedge tb_clk) #1;
    endtask

    task read_data_ack(bit[31:0] data);
        tb_wb_rdata = data;
        tb_wb_ack = 1'b1;
        @(posedge tb_clk) #1;
        tb_wb_rdata = 'b0;
        tb_wb_ack = 1'b0;
        @(posedge tb_clk) #1;
    endtask

    task write_data_ack();
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