module traffic_light(
	input clk,
	input rst,
	output logic [1:0] R,
	output logic [1:0] Y,
	output logic [1:0] G
);
logic [2:0] ncount, ccount;

typedef enum {s0, s1, s2, s3} state_t; //s0 is R[0]=1, G[1]=1; s1 is R[0]=1, Y[1]=1;
state_t ps, ns;                        //s2 is G[0]=1, R[1]=1; s3 is Y[0]=1, R[1]=1;

always_ff@(posedge clk)
begin
	if(rst) begin 
		ps <= s0;
		ccount <= 3'b001;
	end
	else begin
		ps <= ns;
		ccount <= ncount;
	end
end
//next state設定
always_comb
begin
	case(ps)
		s0:
		begin
			ncount = (ccount < 3) ? ccount + 1 : 1; //ncount存回ccount需1個clk，reset為1
			ns = (ccount < 3) ? s0 : s1;
		end
		s1:
		begin
			ncount = (ccount < 2) ? ccount + 1 : 1;
			ns = (ccount < 2) ? s1 : s2;
		end
		s2:
		begin
			ncount = (ccount < 3) ? ccount + 1 : 1;
			ns = (ccount < 3) ? s2 : s3;
		end
		s3:
		begin
			ncount = (ccount < 2) ? ccount + 1 : 1;
			ns = (ccount < 2) ? s3 : s0;
		end
	endcase
end
//output 設定
always_comb
begin
	case(ps)
		s0:
		begin
			R[0] = 1;
			Y[0] = 0;
			G[0] = 0;
			R[1] = 0;
			Y[1] = 0;
			G[1] = 1;
		end
		s1:
		begin
			R[0] = 1;
			Y[0] = 0;
			G[0] = 0;
			R[1] = 0;
			Y[1] = 1;
			G[1] = 0;
		end
		s2:
		begin
			R[0] = 0;
			Y[0] = 0;
			G[0] = 1;
			R[1] = 1;
			Y[1] = 0;
			G[1] = 0;
		end
		s3:
		begin
			R[0] = 0;
			Y[0] = 1;
			G[0] = 0;
			R[1] = 1;
			Y[1] = 0;
			G[1] = 0;
		end
	endcase
end

endmodule