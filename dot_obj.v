module dot_obj(high_score, score, reset_col, dot_x, dot_y, dot_colour, dot_collided, dot_up, clk50, keep_moving);
	output [2:0] dot_colour;
	output [7:0] dot_x;
	output [6:0] dot_y;
	output reset_col;
	output [7:0] score;
	output [7:0] high_score;
	input dot_collided;
	input dot_up;
	input clk50;
	input keep_moving;
	
	wire erase;
	wire dot_clk;
	wire up;
	wire [7:0] dot_x_cord;
	wire [6:0] dot_y_cord;
	assign dot_x = dot_x_cord;
	assign dot_y = dot_y_cord;
	
	// module that controls coordinates of the dot - changes each dot_clk cycle
	// which is simulated by the control
	dot_cord dc(
			.reset_col(reset_col),
			.keep_moving(keep_moving),
			.dot_clk(dot_clk),
			.up(up),
			.collided(dot_collided),
			.dot_y_cord(dot_y_cord),
			.dot_x_cord(dot_x_cord)
			);
	
	// score generator
	score(
			.score(score),
			.dot_x(dot_x_cord),
			.dot_clk(dot_clk),
			.dot_collided(dot_collided)
			);
	
	// high score keeper
	high_score_keeper(
			.high_score(high_score),
			.cur_score(score),
			.dot_clk(dot_clk)
			);
			
	// flying time when key is pressed, to send signal for dot to go up if timer is running
	flying_timer(
			.clk50(clk50),
			.key_press(dot_up),
			.up(up)
			);
	
	// datapath for the dot
	datapath_dot d0(
			.erase(erase),
			.x(dot_x_cord),
			.y(dot_y_cord),
			.x_out(dot_x),
			.y_out(dot_y),
			.col_out(dot_colour)
			);
	
    // FSM control for the dot that makes a clock for the dot
	control_dot c0(
			.erase(erase),
			.clk(clk50),
			.dot_clk(dot_clk)
			);

endmodule

module datapath_dot(erase, x, y, x_out, y_out, col_out);
	input erase;
	input [7:0] x;
	input [6:0] y;
	output [7:0] x_out;
	output [6:0] y_out;
	output reg [2:0] col_out;
	
	assign x_out = x;
	assign y_out = y;
	
	always@(*)
	 begin
		 if (erase == 1'b1)
			// if erase in on, make color black
			col_out = 3'b000;
		 else
			// else make it pinkish
			col_out = 3'b101;
	 end

endmodule

module control_dot(dot_clk, erase, clk);
	input clk;
	output reg erase;
	// one clock cycle will be generated when control goes through all the state
	output reg dot_clk = 1'b0;

	reg [3:0] current_state;
	reg [3:0] next_state;
	wire update_clk;
	
	// generate a customised clock(we will be erasing and drawing with rate 2M/50M)
	rate_divider(
			.CLOCK_50(clk),
			.rate(28'd2000000),
			.update_clk(update_clk)
			);
	
	
	localparam	ERASE = 4'd0,
					ERASE_DONE = 4'd1,
					DRAW_WAIT = 4'd2,
					DRAW = 4'd3;
					
	// state_table
	always@(*)
   begin: state_table 
            case (current_state)
						ERASE: next_state = ERASE_DONE; // state to erase the dot
						ERASE_DONE: next_state = DRAW_WAIT; // state to know when erasing is done
						DRAW_WAIT: next_state = update_clk ? DRAW : DRAW_WAIT; // wait for 2M/50M seconds to draw the next position
						DRAW: next_state = ERASE; // state to draw - go back to beggining after finish drawing
				default:     next_state = ERASE;
        endcase
	end 
	
	 // current_state registers
	always@(posedge clk)
	begin: state_FFs
		current_state <= next_state;
	end // state_FFS

	// Output logic aka all of our datapath control signals
	always @(posedge clk)
	begin: enable_signals
		erase <= 1'b1;
		case (current_state)
			ERASE: begin
					erase <= 1'b1; // set erase to 1 to erase the dot
					end
			ERASE_DONE: begin
					erase <= 1'b1; // still keep erase at 1
					dot_clk <= ~dot_clk; // here the dot_clk will go up - so the coordinates of the dot will be updated by 1
					end
			DRAW_WAIT: begin
					erase <= 1'b0; // keep erase at 0 to draw the dot
					end
			DRAW: begin
					erase <= 1'b0; // keep erase at 0 to draw the dot
					dot_clk <= ~dot_clk; // send clk to low (complete cycle)
					end
	  endcase
	end // enable_signals

endmodule