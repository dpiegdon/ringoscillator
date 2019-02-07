
module lfsr_fibonacci(input CLK, input reset, input random, output reg [0:15] out);

	wire feedback;
	assign feedback = (random ^ out[10] ^ out[12] ^ out[13] ^ out[15]);
	
	always @ (posedge CLK)
	begin
		if(reset)
			out <= 16'b1010_1100_1110_0001;
		else
			out <= {feedback, out[0:14]};
	end

endmodule
	
