/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

// --------------------------------------------------------

void main()
{
    reg_spimaster_config = 0xa002;
	// Configure LA probes [31:0] as inputs to the cpu 
	reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]

    // set reset to high
	reg_la0_data = 1 << 16;
    
    reg_la0_data = 1 << 16 | 0x00 << 8 | 0b11000000; // ldih 0  0xC0
    reg_la0_data = 1 << 16 | 0x01 << 8 | 0b11010000; // ldil 0  0xD0
    reg_la0_data = 1 << 16 | 0x02 << 8 | 0b10110011; // jmp r3  0xB3

    reg_la0_data = 0 << 16;

    while(1) {}
}

