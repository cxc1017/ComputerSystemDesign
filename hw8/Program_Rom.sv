module Program_Rom(
	output logic [13:0] Rom_data_out, 
	input [10:0] Rom_addr_in
);

    logic [13:0] data;
    always_comb
        begin
            case (Rom_addr_in)
                11'h0 : data = 14'h01A5;	//clrf	
                11'h1 : data = 14'h0103;	//clrw
                11'h2 : data = 14'h3006;	//movlw
                11'h3 : data = 14'h07A5;	//addlw
                11'h4 : data = 14'h3005;	//movlw
                11'h5 : data = 14'h0725;	//addwf
                11'h6 : data = 14'h3E02;	//addlw
                11'h7 : data = 14'h05A5;	//andwf
				11'h8 : data = 14'h03A5;	//decf
				11'h9 : data = 14'h09A5;	//comf
				11'ha : data = 14'h280A;	//goto 
				//don't care
				11'hb : data = 14'h3400;
				11'hc : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule
