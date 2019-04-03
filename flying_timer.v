module flying_timer(clk50, up, key_press);
	output reg up;
	input key_press;
	input clk50;
	
	reg [27:0] timer;
	localparam FLYING_TIME = 28'd35000000;
	
	
	always @(posedge clk50)
	begin
		if (!key_press) begin
			// if key is pressed reset the timer, send signal for dot to go down
			timer = FLYING_TIME;
			up <= 1'b0;
			end
		else if (timer == 28'd0)
			// if timer ran out make dot go down
			up <= 1'b0;
		else begin
			// if timer is running (key was recently pressed),send signal for dot to go up
			up <= 1'b1;
			timer <= timer - 1'b1;
			end
	end

endmodule