module fetch(
	input clk,
	input rst,
	output logic[7:0]w_q
);

logic [13:0] Rom_data_out, ir_q;
logic [10:0] pc_in, pc_out, mar_q;
logic load_pc, load_mar, load_ir, load_w, movlw, addlw, iorlw, sublw, 
	  andlw, xorlw, sel_pc, sel_alu, ram_en, dir, addwf, andwf, clrf, clrw, comf, decf, goto;
logic [3:0] op;
logic [7:0] alu, mux1_out, ram_out;

Program_Rom ROM0(
	.Rom_addr_in(mar_q), .Rom_data_out(Rom_data_out)
);

single_port_ram_128x8 ram0(
	.data(alu), .addr(ir_q[6:0]), .ram_en(ram_en), .clk(clk), .q(ram_out)
);
//assign pc_out = pc_in + 1;

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

assign pc_out = sel_pc ? ir_q[10:0] : pc_in + 1;

assign movlw = ir_q[13:8] == 6'h30;
assign addlw = ir_q[13:8] == 6'h3E;
assign iorlw = ir_q[13:8] == 6'h38;
assign andlw = ir_q[13:8] == 6'h39;
assign sublw = ir_q[13:8] == 6'h3C;
assign xorlw = ir_q[13:8] == 6'h3A;

assign addwf = ir_q[13:8] == 6'h07;
assign andwf = ir_q[13:8] == 6'h05;
assign clrf = ir_q[13:7] == 7'b0000011;
assign clrw = ir_q[13:2] == 12'b000001000000;
assign comf = ir_q[13:8] == 6'h09;
assign decf = ir_q[13:8] == 6'h03;
assign goto = ir_q[13:11] == 3'b101;

assign dir = ir_q[7];

assign mux1_out = sel_alu ?  ram_out[7:0] : ir_q[7:0];

always_comb
begin
	unique case(op)
		0: alu = mux1_out + w_q;
		1: alu = mux1_out - w_q;
		2: alu = mux1_out & w_q;
		3: alu = mux1_out | w_q;
		4: alu = mux1_out ^ w_q;
		5: alu = mux1_out;
		6: alu = mux1_out + 1;
		7: alu = mux1_out - 1;
		8: alu = 0;
		9: alu = ~mux1_out;
	endcase
end

always_ff@(posedge clk)
begin
	if(rst) w_q <= 8'h0;
	else if(load_w) w_q <= alu;
end

always_comb
begin
	load_ir = 0; load_mar = 0; load_pc = 0; load_w = 0; op = 0; sel_pc = 0; sel_alu = 0; ram_en = 0;
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
			//sel_pc = 1;
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
			begin
				load_w = 1;
				op = 5;
			end
			else if(addlw)
			begin
				load_w = 1;
				op = 0;
			end
			else if(sublw)
			begin
				load_w = 1;
				op = 1;
			end
			else if(andlw)
			begin
				load_w = 1;
				op = 2;
			end
			else if(iorlw)
			begin
				load_w = 1;
				op = 3;
			end
			else if(xorlw)
			begin
				load_w = 1;
				op = 4;
			end
			else if(addwf)
			begin
				sel_alu = 1;
				if(dir)
				begin
					op = 0;
					ram_en = 1;
				end
				else 
				begin
					op = 0;
					load_w = 1;
				end
			end
			else if(andwf)
			begin
				sel_alu = 1;
				if(dir)
				begin
					op = 2;
					ram_en = 1;
				end
				else
				begin
					op = 2;
					load_w = 1;
				end
			end
			else if(clrf)
			begin
				op = 8;
				ram_en = 1;
			end
			else if(clrw)
			begin
				op = 8;
				load_w = 1;
			end
			else if(comf)
			begin
				/*if(dir)
				begin
					op = 9;
					ram_en = 1;
				end
				else
				begin
					sel_alu = 1;
					op = 9;
				end*/
				op = 9;
				sel_alu = 1;
				ram_en = 1;
			end
			else if(decf)
			begin
				/*if(dir)
				begin
					op = 7;
					ram_en = 1;
				end
				else
				begin
					sel_alu = 1;
					op = 7;
				end*/
				op = 7;
				sel_alu = 1;
				ram_en = 1;
			end
			else if(goto)
			begin
				sel_pc = 1;
				load_pc = 1;
			end
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