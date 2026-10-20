`timescale 1ns/1ps

module tb_uart_peripheral;

    localparam integer CLKS_PER_BIT_SIM = 8;
    localparam [31:0] UART_TXD = 32'h40000018;
    localparam [31:0] UART_RXD = 32'h4000001c;
    localparam [31:0] UART_CON = 32'h40000020;

    reg clk;
    reg reset;
    reg mem_read;
    reg mem_write;
    reg [31:0] addr;
    reg [31:0] write_data;
    reg uart_rx;

    wire [31:0] read_data;
    wire uart_tx;

    reg [7:0] decoded_tx;
    reg [31:0] read_value;

    UartPeripheral #(
        .CLKS_PER_BIT(CLKS_PER_BIT_SIM)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .addr       (addr),
        .write_data (write_data),
        .read_data  (read_data),
        .uart_rx    (uart_rx),
        .uart_tx    (uart_tx)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        mem_read = 1'b0;
        mem_write = 1'b0;
        addr = 32'b0;
        write_data = 32'b0;
        uart_rx = 1'b1;

        repeat (8) @(posedge clk);
        reset = 1'b0;
        repeat (4) @(posedge clk);

        bus_write(UART_TXD, 32'h00000041);
        wait_uart_tx_byte(decoded_tx);
        if (decoded_tx != 8'h41) begin
            $display("FAIL: UART TX expected 0x41, got 0x%02h", decoded_tx);
            $finish;
        end

        drive_uart_rx_byte(8'h5a);
        repeat (4) @(posedge clk);
        bus_read(UART_RXD, read_value);
        if (read_value[7:0] != 8'h5a) begin
            $display("FAIL: UART RX expected 0x5a, got 0x%02h", read_value[7:0]);
            $finish;
        end

        bus_read(UART_CON, read_value);
        if (read_value[3] != 1'b1) begin
            $display("FAIL: UART_CON rx_ready bit was not set before clear: %h", read_value);
            $finish;
        end

        repeat (2) @(posedge clk);
        bus_read(UART_CON, read_value);
        if (read_value[3] != 1'b0) begin
            $display("FAIL: UART_CON rx_ready bit did not clear after read: %h", read_value);
            $finish;
        end

        $display("PASS: UART peripheral TX/RX");
        $finish;
    end

    task bus_write;
        input [31:0] bus_addr;
        input [31:0] bus_data;
        begin
            @(negedge clk);
            addr = bus_addr;
            write_data = bus_data;
            mem_write = 1'b1;
            mem_read = 1'b0;
            @(posedge clk);
            @(negedge clk);
            mem_write = 1'b0;
            addr = 32'b0;
            write_data = 32'b0;
        end
    endtask

    task bus_read;
        input [31:0] bus_addr;
        output [31:0] bus_data;
        begin
            @(negedge clk);
            addr = bus_addr;
            mem_read = 1'b1;
            mem_write = 1'b0;
            #1 bus_data = read_data;
            @(posedge clk);
            @(negedge clk);
            mem_read = 1'b0;
            addr = 32'b0;
        end
    endtask

    task wait_uart_tx_byte;
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
            repeat (CLKS_PER_BIT_SIM) @(posedge clk);
        end
    endtask

endmodule
