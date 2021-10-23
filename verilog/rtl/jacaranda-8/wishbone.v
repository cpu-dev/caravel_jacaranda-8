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

module wishbone(
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_adr_i,
    input [31:0] wbs_dat_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    output reg [7:0] instr_mem_addr,
    output reg [7:0] instr_mem_data,
    output reg instr_mem_en,

    output reg [31:0] uart_freq
);

parameter IMEM_WRITE = 32'h3000_0000;
parameter UART_CLK_FREQ = 32'h3000_0004;

wire valid;
wire we;
wire [31:0] rdata;
wire [31:0] wdata;
wire [31:0] addr;
wire sel;
wire reset;
wire clk;
reg ready;

assign valid = wbs_cyc_i & wbs_stb_i; 
assign wbs_ack_o = ready;
assign we = wbs_we_i;
assign wbs_dat_o = rdata;
assign wdata = wbs_dat_i;
assign addr = wbs_adr_i;
assign sel = wbs_sel_i;

assign reset = wb_rst_i;
assign clk   = wb_clk_i;

always @(posedge clk) begin
    if(reset) begin
        ready <= 1'b0;
        instr_mem_addr <= 8'b0;
        instr_mem_data <= 8'b0;
        instr_mem_en <= 1'b0;
        uart_freq <= 32'd50_000_000;
    end else begin
        if(ready) begin
            ready <= 1'b0;
            instr_mem_en <= 1'b0;
        end
        if (valid && !ready && !we) begin
            ready <= 1'b1;
        end else if (valid && !ready && we) begin
            case(addr)
                IMEM_WRITE: begin
                    instr_mem_addr <= wdata[15:8];
                    instr_mem_data <= wdata[7:0];
                    instr_mem_en <= 1'b1;
                end
                UART_CLK_FREQ: begin
                    uart_freq <= wdata;
                end
            endcase
            ready <= 1'b1;
        end 
    end
end
endmodule

