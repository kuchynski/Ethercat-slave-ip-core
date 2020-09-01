`timescale 1ns / 1ps

module mac_connect(
	input rst_n,
	input[2:0] state,

	input rx0_e,
	input rx0_dv,
	input[3:0] rx0_data,

	input rx1_e,
	input rx1_dv,
	input[3:0] rx1_data,
	input rx1_clk,

	input rx2_e,
	input rx2_dv,
	input[3:0] rx2_data,
	input rx2_clk,

	output reg tx_en,
	output reg[3:0] tx_data,
	input tx_clk);
	
	wire tx_en0, tx_en1, tx_en2;
	wire[3:0] tx_data0, tx_data1, tx_data2;

	always@(posedge tx_clk) begin
		tx_en <= tx_en0 | tx_en1 | tx_en2;
		tx_data <= tx_data0 | tx_data1 | tx_data2;
	end
	
	assign tx_en0 = (!rst_n || (state != 0) || !rx0_e)? 0 : rx0_dv;
	assign tx_data0 = (!rst_n || (state != 0) || !rx0_e)? 0 : rx0_data;

	mii_connect connect1(
		.rst(!rst_n || (state != 1) || !rx1_e),
		.rx_dv(rx1_dv),
		.rx_data(rx1_data),
		.rx_clk(rx1_clk),
		.tx_en(tx_en1),
		.tx_data(tx_data1),
		.tx_clk(tx_clk)
		);

	mii_connect connect2(
		.rst(!rst_n || (state != 2) || !rx2_e),
		.rx_dv(rx2_dv),
		.rx_data(rx2_data),
		.rx_clk(rx2_clk),
		.tx_en(tx_en2),
		.tx_data(tx_data2),
		.tx_clk(tx_clk)
		);

endmodule
