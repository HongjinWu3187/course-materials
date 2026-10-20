module signed_compare_comb #(
    parameter WIDTH = 4 // Bit-width of operands
)(
    input wire [WIDTH-1:0] num_a, // (signed WIDTH-bit)
    input wire [WIDTH-1:0] num_b, // (signed WIDTH-bit)
    output wire greater_than      // 1: num_a > num_b, 0: else
);

    // TODO: Define your variables here
    reg greater_than_reg;  // temporary variable
    reg higher_bits_equal;  // flag indicating higher bits all the same
    integer i;  // index of bit compared currently
    
    assign greater_than = greater_than_reg;

    always @(*) begin
        // TODO: Implement your Signed Compare combinational logic here

        greater_than_reg = 1'b0;
        higher_bits_equal = 1'b1;
        
        // num_a >= 0 && num_b < 0
        if ((!num_a[WIDTH-1]) && (num_b[WIDTH-1])) begin
            greater_than_reg = 1'b1;
        end
        
        // num_a < 0 && num_b >= 0
        else if ((num_a[WIDTH-1]) && (!num_b[WIDTH-1])) begin
            greater_than_reg = 1'b0;
        end
        
        // (num_a >= 0 && num_b >= 0) || (num_a < 0 && num_b < 0)
        else begin
            i = WIDTH - 2;  // compare bit by bit from the (WIDTH-2)th bit to the LSB
            repeat (WIDTH - 1) begin
            if (higher_bits_equal) begin
                    if ((num_a[i]) && (!num_b[i])) begin
                        greater_than_reg = 1'b1;
                        higher_bits_equal = 1'b0;
                    end
                    else if ((!num_a[i]) && (num_b[i])) begin
                        greater_than_reg = 1'b0;
                        higher_bits_equal = 1'b0;
                    end
                end
                i = i - 1;
            end
        end
    end

endmodule