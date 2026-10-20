// Simulation-only implementation top.

module BoardTop_sim(
    input        sysclk,
    input        KEY1,
    input        UART_RX,
    output       UART_TX,
    output [7:0] leds,
    output [3:0] SEL
);

    localparam integer CLKS_PER_BIT_SIM = 16;

    wire [31:0] debug_pc_unused;
    wire [11:0] debug_sevenseg_unused;

    AmplifierSoC #(
        .CLKS_PER_BIT(CLKS_PER_BIT_SIM)
    ) soc (
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
