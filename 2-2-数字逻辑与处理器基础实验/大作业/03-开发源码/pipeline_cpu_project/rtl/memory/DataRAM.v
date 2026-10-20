module DataRAM #(
    parameter RAM_WORDS = 4096,
    parameter INIT_FILE = "D:/Downloads/pipeline_cpu_project/data/amplifier_data.hex"
)(
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] ram [0:RAM_WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < RAM_WORDS; i = i + 1)
            ram[i] = 32'h00000000;
        $readmemh(INIT_FILE, ram);
    end

    assign read_data = (mem_read && addr[31:2] < RAM_WORDS) ? ram[addr[31:2]] : 32'h00000000;

    always @(posedge clk) begin
        if (mem_write && addr[31:2] < RAM_WORDS)
            ram[addr[31:2]] <= write_data;
    end

endmodule
