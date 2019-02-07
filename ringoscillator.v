
module ringoscillator(input CLK, output OUT);
	wire chain_in, chain_out;

	assign OUT = chain_out;
	assign chain_in = !chain_out;

	SB_LUT4 #(
		.LUT_INIT(16'd2)
	) buffers (
		.O(chain_out),
		.I0(chain_in),
		.I1(1'b0),
		.I2(1'b0),
		.I3(1'b0)
	);
endmodule

