`timescale 1ns/1ps

// Post-implementation testbench for the accelerated BoardTop_sim netlist.
// It intentionally observes only board-level ports and testbench state, so it
// does not depend on RTL hierarchy names that may be flattened or renamed.
module tb_board_post_impl;

    localparam integer CLK_PERIOD_NS     = 10;
    localparam integer CLKS_PER_BIT_SIM  = 16;
    localparam integer BIT_TIME_NS       = CLK_PERIOD_NS * CLKS_PER_BIT_SIM;
    localparam integer TIMEOUT_NS        = 2000000; // 2 ms

    localparam [31:0] EXPECTED_UART_WORD = 32'h00000001;
    localparam [11:0] EXPECTED_SEVENSEG  = 12'h83f;

    reg sysclk;
    reg KEY1;
    reg UART_RX;

    wire       UART_TX;
    wire [7:0] leds;
    wire [3:0] SEL;

    integer uart_count;
    reg [7:0]  uart_byte;
    reg [31:0] uart_word;
    reg        seen_expected_sevenseg;

    BoardTop_sim dut (
        .sysclk  (sysclk),
        .KEY1    (KEY1),
        .UART_RX (UART_RX),
        .UART_TX (UART_TX),
        .leds    (leds),
        .SEL     (SEL)
    );

    initial begin
        sysclk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) sysclk = ~sysclk;
    end

    // Hold reset long enough for the post-implementation model to initialize,
    // then release it on a falling clock edge to avoid a recovery/removal race.
    initial begin
        KEY1 = 1'b1;
        UART_RX = 1'b1;
        uart_count = 0;
        uart_byte = 8'b0;
        uart_word = 32'b0;
        seen_expected_sevenseg = 1'b0;

        repeat (50) @(posedge sysclk);
        @(negedge sysclk);
        KEY1 = 1'b0;
        $display("Reset released at %0t", $time);
    end

    // Decode every byte transmitted by the implemented UART output.
    initial begin
        wait (KEY1 == 1'b0);
        forever begin
            wait_uart_tx_byte(uart_byte);
            uart_word = {uart_word[23:0], uart_byte};
            uart_count = uart_count + 1;
            $display("UART byte[%0d] = 0x%02h at %0t",
                     uart_count, uart_byte, $time);
        end
    end

    // Send the same 18-word sample used by tb_amplifier_soc.v.  BoardTop_sim
    // has CLKS_PER_BIT=16 baked into its implemented netlist, and the stimulus
    // uses the matching accelerated UART bit period.
    initial begin
        wait (KEY1 == 1'b0);
        repeat (50) @(posedge sysclk);
        $display("UART input started at %0t", $time);
        send_sample_input;
        $display("UART input completed at %0t", $time);
    end

    // The software display loop repeats forever.  Wait until all four result
    // bytes have been decoded, then observe the expected highest-digit scan.
    initial begin
        wait (KEY1 == 1'b0);
        wait (uart_count >= 4);
        wait ({SEL, leds} === EXPECTED_SEVENSEG);
        seen_expected_sevenseg = 1'b1;
    end

    // Pass/fail is based only on observable board-level behavior.
    initial begin
        wait (KEY1 == 1'b0);
        wait (uart_count >= 4 &&
              uart_word == EXPECTED_UART_WORD &&
              seen_expected_sevenseg == 1'b1);

        $display("PASS: post-implementation result uart=%h sevenseg=%h time=%0t",
                 uart_word, {SEL, leds}, $time);
        $finish;
    end

    initial begin
        wait (KEY1 == 1'b0);
        #(TIMEOUT_NS);
        $display("FAIL: post-implementation timeout uart_count=%0d uart=%h sevenseg=%h time=%0t",
                 uart_count, uart_word, {SEL, leds}, $time);
        $finish;
    end

    task wait_uart_tx_byte;
        output [7:0] data;
        integer i;
        begin
            @(negedge UART_TX);
            #(BIT_TIME_NS + (BIT_TIME_NS / 2));
            for (i = 0; i < 8; i = i + 1) begin
                data[i] = UART_TX;
                #(BIT_TIME_NS);
            end

            // The loop returns here at the middle of the stop bit.  Do not
            // delay for another full bit: the CPU may launch the next byte
            // only a few clocks after the stop bit and its start edge would
            // otherwise be missed by the next @(negedge UART_TX).
            if (UART_TX !== 1'b1)
                $display("WARN: UART_TX stop-bit check failed at %0t", $time);
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

    // Drive transitions near falling sysclk edges and hold each serial bit for
    // the accelerated UART bit time.  Two idle bit periods separate bytes.
    task drive_uart_rx_byte;
        input [7:0] data;
        integer i;
        begin
            @(negedge sysclk);
            UART_RX = 1'b0;
            #(BIT_TIME_NS);

            for (i = 0; i < 8; i = i + 1) begin
                UART_RX = data[i];
                #(BIT_TIME_NS);
            end

            UART_RX = 1'b1;
            #(BIT_TIME_NS * 2);
        end
    endtask

endmodule
