module counter(
	input clk,
	input rst,
	output logic[3:0] w
);
logic[3:0] counter1;	
logic[2:0] counter2;
logic[3:0] s;
logic cnt1, cnt2, load;

typedef enum {T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10} state_t;
state_t ps, ns;

always_ff @(posedge clk) //counter1
begin
	if(rst) counter1 <= 4'b0000;
	else if(cnt1) counter1 <= counter1+1;
end
always_ff @(posedge clk) //counter2
begin
	if(rst) counter2 <= 3'b000;
	else if(cnt2) counter2 <= counter2+1;
end
	
assign s = counter1 + counter2;
assign w = s;

always_ff@(posedge clk, posedge rst)
begin
	if(rst) ps <= T0;
	else ps <= ns;
end
//FSM
always_comb
begin
	cnt1 = 0; cnt2 = 0; load = 0;
	case(ps)
		T0:
		begin
			cnt1 = 1;
			cnt2 = 1;
			load = 1;
			ns = T1;
		end
		T1:
		begin
			cnt1 = 1;
			cnt2 = 1;
			load = 1;
			ns = T2;
		end
		T2:
		begin
			cnt1 = 1;
			cnt2 = 1;
			load = 1;
			ns = T3;
		end
		T3:
		begin
			cnt1 = 1;
			cnt2 = 1;
			load = 1;
			ns = T4;
		end
		T4:
		begin
			cnt1 = 1;
			load = 1;
			ns = T5;
		end
		T5:
		begin
			cnt1 = 1;
			load = 1;
			ns = T6;
		end
		T6:
		begin
			cnt1 = 1;
			load = 1;
			ns = T7;
		end
		T7:
		begin
			cnt1 = 1;
			load = 1;
			ns = T8;
		end
		T8:
		begin
			cnt1 = 1;
			load = 1;
			ns = T9;
		end
		T9:
		begin
			load = 1;
			ns = T10;
		end
		T10:
		begin
			load = 0;
			ns = T10;
		end
	endcase
end

endmodule