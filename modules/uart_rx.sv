module uart_rx (
    input              Clk,
    input              Rst,
    input              Rx,
    output reg [7 : 0] M_axis_tdata,
    output reg         M_axis_tvalid,
    input              M_axis_tready
);
    wire rx_sync;

    reg         rx_sync_q;
    reg [2 : 0] bit_counter;
    reg [3 : 0] cycle_counter;
    reg         bit_counter_ena;
    reg         sample_bit_ena;
    reg         counters_rst;

    enum reg [2 : 0] {
        ST_IDLE      = 3'b1 << 'd0,
        ST_START_BIT = 3'b1 << 'd1,
        ST_DATA_BIT  = 3'b1 << 'd2
    } state, next_state;

    always_ff @(posedge Clk) begin
        if (Rst) begin
            state <= ST_IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                if (~rx_sync & rx_sync_q) begin
                    next_state = ST_START_BIT;
                end
                else begin
                    next_state = ST_IDLE;
                end
            end

            ST_START_BIT: begin
                if (cycle_counter == 4'd15) begin
                    next_state = ST_DATA_BIT;
                end
                else begin
                    next_state = ST_START_BIT;
                end
            end
            
            ST_DATA_BIT: begin
                if (bit_counter == 3'd7 && cycle_counter == 4'd15) begin
                    next_state = ST_IDLE;
                end
                else begin
                    next_state = ST_DATA_BIT;
                end
            end
        endcase
    end

    always_comb begin
        case (state)
            ST_IDLE: begin
                bit_counter_ena = 1'b0;
                sample_bit_ena = 1'b0;
                counters_rst = 1'b1;
            end

            ST_START_BIT: begin
                bit_counter_ena = 1'b0;
                sample_bit_ena = 1'b0;
                counters_rst = 1'b0;
            end
            
            ST_DATA_BIT: begin
                if (cycle_counter == 4'd7)
                    sample_bit_ena = 1'b1;
                else
                    sample_bit_ena = 1'b0;

                if (cycle_counter == 4'd15)
                    bit_counter_ena = 1'b1;
                else
                    bit_counter_ena = 1'b0;

                counters_rst = 1'b0;
            end
        endcase
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            bit_counter <= 3'd0;
        end
        else if (counters_rst) begin
            bit_counter <= 3'd0;
        end
        else if (bit_counter_ena) begin
            bit_counter <= bit_counter + 3'd1;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            cycle_counter <= 'd0;
        end
        else if (counters_rst) begin
            cycle_counter <= 'd0;
        end
        else begin
            cycle_counter <= cycle_counter + 'd1;
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            M_axis_tdata <= 8'b0;
        end
        else if (sample_bit_ena) begin
            M_axis_tdata <= {rx_sync, M_axis_tdata[7:1]};
        end
    end

    always_ff @(posedge Clk) begin
        if (Rst) begin
            M_axis_tvalid <= 1'b0;
        end
        else if (M_axis_tvalid & M_axis_tready) begin
            M_axis_tvalid <= 1'b0;
        end
        else if (bit_counter == 3'd7 & cycle_counter == 4'd15) begin
            M_axis_tvalid <= 1'b1;
        end
    end

    always_ff @(posedge Clk) begin
        rx_sync_q <= rx_sync;
    end
    
    synchronizer synchronizer_inst (
        .Clk      ( Clk ),
        .Async_in ( Rx ),
        .Sync_out ( rx_sync )
    );
    
endmodule