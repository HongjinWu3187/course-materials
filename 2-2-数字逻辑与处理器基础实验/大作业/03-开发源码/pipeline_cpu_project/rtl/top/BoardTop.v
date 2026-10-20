module BoardTop(
    input        sysclk,
    input        KEY1,
    input        UART_RX,
    output       UART_TX,
    output [7:0] leds,
    output [3:0] SEL
);

    wire [31:0] debug_pc_unused;
    wire [11:0] debug_sevenseg_unused;

    AmplifierSoC soc(
        .clk                  (sysclk),
        .reset                (KEY1),
        .uart_rx              (UART_RX),
        .uart_tx              (UART_TX),
        .seg                  (leds),
        .an                   (SEL),
        .debug_pc             (debug_pc_unused),
        .debug_sevenseg_value (debug_sevenseg_unused)
    );

endmodule
