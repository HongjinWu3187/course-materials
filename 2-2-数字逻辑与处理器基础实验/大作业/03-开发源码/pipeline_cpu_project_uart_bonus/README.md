# Pipeline CPU Project for the 2026 Digital Logic Assignment

This directory contains the UART-input bonus version of the five-stage
pipeline MIPS CPU solution.

## What Is Included

- `rtl/cpu/`: five-stage CPU core, control, ALU, register file, forwarding and hazard units.
- `rtl/memory/`: instruction ROM and initialized data RAM.
- `rtl/peripheral/`: seven-segment memory-mapped register and UART RX/TX peripheral.
- `rtl/top/AmplifierSoC.v`: top-level SoC that wires CPU, ROM, RAM, seven-seg and UART.
- `rtl/top/BoardTop.v`: board-facing wrapper for Vivado synthesis and XDC binding.
- `asm/amplifier_fpga.asm`: bare-metal node-amplifier program without syscall.
- `asm/amplifier_program.hex`: generated instruction ROM image.
- `data/amplifier_data.hex`: generated RAM image with the seven-seg lookup table.
- `data/uart_sample_input_bytes.hex`: sample UART hex-mode input bytes.
- `constraints/welog1_pipeline_cpu.xdc`: board constraints for clock, reset, seven-seg and UART.
- `sim/`: RTL testbenches for the full SoC and UART peripheral.
- `tools/`: small assembler and RAM image generator.
- `docs/design_notes.md`: implementation notes and remaining work.

## Memory Map

```text
0x00000000..           Data RAM
0x40000010             Seven-segment peripheral
0x40000018             UART_TXD
0x4000001c             UART_RXD
0x40000020             UART_CON
```

The CPU uses byte addresses. RAM is currently configured as 4096 32-bit words
to leave room for adjacency arrays and recursive DFS stack.

## Rebuild Images

```bash
./tools/build_images.sh
```

This assembles `asm/amplifier_fpga.asm` into `asm/amplifier_program.hex` and
regenerates `data/amplifier_data.hex`.

## Current Verification

The expected sample behavior is:

```text
result = 1
UART input bytes = data/uart_sample_input_bytes.hex
UART output bytes = 00 00 00 01
seven-seg scan values = 0x106, 0x23f, 0x43f, 0x83f
```

RTL testbenches and board XDC are now included, but they still need to be run
inside Vivado or another Verilog simulator.

## Board Top And Constraints

Use `BoardTop` as the Vivado top module for synthesis/implementation. Its
ports are constrained by `constraints/welog1_pipeline_cpu.xdc`:

```text
sysclk   R4   100 MHz
KEY1     B22  active-high reset
UART_RX  B20
UART_TX  A20
leds     seven-segment CA..CG,DP
SEL      digit enables SEL0..SEL3
```

## Simulation

The RTL uses absolute `$readmemh` paths for ROM/RAM initialization:

```text
D:/Downloads/pipeline_cpu_project_uart_bonus/asm/amplifier_program.hex
D:/Downloads/pipeline_cpu_project_uart_bonus/data/amplifier_data.hex
```

If the project is moved on Windows, update `ROM_INIT_FILE` and `RAM_INIT_FILE`
in `rtl/top/AmplifierSoC.v` or the testbench parameter overrides.

## UART Input Protocol

Use the PC serial assistant in hex mode, 9600 baud, 8 data bits, 1 stop bit,
and no parity. Send the theory-assignment input as a stream of 32-bit integers.
Each integer is four bytes, big-endian:

```text
0x00000004 -> 00 00 00 04
```

The stream format is:

```text
n
for node 1..n:
  edge_count
  edge_count pairs of child,length
h
```

For the bundled sample, paste/send `data/uart_sample_input_bytes.hex`. The CPU
then writes the received stream to RAM, runs the algorithm, displays the result
on the seven-seg display, and sends the 32-bit result back over UART.

Provided tests:

```text
sim/tb_amplifier_soc.v
sim/tb_uart_peripheral.v
```
