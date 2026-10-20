module signed_MMS #(
    parameter WIDTH = 4                     // Bit-width of input operands
)(
    input wire clk,                          // Clock signal
    input wire reset,                        // Asynchronous reset signal
    input wire [WIDTH-1:0] data,     // input data
    input wire input_valid,                  // Input valid signal
    input wire start,                     // start signal

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

    // State transition logic
    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed MMS design here
        
    end

endmodule