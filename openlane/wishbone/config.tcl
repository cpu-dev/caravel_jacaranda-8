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

set script_dir [file dirname [file normalize [info script]]]

set ::env(ROUTING_CORES) 16

set ::env(DESIGN_NAME) wishbone

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
    $script_dir/../../verilog/rtl/jacaranda-8/wishbone.v"

set ::env(CLOCK_PORT) wb_clk_i
set ::env(CLOCK_NET) wb_clk_i
set ::env(CLOCK_PERIOD) 20

set ::env(PL_TARGET_DENSITY) 0.05
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 500 500"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

