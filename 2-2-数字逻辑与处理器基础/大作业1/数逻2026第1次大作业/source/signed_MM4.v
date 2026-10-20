module signed_MM4 #(
    parameter WIDTH = 4                       // Bit width of input operands
)(
    input wire clk,                            // Clock signal
    input wire reset,                          // Asynchronous reset signal
    input wire [WIDTH-1:0] num_a,       // input data
    input wire [WIDTH-1:0] num_b,     // input data
    input wire [WIDTH-1:0] num_c,     // input data
    input wire [WIDTH-1:0] num_d,     // input data
    input wire input_valid,                    // Input data valid signal

    output reg [WIDTH-1:0] Max,        // Max
    output reg [WIDTH-1:0] Min         // Min
);
    
    // TODO: Define your variables here
    
    // Comparator instantiation
    /*
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) compare_inst (
        .num_a(comp_a),
        .num_b(comp_b),
        .greater_than(comp_greater)
    );
    */
    // TODO: Instantiate signed_MM4 unit/units

    
    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed MM4 sequential logic here
    
    end

endmodule
