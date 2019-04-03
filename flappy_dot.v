module flappy_dot
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
			LEDR,
        KEY,
        SW,
		  HEX0,
		  HEX1,
		  HEX4,
		  HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [17:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX5;

	// Declare wires.
	wire [2:0] colour, col_colour, dot_colour;
	wire [7:0] x, dot_x, col_x;
	wire [6:0] y, dot_y, col_y, col1_op, col2_op, col3_op, col4_op, col5_op;
	wire collided;
	wire reset_col;
	wire [7:0] score, high_score;
	
	// Create an Instance of a VGA controller
	vga_adapter VGA(
			.resetn(KEY[3]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;	
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// columns maker that outputs the x,y coordinates, and colour of pipes that it is drawing,,
	// as well as the y-cordinates of the gaps in the pipes
	columns(
			.done_col(done_col),
			.draw(draw),
			.col_x(col_x),
			.col_y(col_y),
			.col_colour(col_colour),	
			.reset_col(reset_col),
			.clk(CLOCK_50),
			.col1_op(col1_op),
			.col2_op(col2_op),
			.col3_op(col3_op),
			.col4_op(col4_op)
			);
	
	// dot maker that outputs the x,y coordinates, and colour of the dot, as well as the current
	// score and highscore
	dot_obj(
			.high_score(high_score),
			.score(score),
			.reset_col(reset_col),
			.dot_x(dot_x),
			.dot_y(dot_y),
			.dot_colour(dot_colour),
			.dot_collided(collided),
			.dot_up(KEY[0]),
			.clk50(CLOCK_50),
			.keep_moving(KEY[1])
			);
	
	// collision detector sends a collided signal if x,y coordinates of a dot are the same as
	// the collision objects
	collision_detect(
			.dot_x(dot_x),
			.dot_y(dot_y),
			.col1_op(col1_op),
			.col2_op(col2_op),
			.col3_op(col3_op),
			.col4_op(col4_op),
			.collided(collided)
			);
	
	// vga input provider that x,y coordinates and colour to send to the vga(dot or pipe)
	vga_input_choice(
			.done_col(done_col),
			.col_x(col_x),
			.col_y(col_y),
			.col_colour(col_colour),
			.dot_x(dot_x),
			.dot_y(dot_y),
			.dot_colour(dot_colour),
			.x(x),
			.y(y),
			.colour(colour)
			);
	
	// hex decoders to display score and highscore
	hex_decoder first_score_dig(
			.hex_digit(score[3:0]),
			.segments(HEX0)
			);
	
	hex_decoder second_score_dig(
			.hex_digit(score[7:4]),
			.segments(HEX1)
			);
			
	hex_decoder first_highscore_dig(
			.hex_digit(high_score[3:0]),
			.segments(HEX4)
			);
	
	hex_decoder second_highscore_dig(
			.hex_digit(high_score[7:4]),
			.segments(HEX5)
			);

endmodule
