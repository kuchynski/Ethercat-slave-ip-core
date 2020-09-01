`timescale 1ns / 1ps

module mii_connect(
	input rst,// activ 1

	input rx_dv,
	input [3:0] rx_data,
	input rx_clk,

	output reg tx_en,
	output reg[3:0] tx_data,
	input tx_clk);
	
	reg en, second_state; 
	reg[3:0] data0, data1, data2, data3, data4, data5, data6, data7;
	reg[2:0] st_rx, st_rx_end, st_tx, tx_state;


	always@(posedge rx_clk) begin	
		if(rx_dv) begin 
			en <= 1; 
			st_rx <= st_rx + 1;
			if(st_rx == 0) data0 <= rx_data;
			if(st_rx == 1) data1 <= rx_data;
			if(st_rx == 2) data2 <= rx_data;
			if(st_rx == 3) data3 <= rx_data;
			if(st_rx == 4) data4 <= rx_data;
			if(st_rx == 5) data5 <= rx_data;
			if(st_rx == 6) data6 <= rx_data;
			if(st_rx == 7) data7 <= rx_data;
		end else begin
			st_rx <= 0;
			en <= 0; 
			if(en) 
				st_rx_end <= st_rx;
		end
	end
	
	always@(negedge tx_clk) begin
		if(rst)	begin
			tx_state <= 0;
			tx_en <= 0;
			tx_data <= 0;
		end else	
			case(tx_state)
				0:	begin	
						st_tx <= 0;
						tx_en <= 0;
						tx_data <= 0;
						if(en)
							tx_state <= 1;
					end
				1:	begin
						second_state <= 0;
						tx_state <= 2;
					end
				2:	begin
						if(!en) 
							second_state <= 1;						
						if(second_state && (st_rx_end == st_tx)) begin
							tx_en <= 0;
							tx_data <= 0;
							tx_state <= 0;
						end else begin
							st_tx <= st_tx + 1;
							tx_en <= 1;
							case(st_tx)
								0: tx_data <= data0; 
								1: tx_data <= data1;
								2: tx_data <= data2;
								3: tx_data <= data3; 
								4: tx_data <= data4;
								5: tx_data <= data5;
								6: tx_data <= data6; 
								default: tx_data <= data7;
							endcase		
						end
					end
			endcase		
	end	
endmodule
