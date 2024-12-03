`include "defines.vh"

module core (
    input wire                               Clk,
    input wire                               Rst,
    output reg [$clog2(`RAM_CAPACITY)-1 : 0] Addr,
    output reg                               Cs,
    output reg                               We,
    output reg [8*`WORD_SIZE_B-1 : 0]        Wdata,
    input wire [8*`WORD_SIZE_B-1 : 0]        Rdata,
    input wire                               Ack
);
    int id;
    reg [8*`WORD_SIZE_B-1 : 0] register[32];

    wire [4 : 0]                rs1_id;
    wire [8*`WORD_SIZE_B-1 : 0] rs1;
    wire [8*`WORD_SIZE_B-1 : 0] rs1_alu;
    wire [8*`WORD_SIZE_B-1 : 0] rs1_cu;

    wire [4 : 0]                rs2_id;
    wire [8*`WORD_SIZE_B-1 : 0] rs2;
    wire [8*`WORD_SIZE_B-1 : 0] rs2_alu;
    wire [8*`WORD_SIZE_B-1 : 0] rs2_cu;

    wire [4 : 0]                rd_id;
    wire                        rd_valid;
    wire [8*`WORD_SIZE_B-1 : 0] rd;
    wire [8*`WORD_SIZE_B-1 : 0] rd_alu;
    wire [8*`WORD_SIZE_B-1 : 0] rd_cu;

    wire [3 : 0]                alu_control;
    wire                        alu_enable;

    assign rd  = alu_enable ? rd_alu : rd_cu;
    assign rs1 = register[rs1_id];
    assign rs2 = register[rs2_id];

    assign rs1_alu = alu_enable ? rs1 : 'b0;
    assign rs2_alu = alu_enable ? rs2 : 'b0;
    assign rs1_cu  = alu_enable ? 'b0 : rs1;
    assign rs2_cu  = alu_enable ? 'b0 : rs2;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            for (id=0; id<32; id=id+1) begin
                register[id] <= 'b0;
            end
        end
        else if (rd_valid & rd_id != 5'b0) begin
            register[rd_id] <= rd;
        end
    end

    control_unit control_unit_inst (
        .Clk         ( Clk ),
        .Rst         ( Rst ),
        .Addr        ( Addr ),
        .Cs          ( Cs ),
        .We          ( We ),
        .Wdata       ( Wdata ),
        .Rdata       ( Rdata ),
        .Ack         ( Ack ),
        .rs1_id      ( rs1_id ),
        .rs1_data    ( rs1_cu ),
        .rs2_id      ( rs2_id ),
        .rs2_data    ( rs2_cu ),
        .rd_id       ( rd_id ),
        .rd_valid    ( rd_valid ),
        .rd_data     ( rd_cu ),
        .alu_control ( alu_control ),
        .alu_enable  ( alu_enable )
    );

    alu alu_inst (
        .rs1     ( rs1_alu ),
        .rs2     ( rs2_alu ),
        .rd      ( rd_alu ),
        .control ( alu_control )
    );

endmodule