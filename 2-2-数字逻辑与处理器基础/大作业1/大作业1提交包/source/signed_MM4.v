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
    wire gt_ab, gt_cd, gt_max, gt_min;
    wire [WIDTH-1:0] max_ab, min_ab, max_cd, min_cd;
    wire [WIDTH-1:0] max_result, min_result;
    
    // TODO: Instantiate signed_MM4 unit/units
    
    // Comparator 1: num_a vs num_b
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_ab (
        .num_a(num_a),
        .num_b(num_b),
        .greater_than(gt_ab)
    );
    
    // Comparator 2: num_c vs num_d
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_cd (
        .num_a(num_c),
        .num_b(num_d),
        .greater_than(gt_cd)
    );
    
    // Select max and min from the first pair (a, b)
    assign max_ab = gt_ab ? num_a : num_b;
    assign min_ab = gt_ab ? num_b : num_a;
    
    // Select max and min from the second pair (c, d)
    assign max_cd = gt_cd ? num_c : num_d;
    assign min_cd = gt_cd ? num_d : num_c;
    
    // Comparator 3: max_ab vs max_cd for final Max
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_max (
        .num_a(max_ab),
        .num_b(max_cd),
        .greater_than(gt_max)
    );
    
    // Comparator 4: min_ab vs min_cd for final Min
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_min (
        .num_a(min_ab),
        .num_b(min_cd),
        .greater_than(gt_min)
    );
    
    // Final selection for Max and Min
    assign max_result = gt_max ? max_ab : max_cd;
    assign min_result = gt_min ? min_cd : min_ab;

    
    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed MM4 sequential logic here
        if (reset) begin
            Max <= {WIDTH{1'b0}};
            Min <= {WIDTH{1'b0}};
        end
        else if (input_valid) begin
            Max <= max_result;
            Min <= min_result;
        end
        // When input_valid is 0, Max and Min hold their previous values
    end

endmodule