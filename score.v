module score(score, dot_x, dot_clk, dot_collided);
	input dot_clk;
	input [7:0] dot_x;
	input dot_collided;
	output reg [7:0] score = 8'd0;

	localparam	COL1 = 8'd32,
					COL2 = 8'd64,
					COL3 = 8'd96,
					COL4 = 8'd128;
				
	always @(posedge dot_clk)
	begin
		if (dot_collided)
			// reset the score if dot collides with something
			score <= 8'd0;
		else if (dot_x == COL1 + 8'd2 || dot_x == COL2 + 8'd2 || dot_x == COL3 + 8'd2 || dot_x == COL4 + 8'd2)
			// if dot passes a column, increase score by 1
			score <= score + 1'b1;
		else
			// else don't change the score
			score <= score;
	end

endmodule