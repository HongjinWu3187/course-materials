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

    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed Compare sequential logic here

    end

endmodule
