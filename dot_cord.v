module dot_cord(reset_col, dot_y_cord, dot_x_cord, dot_clk, up, collided, keep_moving);
	input dot_clk;
	input up;
	input collided;
	input keep_moving;
	output reg [6:0] dot_y_cord = 7'd59;
	output reg [7:0] dot_x_cord = 8'd0;
	output reg reset_col;
	
	always @(posedge dot_clk)
	begin
		if (collided) begin
			// reset the coordinate of th edot if it collided with a pipe
			dot_y_cord <= 7'd59;
			dot_x_cord <= 8'd0;
			reset_col <= 1'b0;
			end
		else if (!keep_moving) begin
			// freeze all movement if keep_moving signal is low
			dot_x_cord <= dot_x_cord;
			dot_y_cord <= dot_y_cord;
			reset_col <= 1'b1;
			end
		else if (dot_x_cord == 8'd160) begin
			// if dot reached the end of the screen, make it go back, and send signal to reset columns
			reset_col <= 1'b0;
			dot_x_cord <= 8'd0;
			end
		else if (up) begin
			// if up is on make the dot go up and right
			dot_y_cord <= dot_y_cord - 1;
			dot_x_cord <= dot_x_cord + 1;
			reset_col <= 1'b1;
			end
		else begin
			// moves down, and moves right
			dot_y_cord <= dot_y_cord + 1;
			dot_x_cord <= dot_x_cord + 1;
			reset_col <= 1'b1;
			end
	end

endmodule