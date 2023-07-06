//
// ethercat slave ip core
// copyright Andrei Kuchynski
// kuchynskiandrei@gmail.com
//

`timescale 1ns / 1ps

module slave_pu(
	input rst_n,
	input clk,
	input clk_25,

	input rx_dv,
	input [3:0] rx_data,
	output reg tx_en,
	output reg[3:0] tx_data,

	input[15:0] fp_address,
	input[31:0] fmmu0_address,
	input[31:0] fmmu1_address,
	input[31:0] fmmu2_address,
	input[31:0] fmmu3_address,
	
	output reg[31:0]mem_address_read,
	output reg[31:0]mem_address_write,
	output reg[31:0]mem_logical_address_read,
	output reg[31:0]mem_logical_address_write,
	output reg[7:0]mem_data_write,
	input[7:0]mem_data_read,
	input[7:0]mem_logical_data_read,
	output reg mem_logical_read_en,
	output reg mem_write_en,
	output reg mem_logical_write_en,
	output reg mem_write_end_valid,
	output reg mem_logical_write_end_valid
	);

	reg en_rx, second_state; 
	reg[3:0] data0, data1, data2, data3, data4, data5, data6, data7;
	reg[2:0] tx_state, st_rx_end_of_frame, st_tx_end_of_frame;
	wire[3:0] tx_data_crc, tx_data_ok;
	//reg[3:0] tx_data_in;
	reg next_reset_C, M, rx_end_of_frame, tx_end_of_frame;
	reg[11:0] st_frame, address_sm_ethercat, address_sm_ethernet, len2, frame_end;
	reg[11:0]  st_rx, st_tx;
	wire[11:0] len2_real;
	reg[8:0] data_crc_rx_in, data_crc_tx_in;
	wire[31:0] data_crc_tx_out;
	reg[31:0] data_crc_rx_real;
	wire[31:0] data_crc_rx_out;
	reg crc_rx_ok, data_crc_rx_valid, data_crc_tx_valid;

	reg[11:0] datagram_begin_index, datagram_begin_index_fix, datagram_wkc_index;
	reg[7:0] datagram_cmd, datagram_cmd_fix;
	reg[7:0] datagram_idx;
	reg[31:0] datagram_address, datagram_address_fix;
	reg[15:0] datagram_address_new;
	reg[10:0] datagram_len, detagram_len_fix;
	wire[11:0] datagram_len_4 = {datagram_len[10:0], 1'b0};
	reg datagram_circulating;
	reg datagram_more;
	reg[15:0] datagram_wkc, datagram_wkc_added;
	reg datagram_work;

	assign len2_real = ((len2 > 44)? len2 : 44) + 2;

	always@(posedge clk_25) begin	
		if(rx_dv) begin
			en_rx <= 1;
			st_frame <= 0; 
			st_rx <= st_rx + 1;
			if(st_rx[2:0] == 0) data0 <= rx_data;
			if(st_rx[2:0] == 1) data1 <= rx_data;
			if(st_rx[2:0] == 2) data2 <= rx_data;
			if(st_rx[2:0] == 3) data3 <= rx_data;
			if(st_rx[2:0] == 4) data4 <= rx_data;
			if(st_rx[2:0] == 5) data5 <= rx_data;
			if(st_rx[2:0] == 6) data6 <= rx_data;
			if(st_rx[2:0] == 7) data7 <= rx_data;

			if(st_rx == (address_sm_ethercat +  0)) datagram_begin_index <= st_rx;			
			if(st_rx == (address_sm_ethercat +  0)) datagram_cmd[3:0] <= rx_data;
			if(st_rx == (address_sm_ethercat +  1)) datagram_cmd[7:4] <= rx_data;
			if(st_rx == (address_sm_ethercat +  2)) datagram_idx[3:0] <= rx_data;
			if(st_rx == (address_sm_ethercat +  3)) datagram_idx[7:4] <= rx_data;

			if(st_rx == (address_sm_ethercat +  4)) datagram_address[3:0] <= rx_data;
			if(st_rx == (address_sm_ethercat +  5)) datagram_address[7:4] <= rx_data;
			if(st_rx == (address_sm_ethercat +  6)) datagram_address[11:8] <= rx_data;
			if(st_rx == (address_sm_ethercat +  7)) datagram_address[15:12] <= rx_data;
			if(st_rx == (address_sm_ethercat +  8)) datagram_address[19:16] <= rx_data;
			if(st_rx == (address_sm_ethercat +  9)) datagram_address[23:20] <= rx_data;
			if(st_rx == (address_sm_ethercat + 10)) datagram_address[27:24] <= rx_data;
			if(st_rx == (address_sm_ethercat + 11)) datagram_address[31:28] <= rx_data;
			if(st_rx == (address_sm_ethercat + 12)) datagram_len[3:0] <= rx_data;
			if(st_rx == (address_sm_ethercat + 13)) datagram_len[7:4] <= rx_data;
			if(st_rx == (address_sm_ethercat + 15)) datagram_wkc_index <= address_sm_ethercat + 20 + datagram_len_4;

			if(st_rx == (address_sm_ethercat + 8)) begin
				datagram_begin_index_fix <= datagram_begin_index;
				datagram_cmd_fix <= datagram_cmd;
				datagram_address_fix[15:0] <= datagram_address[15:0];
				datagram_address_new = (datagram_cmd == 1 || datagram_cmd == 2 || datagram_cmd == 3 || 
										datagram_cmd == 7 || datagram_cmd == 8 || datagram_cmd == 9)? datagram_address[15:0] + 16'h0001 : datagram_address[15:0];
			end
			if(st_rx == (address_sm_ethercat + 14)) begin
				datagram_len[10:8] <= rx_data[2:0];
				next_reset_C <= M;
				datagram_address_fix[31:16] <= datagram_address[31:16];
				detagram_len_fix <= {rx_data[2:0], datagram_len[7:4]};
				datagram_work <= 1;
			end else
				datagram_work <= 0;
			if(st_rx == (address_sm_ethercat + 15)) begin
				//address_sm_ethercat_plus <= {datagram_len[10:0], 1'b0} + 24;
				M <= rx_data[3];
				next_reset_C <= 0;
			end

			if(st_rx == (address_sm_ethercat + 20 + datagram_len_4 + 0)) datagram_wkc[3:0] <= rx_data;
			if(st_rx == (address_sm_ethercat + 20 + datagram_len_4 + 1)) datagram_wkc[7:4] <= rx_data;
			if(st_rx == (address_sm_ethercat + 20 + datagram_len_4 + 2)) datagram_wkc[11:8] <= rx_data;
			if(st_rx == (address_sm_ethercat + 20 + datagram_len_4 + 3)) begin
				datagram_wkc[15:12] <= rx_data;
				address_sm_ethercat <= address_sm_ethercat + datagram_len_4 + 24; //st_rx+1
			end
						
			if(st_rx == address_sm_ethernet) 
				rx_end_of_frame <= 1;
			st_rx_end_of_frame <= (!rx_end_of_frame)? 0 : st_rx_end_of_frame + 1;
			if(st_rx == 44) len2[3:0] <= rx_data;
			if(st_rx == 45) len2[7:4] <= rx_data;
			if(st_rx == 46) len2[11:8] <= {1'b0, rx_data[2:0]};
			if(st_rx == 47) address_sm_ethernet <= {len2_real[10:0], 1'b0} + 43;
						
			if(st_rx[0]) data_crc_rx_in[7:4] <= rx_data;
			else data_crc_rx_in[3:0] <= rx_data;
			            
			if((st_rx < 16) || rx_end_of_frame)
				data_crc_rx_valid <= 0;
			else	
				data_crc_rx_valid <= st_rx[0];
				
			if(st_rx_end_of_frame == 0)
				data_crc_rx_real[3:0] <= rx_data;
			if(st_rx_end_of_frame == 1)
				data_crc_rx_real[7:4] <= rx_data;
			if(st_rx_end_of_frame == 2)
				data_crc_rx_real[11:8] <= rx_data;
			if(st_rx_end_of_frame == 3)
				data_crc_rx_real[15:12] <= rx_data;
			if(st_rx_end_of_frame == 4)
				data_crc_rx_real[19:16] <= rx_data;
			if(st_rx_end_of_frame == 5)
				data_crc_rx_real[23:20] <= rx_data;
			if(st_rx_end_of_frame == 6)
				data_crc_rx_real[27:24] <= rx_data;
			if(st_rx_end_of_frame == 7)
				data_crc_rx_real[31:28] <= rx_data;
				
		end else begin
			if(st_rx) begin
				st_frame <= st_rx;
				crc_rx_ok <= (data_crc_rx_real == data_crc_rx_out)? 1 : 0;                    
			end
			st_rx <= 0;
			en_rx <= 0; 
			M <= 1;
			rx_end_of_frame <= 0;
			data_crc_rx_valid <= 0;
			next_reset_C <= 0;
			address_sm_ethercat <= 48;
			address_sm_ethernet <= 60;
			datagram_begin_index <= 0;
			datagram_work <= 0;
			datagram_wkc_index <= 100;
			datagram_begin_index_fix <= 100;
		end
	end

	reg[3:0] work0_state, work1_state;
	wire[15:0] datagram_wkc_new = datagram_wkc + datagram_wkc_added;
	reg[7:0] datagram_data_new;
	reg[1:0] enable_new_data;

	always@(posedge clk_25) begin
		if(!rst_n)    begin
			work1_state <= 0;
		end else begin
			case(work1_state)
				0: begin                
					mem_write_en <= 0;
					mem_logical_write_en <= 0;
					mem_write_en <= 0;
					mem_write_end_valid <= 0;
					mem_logical_write_end_valid <= 0;
					mem_logical_read_en <= 0;
					datagram_wkc_added <= 0;
					if(datagram_work) begin
						mem_logical_address_read <= datagram_address_fix;
						mem_logical_address_write <= datagram_address_fix;
						mem_address_read <= {16'h0, datagram_address_fix[31:16]};
						mem_address_write <= {16'h0, datagram_address_fix[31:16]};
						enable_new_data <= 0;
						if(datagram_cmd_fix == 1 || datagram_cmd_fix == 2 || datagram_cmd_fix == 3) begin
							if(datagram_address_fix[15:0] == 0) begin
								datagram_wkc_added <= (datagram_cmd_fix == 3)? 3 : 1;
								work1_state <= 1;
							end
						end else if(datagram_cmd_fix == 4 || datagram_cmd_fix == 5 || datagram_cmd_fix == 6) begin
							if(datagram_address_fix[15:0] == fp_address) begin
								datagram_wkc_added <= (datagram_cmd_fix == 6)? 3 : 1;
								work1_state <= 1;
							end
						end else if(datagram_cmd_fix == 7 || datagram_cmd_fix == 8 || datagram_cmd_fix == 9) begin
							datagram_wkc_added <= (datagram_cmd_fix == 9)? 3 : 1;
							work1_state <= 1;
						end else if(datagram_cmd_fix == 10 || datagram_cmd_fix == 11 || datagram_cmd_fix == 12) begin
							if(datagram_address_fix == fmmu0_address || datagram_address_fix == fmmu1_address ||
								datagram_address_fix == fmmu2_address || datagram_address_fix == fmmu3_address) begin
								datagram_wkc_added <= (datagram_cmd_fix == 12)? 3 : 1;
								mem_logical_read_en <= (datagram_cmd_fix == 10 || datagram_cmd_fix == 12)? 1 : 0;
								work1_state <= 1;
							end
						end
					end
				end
				1: begin
						// READ operations
					if(datagram_cmd_fix == 1 || datagram_cmd_fix == 3 || 
						datagram_cmd_fix == 4 || datagram_cmd_fix == 6 ||
						datagram_cmd_fix == 7 || datagram_cmd_fix == 9 ||
						datagram_cmd_fix == 10 || datagram_cmd_fix == 12) begin
						enable_new_data <= (datagram_cmd_fix == 7 || datagram_cmd_fix == 9)? 2 : 1;
						if(st_tx >= (datagram_begin_index_fix + 19) && st_tx[0] == 0) begin
							datagram_data_new <= (datagram_cmd_fix == 10 || datagram_cmd_fix == 12)? mem_logical_data_read[7:4] : mem_data_read[7:4];                            
							mem_address_read <= mem_address_read + 1;
							mem_logical_address_read <= mem_logical_address_read + 1;
						end else
							datagram_data_new <= (datagram_cmd_fix == 10 || datagram_cmd_fix == 12)? mem_logical_data_read[3:0] : mem_data_read[3:0];
					end
						// WRITE operations
					if(datagram_cmd_fix == 2 || datagram_cmd_fix == 3 || 
						datagram_cmd_fix == 5 || datagram_cmd_fix == 6 || 
						datagram_cmd_fix == 8 || datagram_cmd_fix == 9 || 
						datagram_cmd_fix == 11 || datagram_cmd_fix == 12) begin
						if(st_tx >= (datagram_begin_index_fix + 20) && st_tx < datagram_wkc_index && st_tx[0] == 1) begin
							mem_data_write[7:4] <= tx_data_old;
							if(st_tx > (datagram_begin_index_fix + 21)) begin
								mem_address_write <= mem_address_write + 1;
								mem_logical_address_write <= mem_logical_address_write + 1;
							end
							if(datagram_cmd_fix == 11 || datagram_cmd_fix == 12)
								mem_logical_write_en <= 1;
							else
								mem_write_en <= 1;
						end else begin
							mem_data_write[3:0] <= tx_data_old;
							mem_logical_write_en <= 0;
							mem_write_en <= 0;
						end
					end
					if(st_tx > datagram_wkc_index) begin
						mem_write_end_valid <= (datagram_cmd_fix == 2 || datagram_cmd_fix == 3 ||
												datagram_cmd_fix == 5 || datagram_cmd_fix == 6 ||
												datagram_cmd_fix == 8 || datagram_cmd_fix == 9)? crc_rx_ok : 0; // datagramm_valid_crc;
						mem_logical_write_end_valid <= (datagram_cmd_fix == 11 || datagram_cmd_fix == 12)? crc_rx_ok : 0; // datagramm_valid_crc;
						work1_state <= 0;
					end
				end
				default: 
					work1_state <= 0;
			endcase
		end
	end

	wire[4:0] tx_data_new =	(st_tx == datagram_wkc_index + 0)? {1'h1, datagram_wkc_new[3:0]} :
							(st_tx == datagram_wkc_index + 1)? {1'h1, datagram_wkc_new[7:4]} :
							(st_tx == datagram_wkc_index + 2)? {1'h1, datagram_wkc_new[11:8]} :
							(st_tx == datagram_wkc_index + 3)? {1'h1, datagram_wkc_new[15:12]} :
							(st_tx == datagram_begin_index_fix + 4)? {1'h1, datagram_address_new[3:0]} :
							(st_tx == datagram_begin_index_fix + 5)? {1'h1, datagram_address_new[7:4]} :
							(st_tx == datagram_begin_index_fix + 6)? {1'h1, datagram_address_new[11:8]} :
							(st_tx == datagram_begin_index_fix + 7)? {1'h1, datagram_address_new[15:12]} :
							(st_tx >= (datagram_begin_index_fix + 20) && st_tx < datagram_wkc_index && enable_new_data == 1)? {1'h1, datagram_data_new[3:0]} : 
							(st_tx >= (datagram_begin_index_fix + 20) && st_tx < datagram_wkc_index && enable_new_data == 2)? {1'h1, datagram_data_new[3:0] | tx_data_old} : 
							0;
	wire[3:0] tx_data_old = (st_tx[2:0] == 0)? data0 :
							(st_tx[2:0] == 1)? data1 :
							(st_tx[2:0] == 2)? data2 :
							(st_tx[2:0] == 3)? data3 :
							(st_tx[2:0] == 4)? data4 :
							(st_tx[2:0] == 5)? data5 :
							(st_tx[2:0] == 6)? data6 : data7;
	//wire[3:0] tx_data_in_prepare = (is_new_wkc)? datagram_wkc_new : tx_data_old;
	wire[3:0] tx_data_in_prepare = (tx_data_new[4])? tx_data_new[3:0] : tx_data_old;
		
	always@(posedge clk_25) begin
		if(!rst_n)	begin
			tx_state <= 0;
		end else begin
			case(tx_state)
				0:	begin	
					st_tx <= 0;
					tx_en <= 0;
					tx_end_of_frame <= 0;
					st_tx_end_of_frame <= 0;
					data_crc_tx_valid <= 0;
					tx_data <= 0;
					if(st_rx == 4)
						tx_state <= 1;
				end
				1:	begin
					st_tx <= st_tx + 1;
					if(st_tx >= address_sm_ethernet) begin
						data_crc_tx_valid <= 0;
						tx_end_of_frame <= 1;
					end else if(st_tx > 15)
						data_crc_tx_valid <= !st_tx[0]; 

					st_tx_end_of_frame <= (tx_end_of_frame)? st_tx_end_of_frame + 1 : 0;
					if((st_tx >= st_frame) && !en_rx) begin
						tx_en <= 0;
						tx_data <= 0;
						tx_state <= 0;
					end else begin
						tx_en <= 1;
						tx_data <= (!tx_end_of_frame)? tx_data_in_prepare : tx_data_crc;
					end
				end
			endcase
		end
	end

	assign tx_data_crc =(st_tx_end_of_frame == 0)? data_crc_tx_out[3:0] : 
						(st_tx_end_of_frame == 1)? data_crc_tx_out[7:4] : 
						(st_tx_end_of_frame == 2)? data_crc_tx_out[11:8] : 
						(st_tx_end_of_frame == 3)? data_crc_tx_out[15:12] : 
						(st_tx_end_of_frame == 4)? data_crc_tx_out[19:16] : 
						(st_tx_end_of_frame == 5)? data_crc_tx_out[23:20]  : 
						(st_tx_end_of_frame == 6)? data_crc_tx_out[27:24] : data_crc_tx_out[31:28];

	crc_pu crc_rx(
		.clk(!clk_25),
		.d(data_crc_rx_in),
		.init(!en_rx),
		.en(data_crc_rx_valid),
		.crc_out(data_crc_rx_out));

	crc_pu crc_tx(
		.clk(clk_25),
		.d({tx_data_in_prepare, tx_data}),
		.init(!tx_en),
		.en(data_crc_tx_valid),
		.crc_out(data_crc_tx_out));

endmodule
