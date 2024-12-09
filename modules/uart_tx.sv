module uart_tx (
    input              Clk,
    input              Rst,
    output reg         Tx = 1'b1,
    input      [7 : 0] S_axis_tdata,
    input              S_axis_tvalid,
    output reg         S_axis_tready = 1'b0
);
    reg [2 : 0] bit_counter = 3'd0;
    reg [3 : 0] cycle_counter = 3'd0;
    reg         bit_counter_ena = 1'b0;
    reg         counters_rst = 1'b1;

    enum reg [3 : 0] {
        ST_IDLE      = 4'b1 << 'd0,
        ST_START_BIT = 4'b1 << 'd1,
        ST_DATA_BIT  = 4'b1 << 'd2,
        ST_STOP_BIT  = 4'b1 << 'd3
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
                if (S_axis_tvalid) begin
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
                    next_state = ST_STOP_BIT;
                end
                else begin
                    next_state = ST_DATA_BIT;
                end
            end

            ST_STOP_BIT: begin
                if (cycle_counter == 4'd15) begin
                    next_state = ST_IDLE;
                end
                else begin
                    next_state = ST_STOP_BIT;
                end
            end
        endcase
    end
    
    always_comb begin
        case (state)
            ST_IDLE: begin
                Tx = 1'b1;
                bit_counter_ena = 1'b0;
                counters_rst = 1'b1;
            end

            ST_START_BIT: begin
                Tx = 1'b0;
                bit_counter_ena = 1'b0;
                counters_rst = 1'b0;
            end

            ST_DATA_BIT: begin
                Tx = S_axis_tdata[bit_counter];

                if (cycle_counter == 4'd15)
                    bit_counter_ena = 1'b1;
                else
                    bit_counter_ena = 1'b0;
                
                counters_rst = 1'b0;
            end

            ST_STOP_BIT: begin
                Tx = 1'b1;
                bit_counter_ena = 1'b0;
                counters_rst = 1'b0;
            end
        endcase
    end
    
    always_ff @(posedge Clk) begin
        if (Rst) begin
            S_axis_tready <= 1'b0;
        end
        else if (S_axis_tvalid & S_axis_tready) begin
            S_axis_tready <= 1'b0;
        end
        else if (bit_counter == 3'd7 & cycle_counter == 4'd15) begin
            S_axis_tready <= 1'b1;
        end
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
            cycle_counter <= 4'd0;
        end
        else if (counters_rst) begin
            cycle_counter <= 4'd0;
        end
        else begin
            cycle_counter <= cycle_counter + 4'd1;
        end
    end

endmodule