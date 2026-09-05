module counter_4bits(
	input clk,
	input rst,
	input load,
	output logic [3:0] q
	);	

always_ff @(posedge clk, negedge rst) begin
	if(!rst)
		q <= 4'b0;
	else if(load)
		q <= (q == 4'b1111) ? 4'b0 :q + 1; //q到15後歸零
	end
endmodule