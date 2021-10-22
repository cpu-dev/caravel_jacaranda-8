// Copyright 2021 cpu-dev
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module decoder(
`ifdef use_power_pins
    inout vccd1,	// user area 1 1.8v supply
    inout vssd1,	// user area 1 digital ground
`endif
    input [7:0] instr,
    output [3:0] opcode,
    output [1:0] rs_a,
    output [1:0] rd_a,
    output [3:0] imm
);

    assign opcode = instr[7:4];
    assign rd_a = instr[3:2];
    assign rs_a = instr[1:0];
    assign imm = instr[3:0];
endmodule
