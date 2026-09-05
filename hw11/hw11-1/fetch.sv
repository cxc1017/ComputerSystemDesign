module fetch(
	input clk,
	input rst,
	output logic[7:0]port_b_out
);

logic [13:0] Rom_data_out, ir_q;
logic [10:0] pc_in, pc_out, mar_q, stack_out;
logic load_pc, load_mar, load_ir, load_w, movlw, addlw, iorlw, sublw, 
	  andlw, xorlw, sel_pc, sel_alu, ram_en, dir, addwf, andwf, clrf, 
	  clrw, comf, decf, goto, incf, iorwf, movf, movwf, subwf, xorwf, sel_bus,
	  bcf, bsf, btfsc, btfss, decfsz, incfsz, alu_zero, load_port_b, addr_port_b, 
	  asrf, lslf, lsrf, rlf, rrf, swapf, push, pop;
logic [4:0] op;
logic [7:0] alu, mux1_out, ram_out, databus, ram_mux, bcf_mux, bsf_mux, btfsc_skip_bit, btfss_skip_bit, w_q;
logic [2:0] sel_ram_mux, sel_bit;

Program_Rom ROM0(
	.Rom_addr_in(mar_q), .Rom_data_out(Rom_data_out)
);

single_port_ram_128x8 ram0(
	.data(databus), .addr(ir_q[6:0]), .ram_en(ram_en), .clk(clk), .q(ram_out)
);
stack s0(
	.stack_out(stack_out), .stack_in(pc_out), .push(push), .pop(pop), .rst(rst), .clk(clk)
);

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

always_comb 
begin
	case(sel_pc)
		0: pc_out = pc_in + 1;
		1: pc_out = ir_q[10:0];
		2: pc_out = stack_out;
	endcase
end

//assign pc_out = sel_pc ? ir_q[10:0] : pc_in + 1;

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

assign incf = ir_q[13:8] == 6'h0a;
assign iorwf = ir_q[13:8] == 6'h04;
assign movf = ir_q[13:8] == 6'h08;
assign movwf = ir_q[13:7] == 7'b0000001;
assign subwf = ir_q[13:8] == 6'h02;
assign xorwf = ir_q[13:8] == 6'h06;

assign bcf = ir_q[13:10] == 4'b0100;
assign bsf = ir_q[13:10] == 4'b0101;
assign btfsc = ir_q[13:10] == 4'b0110;
assign btfss = ir_q[13:10] == 4'b0111;
assign decfsz = ir_q[13:8] == 6'b001011;
assign incfsz = ir_q[13:8] == 6'b001111;

assign asrf = ir_q[13:8] == 6'b110111;
assign lslf = ir_q[13:8] == 6'b110101;
assign lsrf = ir_q[13:8] == 6'b110110;
assign rlf = ir_q[13:8] == 6'b001101;
assign rrf = ir_q[13:8] == 6'b001100;
assign swapf = ir_q[13:8] == 6'b001110;

assign dir = ir_q[7];
assign sel_bit = ir_q[9:7];
assign addr_port_b = (ir_q[6:0] == 7'h0d);

assign mux1_out = sel_alu ?  ram_mux[7:0] : ir_q[7:0];

assign btfsc_skip_bit = (ram_out[ir_q[9:7]] == 0);
assign btfss_skip_bit = (ram_out[ir_q[9:7]] == 1);
assign btfsc_btfss_skip_bit = (btfsc&btfsc_skip_bit)|(btfss&btfss_skip_bit);

assign databus = sel_bus ? w_q[7:0] : alu[7:0];

assign alu_zero = (alu == 0);

always_comb
begin
	case(sel_ram_mux)
		0: ram_mux = ram_out;
		1: ram_mux = bcf_mux;
		2: ram_mux = bsf_mux;
	endcase
end

always_ff@ (posedge clk)
begin
	if(rst) port_b_out <= 7'b0;
	else if(load_port_b) port_b_out <= databus;
end

always_comb
begin
	case(sel_bit)
		3'b000: bcf_mux = ram_out & 8'b1111_1110;
		3'b001: bcf_mux = ram_out & 8'b1111_1101;
		3'b010: bcf_mux = ram_out & 8'b1111_1011;
		3'b011: bcf_mux = ram_out & 8'b1111_0111;
		3'b100: bcf_mux = ram_out & 8'b1110_1111;
		3'b101: bcf_mux = ram_out & 8'b1101_1111;
		3'b110: bcf_mux = ram_out & 8'b1011_1111;
		3'b111: bcf_mux = ram_out & 8'b0111_1111;
	endcase
end
always_comb
begin
	case(sel_bit)
		3'b000: bsf_mux = ram_out | 8'b0000_0001;
		3'b001: bsf_mux = ram_out | 8'b0000_0010;
		3'b010: bsf_mux = ram_out | 8'b0000_0100;
		3'b011: bsf_mux = ram_out | 8'b0000_1000;
		3'b100: bsf_mux = ram_out | 8'b0001_0000;
		3'b101: bsf_mux = ram_out | 8'b0010_0000;
		3'b110: bsf_mux = ram_out | 8'b0100_0000;
		3'b111: bsf_mux = ram_out | 8'b1000_0000;
	endcase
end
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
	    10: alu = {mux1_out[7], mux1_out[7:1]};
		11: alu = {mux1_out[6:0], 1'b0};
		12: alu = {1'b0, mux1_out[7:1]};
		13: alu = {mux1_out[6:0], mux1_out[7]};
		14: alu = {mux1_out[0], mux1_out[7:1]};
		15: alu = {mux1_out[3:0], mux1_out[7:4]};
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
	sel_pc = 0; sel_alu = 0; ram_en = 0; sel_bus = 0; load_port_b = 0;
	sel_ram_mux = 0;
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
				if(dir)
				begin
					op = 9;
					ram_en = 1;
				end
				else
				begin
					sel_alu = 1;
					op = 9;
				end
			end
			else if(decf)
			begin
				if(dir)
				begin
					op = 7;
					ram_en = 1;
				end
				else
				begin
					sel_alu = 1;
					op = 7;
				end
			end
			else if(goto)
			begin
				sel_pc = 1;
				load_pc = 1;
			end
			else if(incf)
			begin
				if(dir)
				begin
					ram_en = 1;
					sel_bus = 0;
					op = 6;
					sel_alu = 1;
				end
				else
				begin
					load_w = 1;
					op = 6;
					sel_alu = 1;
				end
			end
			else if(iorwf)
			begin
				if(dir)
				begin
					ram_en = 1;
					sel_bus = 0;
					op = 3;
					sel_alu = 1;
				end
				else
				begin
					load_w = 1;
					op = 3;
					sel_alu = 1;
				end
			end
			else if(movf)
			begin
				if(dir)
				begin
					ram_en = 1;
					sel_bus = 0;
					op = 5;
					sel_alu = 1;
				end
				else
				begin
					load_w = 1;
					op = 5;
					sel_alu = 1;
				end
			end
			else if(movwf)
			begin
				sel_bus = 1;
				if(addr_port_b == 1)
					load_port_b = 1;
				else if(addr_port_b == 0)
					ram_en = 1;
			end
			else if(subwf)
			begin
				if(dir)
				begin
					ram_en = 1;
					sel_bus = 0;
					op = 1;
					sel_alu = 1;
				end
				else
				begin
					load_w = 1;
					op = 1;
					sel_alu = 1;
				end
			end
			else if(xorwf)
			begin
				if(dir)
				begin
					ram_en = 1;
					sel_bus = 0;
					op = 4;
					sel_alu = 1;
				end
				else
				begin
					load_w = 1;
					op = 4;
					sel_alu = 1;
				end
			end
			else if(bcf)
			begin
				sel_alu = 1;
				sel_ram_mux = 1;
				op = 5;
				sel_bus = 0;
				ram_en = 1;
			end
			else if(bsf)
			begin
				sel_alu = 1;
				sel_ram_mux = 2;
				op = 5;
				sel_bus = 0;
				ram_en = 1;
			end
			else if(btfsc)
			begin
				if(btfsc_btfss_skip_bit)
				begin
					load_pc = 1;
					sel_pc = 0;
				end
			end
			else if(btfss)
			begin
				if(btfsc_btfss_skip_bit)
				begin
					load_pc = 1;
					sel_pc = 0;
				end
			end
			else if(decfsz)
			begin
				if(dir)
				begin
					sel_alu = 1;
					op = 7;
					ram_en = 1;
					sel_bus = 0;
					if(alu_zero)
					begin
						load_pc = 1;
						sel_pc = 0;
					end
				end
				else
				begin
					sel_alu = 1;
					op = 7;
					load_w = 1;
					if(alu_zero)
					begin
						load_pc = 1;
						sel_pc = 0;
					end
				end
			end
			else if(incfsz)
			begin
				if(dir)
				begin
					sel_alu = 1;
					op = 6;
					ram_en = 1;
					sel_bus = 0;
					if(alu_zero)
					begin
						load_pc = 1;
						sel_pc = 0;
					end
				end
				else
				begin
					sel_alu = 1;
					op = 6;
					load_w = 1;
					if(alu_zero)
					begin
						load_pc = 1;
						sel_pc = 0;
					end
				end
			end
			else if(asrf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 10;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
			end
			else if(lslf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 11;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
			end
			else if(lsrf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 12;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
			end
			else if(rlf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 13;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
			end
			else if(rrf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 14;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
			end
			else if(swapf)
			begin
				sel_alu = 1;
				sel_ram_mux = 0;
				op = 15;
				if(dir)
				begin
					sel_bus = 0;
					ram_en = 1;
				end
				else
				begin
					load_w = 1;
				end
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