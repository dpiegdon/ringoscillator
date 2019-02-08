
// implements a fibonacci 16-bit linear feedback shift register
// that allows to shift additional random bits into the front
// to improve its randomness.
// NOTE that only after 16 clocks it will no longer contain data from the
// previous cycle.
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
	
