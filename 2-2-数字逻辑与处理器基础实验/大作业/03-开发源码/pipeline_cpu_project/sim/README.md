# Simulation Files

The provided SoC testbench uses absolute `$readmemh` paths for ROM/RAM
initialization:

```text
D:/Downloads/pipeline_cpu_project/asm/amplifier_program.hex
D:/Downloads/pipeline_cpu_project/data/amplifier_data.hex
```

Provided testbenches:

- `tb_amplifier_soc.v`: full SoC/program test. It overrides UART to
  `CLKS_PER_BIT = 8`, waits for the node-amplifier answer, checks RAM result
  `0x00001b04 == 1`, UART output `0001`, and seven-seg scan state.
- `tb_uart_peripheral.v`: focused UART peripheral TX/RX smoke test.

Filelists from the project root:

- `sim/filelist_tb_amplifier_soc.f`
- `sim/filelist_tb_uart_peripheral.f`

The current environment used to create this project did not include Vivado,
Icarus Verilog, or Verilator, so these testbenches have not yet been compiled
here. Use Vivado xsim or another Verilog simulator for RTL verification.
