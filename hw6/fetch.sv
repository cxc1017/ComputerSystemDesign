module fetch(
	input clk,
	input rst,
	output logic[13:0]ir
);

logic [13:0] Rom_data_out;
logic [10:0] pc_in, pc_out, mar_q;
logic load_pc, load_mar, load_ir;
//呼叫ROM
ROM ROM0(
	.Rom_addr_in(mar_q), .Rom_data_out(Rom_data_out)
);

assign pc_out = pc_in + 1;

always_ff@(posedge clk)
begin
	if(rst) pc_in <= 11'b0000000000;
	else if(load_pc) pc_in <= pc_out;
end

always_ff@(posedge clk)
begin
	if(rst) mar_q <= 11'b0000000000;
	else if(load_mar) mar_q <= pc_in;
end
always_ff@(posedge clk)
begin
	if(rst) ir <= 14'b00000000000000;
	else if(load_ir) ir <= Rom_data_out;
end

typedef enum{T0, T1, T2, T3} state_t;
state_t ps, ns;

always_ff@(posedge clk)
begin
	if(rst) ps <= T0;
	else ps <= ns;
end
//FSM
always_comb
begin
	load_ir = 0; load_mar = 0; load_pc = 0;
	case(ps)
		T0:
		begin
			ns = T1;
		end
		T1:
		begin
			load_mar = 1;
			ns = T2;
		end
		T2:
		begin
			load_pc = 1;
			ns = T3;
		end
		T3:
		begin
			load_ir = 1;
			ns = T1;
		end
	endcase
end

endmodule