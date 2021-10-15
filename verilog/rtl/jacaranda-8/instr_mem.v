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

module instr_mem(addr, w_data, w_en, r_data, clock, reset);
    input [7:0] addr;
    input [7:0] w_data;
    input w_en;
    input clock;
    output [7:0] r_data;
    input reset;

    reg [7:0] mem[0:255];
    
    assign r_data = reset ? 8'b0 : mem[addr];

    always @(posedge clock) begin
        if(w_en) begin
            mem[addr] <= w_data;
        end else begin
            mem[addr] <= mem[addr];
        end
    end
endmodule
