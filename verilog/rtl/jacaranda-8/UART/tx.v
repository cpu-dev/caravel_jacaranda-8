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

module tx(clk, reset, tx_en, begin_flag, data, tx, busy_flag, clk_count_bit);
    input wire clk;
    input wire reset;
    input wire tx_en;
    input wire begin_flag;
    input wire[7:0] data;
    output reg tx;
    output wire busy_flag;
    input wire [31:0] clk_count_bit;

    reg[1:0] state;
    reg[31:0] clk_count;
    reg[2:0] bit_count;
    wire update_flag;
    
    assign update_flag = (clk_count == clk_count_bit - 32'd1);
    assign busy_flag = ~(state == 2'b00);

    always @(posedge clk) begin
        if(reset) begin
            clk_count <= 32'd0;
            bit_count <= 3'd0;
            state <= 2'b00;
            tx  <= 1'b1;
        end else begin
            case(state)
                2'b00: begin
                    tx <= 1'b1;
                    clk_count = 32'd0;
                    bit_count <= 3'd0;
                    state <= (begin_flag & tx_en) ? 2'b01 : state;
                end
                2'b01: begin
                    tx <= 1'b0;
                    clk_count <= clk_count + 32'd1;
                    if(update_flag) begin
                        state <= 2'b11;
                        clk_count <= 32'd0;
                    end
                end
                2'b11: begin
                    tx <= data[bit_count];
                    clk_count <= clk_count + 32'd1;
                    if(update_flag) begin
                        state <= (bit_count == 3'd7) ? 2'b10 : state;
                        bit_count <= bit_count + 3'd1;
                        clk_count <= 32'd0;
                    end
                end
                2'b10: begin
                    tx <= 1'b1;
                    clk_count <= clk_count + 32'd1;
                    case({update_flag, begin_flag})
                        2'b11: begin
                            state <= 2'b01;
                            clk_count <= 32'd0;
                            bit_count <= 3'd0;
                        end
                        2'b10: state <= 2'b00;
                        default: state <= state;
                    endcase
                end
            endcase
        end
    end
endmodule
