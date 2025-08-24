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
	output wire LED0,
	output wire LED1,
	output wire LED2,
	output wire LED3,
	output wire LED4,
	input wire RX,
	output wire TX);

	parameter ENABLE_ADDITIONAL_RINGOSCILLATORS = 1;


	/* reset circuit */
	wire reset_in;
	wire rst;
	synchronous_reset_timer resetter(CLK, rst, reset_in);

	/* optional ringoscillator outputs */
	wire r_out_insane;
	wire r_out_fast;
	wire r_out_slow;
	generate
		if(ENABLE_ADDITIONAL_RINGOSCILLATORS) begin : extra_ringoscillators
			ringoscillator #(.DELAY_LUTS(0)) ringosci_insane(r_out_insane);

			ringoscillator #(.DELAY_LUTS(1)) ringosci_fast(r_out_fast);

			ringoscillator #(.DELAY_LUTS(20)) ringosci_slow(r_out_slow);

		end else begin
			assign r_out_insane = 0;
			assign r_out_fast = 0;
			assign r_out_slow = 0;
		end
	endgenerate

	wire [15:0] lfsr;
	wire word_ready;
	wire bit_ready;
	wire metastable;
	randomized_lfsr randomized_lfsr(CLK, rst, bit_ready, word_ready, lfsr, metastable);

	assign J1_10 = metastable;


	/* UART implementation */
	wire is_transmitting;
	wire uart_received;
	wire [7:0] uart_rxByte;
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

	assign reset_in = uart_received && (uart_rxByte == 8'h72);
	assign J1_9 = lfsr[0];
	assign J1_8 = bit_ready;
	assign J1_7 = word_ready;


	/* debugging outputs */
	assign J1_3 = r_out_slow;
	assign J1_4 = r_out_fast;
	assign J1_5 = r_out_insane;
	assign J1_6 = rst;
	reg rst_counter = 0;
	reg uart_counter = 0;
	always @(posedge rst) begin
		rst_counter = !rst_counter;
	end
	always @(posedge uart_received) begin
		uart_counter = !uart_counter;
	end

	//assign LED0 = metastable;
	//assign LED1 = r_out_insane;
	//assign LED2 = r_out_fast;
	assign LED3 = uart_counter;
	assign LED4 = rst_counter;
endmodule
