module UartPeripheral #(
    parameter CLKS_PER_BIT = 10417
)(
    input         clk,
    input         reset,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output reg [31:0] read_data,
    input         uart_rx,
    output        uart_tx
);

    localparam UART_TXD = 32'h40000018;
    localparam UART_RXD = 32'h4000001c;
    localparam UART_CON = 32'h40000020;

    wire       tx_busy;
    wire       tx_done_pulse;
    reg        tx_start;
    reg [7:0]  tx_data;

    wire [7:0] rx_data_wire;
    wire       rx_done_pulse;
    reg [7:0]  rx_data_reg;
    reg        rx_ready;
    reg        tx_done_flag;

    UartTx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_tx_unit (
        .clk   (clk),
        .reset (reset),
        .start (tx_start),
        .data  (tx_data),
        .tx    (uart_tx),
        .busy  (tx_busy),
        .done  (tx_done_pulse)
    );

    UartRx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_unit (
        .clk   (clk),
        .reset (reset),
        .rx    (uart_rx),
        .data  (rx_data_wire),
        .done  (rx_done_pulse)
    );

    always @(*) begin
        case (addr)
            UART_RXD: read_data = {24'b0, rx_data_reg};
            UART_CON: read_data = {27'b0, tx_busy, rx_ready, tx_done_flag, 2'b00};
            default:  read_data = 32'b0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start     <= 1'b0;
            tx_data      <= 8'b0;
            rx_data_reg  <= 8'b0;
            rx_ready     <= 1'b0;
            tx_done_flag <= 1'b1;
        end else begin
            tx_start <= 1'b0;

            if (rx_done_pulse) begin
                rx_data_reg <= rx_data_wire;
                rx_ready    <= 1'b1;
            end

            if (tx_done_pulse)
                tx_done_flag <= 1'b1;

            if (mem_write && addr == UART_TXD && !tx_busy) begin
                tx_data      <= write_data[7:0];
                tx_start     <= 1'b1;
                tx_done_flag <= 1'b0;
            end

            if (mem_read && addr == UART_CON) begin
                tx_done_flag <= 1'b0;
                rx_ready     <= 1'b0;
            end
        end
    end

endmodule
