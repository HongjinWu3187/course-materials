module UartTx #(
    parameter CLKS_PER_BIT = 10417
)(
    input        clk,
    input        reset,
    input        start,
    input  [7:0] data,
    output reg   tx,
    output reg   busy,
    output reg   done
);

    localparam S_IDLE  = 3'd0;
    localparam S_START = 3'd1;
    localparam S_DATA  = 3'd2;
    localparam S_STOP  = 3'd3;

    reg [2:0]  state;
    reg [31:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= S_IDLE;
            tx        <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            clk_count <= 32'b0;
            bit_index <= 3'b0;
            tx_data   <= 8'b0;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 32'b0;
                    bit_index <= 3'b0;
                    if (start) begin
                        busy    <= 1'b1;
                        tx_data <= data;
                        state   <= S_START;
                    end
                end

                S_START: begin
                    tx <= 1'b0;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'b0;
                        state     <= S_DATA;
                    end else begin
                        clk_count <= clk_count + 32'd1;
                    end
                end

                S_DATA: begin
                    tx <= tx_data[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'b0;
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'b0;
                            state     <= S_STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                        end
                    end else begin
                        clk_count <= clk_count + 32'd1;
                    end
                end

                S_STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'b0;
                        busy      <= 1'b0;
                        done      <= 1'b1;
                        state     <= S_IDLE;
                    end else begin
                        clk_count <= clk_count + 32'd1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
