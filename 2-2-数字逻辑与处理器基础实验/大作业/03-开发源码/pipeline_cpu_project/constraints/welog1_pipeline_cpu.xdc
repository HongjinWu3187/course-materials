## XDC for BoardTop on the course WELOG1 / xc7a35tfgg484-1 board.
## Sources:
## - Spring Experiment 1: system_clk R4, KEY1 B22, seven-seg CA..CG and SEL1..SEL4.
## - Spring Experiment 2: DP V3 and physical digit-enable pins M2/P2/R1/Y3.
## - Spring Experiment 3: UART_RX B20, UART_TX A20.
## - 02_春季学期小实验参考/BCD译码器xdc参考.xdc style.

## 100 MHz global clock
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {sysclk}]
create_clock -name sysclk -period 10.000 [get_ports {sysclk}]

## Active-high reset. KEY1 is high when pressed in the course guides.
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS33} [get_ports {KEY1}]

## UART through the FT2232 USB-UART bridge
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {UART_RX}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports {UART_TX}]

## Seven-segment segments: leds[7:0] = {DP, CG, CF, CE, CD, CC, CB, CA} by bit index
## Software writes bit0..bit7 as {CA, CB, CC, CD, CE, CF, CG, DP}.
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {leds[0]}] ;# CA
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {leds[1]}] ;# CB
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {leds[2]}] ;# CC
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {leds[3]}] ;# CD
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {leds[4]}] ;# CE
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {leds[5]}] ;# CF
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {leds[6]}] ;# CG
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {leds[7]}] ;# DP

## Digit enables, active high. Logical SEL[0] is the lowest/rightmost digit.
## The board's physical order is reversed, so logical SEL is mapped right to left.
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVCMOS33} [get_ports {SEL[0]}] ;# lowest/rightmost digit
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {SEL[1]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {SEL[2]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {SEL[3]}] ;# highest/leftmost digit

## Conservative output slew/drive settings for simple board I/O.
set_property SLEW SLOW [get_ports {UART_TX}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {SEL[*]}]
set_property DRIVE 8 [get_ports {UART_TX}]
set_property DRIVE 8 [get_ports {leds[*]}]
set_property DRIVE 8 [get_ports {SEL[*]}]
