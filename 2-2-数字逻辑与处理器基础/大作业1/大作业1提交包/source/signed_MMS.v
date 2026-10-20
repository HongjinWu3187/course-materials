module signed_MMS #(
    parameter WIDTH = 4                     // Bit-width of input operands
)(
    input wire clk,                          // Clock signal
    input wire reset,                        // Asynchronous reset signal
    input wire [WIDTH-1:0] data,             // input data
    input wire input_valid,                  // Input valid signal
    input wire start,                        // start signal

    output reg [WIDTH-1:0] Max,              // Max
    output reg [WIDTH-1:0] Min               // Min
);

    // TODO: Define your variables here
    wire gt_data_max;   // 1: data > Max, update Max
    wire gt_min_data;   // 1: Min > data, update Min
    
    // Sign: whether the sequence has received the first valid data
    reg initialized;


    // Data vs current Max
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_data_vs_max (
        .num_a(data),
        .num_b(Max),
        .greater_than(gt_data_max)
    );

    // Current Min vs data
    signed_compare_comb #(
        .WIDTH(WIDTH)
    ) comp_min_vs_data (
        .num_a(Min),
        .num_b(data),
        .greater_than(gt_min_data)
    );

    always @(posedge clk or posedge reset) begin
        // TODO: Implement your Signed MMS design here
        
        if (reset) begin
            Max <= {WIDTH{1'b0}};
            Min <= {WIDTH{1'b0}};
            initialized <= 1'b0;
        end
        
        // New sequence: Max, Min & initialized back to 0
        else if (start) begin
            Max <= {WIDTH{1'b0}};
            Min <= {WIDTH{1'b0}};
            initialized <= 1'b0;
        end
            
        // First valid data: directly let Max & Min = current data
        else if (input_valid) begin
            if (!initialized) begin
                Max <= data;
                Min <= data;
                initialized <= 1'b1;
            end
            
            // Not the first valid data: compare and update
            else begin
                if (gt_data_max) begin
                    Max <= data; 
                end
                if (gt_min_data) begin
                    Min <= data;
                end
            end
        end
        
        // default (input_valid = 0): keep current Max & Min
    end

endmodule