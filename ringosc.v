`timescale 1ns / 1ps

module top(input CLK, output J1_10, LED0, LED1, LED2, LED3, LED4);
	// ring oscillator

	wire chain_in, chain_out;

	assign J1_10 = chain_out;
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
