// module that uses flip modules and xor gate to create random numbers(4 bit)
module random(out,clk);
    output [3:0] out;
	 input clk;
    xor (t0,out[3],out[2]);
    assign t1 = out[0];
    assign t2 = out[1];
    assign t3 = out[2];
    flip u1(out[0],t0,clk);
    flip1 u2(out[1],t1,clk);
    flip1 u3(out[2],t2,clk);
    flip1 u4(out[3],t3,clk);
endmodule

// module to flip output each clock cycle
module flip(q, t, clk);
    output q;
    input t, clk;
    reg q;
    initial 
     begin 
      q = 1'b1;
     end
    always @ (posedge clk)
    begin
        if (t == 1'b0)
				q = q;
        else
				q = ~q;
    end
endmodule

// another module to flip output each clock cycle 
module flip1(q , t, clk);
    output q;
    input t, clk;
    reg q;
    initial 
     begin 
      q = 1'b0;
     end
    always @ (posedge clk)
    begin
        if (t == 1'b0)
			q = q;
        else 
			q = ~q;
    end
endmodule
