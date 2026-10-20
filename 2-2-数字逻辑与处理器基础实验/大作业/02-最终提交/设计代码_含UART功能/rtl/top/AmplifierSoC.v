module AmplifierSoC #(
    parameter ROM_WORDS     = 1024,
    parameter RAM_WORDS     = 4096,
    parameter ROM_INIT_FILE = "D:/Downloads/pipeline_cpu_project_uart_bonus/asm/amplifier_program.hex",
    parameter RAM_INIT_FILE = "D:/Downloads/pipeline_cpu_project_uart_bonus/data/amplifier_data.hex",
    parameter CLKS_PER_BIT  = 10417
)(
    input         clk,
    input         reset,
    input         uart_rx,
    output        uart_tx,
    output [7:0]  seg,
    output [3:0]  an,
    output [31:0] debug_pc,
    output [11:0] debug_sevenseg_value
);

    localparam SEVENSEG_ADDR = 32'h40000010;
    localparam UART_TXD      = 32'h40000018;
    localparam UART_RXD      = 32'h4000001c;
    localparam UART_CON      = 32'h40000020;

    wire [31:0] instr_addr;
    wire [31:0] instr_data;
    wire        data_mem_read;
    wire        data_mem_write;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;

    wire [31:0] ram_rdata;
    wire [31:0] uart_rdata;

    wire ram_selected;
    wire sevenseg_selected;
    wire uart_selected;

    assign ram_selected      = (data_addr[31:30] == 2'b00);
    assign sevenseg_selected = (data_addr == SEVENSEG_ADDR);
    assign uart_selected     = (data_addr == UART_TXD || data_addr == UART_RXD || data_addr == UART_CON);

    assign data_rdata = ram_selected  ? ram_rdata :
                        uart_selected ? uart_rdata :
                                        32'b0;

    PipelineCPU cpu(
        .clk                (clk),
        .reset              (reset),
        .instr_addr         (instr_addr),
        .instr_rdata        (instr_data),
        .data_mem_read      (data_mem_read),
        .data_mem_write     (data_mem_write),
        .data_addr          (data_addr),
        .data_wdata         (data_wdata),
        .data_rdata         (data_rdata),
        .debug_pc           (debug_pc),
        .debug_wb_pc        (),
        .debug_wb_reg_write (),
        .debug_wb_reg       (),
        .debug_wb_data      ()
    );

    InstructionROM #(
        .ROM_WORDS (ROM_WORDS),
        .INIT_FILE (ROM_INIT_FILE)
    ) instruction_rom (
        .addr  (instr_addr),
        .instr (instr_data)
    );

    DataRAM #(
        .RAM_WORDS (RAM_WORDS),
        .INIT_FILE (RAM_INIT_FILE)
    ) data_ram (
        .clk        (clk),
        .mem_read   (data_mem_read && ram_selected),
        .mem_write  (data_mem_write && ram_selected),
        .addr       (data_addr),
        .write_data (data_wdata),
        .read_data  (ram_rdata)
    );

    SevenSegPeripheral sevenseg_peripheral (
        .clk        (clk),
        .reset      (reset),
        .mem_write  (data_mem_write && sevenseg_selected),
        .write_data (data_wdata),
        .seg        (seg),
        .an         (an),
        .raw_value  (debug_sevenseg_value)
    );

    UartPeripheral #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_peripheral (
        .clk        (clk),
        .reset      (reset),
        .mem_read   (data_mem_read && uart_selected),
        .mem_write  (data_mem_write && uart_selected),
        .addr       (data_addr),
        .write_data (data_wdata),
        .read_data  (uart_rdata),
        .uart_rx    (uart_rx),
        .uart_tx    (uart_tx)
    );

endmodule
