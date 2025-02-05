module vga_input_choice(done_col, col_x, col_y, col_colour, dot_x, dot_y, dot_colour, x, y, colour);
	input done_col;
	input [7:0] col_x, dot_x;
	input [6:0] col_y, dot_y;
	input [2:0] dot_colour, col_colour;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	
	always @(*)
	begin
		if (!done_col) begin
			// if columns are still being drawn make vga take columns input
			x = col_x;
			y = col_y;
			colour = col_colour;
			end
		else begin
			// else make it take input from the dot
			x = dot_x;
			y = dot_y;
			colour = dot_colour;
			end
	end
endmodule
