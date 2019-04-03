module high_score_keeper(high_score, cur_score, dot_clk);
	output reg [7:0] high_score;
	input [7:0] cur_score;
	input dot_clk;
	
	always @(posedge dot_clk)
	begin
		if (cur_score > high_score)
			// if current score is greater than highscore, update highscore
			high_score <= cur_score;
		else
			// else don't change the high score
			high_score <= high_score;
	end

endmodule