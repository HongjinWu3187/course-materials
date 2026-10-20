# Design Notes

## Pipeline CPU

The CPU implements the classic five stages:

```text
IF -> ID -> EX -> MEM -> WB
```

The implemented pipeline registers are:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

Hazard handling currently includes:

- EX/MEM to EX forwarding for ALU and link results.
- MEM/WB to EX forwarding for ALU, memory and link results.
- One-cycle load-use stall.
- Extra stall for `jr`/`jalr` when the jump target register is still pending.
- EX-stage branch decision and IF/ID plus ID/EX flush on taken branches.
- ID-stage jump decision and IF/ID flush on jumps.

This implementation uses no architectural delay slot. `jal` and `jalr` write
`PC + 4`, matching the flush behavior used here.

## Supported Instructions

Implemented instruction subset:

```text
lw, sw, lui
add, addu, sub, subu, addi, addiu
and, or, xor, nor, andi, ori, xori
sll, srl, sra
slt, sltu, slti, sltiu
beq, bne, blez, bgtz, bltz, bgez
j, jal, jr, jalr
mul
nop
```

`ori` and `xori` are included because they are useful for constructing
memory-mapped peripheral addresses.

## Node-Amplifier Program

`asm/amplifier_fpga.asm` is a bare-metal version of the MARS DFS solution:

- No `syscall`.
- Input is read from RAM word stream starting at `0x00000000`.
- Arrays are stored in RAM at fixed byte addresses.
- The answer is stored at `0x00001b04`.
- UART sends the low 16-bit answer as four hex characters.
- Seven-segment display scans four hex digits forever.

The seven-segment conversion is software lookup only. The table at
`0x00001a00` stores segment patterns for `0..F`; Verilog only latches the
already-decoded value written by software.

## UART Peripheral

UART is memory mapped:

```text
0x40000018  UART_TXD
0x4000001c  UART_RXD
0x40000020  UART_CON
```

`UART_CON` bits:

```text
bit 2  tx_done flag
bit 3  rx_ready flag
bit 4  tx_busy
```

The default baud setting assumes:

```text
100 MHz / 9600 baud = 10417 clocks per bit
```

## Remaining Work

- Run Vivado synthesis/implementation and fix any tool-specific syntax issues.
- Add post-synthesis or post-implementation timing simulation.
- Record CPI and Fmax for the report.

## Board Constraints Added

`constraints/welog1_pipeline_cpu.xdc` binds `BoardTop` to the course board
pins found in the spring experiment guides:

```text
sysclk -> R4
KEY1   -> B22
UART_RX -> B20
UART_TX -> A20
leds[0..7] -> CA, CB, CC, CD, CE, CF, CG, DP
SEL[0..3] -> SEL0, SEL1, SEL2, SEL3
```

`BoardTop` intentionally hides debug-only ports from the board-level top so
Vivado does not require physical constraints for them.
