module counter(
	input clk,
	input rst,
	output logic[7:0] s, 
	output logic[7:0] port_A,
	output logic[7:0] port_B
);

logic cnt, load, loadA, loadB;
logic [7:0]w;
logic [7:0]b;

typedef enum{T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17, T18, T19, T20, T21} state_t;
state_t ps, ns;

always_ff@(posedge clk)
begin
	if(rst) b <= 8'b00000000;
	else b <= b+1;
end

assign w = s + b;

always_ff@(posedge clk)
begin
	if(rst) s <= 8'b00000000;
	else if(load) s <= w;
end

always_ff@(posedge clk) //load_A在加到10時變成1，把資料存入port_A
begin
	if(rst) port_A <= 8'b00000000;
	else if(loadA) port_A <= s;
end
always_ff@(posedge clk) //load_B在加到20時變成1，把資料存入port_B
begin
	if(rst) port_B <= 8'b00000000;
	else if(loadB) port_B <= s;
end

always_ff@(posedge clk)
begin
	if(rst) ps <= T0;
	else ps <= ns;
end

always_comb //FSM
begin
	ns = T0; cnt = 0; load = 0; loadA = 0; loadB = 0;
	case(ps)
		T0:
		begin
			cnt = 1;
			load = 1;
			ns = T1;
		end
		T1:
		begin
			cnt = 1;
			load = 1;
			ns = T2;
		end
		T2:
		begin
			cnt = 1;
			load = 1;
			ns = T3;
		end
		T3:
		begin
			cnt = 1;
			load = 1;
			ns = T4;
		end
		T4:
		begin
			cnt = 1;
			load = 1;
			ns = T5;
		end
		T5:
		begin
			cnt = 1;
			load = 1;
			ns = T6;
		end
		T6:
		begin
			cnt = 1;
			load = 1;
			ns = T7;
		end
		T7:
		begin
			cnt = 1;
			load = 1;
			ns = T8;
		end
		T8:
		begin
			cnt = 1;
			load = 1;
			ns = T9;
		end
		T9:
		begin
			cnt = 1;
			load = 1;
			ns = T10;
		end
		T10:
		begin
			cnt = 1;
			load = 1;
			ns = T11;
		end
		T11:
		begin
			cnt = 1;
			load = 1;
			loadA = 1;
			ns = T12;
		end
		T12:
		begin
			cnt = 1;
			load = 1;
			ns = T13;
		end
		T13:
		begin
			cnt = 1;
			load = 1;
			ns = T14;
		end
		T14:
		begin
			cnt = 1;
			load = 1;
			ns = T15;
		end
		T15:
		begin
			cnt = 1;
			load = 1;
			ns = T16;
		end
		T16:
		begin
			cnt = 1;
			load = 1;
			ns = T17;
		end
		T17:
		begin
			cnt = 1;
			load = 1;
			ns = T18;
		end
		T18:
		begin
			cnt = 1;
			load = 1;
			ns = T19;
		end
		T19:
		begin
			cnt = 1;
			load = 1;
			ns = T20;
		end
		T20:
		begin
			load = 1;
			ns = T21;
		end
		T21:
		begin
			loadB = 1;
			ns = T21;
		end
	endcase
end

endmodule