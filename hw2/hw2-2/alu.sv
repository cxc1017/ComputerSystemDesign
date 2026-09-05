module alu(
	input logic [3:0]a, b,
	input logic op,
	output logic [3:0]s,
	output logic C	//進位
	);
	logic [4:0] temp;
	assign temp = op ? a-b : a+b;
	assign s = temp[3:0];
	assign C = temp[4];
endmodule