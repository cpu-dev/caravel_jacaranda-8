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

module alu(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input [7:0] rd, 
    input [7:0] rs,
    input [3:0] alu_ctrl,
    output [7:0] alu_out
);

    assign alu_out = execute(rd, rs, alu_ctrl);

    function [7:0] execute(input [7:0] rd, input [7:0] rs, input [3:0] alu_ctrl);
        begin
            case(alu_ctrl)
            4'b0000: execute = rd + rs;
            4'b0001: execute = rd & rs;
            4'b0010: execute = rd | rs;
            4'b0011: execute = ~rs;
            4'b0100: execute = rd << rs;
            4'b0101: execute = rd >> rs;
            4'b0110: execute = $signed(rd) >>> $signed(rs);
            4'b0111: execute = (rd == rs);
            4'b1000: execute = rd - rs;
            default: execute = 8'b0000_0000;
            endcase
        end
    endfunction
endmodule
