module UartRx #(
    parameter CLKS_PER_BIT = 10417
)(
    input        clk,
    input        reset,
    input        rx,
    output reg [7:0] data,
    output reg       done
);

    localparam S_IDLE  = 3'd0;
    localparam S_START = 3'd1;
    localparam S_DATA  = 3'd2;
    localparam S_STOP  = 3'd3;

    reg [2:0]  state;
    reg [31:0] clk_count;
    reg [2:0]  bit_index;
    reg        rx_meta;
    reg        rx_sync;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= S_IDLE;
            clk_count <= 32'b0;
            bit_index <= 3'b0;
            data      <= 8'b0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE: begin
                    clk_count <= 32'b0;
                    bit_index <= 3'b0;
                    if (rx_sync == 1'b0)
                        state <= S_START;
                end

                S_START: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        if (rx_sync == 1'b0) begin
                            clk_count <= 32'b0;
                            state     <= S_DATA;
                        end else begin
                            state <= S_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 32'd1;
                    end
                end

                S_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count       <= 32'b0;
                        data[bit_index] <= rx_sync;
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
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 32'b0;
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
