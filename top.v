`default_nettype none

module top(input wire CLK, output wire J1_10, output wire J1_8, output wire J1_6, output wire J1_4, input wire RX, output wire TX);

	wire [7:0] uart_rxByte;
	wire uart_received;

	wire reset_in;
	assign reset_in = uart_received && (uart_rxByte == 8'h72);

	wire rst;
	synchronous_reset_timer resetter(CLK, rst, reset_in);

	wire [15:0] lfsr;
	wire metastable;
	wire bit_clk;
	wire word_clk;
	randomized_lfsr randomized_lfsr(CLK, rst, bit_clk, word_clk, lfsr, metastable);

	wire txFree;
	wire dataReady;

	uart #(.CLOCKFRQ(12000000), .BAUDRATE(3000000) ) uart(
		.clk(CLK),
		.rst(rst),
		.rx(RX),
		.tx(TX),
		.transmit(txFree & word_clk),
		.tx_free(txFree),
		.tx_byte(lfsr[7:0]),
		.received(uart_received),
		.rx_byte(uart_rxByte),
		.is_receiving(),
		.is_transmitting(),
		.recv_error()
	);

	assign J1_10 = metastable;
	assign J1_8 = lfsr[0];
	assign J1_6 = bit_clk;
	assign J1_4 = word_clk;

endmodule

