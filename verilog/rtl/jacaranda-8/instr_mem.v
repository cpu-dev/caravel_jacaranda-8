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
