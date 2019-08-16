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

	wire [7:0] uart_rxByte;
	wire uart_received;

	wire reset_in;
	assign reset_in = uart_received && (uart_rxByte == 8'h72);

	wire rst;
	synchronous_reset_timer resetter(CLK, rst, reset_in);

	wire [15:0] lfsr;
	wire metastable;
	wire bit_ready;
	wire word_ready;
	randomized_lfsr randomized_lfsr(CLK, rst, bit_ready, word_ready, lfsr, metastable);

	wire is_transmitting;
	wire dataReady;

	uart #(.CLOCKFRQ(12000000), .BAUDRATE(3000000) ) uart(
		.clk(CLK),
		.rst(rst),
		.rx(RX),
		.tx(TX),
		.transmit(!is_transmitting & word_ready),
		.tx_byte(lfsr[7:0]),
		.received(uart_received),
		.rx_byte(uart_rxByte),
		.is_receiving(),
		.is_transmitting(is_transmitting),
		.recv_error()
	);

	wire ringosci_insane_out;
	ringoscillator #(.DELAY_LUTS(0))
		ringosci_insane(ringosci_insane_out);

	wire ringosci_fast_out;
	ringoscillator #(.DELAY_LUTS(1))
		ringosci_fast(ringosci_fast_out);

	wire ringosci_slow_out;
	ringoscillator #(.DELAY_LUTS(20))
		ringosci_slow(ringosci_slow_out);

	assign J1_10 = metastable;

	assign J1_9 = lfsr[0];
	assign J1_8 = bit_ready;
	assign J1_7 = word_ready;
	assign J1_6 = 0;
	assign J1_5 = ringosci_insane_out;
	assign J1_4 = ringosci_fast_out;
	assign J1_3 = ringosci_slow_out;

endmodule

