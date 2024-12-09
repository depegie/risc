module uart_tx (
    input              Clk,
    input              Rst,
    output reg         Tx,
    input      [7 : 0] S_axis_tdata,
    input              S_axis_tvalid,
    output reg         S_axis_tready
);
    reg [2 : 0] bit_counter;
    reg [3 : 0] cycle_counter;
    reg         bit_counter_ena;
    reg         counters_rst;

    enum reg [7 : 0] {
        ST_IDLE,
        ST_START_BIT,
        ST_DATA_BIT,
        ST_STOP_BIT
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

endmodule