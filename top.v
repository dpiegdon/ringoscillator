`default_nettype none

module top(input wire CLK,
	output wire J1_10, 
	output wire J1_9, 
	output wire J1_8,
	output wire J1_7,
	output wire J1_6,
	output wire J1_5,
	output wire J1_4,
	output wire J1_3,
	input wire RX,
	output wire TX);

	wire ringosci_fast_out;
	ringoscillator #(.DELAY_LUTS(1))
		ringosci_fast(ringosci_fast_out);

	assign J1_4 = ringosci_fast_out;

endmodule

