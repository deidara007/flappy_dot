module collision_detect(dot_x, dot_y, col1_op, col2_op, col3_op, col4_op, collided);
	input [7:0] dot_x;
	input [6:0] dot_y;
	input [6:0] col1_op;
	input [6:0] col2_op;
	input [6:0] col3_op;
	input [6:0] col4_op;
	output reg collided;

	localparam	COL1 = 8'd32,
					COL2 = 8'd64,
               COL3 = 8'd96,
               COL4 = 8'd128,
					UP_WIDTH = 7'd11,
					DOWN_WIDTH = 7'd34;

	// define parts where collisions happen, if coordinates of the dot are there, set collision to 1, else set to 0
	always @(*) 
		begin
			if ((dot_x == COL1 || dot_x == (COL1 + 1'b1)) && (dot_y < col1_op - UP_WIDTH || dot_y > (col1_op + DOWN_WIDTH)))
				collided = 1'b1;  
			else if ((dot_x == COL2 || dot_x == (COL2 + 1'b1)) && (dot_y < col2_op - UP_WIDTH || dot_y > (col2_op + DOWN_WIDTH)))
				collided = 1'b1; 
			else if ((dot_x == COL3 || dot_x == (COL3 + 1'b1)) && (dot_y < col3_op - UP_WIDTH|| dot_y > (col3_op + DOWN_WIDTH)))
				collided = 1'b1; 
			else if ((dot_x == COL4 || dot_x == (COL4 + 1'b1)) && (dot_y < col4_op - UP_WIDTH || dot_y > (col4_op + DOWN_WIDTH)))
				collided = 1'b1; 
			else if (dot_y == 7'd121)
				collided = 1'b1;
			else
				collided = 1'b0;
		end

endmodule
