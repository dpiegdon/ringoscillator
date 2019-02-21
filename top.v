`default_nettype none

module top(input wire CLK, output wire J1_10, output wire J1_8, output wire J1_6, input wire RX, output wire TX);

	wire [7:0] uart_rxByte;
	wire uart_received;

	wire reset_in;
	assign reset_in = uart_received && (uart_rxByte == 8'h72);

	wire rst;
	synchronous_reset_timer resetter(CLK, rst, reset_in);

	assign J1_6 = rst;

	wire [15:0] lfsr;
	wire metastable;
	randomized_lfsr16 lfsr16_generator(CLK, lfsr, metastable);

	assign J1_10 = lfsr[0];
	assign J1_8 = metastable;

	wire txReady;

	uart #(.CLOCKFRQ(12000000), .BAUDRATE(4000000) ) uart(
		.clk(CLK),
		.rst(rst),
		.rx(RX),
		.tx(TX),
		.transmit(txReady),
		.tx_free(txReady),
		.tx_byte(lfsr[7:0]),
		.received(uart_received),
		.rx_byte(uart_rxByte),
		.is_receiving(),
		.is_transmitting(),
		.recv_error()
	);

endmodule

