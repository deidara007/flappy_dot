module rate_divider(CLOCK_50, rate, update_clk);
	input CLOCK_50;
	input [28:0] rate;
	output reg update_clk;
	
	reg [28:0] cur_rate;
	
	// make a clock with rate of (500000000/rate) clock cycles per second
	always @(posedge CLOCK_50)
	begin
		if(cur_rate == 0) begin
			cur_rate <= rate;
			update_clk <= 1'b1;
			end
		else begin
			cur_rate <= cur_rate - 1'b1;
			update_clk <= 1'b0;
			end
	end

endmodule