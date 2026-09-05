module fetch(
	input clk,
	input rst,
	output logic[7:0]w_q
);

logic [13:0] Rom_data_out, ir_q;
logic [10:0] pc_in, pc_out, mar_q;
logic load_pc, load_mar, load_ir, load_w, movlw, addlw, iorlw, sublw, andlw, xorlw;
logic [2:0] op;
logic [7:0] alu;

Program_Rom ROM0(
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
	if(rst) ir_q <= 14'b00000000000000;
	else if(load_ir) ir_q <= Rom_data_out;
end

typedef enum{T0, T1, T2, T3, T4, T5, T6} state_t;
state_t ps, ns;

always_ff@(posedge clk)
begin
	if(rst) ps <= T0;
	else ps <= ns;
end

assign movlw = ir_q[13:8] == 6'h30;
assign addlw = ir_q[13:8] == 6'h3E;
assign iorlw = ir_q[13:8] == 6'h38;
assign andlw = ir_q[13:8] == 6'h39;
assign sublw = ir_q[13:8] == 6'h3C;
assign xorlw = ir_q[13:8] == 6'h3A;

always_comb
begin
	unique case(op)
		0: alu = ir_q[7:0] + w_q;
		1: alu = ir_q[7:0] - w_q;
		2: alu = ir_q[7:0] & w_q;
		3: alu = ir_q[7:0] | w_q;
		4: alu = ir_q[7:0] ^ w_q;
		5: alu = ir_q[7:0];
	endcase
end

always_ff@(posedge clk)
begin
	if(rst) w_q <= 8'h0;
	else if(load_w) w_q <= alu;
end

always_comb
begin
	load_ir = 0; load_mar = 0; load_pc = 0; load_w = 0; op = 0;
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
			ns = T4;
		end
		T4:
		begin
			if(movlw)
				op = 5;
			else if(addlw)
				op = 0;
			else if(sublw)
				op = 1;
			else if(andlw)
				op = 2;
			else if(iorlw)
				op = 3;
			else if(xorlw)
				op = 4;
			load_w = 1;
			ns = T5;
		end
		T5:
		begin
			ns = T6; 
		end
		T6:
		begin
			ns = T1;
		end
	endcase
end

endmodule