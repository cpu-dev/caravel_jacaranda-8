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
    output reg instr_mem_en
);

// 0x3000_0100 - 0x3000_01FF: IMEM_WRITE
parameter IMEM_WRITE_PREFIX = 24'h3000_01;

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
        // reset
        ready <= 1'b0;
    end else begin
        if(ready) begin
            ready <= 1'b0;
            instr_mem_en <= 1'b0;
        end
        // Read
        if (valid && !ready && !we) begin
            //case(addr)
            //endcase
            ready <= 1'b1;
        // Write
        end else if (valid && !ready && we) begin
            case(addr[31:8])
                IMEM_WRITE_PREFIX: begin
                    instr_mem_addr <= addr[7:0];
                    instr_mem_data <= wdata[7:0];
                    instr_mem_en <= 1'b1;
                end
            endcase
            ready <= 1'b1;
        end 
    end
end
endmodule

