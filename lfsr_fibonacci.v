
// implements a fibonacci 16-bit linear feedback shift register
// that allows to shift additional random bits into the front
// to improve its randomness.
// NOTE that only after 16 clocks it will no longer contain data from the
// previous cycle.
module lfsr_fibonacci(input clk, input random, output reg [0:15] lfsr);

	wire feedback;
	assign feedback = (random ^ lfsr[10] ^ lfsr[12] ^ lfsr[13] ^ lfsr[15]);
	reg init_done = 0;

	always @ (posedge clk)
	begin
		if(init_done) begin
			lfsr <= {feedback, lfsr[0:14]};
		end else begin
			lfsr <= 16'b1010_1100_1110_0001;
			init_done <= 1;
		end
	end

endmodule

