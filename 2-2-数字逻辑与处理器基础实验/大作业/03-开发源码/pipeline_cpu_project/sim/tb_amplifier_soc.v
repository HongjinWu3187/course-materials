`timescale 1ns/1ps

module tb_amplifier_soc;

    localparam integer CLKS_PER_BIT_SIM = 8;
    localparam integer RESULT_WORD      = 1729; // 0x1b04 / 4

    reg clk;
    reg reset;
    reg uart_rx;

    wire uart_tx;
    wire [7:0] seg;
    wire [3:0] an;
    wire [31:0] debug_pc;
    wire [11:0] debug_sevenseg_value;

    integer cycle;
    integer uart_count;
    reg [7:0] uart_byte;
    reg [31:0] uart_word;

    AmplifierSoC #(
        .ROM_INIT_FILE("D:/Downloads/pipeline_cpu_project/asm/amplifier_program.hex"),
        .RAM_INIT_FILE("D:/Downloads/pipeline_cpu_project/data/amplifier_data.hex"),
        .CLKS_PER_BIT(CLKS_PER_BIT_SIM)
    ) dut (
        .clk                  (clk),
        .reset                (reset),
        .uart_rx              (uart_rx),
        .uart_tx              (uart_tx),
        .seg                  (seg),
        .an                   (an),
        .debug_pc             (debug_pc),
        .debug_sevenseg_value (debug_sevenseg_value)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        uart_rx = 1'b1;
        uart_count = 0;
        uart_word = 32'b0;

        #1;
        $display("Init check: ROM[0]=%h RAM[0]=%h", dut.instruction_rom.rom[0], dut.data_ram.ram[0]);
        if (dut.instruction_rom.rom[0] !== 32'h241d3ffc) begin
            $display("FAIL: instruction ROM was not initialized. Check ROM_INIT_FILE absolute path.");
            $finish;
        end
        if (dut.data_ram.ram[0] !== 32'h00000004) begin
            $display("FAIL: data RAM was not initialized. Check RAM_INIT_FILE absolute path.");
            $finish;
        end

        repeat (12) @(posedge clk);
        reset = 1'b0;

        for (cycle = 0; cycle < 200000; cycle = cycle + 1) begin
            @(posedge clk);
            if (dut.data_ram.ram[RESULT_WORD] == 32'd1 &&
                uart_count >= 4 &&
                uart_word == 32'h30303031 &&
                debug_sevenseg_value == 12'h83f) begin
                $display("PASS: result=%0d uart=%h sevenseg=%h cycles=%0d pc=%h",
                         dut.data_ram.ram[RESULT_WORD], uart_word, debug_sevenseg_value, cycle, debug_pc);
                $finish;
            end
        end

        $display("FAIL: timeout result=%0d uart_count=%0d uart=%h sevenseg=%h pc=%h",
                 dut.data_ram.ram[RESULT_WORD], uart_count, uart_word, debug_sevenseg_value, debug_pc);
        $finish;
    end

    initial begin
        wait (reset == 1'b0);
        forever begin
            wait_uart_byte(uart_byte);
            uart_word = {uart_word[23:0], uart_byte};
            uart_count = uart_count + 1;
            $display("UART byte[%0d] = 0x%02h (%c)", uart_count, uart_byte, uart_byte);
        end
    end

    task wait_uart_byte;
        output [7:0] data;
        integer i;
        begin
            @(negedge uart_tx);
            repeat (CLKS_PER_BIT_SIM + (CLKS_PER_BIT_SIM / 2)) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                #1;
                data[i] = uart_tx;
                repeat (CLKS_PER_BIT_SIM) @(posedge clk);
            end
            repeat (CLKS_PER_BIT_SIM) @(posedge clk);
        end
    endtask

endmodule
