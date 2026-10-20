module signed_compare_comb #(
    parameter WIDTH = 4 // Bit-width of operands
)(
    input wire [WIDTH-1:0] num_a, // (signed WIDTH-bit)
    input wire [WIDTH-1:0] num_b, // (signed WIDTH-bit)
    output wire greater_than      // 1: num_a > num_b, 0: else
);

    // TODO: Define your variables here

    always @(*) begin
        // TODO: Implement your Signed Compare combinational logic here

    end

endmodule