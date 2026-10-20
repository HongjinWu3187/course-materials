`timescale 1ns/1ps

module tb_amplifier_soc_cpi;

    localparam integer CLKS_PER_BIT_SIM = 16;
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

    // CPI statistics for the node-amplifier algorithm itself.
    // Start: PC 0x00000008 enters IF after UART input returns.
    // End:   PC 0x00000104 reaches MEM/WB after writing the result.
    integer cpi_cycles;
    integer cpi_instructions;
    reg uart_receive_entered;
    reg cpi_cycle_active;
    reg cpi_retire_active;
    reg cpi_finished;
    real cpi_value;

    AmplifierSoC #(
        .ROM_INIT_FILE("D:/Downloads/pipeline_cpu_project_uart_bonus/asm/amplifier_program.hex"),
        .RAM_INIT_FILE("D:/Downloads/pipeline_cpu_project_uart_bonus/data/amplifier_data.hex"),
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
        if (dut.data_ram.ram[0] !== 32'h00000000) begin
            $display("FAIL: data RAM was not initialized. Check RAM_INIT_FILE absolute path.");
            $finish;
        end

        repeat (12) @(posedge clk);
        reset = 1'b0;

        for (cycle = 0; cycle < 200000; cycle = cycle + 1) begin
            @(posedge clk);
            if (dut.data_ram.ram[RESULT_WORD] == 32'd1 &&
                uart_count >= 4 &&
                uart_word == 32'h00000001 &&
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

    // Count elapsed clock periods and retired instructions in the same
    // algorithm interval. The one-nanosecond delay lets nonblocking updates
    // inside PipelineCPU settle before the debug signals are sampled.
    always @(posedge clk) begin
        #1;

        if (reset) begin
            cpi_cycles       = 0;
            cpi_instructions = 0;
            uart_receive_entered = 1'b0;
            cpi_cycle_active = 1'b0;
            cpi_retire_active = 1'b0;
            cpi_finished      = 1'b0;
            cpi_value         = 0.0;
        end
        else if (!cpi_finished) begin
            // PC 0x8 is fetched speculatively once immediately after the
            // initial jal. Ignore that wrong-path fetch and accept PC 0x8
            // only after the UART receive routine at PC 0x1a0 was entered.
            if (debug_pc == 32'h000001a0) begin
                uart_receive_entered = 1'b1;
            end

            // Start at zero so the count equals (end_time-start_time)/Tclk.
            if (!cpi_cycle_active && uart_receive_entered &&
                debug_pc == 32'h00000008) begin
                cpi_cycle_active = 1'b1;
                cpi_cycles = 0;
                $display("CPI counting started: IF PC=%h time=%0t", debug_pc, $time);
            end
            else if (cpi_cycle_active) begin
                cpi_cycles = cpi_cycles + 1;
            end

            // Do not count older UART-receive instructions still draining
            // from the pipeline. Begin when the first algorithm PC reaches WB.
            if (!cpi_retire_active &&
                dut.cpu.debug_wb_pc == 32'h00000008) begin
                cpi_retire_active = 1'b1;
            end

            // This CPU propagates PC=0 for bubbles inserted by stall or flush.
            // All real algorithm instructions have nonzero PCs in this window.
            if (cpi_retire_active &&
                dut.cpu.debug_wb_pc != 32'h00000000) begin
                cpi_instructions = cpi_instructions + 1;
            end

            // The store at PC 0x104 writes the answer to RAM address 0x1b04.
            if (cpi_retire_active &&
                dut.cpu.debug_wb_pc == 32'h00000104) begin
                cpi_value = 1.0 * cpi_cycles / cpi_instructions;
                $display("CPI_RESULT: cycles=%0d instructions=%0d CPI=%0.4f start_pc=00000008 end_pc=00000104 time=%0t",
                         cpi_cycles, cpi_instructions, cpi_value, $time);

                cpi_cycle_active  = 1'b0;
                cpi_retire_active = 1'b0;
                cpi_finished      = 1'b1;
            end
        end
    end

    initial begin
        wait (reset == 1'b0);
        forever begin
            wait_uart_byte(uart_byte);
            uart_word = {uart_word[23:0], uart_byte};
            uart_count = uart_count + 1;
            $display("UART byte[%0d] = 0x%02h", uart_count, uart_byte);
        end
    end

    initial begin
        wait (reset == 1'b0);
        repeat (50) @(posedge clk);
        send_sample_input;
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

    task send_sample_input;
        begin
            drive_uart_rx_word32(32'd4);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd3);
            drive_uart_rx_word32(32'd3);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd3);
            drive_uart_rx_word32(32'd4);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd1);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd2);
            drive_uart_rx_word32(32'd4);
        end
    endtask

    task drive_uart_rx_word32;
        input [31:0] data;
        begin
            drive_uart_rx_byte(data[31:24]);
            drive_uart_rx_byte(data[23:16]);
            drive_uart_rx_byte(data[15:8]);
            drive_uart_rx_byte(data[7:0]);
        end
    endtask

    task drive_uart_rx_byte;
        input [7:0] data;
        integer i;
        begin
            uart_rx = 1'b0;
            repeat (CLKS_PER_BIT_SIM) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                repeat (CLKS_PER_BIT_SIM) @(posedge clk);
            end
            uart_rx = 1'b1;
            repeat (CLKS_PER_BIT_SIM * 2) @(posedge clk);
        end
    endtask

endmodule
