
module top(input CLK, output J1_10, output J1_8);

	wire [0:15] lfsr;
	wire metastable;

	randomized_lfsr16 lfsr16_generator(CLK, lfsr, metastable);

	assign J1_10 = lfsr[15];
	assign J1_8 = metastable;

endmodule

