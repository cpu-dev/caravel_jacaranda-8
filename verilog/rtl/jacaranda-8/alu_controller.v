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

module alu_controller(
`ifdef use_power_pins
    inout vccd1,	// user area 1 1.8v supply
    inout vssd1,	// user area 1 digital ground
`endif
    input [3:0] opcode,
    output [3:0] alu_ctrl
);

    assign alu_ctrl = alu_control(opcode);

    function [3:0] alu_control(input [3:0] opcode);
        begin
            case(opcode)
                4'b0001: alu_control = 4'b0000;
                4'b0010: alu_control = 4'b1000;
                4'b0011: alu_control = 4'b0001;
                4'b0100: alu_control = 4'b0010;
                4'b0101: alu_control = 4'b0011;
                4'b0110: alu_control = 4'b0100;
                4'b0111: alu_control = 4'b0101;
                4'b1000: alu_control = 4'b0110;
                4'b1001: alu_control = 4'b0111;
            endcase
        end
    endfunction
endmodule
