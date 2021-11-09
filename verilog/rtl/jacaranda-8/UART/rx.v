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

module rx(clk, reset, rx_en, rx, data, end_flag, clk_count_bit);
    input wire clk;
    input wire reset;
    input wire rx_en;
    input wire rx;
    output reg[7:0] data;
    output reg end_flag;
    input wire [31:0] clk_count_bit;

    wire [31:0] clk_begin_to_receive;

    reg[1:0] state;
    reg[31:0] clk_count;
    reg[2:0] bit_count;
    reg[3:0] recent;
    wire update_flag;

    assign clk_begin_to_receive = clk_count_bit + clk_count_bit / 2 - 4;

    assign update_flag = (state == 2'b01) 
        ? clk_count == clk_begin_to_receive
        : clk_count == clk_count_bit - 32'd1;
    
    always @(posedge clk) begin
        if(reset) begin
            data <= 8'b0;
            end_flag <= 1'b0;
            state <= 2'b0;
            clk_count <= 32'd0;
            bit_count <= 3'd0;
            recent <= 4'b1111;
        end else begin
            case(state)
                2'b00: begin
                    clk_count <= 32'd0;
                    bit_count <= 3'd0;
                    end_flag <= 1'b0;
                    recent = {recent[2:0], rx};
                    state = (recent == 4'b0000) & rx_en ? 2'b01 : state;
                end
                2'b01: begin
                    clk_count <= clk_count + 32'd1;
                    if(update_flag) begin
                        state = 2'b11;
                        clk_count <= 32'd0;
                        data[2'd0] <= rx;
                        bit_count <= 3'd1;
                    end
                end
                2'b11: begin
                    clk_count <= clk_count + 32'd1;
                    if(update_flag) begin
                        state <= (bit_count == 3'd7) ? 2'b10 : state;
                        data[bit_count] <= rx;
                        bit_count <= bit_count + 3'd1;
                   clk_count <= 32'd0;
                    end
                end
                2'b10: begin
                    clk_count <= clk_count + 32'd1;
                    if(update_flag) begin
                        state <= 2'b00;
                        end_flag <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
