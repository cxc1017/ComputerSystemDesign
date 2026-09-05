module clock(
	input logic clk,
	input logic rst,
	output logic [5:0] min,
	output logic [4:0] hr,
	output logic red
	);
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        if (min == 59) begin //59分時，min歸零
            min <= 0;
			if (hr == 23) begin //23時，hr歸零，紅線變成0
				hr <= 0;
				red <= 0;
			end
			else if(hr == 19) begin //時的二位數變成2時，紅線變成1
				hr <= hr + 1;
				red <= 1;
			end
			else begin
				hr <= hr + 1;
			end
		end
		else begin
			min <= min + 1;
		end
    end
    else begin	//rst==1時歸零
        min <= 0;
        hr <= 0;
        red <= 0;
    end
end

endmodule