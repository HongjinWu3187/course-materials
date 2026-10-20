module InstructionROM #(
    parameter ROM_WORDS = 1024,
    parameter INIT_FILE = "D:/Downloads/pipeline_cpu_project/asm/amplifier_program.hex"
)(
    input  [31:0] addr,
    output [31:0] instr
);

    reg [31:0] rom [0:ROM_WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < ROM_WORDS; i = i + 1)
            rom[i] = 32'h00000000;
        $readmemh(INIT_FILE, rom);
    end

    assign instr = (addr[31:2] < ROM_WORDS) ? rom[addr[31:2]] : 32'h00000000;

endmodule
