module pipeline(
	input clk,
	input rst, 
	input [4:0] a, b, c, d, e,
	output logic[4:0] s
);
logic [5:0] ABsum, CDsum , minus;
logic [5:0] x, y, z, e1, e2;

assign ABsum = a + b; //AB加法
assign CDsum = c + d; //CD加法
assign minus = x - y; //AB和CD減法
assign s = z & e2;	  

always_ff@(posedge clk) //AB加法經過pipeline
begin
	if(rst) x <= 5'b00000;
	else x <= ABsum;
end
always_ff@(posedge clk) //CD加法經過pipeline
begin
	if(rst) y <= 5'b00000;
	else y <= CDsum;
end
always_ff@(posedge clk) //z為減法經過pipeline
begin
	if(rst) z <= 5'b00000;
	else z <= minus;
end
always_ff@(posedge clk) //e經過第一個pipeline
begin
	if(rst) e1 <= 5'b00000;
	else e1 <= e;
end
always_ff@(posedge clk) //e經過第二個pipeline
begin
	if(rst) e2 <= 5'b00000;
	else e2 <= e1;
end
endmodule