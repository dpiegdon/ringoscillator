
// random number generator based on a 16 bit LFSR that is seeded
// from a metastable source
module randomized_lfsr16(input clk, output wire [0:15] out, output wire metastable);

	metastable_oscillator osci(metastable);
	lfsr shiftreg(clk, metastable, out);

endmodule

