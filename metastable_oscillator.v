`default_nettype none

// Lattice ICE40 specific.
// May also work for ECP5 when `defining SB_LUT4 to LUT4.

// circuit generating a metastable output
module metastable_oscillator(output wire metastable);

	wire s0, s1, s2, s3;

	ringoscillator r0(s0);
	ringoscillator r1(s1);
	ringoscillator r2(s2);
	ringoscillator r3(s3);

	SB_LUT4 #(.LUT_INIT(16'b1010_1100_1110_0001))
		destabilizer (.O(metastable), .I0(s0), .I1(s1), .I2(s2), .I3(s3));

endmodule

