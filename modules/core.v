`include "defines.vh"

module core (
    input wire                               Clk,
    input wire                               Rst,
    output reg [$clog2(`RAM_CAPACITY)-1 : 0] Addr,
    output reg                               Cs,
    output reg                               We,
    output reg [8*`WORD_SIZE-1 : 0]          Wdata,
    input wire [8*`WORD_SIZE-1 : 0]          Rdata,
    input wire                               Ack
);
    integer id;
    reg [8*`WORD_SIZE-1 : 0] register[0 : 31];

    wire [4 : 0]              rs1_id;
    wire                      rs1_valid;
    reg  [8*`WORD_SIZE-1 : 0] rs1;

    wire [4 : 0]              rs2_id;
    wire                      rs2_valid;
    reg  [8*`WORD_SIZE-1 : 0] rs2;

    wire [4 : 0]              rd_id;
    wire                      rd_valid;
    wire [8*`WORD_SIZE-1 : 0] rd;

    always @(posedge Clk) begin
        if (Rst) begin
            for (id=0; id<32; id=id+1) begin
                register[id] <= 'b0;
            end
        end
        else if (rd_valid) begin
            register[id] <= rd;
        end
    end

    always @(posedge Clk) begin
        if (Rst) begin
            rs1 <= 'b0;
        end
        else if (rs1_valid) begin
            rs1 <= register[rs1_id];
        end
    end

    always @(posedge Clk) begin
        if (Rst) begin
            rs2 <= 'b0;
        end
        else if (rs2_valid) begin
            rs2 <= register[rs2_id];
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
        .rs1_valid   ( rs1_valid ),
        .rs1_data_in ( rs1 ),
        .rs2_id      ( rs2_id ),
        .rs2_valid   ( rs2_valid ),
        .rs2_data_in ( rs2 ),
        .rd_id       ( rd_id ),
        .rd_valid    ( rd_valid ),
        .rd          ( rd )
    );

endmodule