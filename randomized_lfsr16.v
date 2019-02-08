
// random number generator based on a 16 bit LFSR that is
// seeded with multiple ring oscillators, which in turn
// generate randomness via metastable state in a LUT.
module randomized_lfsr16(input CLK, input reset, output wire [0:15] out);

	wire random;

	wire s0, s1, s2, s3;

	ringoscillator r0(s0);
	ringoscillator r1(s1);
	ringoscillator r2(s2);
	ringoscillator r3(s3);

	SB_LUT4 #(.LUT_INIT(16'b1010_1100_1110_0001))
		destabilizer (.O(random), .I0(s0), .I1(s1), .I2(s2), .I3(s3));

	lfsr_fibonacci fibo(CLK, 0, random, out);

endmodule

