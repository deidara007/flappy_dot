module columns(col1_op, col2_op, col3_op, col4_op, done_col, draw, col_x, col_y, col_colour, reset_col, clk);
	output [7:0] col_x;
	output [6:0] col_y, col1_op, col2_op, col3_op, col4_op;
	output [2:0] col_colour;
	output draw, done_col;
	input clk;
	input reset_col;
	
	wire [6:0] opening_pos;
	wire [7:0] col_start;
	wire [6:0] vert_dist;
	wire hor_dist;
		
   // Instansiate datapath
	col_datapath D0(
		  .vert_dist(vert_dist),
		  .hor_dist(hor_dist),
		  .col_start(col_start),
        .opening_pos(opening_pos),
		  .x(col_x),
		  .y(col_y),
		  .colour_out(col_colour)
    );
	
    // Instansiate FSM control
	 col_control C0(
        .clk(clk),
        .resetn(reset_col),
		  .vert_dist(vert_dist),
		  .hor_dist(hor_dist),
		  .col_start(col_start),
        .opening_pos(opening_pos),
		  .draw(draw),
		  .done_col(done_col),
		  .col1_op(col1_op),
		  .col2_op(col2_op),
		  .col3_op(col3_op),
		  .col4_op(col4_op)
		);
endmodule


module col_control(
	input resetn,
	input clk,
	output reg [7:0] col_start,
	output reg [6:0] opening_pos,
	output reg draw,
	output [6:0] vert_dist,
	output hor_dist,
	output reg [6:0] col1_op, col2_op, col3_op, col4_op,
	output reg done_col
	);
	wire go;
	wire [1:0] random;
	assign random = random_num[1:0];
	reg [3:0] current_state;
	reg [3:0] next_state;
	reg clr;
	
	wire [7:0] counter;
	assign vert_dist = counter[6:0];
	assign hor_dist = counter[7];
	wire [3:0] random_num;
	
	// eight bit counter to get coordinates of current drawn pixel
	eight_bit_counter(
		.q(counter),
		.go(go),
		.clk(clk),
		.clr(clr),
		.enable(1'b1)
	);
	
	// random number generator to help randomly generate columns
	random(
		.out(random_num),
		.clk(clk)
	);
	
	// constants
	localparam	COL1 = 8'd32,
					COL2 = 8'd64,
               COL3 = 8'd96,
               COL4 = 8'd128,
					OPENING = 5'd20,
					
					PRE_LOAD = 4'd0,
					LOAD_COL1 = 4'd1,
               LOAD_COL1_WAIT = 4'd2,
               LOAD_COL2 = 4'd3,
               LOAD_COL2_WAIT = 4'd4,
					LOAD_COL3 = 4'd5,
               LOAD_COL3_WAIT = 4'd6,
					LOAD_COL4 = 4'd7,
               LOAD_COL4_WAIT = 4'd8,
					DONE = 4'd9;
					
	// state_table
	always@(*)
   begin: state_table 
			case (current_state)
				 PRE_LOAD: next_state = LOAD_COL1; 
				 LOAD_COL1: next_state = LOAD_COL1_WAIT;
				 LOAD_COL1_WAIT: next_state = go ? LOAD_COL2: LOAD_COL1_WAIT; // go to next state after first col is drawn
				 LOAD_COL2: next_state = LOAD_COL2_WAIT; 
				 LOAD_COL2_WAIT: next_state = go ? LOAD_COL3 : LOAD_COL2_WAIT; // go to next state after second col is drawn
				 LOAD_COL3: next_state = LOAD_COL3_WAIT; 
				 LOAD_COL3_WAIT: next_state = go ? LOAD_COL4: LOAD_COL3_WAIT; // go to next state after third col is drawn
				 LOAD_COL4: next_state = LOAD_COL4_WAIT; 
				 LOAD_COL4_WAIT: next_state = go ?  DONE : LOAD_COL4_WAIT;  // go to DONE state after col4 is done drawing
				 DONE: next_state = DONE;
				default:     next_state = PRE_LOAD;
			endcase
    end 
	
	 // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
				// if reset is 0, go to WAIT state to redraw columns
            current_state <= PRE_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
	
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
		  draw = 1'b1; // always draw
		  done_col = 1'b0; // on default the done signal is 0
		  clr = 1'b0; // reset the counter on default
		  
        case (current_state)
				PRE_LOAD: begin
					draw = 1'b0;
					end
            LOAD_COL1: begin
					col_start = COL1; // set the column x coordinate to datapath
					opening_pos = (random_num[1:0] + 1'b1)*OPENING; // get the opening position for col1
					end
				LOAD_COL1_WAIT: begin
					clr = 1'b1; // start the counter
					col_start = COL1; // set the column x coordinate to datapath
					col1_op = opening_pos; // output the opening position for col1
					end
            LOAD_COL2: begin
					 col_start = COL2; // set the column x coordate to datapath
					 opening_pos = (random_num[1:0] + 1'b1)*OPENING; // get the opening position for col2
					 end
				LOAD_COL2_WAIT: begin
					clr = 1'b1; // start the counter
					col_start = COL2; // set the column x coordate to datapath
					col2_op = opening_pos; // output opening position for col2
					end
				LOAD_COL3: begin
					col_start = COL3; // set the column x coordate to datapath
					opening_pos = (random_num[1:0] + 1'b1)*OPENING; // get the opening position for col3
					end
				LOAD_COL3_WAIT: begin
					clr = 1'b1; // start the counter
					col_start = COL3; // set the column x coordate to datapath
					col3_op = opening_pos; // output opening position for col3
					end
				LOAD_COL4: begin			
					col_start = COL4; // set the column x coordate to datapath
					opening_pos = (random_num[1:0] + 1'b1)*OPENING; // get the opening position for col4
					end
				LOAD_COL4_WAIT: begin
					clr = 1'b1; // start the counter
					col_start = COL4; // set the column x coordate to datapath
					col4_op = opening_pos; // output opening position for col4
					end
				DONE: begin
					done_col = 1'b1; // set the done drawing pipes signal to 1
					end
        endcase
    end // enable_signals
endmodule

module col_datapath(
	 input hor_dist,
	 input [6:0] vert_dist,
	 input [7:0] col_start,
	 input [6:0] opening_pos,
	 output [6:0] y,
	 output [7:0] x,
	 output reg [2:0] colour_out
    );
	 
	 localparam UP_WIDTH = 7'd11,
					DOWN_WIDTH = 7'd34;

	 assign x = col_start + hor_dist;
	 assign y = vert_dist;
    
	 // choose color to make an opening in the columns
	 always@(*)
	 begin
		 if (vert_dist >= opening_pos - UP_WIDTH && vert_dist <= opening_pos + DOWN_WIDTH)
			// set colour to black if it's the pipe opening coordinate
			colour_out = 3'b000;
		 else
			// otherwise set it white to draw the pipe
			colour_out = 3'b111;
	 end
	 
endmodule

module eight_bit_counter(q, go, clr, clk, enable);
   input enable, clk, clr;
	output reg [7:0] q;
	output reg go;
   
   always@(posedge clk, negedge clr)
   begin
	if (clr == 1'b0) begin
	   q <= 8'd0;
		go <= 1'b0;
		end
	else if (q == 8'b11111111) begin
		q <= 8'd0;
		go <= 1'b1;
		end
	else if (enable == 1'b1) begin
	   q <= q + 1'b1;
		go <= 1'b0;
		end
	end
endmodule
