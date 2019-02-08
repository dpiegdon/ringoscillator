
module top(input CLK, output J1_10);

	wire [0:15] lfsr;
	randomized_lfsr16 lfsr16_generator(CLK, 0, lfsr);

	assign J1_10 = lfsr[15];

endmodule

