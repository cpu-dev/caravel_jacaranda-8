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

module data_mem(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input clock,
    input [7:0] addr,
    input [7:0] w_data,
    input w_en,
    output [7:0] r_data
);

    reg [7:0] mem[0:255];
    
    assign r_data = mem[addr];

    always @(posedge clock) begin
        if(w_en) begin
            mem[addr] <= w_data;
        end else begin
            mem[addr] <= mem[addr];
        end
    end
endmodule
