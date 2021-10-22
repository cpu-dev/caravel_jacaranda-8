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

module cpu(
`ifdef use_power_pins
    inout vccd1,	// user area 1 1.8v supply
    inout vssd1,	// user area 1 digital ground
`endif
    input clock,
    input reset,
    input [7:0] instr,
    output [7:0] pc,
    output [7:0] rd_data,
    output [7:0] rs_data,
    output mem_w_en,
    input [7:0] mem_r_data,
    input int_req,
    input [7:0] int_en,
    input [7:0] int_vec,
    output reg_w_en
);
    
    reg [7:0] ret_addr;

    reg flag;
    reg [7:0] pc;
    
    wire [3:0] opcode;
    wire [1:0] rd_a, rd_a_p, rs_a, rs_a_p;
    wire [3:0] imm;

    wire [7:0] reg_w_data;
    wire [7:0] reg_w_data_p;
    wire [7:0] reg_w_data_p_p;
    wire [7:0] reg_w_imm;

    wire reg_reg_mem_w_sel;
    wire reg_alu_w_sel;

    wire [3:0] alu_ctrl;
    wire [7:0] alu_out;

    wire flag_w_en;

    wire imm_en;
    wire ih_il_sel;

    wire jmp_en, je_en;
    wire ret;

    reg intr_en = 1'b0;
    reg _flag;

    decoder decoder(
    `ifdef use_power_pins
        .vccd1(vccd1),  // user area 1 1.8v power
        .vssd1(vssd1),  // user area 1 digital ground
    `endif
        .instr(instr),
        .opcode(opcode),
        .rs_a(rs_a_p),
        .rd_a(rd_a_p),
        .imm(imm)
    );

    main_controller main_controller(
    `ifdef use_power_pins
        .vccd1(vccd1),  // user area 1 1.8v power
        .vssd1(vssd1),  // user area 1 digital ground
    `endif
        .opcode(opcode),
        .rd_a(rd_a_p),
        .reg_w_en(reg_w_en),
        .mem_w_en(mem_w_en),
        .reg_reg_mem_w_sel(reg_reg_mem_w_sel),
        .reg_alu_w_sel(reg_alu_w_sel),
        .flag_w_en(flag_w_en),
        .imm_en(imm_en),
        .ih_il_sel(ih_il_sel),
        .jmp_en(jmp_en),
        .je_en(je_en),
        .ret(ret)
    );

    alu_controller alu_controller(
    `ifdef use_power_pins
        .vccd1(vccd1),  // user area 1 1.8v power
        .vssd1(vssd1),  // user area 1 digital ground
    `endif
        .opcode(opcode),
        .alu_ctrl(alu_ctrl)
    );

    regfile regfile(
    `ifdef use_power_pins
        .vccd1(vccd1),  // user area 1 1.8v power
        .vssd1(vssd1),  // user area 1 digital ground
    `endif
        .rd_addr(rd_a), 
        .rs_addr(rs_a),
        .w_data(reg_w_data),
        .w_en(reg_w_en),
        .rd_data(rd_data),
        .rs_data(rs_data), 
        .clock(clock),
        .intr_en(intr_en)
    );

    assign rd_a = imm_en ? 2'b11 : rd_a_p;
    assign rs_a = imm_en ? 2'b11 : rs_a_p;

    assign reg_w_data_p_p = reg_reg_mem_w_sel ? mem_r_data : rs_data;
    assign reg_w_data_p = reg_alu_w_sel ? alu_out : reg_w_data_p_p;
    assign reg_w_imm = ih_il_sel ? {imm, rs_data[3:0]} : {rs_data[7:4], imm};
    assign reg_w_data = imm_en ? reg_w_imm : reg_w_data_p;

    alu alu(
    `ifdef use_power_pins
        .vccd1(vccd1),  // user area 1 1.8v power
        .vssd1(vssd1),  // user area 1 digital ground
    `endif
        .rd(rd_data),
        .rs(rs_data),
        .alu_ctrl(alu_ctrl),
        .alu_out(alu_out)
    );

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            flag <= 0;
        end else if(ret) begin
            flag <= _flag;
        end else if(je_en) begin
            flag <= 0;
        end else if(flag_w_en) begin
            flag <= alu_out;
        end else begin
            flag <= flag;
        end
    end

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            intr_en <= 1'b0;
        end else if(ret) begin
            intr_en <= 1'b0;
        end else if(int_req && int_en[0]) begin
			intr_en <= 1'b1;
        end
    end

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            ret_addr <= 8'b0;
        end else if(int_req == 1'b1 && int_en[0]) begin
            if(jmp_en) begin
                ret_addr <= rs_data;
            end else if(je_en && flag) begin
                ret_addr <= rs_data;
            end else begin
                ret_addr <= pc + 1;
            end
        end else begin
            ret_addr <= ret_addr;
        end
    end

    always @(posedge clock or posedge reset) begin
        if(reset) begin
            _flag <= 1'b0;
            pc <= 8'b0;
        end else if(int_req && int_en[0]) begin
            _flag <= flag;
            pc <= int_vec;
        end else if(ret) begin
            pc <= ret_addr;
        end else if(jmp_en) begin
            pc <= rs_data;
        end else if(je_en) begin
            if(flag) begin
                pc <= rs_data;
            end else begin
                pc <= pc + 1;
            end
        end else begin
            pc <= pc + 1;
        end
    end
endmodule
