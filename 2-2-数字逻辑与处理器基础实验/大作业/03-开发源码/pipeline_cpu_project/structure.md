# 2026 数字逻辑与处理器实验目录结构说明

本文说明 `/Users/hongjinwu/Downloads/2026数逻` 文件夹的资料结构、工程结构，以及各源文件在流水线 CPU 大作业中的作用。

本目录的核心目标是完成 2026 夏季学期数字逻辑与处理器实验综合大作业：实现一个五级流水线 MIPS CPU，在该 CPU 上运行“节点放大器”MIPS 程序，并通过 RAM 初始化、软件七段译码、UART/数码管外设完成验收要求。

隐藏文件 `.DS_Store` 是 macOS 自动生成的目录元数据，不属于工程资料或源码，本文不再逐项说明。

## 1. 顶层结构

```text
2026数逻/
  00_综合实验要求_流水线MIPS处理器设计_2026夏.pdf
  01_课程绪论与流水线CPU要求_2026夏.pdf
  02_春季学期小实验参考/
  03_理论课汇编大作业_节点放大器_2026春/
  04_参考资料_单周期MIPS处理器大作业_2024春答案/
  05_Codex完成流水线CPU大作业的任务Prompt与约束.md
  pipeline_cpu_project/
  structure.md
```

### 顶层文件和文件夹说明

| 路径 | 内容 | 在工程中的地位 |
|---|---|---|
| `00_综合实验要求_流水线MIPS处理器设计_2026夏.pdf` | 2026 夏综合实验正式指导书。 | 最权威的需求来源，定义流水线 CPU、外设地址、前仿/后仿、报告、验收、评分标准。 |
| `01_课程绪论与流水线CPU要求_2026夏.pdf` | 综合实验介绍课件。 | 对指导书的课堂解释，补充指令集、测试数据、数码管显示、CPI、Fmax、现场验收方式。 |
| `02_春季学期小实验参考/` | 春季基础实验指导书和一个 BCD 七段译码器 XDC。 | 提供板卡管脚信息、UART 管脚、数码管管脚、100MHz 时钟和按键约束参考。 |
| `03_理论课汇编大作业_节点放大器_2026春/` | 理论课 MIPS 汇编作业资料、节点放大器汇编和样例数据。 | 算法来源。流水线 CPU 要执行的程序来自这里，但需改造成裸机版本。 |
| `04_参考资料_单周期MIPS处理器大作业_2024春答案/` | 往年单周期 CPU 参考答案、MIPS 手册、参考 RTL。 | 只能作为模块划分、控制信号、单周期实现的参考；本次工程必须改造为五级流水线。 |
| `05_Codex完成流水线CPU大作业的任务Prompt与约束.md` | 给后续 Codex 的详细任务 prompt 和约束。 | 工程规格说明，明确作业目标、实现路线、禁止事项和提高要求。 |
| `pipeline_cpu_project/` | 当前实现的五级流水线 CPU 工程。 | 本目录下最重要的可开发工程，包含 RTL、汇编、初始化文件、约束、仿真和工具脚本。 |
| `structure.md` | 本文件。 | 目录和源码说明文档。 |

## 2. 春季小实验参考资料

```text
02_春季学期小实验参考/
  BCD译码器xdc参考.xdc
  实验1_计数器与序列检测器.pdf
  实验2_反应速度测试仪.pdf
  实验3_UART与存储.pdf
  实验4-IP核.pdf
```

| 文件 | 内容 | 对当前工程的作用 |
|---|---|---|
| `BCD译码器xdc参考.xdc` | BCD 七段译码器实验的约束文件。 | 约束文件写法参考；提供 LED/拨码开关/数码管管脚风格。注意当前工程不得使用硬件 BCD 译码。 |
| `实验1_计数器与序列检测器.pdf` | 计数器、序列检测器、按键、数码管基础实验。 | 提供系统时钟 `R4`、按键 `KEY1 B22`、`KEY2 B21`、数码管段选和位选等管脚信息。 |
| `实验2_反应速度测试仪.pdf` | 反应速度测试仪实验。 | 提供 100MHz 时钟、4 位七段数码管扫描、`leds[7:0]` 和 `SEL[3:0]` 的管脚顺序。 |
| `实验3_UART与存储.pdf` | UART 与存储器实验。 | 提供 UART_RX `B20`、UART_TX `A20`、波特率、串口调试方式、ROM/RAM 使用方式。 |
| `实验4-IP核.pdf` | Vivado IP、PLL、RAM IP 使用说明。 | 若后续 100MHz 时序不满足，可参考 Clocking Wizard 降频；当前工程先按 100MHz 设计。 |

## 3. 理论课汇编大作业资料

```text
03_理论课汇编大作业_节点放大器_2026春/
  00_MIPS汇编实验指导书_2026春.pdf
  01_节点放大器_MARS汇编实现_exp2_2.asm
  02_节点放大器_题面与测试样例/
    00_节点放大器_伪代码与算法说明.txt
    01_节点放大器_样例输入_小端32位整数.dat
    02_节点放大器_样例输出_期望答案.dat
```

### `00_MIPS汇编实验指导书_2026春.pdf`

- 主要功能：理论课汇编实验指导书，介绍 MIPS 汇编语法、伪指令、数据段、过程调用、系统调用和 MARS 使用方式。
- 实现方式：课程 PDF 资料，不参与综合。
- 输入输出：无硬件 I/O；用于人工阅读。
- 工程地位：帮助理解理论课 MIPS 程序如何运行，尤其是 MARS 中的 `syscall`、`.data`、栈、寄存器约定。

### `01_节点放大器_MARS汇编实现_exp2_2.asm`

- 主要功能：理论课节点放大器的 MARS 汇编实现。
- 实现方式：使用 MIPS 汇编，在 MARS 中通过 `syscall` 打开 `test.dat`、读取文件、递归 DFS、打印结果。
- 输入：MARS 工作目录中的二进制测试文件。
- 输出：通过 MARS `syscall` 打印整数结果。
- 工程地位：算法和寄存器使用的重要参考，但不能直接上 FPGA。当前工程的 `pipeline_cpu_project/asm/amplifier_fpga.asm` 是它的裸机改造版本。

### `02_节点放大器_题面与测试样例/00_节点放大器_伪代码与算法说明.txt`

- 主要功能：说明节点放大器算法流程。
- 实现方式：文本伪代码，描述读取输入、初始化数组、DFS、更新 `f[u]` 和 `g[u]`、输出答案。
- 输入输出：无直接 I/O。
- 工程地位：算法正确性的根本依据。

### `02_节点放大器_题面与测试样例/01_节点放大器_样例输入_小端32位整数.dat`

- 主要功能：理论课样例输入数据。
- 实现方式：二进制文件，按小端 32 位整数存储。
- 输入输出：作为程序输入；样例解码为 `4, 2, 2, 3, ... , 4`。
- 工程地位：当前 `pipeline_cpu_project/data/amplifier_data.hex` 中 RAM 初始数据的来源。

### `02_节点放大器_题面与测试样例/02_节点放大器_样例输出_期望答案.dat`

- 主要功能：样例期望输出。
- 实现方式：文本/数据文件，内容为答案 `1`。
- 输入输出：作为校验结果。
- 工程地位：仿真和 ISA 级验证的参考答案。

## 4. 单周期 MIPS 参考工程

```text
04_参考资料_单周期MIPS处理器大作业_2024春答案/
  00_单周期MIPS处理器设计说明_2024春.pdf
  01_单周期MIPS处理器评分标准_2024春.pdf
  02_MIPS32架构简介_英文.pdf
  03_MIPS32指令集手册_英文.pdf
  04_单周期参考工程约束_xc7a35tcsg324_2024.xdc
  10_单周期CPU参考RTL工程/
```

这些资料说明了如何实现单周期 MIPS CPU。当前大作业要求五级流水线，因此只能参考，不可直接提交。

### 参考 RTL 文件

| 文件 | 主要功能 | 实现方式 | 输入输出 | 工程地位 |
|---|---|---|---|---|
| `CPU_single_cycle_top.v` | 单周期 CPU 顶层。 | 一个 PC 寄存器加组合数据通路，在一个周期内完成取指、译码、执行、访存、写回。 | 输入 `reset/clk/Device_Read_Data`；输出访存总线信号。 | 当前流水线 CPU 的对照参考；不能作为最终 CPU。 |
| `Control_decoder_single_cycle.v` | 单周期控制器。 | 根据 `OpCode/Funct` 组合译码，生成 `PCSrc/RegWrite/MemRead/MemWrite/ALUOp` 等控制信号。 | 输入指令 opcode/funct；输出控制信号。 | 当前 `ControlUnit.v` 的思路参考，但流水线控制信号需要分阶段寄存。 |
| `ALU_integer_ops.v` | 整数 ALU。 | 组合逻辑实现加减、逻辑、移位、比较、乘法等。 | 输入两个操作数、ALU 控制码；输出结果和 zero。 | 当前 `ALU.v` 的直接参考之一。 |
| `ALU_control_decoder.v` | ALU 控制译码。 | 根据 `ALUOp/Funct` 生成 ALU 操作码。 | 输入主控制器 ALUOp 和 funct；输出 ALUCtl/Sign。 | 当前工程将类似逻辑合入 `ControlUnit.v` 的 `alu_ctl` 输出。 |
| `RegisterFile_32x32.v` | 32 个 MIPS 通用寄存器。 | 组合读、时钟上升沿写，`$zero` 固定为 0。 | 输入读寄存器号、写寄存器号、写数据；输出两个读端口。 | 当前 `RegisterFile.v` 的参考。 |
| `InstructionMemory_case_rom_template.v` | 指令 ROM 模板。 | 使用 `case(Address[9:2])` 输出指令。 | 输入字节地址；输出 32 位指令。 | 当前工程改用数组式 `InstructionROM.v`，通过绝对路径 `$readmemh` 初始化。 |
| `DataMemory_reset_init_ram.v` | 单周期数据 RAM。 | Verilog 数组，复位时初始化，读写按地址索引。 | 输入地址、写数据、读写控制；输出读数据。 | 当前 `DataRAM.v` 的参考；当前工程通过绝对路径 `$readmemh` 初始化。 |
| `tb_single_cycle_cpu.v` | 单周期 CPU 仿真顶层。 | 生成时钟/复位，实例化单周期 CPU。 | 无外部输入；观察内部波形。 | 当前 `tb_amplifier_soc.v` 的仿真风格参考。 |
| `program_q1_1_machine_code_snippet.txt` | 往年题 1-1 机器码片段。 | 文本机器码。 | 供 ROM 粘贴。 | 单周期参考工程测试数据。 |
| `program_q1_2_machine_code_snippet.txt` | 往年题 1-2 机器码片段。 | 文本机器码。 | 供 ROM 粘贴。 | 单周期参考工程测试数据。 |
| `data_q1_initial_ram_snippet.txt` | 往年题 RAM 初始化片段。 | 文本初始化语句。 | 供 DataMemory 粘贴。 | 单周期参考工程测试数据。 |

## 5. Codex 任务 Prompt 文件

### `05_Codex完成流水线CPU大作业的任务Prompt与约束.md`

- 主要功能：给后续 Codex 或开发者的完整任务说明。
- 实现方式：Markdown 文档。
- 输入输出：无硬件 I/O。
- 工程地位：定义大作业的实现边界，包括五级流水线、forwarding、stall、flush、RAM 初始化、软件七段译码、UART 提高要求、仿真和验收要求。

## 6. `pipeline_cpu_project/` 工程总览

```text
pipeline_cpu_project/
  README.md
  asm/
  constraints/
  data/
  docs/
  rtl/
  sim/
  tools/
```

### 目录职责

| 目录 | 内容 | 工程地位 |
|---|---|---|
| `README.md` | 工程快速说明。 | 给开发者和 Vivado 使用者的入口说明。 |
| `asm/` | 裸机 MIPS 汇编和生成后的机器码。 | 算法程序层。CPU 执行的指令来自这里。 |
| `constraints/` | 板级 XDC 约束。 | Vivado 综合实现和上板必须使用。 |
| `data/` | RAM 初始化镜像。 | 输入数据、数组初值、软件七段译码查表数据来源。 |
| `docs/` | 工程设计说明。 | 解释设计选择、剩余工作、板级约束来源。 |
| `rtl/` | Verilog 源码。 | CPU、存储器、外设和顶层 SoC 的主体。 |
| `sim/` | 仿真文件。 | 前仿验证入口。 |
| `tools/` | 生成机器码和 RAM 镜像的工具脚本。 | 保证汇编和初始化文件可复现。 |

## 7. 汇编和机器码文件

### `pipeline_cpu_project/asm/amplifier_fpga.asm`

- 主要功能：节点放大器算法的 FPGA 裸机 MIPS 程序。
- 实现方式：
  - 从 RAM 地址 `0x0000` 顺序读取输入整数。
  - 构建邻接表数组 `head/to_arr/len_arr/next_arr`。
  - 通过递归 `dfs` 计算 `f[u]` 和 `g[u]`。
  - 结果存入 RAM 地址 `0x1b04`。
  - 通过 UART 输出低 16 位十六进制字符串。
  - 进入 `display_loop`，用 RAM 中的七段码查表软件扫描 4 位数码管。
- 主要输入：
  - RAM 中的输入整数流。
  - RAM 中 `display_lut[16]` 七段码表。
- 主要输出：
  - RAM `0x1b04` 中的答案。
  - 对外设地址 `0x40000018` 写 UART 字符。
  - 对外设地址 `0x40000010` 写数码管段选/位选值。
- 工程地位：这是 CPU 实际运行的算法程序。它不含 `syscall`，符合 FPGA 裸机运行要求。
- 重要标签：
  - `main`：程序入口。
  - `dfs`：递归 DFS 子程序。
  - `program_done`：保存结果并调用 UART 输出。
  - `display_loop`：软件七段查表和动态扫描。
  - `uart_send_hex16` / `uart_send_nibble`：UART 十六进制输出。

### `pipeline_cpu_project/asm/amplifier_program.hex`

- 主要功能：指令 ROM 初始化文件。
- 实现方式：每行一个 32 位 MIPS 机器码十六进制 word，由 `tools/assemble_mips.py` 从 `amplifier_fpga.asm` 生成。
- 输入：无运行时输入；由 Verilog `$readmemh` 通过绝对路径 `D:/Downloads/pipeline_cpu_project/asm/amplifier_program.hex` 读取。
- 输出：作为 `InstructionROM` 的内容。
- 工程地位：CPU 取指执行的真实程序镜像。

## 8. RAM 初始化文件

### `pipeline_cpu_project/data/amplifier_data.hex`

- 主要功能：数据 RAM 初始化文件。
- 实现方式：每行一个 32 位 word，共 4096 行，由 `tools/generate_data_image.py` 生成。
- 主要内容：
  - 起始区域：节点放大器样例输入整数流。
  - `0x1a00`：`0-F` 的七段码软件查表。
  - 其他区域：初始化为 0，供程序运行时写数组、结果和栈。
- 输入：无运行时输入；由 Verilog `$readmemh` 通过绝对路径 `D:/Downloads/pipeline_cpu_project/data/amplifier_data.hex` 读取。
- 输出：作为 `DataRAM` 初始内容。
- 工程地位：满足老师“测试数据推荐放 RAM 初始化”的要求，验收换数据时应优先修改此镜像或生成脚本。

## 9. RTL CPU 源文件

### `pipeline_cpu_project/rtl/cpu/ALU.v`

- 模块名：`ALU`
- 主要功能：实现整数算术逻辑运算。
- 实现方式：组合逻辑 `case(alu_ctl)`，支持 `and/or/add/sub/slt/nor/xor/sll/srl/sra/sltu`；`mul` 通路保留参数接口但默认关闭，以减轻 100MHz 上板时序压力。
- 输入：
  - `in1[31:0]`：操作数 1。
  - `in2[31:0]`：操作数 2。
  - `alu_ctl[4:0]`：ALU 操作选择。
- 输出：
  - `out[31:0]`：运算结果。
  - `zero`：结果是否为 0。
- 工程地位：流水线 EX 阶段核心组合逻辑。

### `pipeline_cpu_project/rtl/cpu/RegisterFile.v`

- 模块名：`RegisterFile`
- 主要功能：实现 MIPS 32 个通用寄存器。
- 实现方式：
  - `regs[31:1]` 保存 1-31 号寄存器。
  - `$zero` 通过组合逻辑固定读为 0。
  - 时钟上升沿写回。
  - 组合读包含同周期写回旁路，减少 WB/ID 读写冲突。
- 输入：
  - `clk/reset`
  - `reg_write`
  - `read_reg1/read_reg2`
  - `write_reg/write_data`
- 输出：
  - `read_data1/read_data2`
- 工程地位：流水线 ID 阶段读寄存器、WB 阶段写回的共享寄存器堆。

### `pipeline_cpu_project/rtl/cpu/ControlUnit.v`

- 模块名：`ControlUnit`
- 主要功能：指令译码并产生流水线控制信号。
- 实现方式：
  - 根据 `instr[31:26]` opcode、`instr[5:0]` funct、`rt` 字段组合译码。
  - 直接生成寄存器写、访存、写回来源、ALU 操作、立即数扩展、分支类型、跳转类型、源寄存器使用情况。
- 输入：
  - `instr[31:0]`
- 输出：
  - `reg_write`
  - `reg_dst`
  - `mem_read/mem_write`
  - `result_src`
  - `alu_src1_shamt/alu_src2_imm`
  - `imm_zero_ext/imm_lui`
  - `alu_ctl`
  - `branch_type`
  - `jump_type`
  - `uses_rs/uses_rt`
- 支持指令：
  - `lw/sw/lui`
  - `add/addu/sub/subu/addi/addiu`
  - `and/or/xor/nor/andi/ori/xori`
  - `sll/srl/sra`
  - `slt/sltu/slti/sltiu`
  - `beq/bne/blez/bgtz/bltz/bgez`
  - `j/jal/jr/jalr`
  - `mul`
  - `nop`
- 工程地位：ID 阶段控制中心，输出信号会进入 ID/EX 流水线寄存器。

### `pipeline_cpu_project/rtl/cpu/ForwardingUnit.v`

- 模块名：`ForwardingUnit`
- 主要功能：解决常规数据冒险。
- 实现方式：
  - 比较 ID/EX 阶段源寄存器与 EX/MEM、MEM/WB 阶段目的寄存器。
  - EX/MEM 优先于 MEM/WB。
  - 对 load 指令结果不从 EX/MEM 提前转发，因为 load 数据在 MEM 后才有效。
- 输入：
  - `id_ex_rs/id_ex_rt`
  - `ex_mem_reg_write/ex_mem_can_forward/ex_mem_write_reg`
  - `mem_wb_reg_write/mem_wb_write_reg`
- 输出：
  - `forward_a[1:0]`
  - `forward_b[1:0]`
- 工程地位：EX 阶段 ALU 输入选择控制，支撑 forwarding 要求。

### `pipeline_cpu_project/rtl/cpu/HazardUnit.v`

- 模块名：`HazardUnit`
- 主要功能：检测必须暂停的冒险。
- 实现方式：
  - 检测 load-use：ID 阶段指令使用 ID/EX 中 `lw` 的目标寄存器时暂停。
  - 检测 `jr/jalr` 目标寄存器尚在 EX/MEM 前面的情况，避免 ID 阶段过早取错跳转目标。
- 输入：
  - `id_ex_mem_read/id_ex_rt`
  - `if_id_rs/if_id_rt`
  - `if_id_uses_rs/if_id_uses_rt`
  - `if_id_jump_reg`
  - `id_ex_reg_write/id_ex_write_reg`
  - `ex_mem_reg_write/ex_mem_write_reg`
- 输出：
  - `stall`
- 工程地位：控制 PC 和 IF/ID 是否冻结、ID/EX 是否插入 bubble。

### `pipeline_cpu_project/rtl/cpu/PipelineCPU.v`

- 模块名：`PipelineCPU`
- 主要功能：五级流水线 MIPS CPU 核心。
- 实现方式：
  - IF：PC、取指地址、PC+4。
  - ID：指令译码、寄存器读取、立即数扩展、跳转目标生成。
  - EX：ALU 运算、branch 判断、branch target 计算、forwarding。
  - MEM：输出数据总线读写控制。
  - WB：选择 ALU/MEM/LINK 结果写回寄存器堆。
  - 包含 IF/ID、ID/EX、EX/MEM、MEM/WB 流水线寄存器。
  - branch 在 EX 阶段判断，taken 时 flush IF/ID 和 ID/EX。
  - jump 在 ID 阶段处理，flush IF/ID。
- 输入：
  - `clk/reset`
  - `instr_rdata`
  - `data_rdata`
- 输出：
  - `instr_addr`
  - `data_mem_read/data_mem_write`
  - `data_addr/data_wdata`
  - 调试信号 `debug_pc/debug_wb_*`
- 工程地位：整个处理器系统的 CPU 核心，由 `AmplifierSoC` 例化。

## 10. RTL 存储器源文件

### `pipeline_cpu_project/rtl/memory/InstructionROM.v`

- 模块名：`InstructionROM`
- 主要功能：指令存储器。
- 实现方式：
  - Verilog 数组 `rom[0:ROM_WORDS-1]`。
  - `initial` 中先清零，再 `$readmemh(INIT_FILE, rom)`。
  - 默认 `INIT_FILE` 为 `D:/Downloads/pipeline_cpu_project/asm/amplifier_program.hex`。
  - 用 `addr[31:2]` 将字节地址转换为 word 索引。
- 输入：
  - `addr[31:0]`
- 输出：
  - `instr[31:0]`
- 参数：
  - `ROM_WORDS`
  - `INIT_FILE`
- 工程地位：哈佛结构中的指令 ROM，为 IF 阶段提供指令。

### `pipeline_cpu_project/rtl/memory/DataRAM.v`

- 模块名：`DataRAM`
- 主要功能：数据存储器。
- 实现方式：
  - Verilog 数组 `ram[0:RAM_WORDS-1]`。
  - `initial` 中先清零，再 `$readmemh(INIT_FILE, ram)`。
  - 默认 `INIT_FILE` 为 `D:/Downloads/pipeline_cpu_project/data/amplifier_data.hex`。
  - 组合读、时钟上升沿写。
  - 用 `addr[31:2]` 做 word 索引。
- 输入：
  - `clk`
  - `mem_read/mem_write`
  - `addr`
  - `write_data`
- 输出：
  - `read_data`
- 参数：
  - `RAM_WORDS`
  - `INIT_FILE`
- 工程地位：数据地址空间 `0x00000000` 起始区域，存放输入、数组、结果、栈、七段查表。

## 11. RTL 外设源文件

### `pipeline_cpu_project/rtl/peripheral/SevenSegPeripheral.v`

- 模块名：`SevenSegPeripheral`
- 主要功能：七段数码管外设寄存器。
- 实现方式：
  - 只锁存 CPU 写入的 `write_data[11:0]`。
  - `value[7:0]` 输出到段选，`value[11:8]` 输出到位选。
  - 不包含任何数字到七段码的硬件译码。
- 输入：
  - `clk/reset`
  - `mem_write`
  - `write_data`
- 输出：
  - `seg[7:0]`
  - `an[3:0]`
  - `raw_value[11:0]`
- 工程地位：映射到 `0x40000010`。满足“软件方式七段译码”的硬件端口。

### `pipeline_cpu_project/rtl/peripheral/UartTx.v`

- 模块名：`UartTx`
- 主要功能：UART 发送器。
- 实现方式：
  - 有限状态机：`IDLE -> START -> DATA -> STOP`。
  - 按 `CLKS_PER_BIT` 对每一位计时。
  - 低位优先发送 8 位数据。
- 输入：
  - `clk/reset`
  - `start`
  - `data[7:0]`
- 输出：
  - `tx`
  - `busy`
  - `done`
- 工程地位：UART 外设的发送子模块，供 CPU 写 `0x40000018` 触发发送。

### `pipeline_cpu_project/rtl/peripheral/UartRx.v`

- 模块名：`UartRx`
- 主要功能：UART 接收器。
- 实现方式：
  - 双触发器同步输入 `rx`。
  - 有限状态机检测起始位、按位采样 8 个数据位、等待停止位。
  - 低位优先接收。
- 输入：
  - `clk/reset`
  - `rx`
- 输出：
  - `data[7:0]`
  - `done`
- 工程地位：UART 外设的接收子模块，支持提高要求中的串口输入。

### `pipeline_cpu_project/rtl/peripheral/UartPeripheral.v`

- 模块名：`UartPeripheral`
- 主要功能：把 UART TX/RX 包装为 CPU 可访问的内存映射外设。
- 实现方式：
  - 例化 `UartTx` 和 `UartRx`。
  - 地址 `0x40000018`：写低 8 位触发 UART 发送。
  - 地址 `0x4000001c`：读接收到的低 8 位数据。
  - 地址 `0x40000020`：读状态寄存器。
  - `UART_CON` bit2 为发送完成标志，bit3 为接收完成标志，bit4 为发送忙。
  - 读 `UART_CON` 后清除完成标志。
- 输入：
  - CPU 总线：`mem_read/mem_write/addr/write_data`
  - 串口输入：`uart_rx`
- 输出：
  - CPU 读数据：`read_data`
  - 串口输出：`uart_tx`
- 工程地位：映射到 `0x40000018`、`0x4000001c`、`0x40000020`，实现 UART 提高要求的硬件基础。

## 12. RTL 顶层源文件

### `pipeline_cpu_project/rtl/top/AmplifierSoC.v`

- 模块名：`AmplifierSoC`
- 主要功能：片上系统顶层，连接 CPU、ROM、RAM、数码管和 UART。
- 实现方式：
  - 例化 `PipelineCPU`。
  - 例化 `InstructionROM` 和 `DataRAM`。
  - 例化 `SevenSegPeripheral` 和 `UartPeripheral`。
  - 根据 CPU 数据地址做地址译码：
    - `0x00000000` 起始区域映射 RAM。
    - `0x40000010` 映射七段数码管。
    - `0x40000018/1c/20` 映射 UART。
- 输入：
  - `clk/reset`
  - `uart_rx`
- 输出：
  - `uart_tx`
  - `seg[7:0]`
  - `an[3:0]`
  - 调试信号 `debug_pc/debug_sevenseg_value`
- 参数：
  - `ROM_WORDS/RAM_WORDS`
  - `ROM_INIT_FILE/RAM_INIT_FILE`
  - `CLKS_PER_BIT`
- 工程地位：仿真使用的完整 SoC 顶层，也是板级 wrapper 的内部核心。

### `pipeline_cpu_project/rtl/top/BoardTop.v`

- 模块名：`BoardTop`
- 主要功能：板级顶层 wrapper。
- 实现方式：
  - 例化 `AmplifierSoC`。
  - 将板卡端口名固定为 XDC 使用的名字。
  - 隐藏 debug 端口，避免上板时必须约束调试信号。
- 输入：
  - `sysclk`：100MHz 系统时钟。
  - `KEY1`：高有效复位。
  - `UART_RX`：板上串口输入。
- 输出：
  - `UART_TX`：板上串口输出。
  - `leds[7:0]`：七段段选 CA/CB/CC/CD/CE/CF/CG/DP。
  - `SEL[3:0]`：四位数码管位选。
- 工程地位：Vivado 综合实现时推荐设置为 top module，并配合 `welog1_pipeline_cpu.xdc` 使用。

### `pipeline_cpu_project/rtl/filelist.f`

- 主要功能：RTL 源文件列表。
- 实现方式：文本文件，先设置 `rtl/memory` include 路径，再列出每个 RTL 相对路径。
- 输入输出：供仿真器或脚本读取。
- 工程地位：便于批量加入 RTL 文件到仿真或 Vivado 工程。

## 13. 约束文件

### `pipeline_cpu_project/constraints/welog1_pipeline_cpu.xdc`

- 主要功能：板级管脚约束。
- 实现方式：Vivado XDC/Tcl 约束语句。
- 主要约束：
  - `sysclk` -> `R4`，并创建 100MHz 时钟。
  - `KEY1` -> `B22`。
  - `UART_RX` -> `B20`。
  - `UART_TX` -> `A20`。
  - `leds[0..7]` -> `CA, CB, CC, CD, CE, CF, CG, DP`。
  - `SEL[0..3]` -> `Y3, R1, P2, M2`，使逻辑 `SEL[0]` 对应右端最低位。
  - 输出端设置 `SLEW SLOW` 和 `DRIVE 8`。
- 输入输出：
  - 绑定 `BoardTop` 的外部端口到 FPGA 管脚。
- 工程地位：上板综合实现必需文件。其管脚信息来自春季小实验指导书和参考 XDC。

## 14. 仿真文件

### `pipeline_cpu_project/sim/tb_amplifier_soc.v`

- 模块名：`tb_amplifier_soc`
- 主要功能：完整 SoC 和节点放大器程序前仿 testbench。
- 实现方式：
  - 例化 `AmplifierSoC`。
  - 将 `CLKS_PER_BIT` 改为 8，加快 UART 仿真。
  - 产生时钟和复位。
  - 监听 UART TX 字节。
  - 检查 RAM `0x1b04` 的结果是否为 `1`。
  - 检查 UART 输出是否为 ASCII `0001`。
  - 检查数码管扫描值是否进入预期状态。
- 输入：
  - testbench 内部生成 `clk/reset/uart_rx`。
- 输出：
  - `$display` 打印 PASS/FAIL 信息。
- 工程地位：验证 CPU、ROM、RAM、外设、汇编程序能协同运行的主仿真入口。

### `pipeline_cpu_project/sim/tb_uart_peripheral.v`

- 模块名：`tb_uart_peripheral`
- 主要功能：UART 外设单元测试。
- 实现方式：
  - 例化 `UartPeripheral`。
  - 通过总线写 `UART_TXD`，解码 `uart_tx` 波形，验证发送字节。
  - 通过 task 驱动 `uart_rx`，读 `UART_RXD` 和 `UART_CON`，验证接收和状态位清除。
- 输入：
  - testbench 内部生成总线读写、串口输入。
- 输出：
  - `$display` 打印 PASS/FAIL 信息。
- 工程地位：单独验证 UART 提高要求硬件。

### `pipeline_cpu_project/sim/filelist_sim.f`

- 主要功能：公共 RTL 仿真文件列表。
- 实现方式：文本路径列表，包含 `rtl/memory` include 路径和公共 RTL，不包含 testbench。
- 输入输出：供仿真器读取。
- 工程地位：作为其他 testbench filelist 的公共基础。

### `pipeline_cpu_project/sim/filelist_tb_amplifier_soc.f`

- 主要功能：完整 SoC 仿真的 filelist。
- 实现方式：设置 `rtl/memory` include 路径，并列出 CPU、存储器、外设、`AmplifierSoC` 和 `tb_amplifier_soc.v`。
- 输入输出：供 Vivado xsim 或其他 Verilog 仿真器读取。
- 工程地位：运行主前仿的推荐文件列表。

### `pipeline_cpu_project/sim/filelist_tb_uart_peripheral.f`

- 主要功能：UART 单测仿真的 filelist。
- 实现方式：设置通用 include 路径，并列出 UART 相关 RTL 和 `tb_uart_peripheral.v`。
- 输入输出：供仿真器读取。
- 工程地位：运行 UART 外设前仿的推荐文件列表。

### `pipeline_cpu_project/sim/README.md`

- 主要功能：仿真说明。
- 实现方式：Markdown 文档。
- 输入输出：无硬件 I/O。
- 工程地位：说明绝对路径 `$readmemh` 初始化和 testbench 用法。

## 15. 工具脚本

### `pipeline_cpu_project/tools/assemble_mips.py`

- 主要功能：轻量级 MIPS 子集汇编器。
- 实现方式：
  - Python 脚本，两遍扫描。
  - 第一遍收集 label 和 PC。
  - 第二遍编码 R/I/J 型真实 MIPS 指令。
  - 输出每行一个 32 位十六进制机器码 word。
- 输入：
  - MIPS 汇编文件，例如 `asm/amplifier_fpga.asm`。
- 输出：
  - ROM 初始化 hex 文件，例如 `asm/amplifier_program.hex`。
- 工程地位：保证裸机汇编程序可复现地转换为 CPU 可执行机器码。
- 注意：只支持当前工程所需的真实指令子集，不是完整 MIPS 汇编器。

### `pipeline_cpu_project/tools/generate_data_image.py`

- 主要功能：生成数据 RAM 初始化镜像。
- 实现方式：
  - Python 脚本创建 4096 个 word。
  - 写入节点放大器样例输入。
  - 在 `0x1a00` 写入 `0-F` 七段码软件查表。
  - 其余位置填 0。
- 输入：
  - 脚本内置样例输入和七段码表。
- 输出：
  - `data/amplifier_data.hex`。
- 工程地位：满足 RAM 初始化数据要求；后续验收换测试数据时可以修改此脚本或输出 hex。

### `pipeline_cpu_project/tools/build_images.sh`

- 主要功能：一键重建 ROM/RAM 镜像。
- 实现方式：Shell 脚本，依次运行 `assemble_mips.py` 和 `generate_data_image.py`。
- 输入：
  - `asm/amplifier_fpga.asm`
  - `tools/generate_data_image.py` 内置数据。
- 输出：
  - `asm/amplifier_program.hex`
  - `data/amplifier_data.hex`
- 工程地位：构建流程入口；修改汇编或输入数据后应重新运行。

## 16. 工程文档

### `pipeline_cpu_project/README.md`

- 主要功能：工程快速入口。
- 内容：
  - 目录说明。
  - 内存映射。
  - 镜像重建命令。
  - 当前验证结果。
  - 板级顶层和仿真说明。
- 工程地位：给使用者快速上手。

### `pipeline_cpu_project/docs/design_notes.md`

- 主要功能：设计说明。
- 内容：
  - 五级流水线结构。
  - hazard/forwarding/flush 策略。
  - 支持指令集。
  - 节点放大器程序说明。
  - UART 外设说明。
  - 板级约束来源。
  - 剩余工作。
- 工程地位：报告和后续维护的设计依据。

## 17. 工程数据流和控制流

### 硬件结构

```text
BoardTop
  -> AmplifierSoC
      -> PipelineCPU
      -> InstructionROM
      -> DataRAM
      -> SevenSegPeripheral
      -> UartPeripheral
          -> UartTx
          -> UartRx
```

### 软件执行链

```text
amplifier_fpga.asm
  -> assemble_mips.py
  -> amplifier_program.hex
  -> InstructionROM
  -> PipelineCPU 取指执行
  -> DataRAM / SevenSegPeripheral / UartPeripheral
```

### 数据初始化链

```text
generate_data_image.py
  -> amplifier_data.hex
  -> DataRAM
  -> 输入数据 + 运行时数组 + 软件七段码查表
```

### 外设地址

| 地址 | 外设 | 读写 | 说明 |
|---|---|---|---|
| `0x00000000` 起 | Data RAM | 读/写 | 输入、数组、结果、栈、查表。 |
| `0x40000010` | Seven-seg | 写 | CPU 写入已查表的段码和位选。 |
| `0x40000018` | UART_TXD | 写 | 写低 8 位触发发送。 |
| `0x4000001c` | UART_RXD | 读 | 读低 8 位接收数据。 |
| `0x40000020` | UART_CON | 读 | bit2 tx_done、bit3 rx_ready、bit4 tx_busy；读后清标志。 |

## 18. 已完成和待完成

### 已完成

- 五级流水线 CPU RTL。
- forwarding、load-use stall、branch/jump flush。
- 节点放大器裸机 MIPS 程序。
- ROM/RAM 初始化文件。
- 软件七段码查表。
- 七段数码管外设。
- UART TX/RX 外设。
- 板级 wrapper。
- XDC 管脚约束。
- 主 SoC 仿真和 UART 单测 testbench。

### 待完成

- 在 Vivado/xsim 或其他 Verilog 仿真器中实际编译运行 testbench。
- 根据仿真结果修正可能的 RTL 语法或时序细节。
- 做综合、实现、时序报告和资源报告。
- 做后仿。
- 生成 bitstream 并上板验证。
- 统计 CPI 和 Fmax，补充实验报告材料。
