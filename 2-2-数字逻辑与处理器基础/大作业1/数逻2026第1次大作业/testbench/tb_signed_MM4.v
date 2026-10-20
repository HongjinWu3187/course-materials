`timescale 1ns / 1ps

module tb_signed_MM4;

    // ========================================
    // Parameters
    // ========================================
    parameter WIDTH = 4;

    // ========================================
    // Testbench signals
    // ========================================
    reg clk;
    reg reset;
    reg input_valid;
    
    reg signed [WIDTH-1:0] num_a;
    reg signed [WIDTH-1:0] num_b;
    reg signed [WIDTH-1:0] num_c;
    reg signed [WIDTH-1:0] num_d;
    
    wire signed [WIDTH-1:0] Max;
    wire signed [WIDTH-1:0] Min;

    // ========================================
    // Instantiate DUT
    // ========================================
    signed_MM4 #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .num_a(num_a),
        .num_b(num_b),
        .num_c(num_c),
        .num_d(num_d),
        .input_valid(input_valid),
        .Max(Max),
        .Min(Min)
    );

    // ========================================
    // Clock generation (10ns period)
    // ========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ========================================
    // Test cases
    // ========================================
    initial begin
        // Initialize
        reset = 1;
        input_valid = 0;
        num_a = 0;
        num_b = 0;
        num_c = 0;
        num_d = 0;
        #20;
        
        reset = 0;
        #10;

        // ================= TEST 1 =================
        num_a = 4'd3;
        num_b = 4'd1;
        num_c = -4'd2;
        num_d = 4'd5;
        run_test_case(num_a, num_b, num_c, num_d);
        
        // ================= TEST 2 =================
        num_a = -4'd1;
        num_b = -4'd3;
        num_c = -4'd4;
        num_d = 4'd0;
        run_test_case(num_a, num_b, num_c, num_d);
        
        // ================= TEST 3 =================
        num_a = 4'd7;
        num_b = -4'd8;
        num_c = 4'd2;
        num_d = -4'd5;
        run_test_case(num_a, num_b, num_c, num_d);

        $display("========================================");
        $display("All Max/Min test cases finished!");
        $display("========================================");
        #100;
        $finish;
    end

    // ========================================
    // Task: Run one test and display PASS/ERROR
    // ========================================
    task run_test_case(
        input signed [WIDTH-1:0] a,
        input signed [WIDTH-1:0] b,
        input signed [WIDTH-1:0] c,
        input signed [WIDTH-1:0] d
    );
        reg signed [WIDTH-1:0] exp_max;
        reg signed [WIDTH-1:0] exp_min;
    begin
        // Assign inputs
        num_a = a;
        num_b = b;
        num_c = c;
        num_d = d;

        // Generate expected Max & Min
        exp_max = max4(a, b, c, d);
        exp_min = min4(a, b, c, d);

        // Trigger input valid
        @(posedge clk);
        input_valid = 1;
        @(posedge clk);
        input_valid = 0;
        
        // Wait for output stable
        repeat(2) @(posedge clk);
        
        // Check result
        if ((Max === exp_max) && (Min === exp_min))
            $display("PASS: A=%2d, B=%2d, C=%2d, D=%2d | Max=%2d, Min=%2d",
                     a, b, c, d, Max, Min);
        else
            $display("ERROR: A=%2d, B=%2d, C=%2d, D=%2d | EXP Max=%2d Min=%2d | GOT Max=%2d Min=%2d",
                     a, b, c, d, exp_max, exp_min, Max, Min);
    end
    endtask

    // ========================================
    // Function: Compute expected 4-input MAX
    // ========================================
    function signed [WIDTH-1:0] max4(
        input signed [WIDTH-1:0] a,b,c,d
    );
    begin
        max4 = a;
        if (b > max4) max4 = b;
        if (c > max4) max4 = c;
        if (d > max4) max4 = d;
    end
    endfunction

    // ========================================
    // Function: Compute expected 4-input MIN
    // ========================================
    function signed [WIDTH-1:0] min4(
        input signed [WIDTH-1:0] a,b,c,d
    );
    begin
        min4 = a;
        if (b < min4) min4 = b;
        if (c < min4) min4 = c;
        if (d < min4) min4 = d;
    end
    endfunction

endmodule