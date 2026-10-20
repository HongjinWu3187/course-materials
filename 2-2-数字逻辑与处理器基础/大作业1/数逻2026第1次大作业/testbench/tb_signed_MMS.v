`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module tb_signed_MMS;

    //========================================
    // Parameters
    //========================================
    parameter WIDTH = 4;

    //========================================
    // Testbench Signals
    //========================================
    reg clk;
    reg reset;
    reg signed [WIDTH-1:0] data;
    reg input_valid;
    reg start;

    wire signed [WIDTH-1:0] Max;
    wire signed [WIDTH-1:0] Min;

    //========================================
    // DUT Instantiation
    //========================================
    signed_MMS #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .input_valid(input_valid),
        .start(start),
        .Max(Max),
        .Min(Min)
    );

    //========================================
    // Clock Generation (10ns period)
    //========================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //========================================
    // Test Stimulus
    //========================================
    initial begin
        // Initialization
        reset = 1'b1;
        data = 0;
        input_valid = 1'b0;
        start = 1'b0;
        #20;
        reset = 1'b0;
        #10;

        // ==============================================
        // Test Sequence 1: 3, -1, 5, -4, -7
        // ==============================================
        $display("==============================================");
        $display("Test Sequence 1: 3, -1, 5, -4, -7");
        $display("==============================================");
        
        // Generate single cycle start pulse (SAFE)
        #10;
        start = 1'b1;
        #10;
        start = 1'b0;
        
        // Valid goes HIGH BEFORE data
        input_valid = 1'b1;
        
        // Feed data continuously
        data = 4'd3;    #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd1;   #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = 4'd5;    #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd4;   #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd7;    #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        
        // All data done → valid LOW
        input_valid = 1'b0;
        #10;
        
        // Check result
        check_result(5, -7);


        // ==============================================
        // Test Sequence 2: -8, -7, -1, -3
        // ==============================================
        $display("\n==============================================");
        $display("Test Sequence 2: -8, -7, -1, -3");
        $display("==============================================");
        
        #10;
        start = 1'b1;
        #10;
        start = 1'b0;
        
        input_valid = 1'b1;
        
        data = -4'd8;   #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd7;    #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd1;    #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        data = -4'd3;   #10;   $display("Data = %2d | Max = %2d, Min = %2d", data, Max, Min);
        
        input_valid = 1'b0;
        #10;
        
        check_result(-1, -8);

        #100;
        $finish;
    end

    //========================================
    // Check Result Task
    //========================================
    task check_result(input signed [WIDTH-1:0] exp_max, exp_min);
    begin
        if ((Max === exp_max) && (Min === exp_min))
            $display("PASS: Final Max=%d, Min=%d", exp_max, exp_min);
        else
            $display("ERROR: Expected Max=%d, Min=%d | Got Max=%d, Min=%d",
                exp_max, exp_min, Max, Min);
    end
    endtask

endmodule
