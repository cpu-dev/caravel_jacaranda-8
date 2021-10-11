`default_nettype none

// module computer(
//     input clock,
//     input rx,
//     output tx,
//     output [3:0] led_out_data,
//     output [6:0] seg_out_1,
//     output [6:0] seg_out_2,
//     output [6:0] seg_out_3
// );


module computer(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
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

    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    output [2:0] irq
);

/** temporary **/
    wire rx;
    wire tx;
    wire [3:0] led_out_data;
    wire [6:0] seg_out_1;
    wire [6:0] seg_out_2;
    wire [6:0] seg_out_3;
/** **/
    // output enable
    assign io_oeb[37:36] = 2'b11;
    // UART - GPIO
    assign io_out[37] = tx;
    assign io_out[36] = rx;

    wire [7:0] instr;
    wire [7:0] pc;
    wire [7:0] rd_data;
    wire [7:0] rs_data;
    wire mem_w_en;
    wire [7:0] mem_r_data;
    wire [7:0] _mem_r_data;
    wire busy_flag;
    wire receive_flag;
    reg tx_en;
    reg rx_en;
    //reg begin_flag;
    wire begin_flag;
    reg [7:0] tx_data;
    wire [7:0] rx_data;

    reg [7:0] int_vec;
    reg [7:0] int_en;

    wire int_req;

    wire reg_w_en;

    reg [7:0] led_in_data;
    reg led_begin_flag;
    wire [7:0] led_state_reg;

    reg [7:0] nanaseg_in_data;

    wire [7:0] instr_mem_addr;
    wire [7:0] instr_mem_data; 
    wire instr_mem_en;

    wire [7:0] wb_instr_req_addr;

    assign instr_mem_addr = reset ? wb_instr_req_addr: pc;

    wire reset;

    assign reset = la_data_in[0];

    wire clock;
    assign clock = reset ? 1'b1 : wb_clk_i;

    wishbone wb(.wb_clk_i(wb_clk_i),
                .wb_rst_i(wb_rst_i),
                .wbs_stb_i(wbs_stb_i),
                .wbs_cyc_i(wbs_cyc_i),
                .wbs_we_i(wbs_we_i),
                .wbs_sel_i(wbs_sel_i),
                .wbs_adr_i(wbs_adr_i),
                .wbs_dat_i(wbs_dat_i),
                .wbs_ack_o(wbs_ack_o),
                .wbs_dat_o(wbs_dat_o),
                .instr_mem_addr(wb_instr_req_addr),
                .instr_mem_data(instr_mem_data),
                .instr_mem_en(instr_mem_en));

    instr_mem instr_mem(.addr(instr_mem_addr),
                        .w_data(instr_mem_data),
                        .w_en(instr_mem_en),
                        .r_data(instr),
                        .clock(wb_clk_i),
                        .reset(reset));

    cpu cpu(.clock(clock),
            .reset(reset),
            .instr(instr),
            .pc(pc),
            .rd_data(rd_data),
            .rs_data(rs_data),
            .mem_w_en(mem_w_en),
            .mem_r_data(mem_r_data),
            .int_req(int_req),
            .int_en(int_en),
            .int_vec(int_vec),
            .reg_w_en(reg_w_en));

    always @(posedge clock) begin
        if(rs_data == 8'd255 && mem_w_en == 1) begin
            tx_en <= rd_data[0];
            rx_en <= rd_data[1];
        end
    end

    always @(posedge clock) begin
        if(rs_data == 8'd253 && mem_w_en == 1) begin
            tx_data <= rd_data;
            //begin_flag = 1;
        end else begin
            tx_data <= tx_data;
            //begin_flag = 0;
        end
    end
    assign begin_flag = (rs_data == 8'd253) & (mem_w_en == 1);

    data_mem data_mem(.addr(rs_data),
                      .w_data(rd_data),
                      .w_en(mem_w_en),
                      .r_data(_mem_r_data),
                      .clock(clock));

    assign mem_r_data = (rs_data == 8'd254) ? {6'b0, receive_flag, busy_flag}
                      : (rs_data == 8'd252) ? rx_data
                      : (rs_data == 8'd250) ? int_vec
                      : (rs_data == 8'd249) ? led_state_reg
                      : _mem_r_data;

    always @(posedge clock) begin
        if(rs_data == 8'd251 && mem_w_en == 1) begin
            led_in_data <= rd_data;
            led_begin_flag <= 1'b1;
        end else begin
            led_in_data <= led_in_data;
            led_begin_flag <= 1'b0;
        end
    end

    always @(posedge clock) begin
        if(rs_data == 8'd248 && mem_w_en == 1) begin
            nanaseg_in_data <= rd_data;
        end else begin
            nanaseg_in_data <= nanaseg_in_data;
        end
    end
    

    //割り込み要求が立っている時は割り込み不許可
    always @(posedge clock) begin
        if(int_req == 1'b1) begin
            int_en <= 8'h00;
        end else if(int_req == 1'b0) begin
            int_en <= 8'h01;
        end
    end

    always @(posedge clock) begin
        //割り込みベクタの書き込み
        if(rs_data == 8'd250 && mem_w_en == 1'b1) begin
            int_vec <= rd_data;
        end else begin
            int_vec <= int_vec;
        end
    end

    UART UART(.clk(clock),
              .reset(reset),
              .tx_en(tx_en),
              .rx_en(rx_en),
              .begin_flag(begin_flag),
              .rx(rx),
              .tx_data(tx_data),
              .tx(tx),
              .rx_data(rx_data),
              .busy_flag(busy_flag),
              .receive_flag(receive_flag),
              .int_req(int_req),
              .access_addr(rs_data),
              .reg_w_en(reg_w_en));
//
//    LED4 LED4(.in_data(led_in_data),
//              .begin_flag(led_begin_flag),
//              .state_reg(led_state_reg),
//              .out_data(led_out_data),
//              .clock(wb_clk_i));
//
//    nanaseg nanaseg(.bin_in(nanaseg_in_data),
//                    .seg_dig1(seg_out_1),
//                    .seg_dig2(seg_out_2),
//                    .seg_dig3(seg_out_3));

endmodule
