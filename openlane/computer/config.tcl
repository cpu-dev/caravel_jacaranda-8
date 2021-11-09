# Copyright 2021 cpu-dev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(ROUTING_CORES) 16

set ::env(DESIGN_NAME) computer

set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
    $script_dir/../../verilog/rtl/jacaranda-8/UART/UART.v \
    $script_dir/../../verilog/rtl/jacaranda-8/UART/rx.v \
    $script_dir/../../verilog/rtl/jacaranda-8/UART/tx.v \
    $script_dir/../../verilog/rtl/jacaranda-8/alu.v \
    $script_dir/../../verilog/rtl/jacaranda-8/cpu.v \
    $script_dir/../../verilog/rtl/jacaranda-8/decoder.v \
    $script_dir/../../verilog/rtl/jacaranda-8/alu_controller.v \
    $script_dir/../../verilog/rtl/jacaranda-8/computer.v \
    $script_dir/../../verilog/rtl/jacaranda-8/data_mem.v \
    $script_dir/../../verilog/rtl/jacaranda-8/instr_mem.v \
    $script_dir/../../verilog/rtl/jacaranda-8/main_controller.v \
    $script_dir/../../verilog/rtl/jacaranda-8/regfile.v \
    $script_dir/../../verilog/rtl/jacaranda-8/wishbone.v"

set ::env(CLOCK_PORT) wb_clk_i
set ::env(CLOCK_NET) wb_clk_i
set ::env(CLOCK_PERIOD) 500

set ::env(SYNTH_STRATEGY) "DELAY 2"
set ::env(FP_PDN_CORE_RING) 0
set ::env(CELL_PAD) 2

set ::env(PL_TARGET_DENSITY) 0.07
set ::env(FP_CORE_UTIL) 6
set ::env(FP_SIZING) relative

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4
