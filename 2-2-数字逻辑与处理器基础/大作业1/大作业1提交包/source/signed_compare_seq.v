module signed_compare_seq #(
    parameter WIDTH = 4 // Bit-width of operands
)(
    input wire clk,                      // Clock signal
    input wire reset,                    // Reset signal
    input wire start,                    // Start signal
    input wire [WIDTH-1:0] num_a,        // (signed WIDTH-bit)
    input wire [WIDTH-1:0] num_b,        // (signed WIDTH-bit)
    output reg greater_than,             // 1: num_a > num_b, 0: else
    output reg done                      // Done signal (0: not done, 1: done)
);

    // Hints for State definitions
    localparam IDLE = 2'b00;
    localparam COMPARE = 2'b01;
    localparam DONE = 2'b10;

    // TODO: Define your variables here
    reg [1:0] state;
    
    reg [WIDTH-1:0] a_reg;
    reg [WIDTH-1:0] b_reg;  // latch num_a and num_b when start turns 1
    
    integer bit_index;

    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed Compare sequential logic here
        
        // reset = 1: all back to IDLE
        if (reset) begin
            state <= IDLE;
            a_reg <= {WIDTH{1'b0}};
            b_reg <= {WIDTH{1'b0}};
            greater_than <= 1'b0;
            done <= 1'b0;
            bit_index <= 0;
        end
        
        else begin
            case (state)
            
                // state IDLE: waiting for start signal.
                IDLE: begin
                    done <= 1'b0;
                    greater_than <= 1'b0;
                    
                    if (start) begin
                        a_reg <= num_a;
                        b_reg <= num_b;
                        bit_index <= WIDTH - 1;
                        state <= COMPARE;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                
                // state COMPARE: compare from MSB to LSB bit by bit
                COMPARE: begin

                    // First compare the MSB
                    if (bit_index == WIDTH - 1) begin
                        if ((!a_reg[WIDTH-1]) && (b_reg[WIDTH-1])) begin
                            greater_than <= 1'b1;
                            done <= 1'b1;
                            state <= DONE;
                        end

                        else if ((a_reg[WIDTH-1]) && (!b_reg[WIDTH-1])) begin
                            greater_than <= 1'b0;
                            done <= 1'b1;
                            state <= DONE;
                        end

                        else begin
                            if (bit_index == 0) begin
                                // This only matters when WIDTH = 1.
                                greater_than <= 1'b0;
                                done <= 1'b1;
                                state <= DONE;
                            end
                            else begin
                                bit_index <= bit_index - 1;
                                state <= COMPARE;
                            end
                        end
                    end

                    // Compare the remaining bits from high to low.
                    else begin
                        if ((a_reg[bit_index]) && (!b_reg[bit_index])) begin
                            greater_than <= 1'b1;
                            done <= 1'b1;
                            state <= DONE;
                        end
                        else if ((!a_reg[bit_index]) && (b_reg[bit_index])) begin
                            greater_than <= 1'b0;
                            done <= 1'b1;
                            state <= DONE;
                        end
                        else begin
                            // If the current bit is the LSB, all bits are equal.
                            if (!bit_index) begin
                                greater_than <= 1'b0;
                                done <= 1'b1;
                                state <= DONE;
                            end
                            else begin
                                bit_index <= bit_index - 1;
                                state <= COMPARE;
                            end
                        end
                    end
                end
                
                // state DONE: hold the result and wait for a new start signal.
                DONE: begin
                    done <= 1'b1;
                    
                    if (start) begin
                        done <= 1'b0;
                        greater_than <= 1'b0;
                        a_reg <= num_a;
                        b_reg <= num_b;
                        bit_index <= WIDTH - 1;
                        state <= COMPARE;
                    end
                    else begin
                        state <= DONE;
                    end
                end

                default: begin
                    state <= IDLE;
                    greater_than <= 1'b0;
                    done <= 1'b0;
                    a_reg <= {WIDTH{1'b0}};
                    b_reg <= {WIDTH{1'b0}};
                    bit_index <= 0;
                end

            endcase
        end    
    end

endmodule