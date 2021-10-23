# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

# Jacaranda-8: 8bit CPU
Jacaranda-8 is educational ISA for home-build CPU beginners. This project implements the microarchitecture: CHARLATAN which is a simple implementation of Jacaranda-8 ISA.The following table shows the specifications of this CPU.

|item|value|
|:---------:|:----------:|
|microarchitecture|CHARLATAN|
|data bus width|8bit|
|instruction bus width|8bit|
|memory address bus width|8bit|
|architecture type|harvard architecture, RISC|
|number of general purpose register|4|
|I/O|memory mapped|
|Interruption|enabled|

|Instruction type|field|
|----------------|-|
|reg-imm load/store|op[3:0] imm[3:0]|
|reg-reg mov|op[3:0] rd[1:0] rs[1:0]|
|reg-reg cal|op[3:0] rd[1:0] rs[1:0]|
|jump/branch|op[3:0] mode[1:0] rs[1:0]|
|reg-mem load/store|op[3:0] rd[1:0] rs[1:0]|

|registers|type|
|---------|----|
|pc|program counter|
|flag|comparison flag|
|r0|general purpose|
|r1|general purpose|
|r2|general purpose|
|r3|general purpose/immediate load|

|Number|Instruction name|mnemonic|7|6|5|4|3|2|1|0|pesudo code|
|------|----------------|--------|-|-|-|-|-|-|-|-|-----------|
|0|Move|mov rd, rs|0|0|0|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rs[7:0], PC += 1|
|1|Add|add rd, rs|0|0|0|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] + rs[7:0], PC += 1|
|2|Substruct|sub rd, rs|0|0|1|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] - rs[7:0], PC += 1|
|3|And|and rd, rs|0|0|1|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] & rs[7:0], PC += 1|
|4|Or|or rd, rs|0|1|0|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] \| rs[7:0], PC += 1|
|5|Not|not rd, rs|0|1|0|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = !rs[7:0], PC += 1|
|6|Shift Left Logical|sll rd, rs|0|1|1|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] << rs[7:0], PC += 1|
|7|Shift Right Logical|srl rd, rs|0|1|1|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] >> rs[7:0], PC += 1|
|8|Shift Right Arithmetic|sra rd, rs|1|0|0|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = rd[7:0] >>> rs[7:0], PC += 1|
|9|Compare|cmp rd, rs|1|0|0|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|flag = rd[7:0] == rs[7:0], PC += 1|
|10|Jump equal|je rs|1|0|1|0|0|0|rs_index[1]|rs_index[0]|PC = flag ? rs[7:0] : PC += 1|
|11|Jump|jmp rs|1|0|1|1|0|0|rs_index[1]|rs_index[0]|PC = rs[7:0]|
|12|Load Immediate High|ldih imm|1|1|0|0|imm[3]|imm[2]|imm[1]|imm[0]|imm_register[7:4] = imm[3:0], PC += 1|
|13|Load Immediate Low|ldil imm|1|1|0|1|imm[3]|imm[2]|imm[1]|imm[0]|imm_register[3:0] = imm[3:0], PC += 1|
|14|Load|ld rd, rs|1|1|1|0|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|rd[7:0] = mem[rs[7:0]], PC += 1|
|15|Store|st rd, rs|1|1|1|1|rd_index[1]|rd_index[0]|rs_index[1]|rs_index[0]|mem[rs[7:0]] = rd[7:0], PC += 1|
|16|Interrupt Return|iret|1|0|1|1|0|1|0|0|PC = retaddr|

## project build guide

## Jacaranda-8 programming guide
You can program your Jacaranda-8 machine code from the management SoC by Wishbone bus.

|address|function|
|:-----:|:-------|
|0x3000_0000|IMEM_WRITE|
|0x3000_0004|UART_CLK_FREQ|

### IMEM_WRITE
* bits[7:0] for data that will be contained in the instruction memory.
* bits[15:8] for address that indicates address in the instruction memory.

### UART_CLK_FREQ
put board's clock frequency


## Jacaranda MMapped I/O summary

|address|description|note|
|-------|-----------|----|
|255|UART FLAG REGISTER 1(UFR1)||
|254|UART FLAG REGISTER 2(UFR2)|read only|
|253|UART TX DATA(UTD)||
|252|UART RX DATA(URD)|read only|
|251|GPIO OUT||
|250|interrupt vector||
|249|GPIO IN|read only|
