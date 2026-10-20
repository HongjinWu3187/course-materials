`timescale 1ns / 1ps 

module tb_signed_compare;

    // ========================================
    // Parameters
    // ========================================
    parameter WIDTH = 4;          // Bit-width for operands
    parameter USE_COMB = 1;       // 1: use combinational comparator

    // ========================================
    // Testbench signals
    // ========================================
    reg clk;                      // Clock signal    
    reg reset;                    // Reset signal
    reg start;                    // Start signal (for sequential version)
    reg signed [WIDTH-1:0] num_a; // Input operand A
    reg signed [WIDTH-1:0] num_b; // Input operand B
    wire greater_than;            // 1 if num_a > num_b
    wire done;                    // Done signal

    integer i, j;                 // Loop indices

    // ========================================
    // Instantiate comparator under test
    // ========================================
    generate
        if (USE_COMB) begin
            // Combinational version
            signed_compare_comb #(.WIDTH(WIDTH)) uut (
                .num_a(num_a),
                .num_b(num_b),
                .greater_than(greater_than)
            );
            assign done = 1'b1;
        end else begin
            // Sequential version (if available)
            signed_compare_seq #(.WIDTH(WIDTH)) uut (
                .clk(clk),
                .reset(reset),
                .start(start),
                .num_a(num_a),
                .num_b(num_b),
                .greater_than(greater_than),
                .done(done)
            );
        end
    endgenerate

    // ========================================
    // Clock generation
    // ========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // ========================================
    // Test procedure
    // ========================================
    initial begin
        // Initialize signals
        reset = 1;
        start = 0;
        num_a = 0;
        num_b = 0;

        // Apply reset
        #10 reset = 0;
        #5;

        // Test all combinations from -8 to 7 for WIDTH=4
        for (i = -$pow(2, WIDTH-1); i <= $pow(2, WIDTH-1)-1; i = i + 1) begin
            for (j = -$pow(2, WIDTH-1); j <= $pow(2, WIDTH-1)-1; j = j + 1) begin
                run_test(i, j);
            end
        end

        $display("All comparison test cases completed.");
        #100;
        $finish;
    end

    // ========================================
    // Task: Run single test
    // ========================================
    task run_test(input signed [WIDTH-1:0] a, input signed [WIDTH-1:0] b);
        reg expected_result;
    begin
        // Apply inputs
        num_a = a;
        num_b = b;

        // Expected comparison
        expected_result = (a > b);

        if (USE_COMB) begin
            #1; // small delay for combinational output to settle
            if (greater_than !== expected_result)
                $display("ERROR: num_a=%d, num_b=%d, expected=%b, got=%b", a, b, expected_result, greater_than);
            else
                $display("PASS : num_a=%d, num_b=%d, greater_than=%b", a, b, greater_than);
        end else begin
            // Sequential version: pulse start and wait done
            #10;
            start = 1;
            #5;
            @(posedge clk);
            start = 0;

            repeat (WIDTH + 1) @(posedge clk);

            if (done !==1) begin
                $display("ERROR: num_a=%d, num_b=%d, Done signal is not 1 after %d cycles!", a, b, WIDTH+1);
            end
            else begin 
                if (greater_than !== expected_result)
                    $display("ERROR: num_a=%d, num_b=%d, expected=%b, got=%b", a, b, expected_result, greater_than);
                else
                    $display("PASS : num_a=%d, num_b=%d, greater_than=%b", a, b, greater_than);
                end
            end
    end
    endtask

endmodule
