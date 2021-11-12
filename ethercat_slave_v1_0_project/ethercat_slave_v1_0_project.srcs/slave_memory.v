`timescale 1ns / 1ps

module slave_memory(
	input rst_n,
	input clk,
	input clk_25,

	input[1:0] link,
	output[15:0] fp_address,
	output[31:0] fmmu0_address,
	output[31:0] fmmu1_address,
	output[31:0] fmmu2_address,
	output[31:0] fmmu3_address,

	output reg vled,

	input[31:0]mem_address_read,
	input[31:0]mem_address_write,
	input[31:0]mem_logical_address_read,
	input[31:0]mem_logical_address_write,
	input[7:0]mem_data_write,
	output[7:0]mem_data_read,
	output[7:0]mem_logical_data_read,
	input mem_write_end_valid,
	/*(* mark_debug = "true" *)*/
	input mem_logical_write_end_valid,
	input mem_write_en,
	input mem_logical_write_en,
	input mem_logical_read_en
	);

	wire[7:0] mem_000 = 8'h11;
	wire[7:0] mem_004 = 8'h02;
	wire[7:0] mem_005 = 8'h02;
	wire[7:0] mem_006 = 8'h08;
	wire[7:0] mem_007 = 8'h0F;
	wire[7:0] mem_008 = 8'hFC;
	reg[7:0] mem_00A;
	reg[7:0] mem_010;
	reg[7:0] mem_011;
	wire[7:0] mem_012 = 8'h9F;
	reg[7:0] mem_100;
	reg[7:0] mem_101;
	reg[7:0] mem_102;
	reg[7:0] mem_103;
	wire[7:0] mem_110 = {2'h0, link, 4'h3};
	wire[7:0] mem_111 = {4'h5, link[1], !link[1], link[0], !link[0]};
	reg[7:0] mem_120;  //AL Control
	wire[7:0] mem_121 = 8'h00;
	wire[7:0] mem_130 = (mem_120)? mem_120 : 1; //State
	wire[7:0] mem_131 = 8'h00;
	wire[7:0] mem_134 = 8'h00; //AL status code
	wire[7:0] mem_135 = 8'h00;
	wire[7:0] mem_140 = 8'h08;
	wire[7:0] mem_141 = 8'h0C;

	//FMMU
	reg[7:0] mem_600, mem_601, mem_602, mem_603, mem_604, mem_605, mem_608, mem_609;
	reg[2:0] mem_606, mem_607, mem_60A, mem_60B, mem_60C;
	reg[7:0] mem_610, mem_611, mem_612, mem_613, mem_614, mem_615, mem_618, mem_619;
	reg[2:0] mem_616, mem_617, mem_61A, mem_61B, mem_61C;
	reg[7:0] mem_620, mem_621, mem_622, mem_623, mem_624, mem_625, mem_628, mem_629;
	reg[2:0] mem_626, mem_627, mem_62A, mem_62B, mem_62C;
	reg[7:0] mem_630, mem_631, mem_632, mem_633, mem_634, mem_635, mem_638, mem_639;
	reg[2:0] mem_636, mem_637, mem_63A, mem_63B, mem_63C;

	wire[7:0] mem_data_read_reg =	(mem_address_read[15:0] == 16'h000)? mem_000 :
									(mem_address_read[15:0] == 16'h004)? mem_004 :
									(mem_address_read[15:0] == 16'h005)? mem_005 :
									(mem_address_read[15:0] == 16'h006)? mem_006 :
									(mem_address_read[15:0] == 16'h007)? mem_007 :
									(mem_address_read[15:0] == 16'h008)? mem_008 :
									(mem_address_read[15:0] == 16'h00A)? mem_00A :
									(mem_address_read[15:0] == 16'h010)? mem_010 :
									(mem_address_read[15:0] == 16'h011)? mem_011 :
									(mem_address_read[15:0] == 16'h012)? mem_012 :
									(mem_address_read[15:0] == 16'h100)? mem_100 :
									(mem_address_read[15:0] == 16'h101)? mem_101 :
									(mem_address_read[15:0] == 16'h102)? mem_102 :
									(mem_address_read[15:0] == 16'h103)? mem_103 :
									(mem_address_read[15:0] == 16'h110)? mem_110 :
									(mem_address_read[15:0] == 16'h111)? mem_111 :
									(mem_address_read[15:0] == 16'h120)? mem_120 :
									(mem_address_read[15:0] == 16'h121)? mem_121 :
									(mem_address_read[15:0] == 16'h130)? mem_130 :
									(mem_address_read[15:0] == 16'h131)? mem_131 :
									(mem_address_read[15:0] == 16'h134)? mem_134 :
									(mem_address_read[15:0] == 16'h135)? mem_135 :
									(mem_address_read[15:0] == 16'h140)? mem_140 :
									(mem_address_read[15:0] == 16'h141)? mem_141 :
									(mem_address_read[15:0] == 16'h600)? mem_600 :
									(mem_address_read[15:0] == 16'h601)? mem_601 :
									(mem_address_read[15:0] == 16'h602)? mem_602 :
									(mem_address_read[15:0] == 16'h603)? mem_603 :
									(mem_address_read[15:0] == 16'h604)? mem_604 :
									(mem_address_read[15:0] == 16'h605)? mem_605 :
									(mem_address_read[15:0] == 16'h606)? {5'h0, mem_606} :
									(mem_address_read[15:0] == 16'h607)? {5'h0, mem_607} :
									(mem_address_read[15:0] == 16'h608)? mem_608 :
									(mem_address_read[15:0] == 16'h609)? mem_609 :
									(mem_address_read[15:0] == 16'h60A)? {5'h0, mem_60A} :
									(mem_address_read[15:0] == 16'h60B)? {5'h0, mem_60B} :
									(mem_address_read[15:0] == 16'h60C)? {5'h0, mem_60C} :
									(mem_address_read[15:0] == 16'h610)? mem_610 :
									(mem_address_read[15:0] == 16'h611)? mem_611 :
									(mem_address_read[15:0] == 16'h612)? mem_612 :
									(mem_address_read[15:0] == 16'h613)? mem_613 :
									(mem_address_read[15:0] == 16'h614)? mem_614 :
									(mem_address_read[15:0] == 16'h615)? mem_615 :
									(mem_address_read[15:0] == 16'h616)? {5'h0, mem_616} :
									(mem_address_read[15:0] == 16'h617)? {5'h0, mem_617} :
									(mem_address_read[15:0] == 16'h618)? mem_618 :
									(mem_address_read[15:0] == 16'h619)? mem_619 :
									(mem_address_read[15:0] == 16'h61A)? {5'h0, mem_61A} :
									(mem_address_read[15:0] == 16'h61B)? {5'h0, mem_61B} :
									(mem_address_read[15:0] == 16'h61C)? {5'h0, mem_61C} :
									(mem_address_read[15:0] == 16'h620)? mem_620 :
									(mem_address_read[15:0] == 16'h621)? mem_621 :
									(mem_address_read[15:0] == 16'h622)? mem_622 :
									(mem_address_read[15:0] == 16'h623)? mem_623 :
									(mem_address_read[15:0] == 16'h624)? mem_624 :
									(mem_address_read[15:0] == 16'h625)? mem_625 :
									(mem_address_read[15:0] == 16'h626)? {5'h0, mem_626} :
									(mem_address_read[15:0] == 16'h627)? {5'h0, mem_627} :
									(mem_address_read[15:0] == 16'h628)? mem_628 :
									(mem_address_read[15:0] == 16'h629)? mem_629 :
									(mem_address_read[15:0] == 16'h62A)? {5'h0, mem_62A} :
									(mem_address_read[15:0] == 16'h62B)? {5'h0, mem_62B} :
									(mem_address_read[15:0] == 16'h62C)? {5'h0, mem_62C} :
									(mem_address_read[15:0] == 16'h630)? mem_630 :
									(mem_address_read[15:0] == 16'h631)? mem_631 :
									(mem_address_read[15:0] == 16'h632)? mem_632 :
									(mem_address_read[15:0] == 16'h633)? mem_633 :
									(mem_address_read[15:0] == 16'h634)? mem_634 :
									(mem_address_read[15:0] == 16'h635)? mem_635 :
									(mem_address_read[15:0] == 16'h636)? {5'h0, mem_636} :
									(mem_address_read[15:0] == 16'h637)? {5'h0, mem_637} :
									(mem_address_read[15:0] == 16'h638)? mem_638 :
									(mem_address_read[15:0] == 16'h639)? mem_639 :
									(mem_address_read[15:0] == 16'h63A)? {5'h0, mem_63A} :
									(mem_address_read[15:0] == 16'h63B)? {5'h0, mem_63B} :
									(mem_address_read[15:0] == 16'h63C)? {5'h0, mem_63C}: 0;

	assign fp_address = {mem_011, mem_010};
	assign fmmu0_address = {mem_603, mem_602, mem_601, mem_600};
	assign fmmu1_address = {mem_613, mem_612, mem_611, mem_610};
	assign fmmu2_address = {mem_623, mem_622, mem_621, mem_620};
	assign fmmu3_address = {mem_633, mem_632, mem_631, mem_630};

	assign mem_logical_data_read = (mem_logical_address_read == fmmu2_address)? mem_00A : 0;

	// EEPROM
	wire[7:0] mem_500 = 8'h00;
	wire[7:0] mem_501 = 8'h00;
	reg[7:0] mem_502 = 8'hC0;
	reg[7:0] mem_503 = 8'h00;
	reg [7:0] mem_504; //address
	wire[7:0] mem_505 = 8'h0; //address
	wire[7:0] mem_506 = 8'h0; //address
	wire[7:0] mem_507 = 8'h0; //address
	reg[7:0] mem_508; //data
	reg[7:0] mem_509; //data
	reg[7:0] mem_50a; //data
	reg[7:0] mem_50b; //data
	reg[7:0] mem_50c; //data
	reg[7:0] mem_50d; //data
	reg[7:0] mem_50e; //data
	reg[7:0] mem_50f; //data

	always@(posedge clk_25) begin
		if(!rst_n) begin
			mem_504 <= 8'h00;
		end else begin
			if(mem_write_en_bram == 1) begin
				case(mem_address_write_bram[15:0])
					16'h010: mem_010 <= mem_data_write_bram;
					16'h011: mem_011 <= mem_data_write_bram;
					16'h100: mem_100 <= mem_data_write_bram;
					16'h101: mem_101 <= mem_data_write_bram;
					16'h102: mem_102 <= mem_data_write_bram;
					16'h103: mem_103 <= mem_data_write_bram;
					16'h120: mem_120 <= {4'h0, mem_data_write_bram[3:0]};
					16'h504: mem_504 <= mem_data_write_bram;//bram_write_data_r; ///!
					16'h600: mem_600 <= mem_data_write_bram;
					16'h601: mem_601 <= mem_data_write_bram;
					16'h602: mem_602 <= mem_data_write_bram;
					16'h603: mem_603 <= mem_data_write_bram;
					16'h604: mem_604 <= mem_data_write_bram;
					16'h605: mem_605 <= mem_data_write_bram;
					16'h606: mem_606 <= mem_data_write_bram;
					16'h607: mem_607 <= mem_data_write_bram;
					16'h608: mem_608 <= mem_data_write_bram;
					16'h609: mem_609 <= mem_data_write_bram;
					16'h60A: mem_60A <= mem_data_write_bram;
					16'h60B: mem_60B <= mem_data_write_bram;
					16'h60C: mem_60C <= mem_data_write_bram;
					16'h610: mem_610 <= mem_data_write_bram;
					16'h611: mem_611 <= mem_data_write_bram;
					16'h612: mem_612 <= mem_data_write_bram;
					16'h613: mem_613 <= mem_data_write_bram;
					16'h614: mem_614 <= mem_data_write_bram;
					16'h615: mem_615 <= mem_data_write_bram;
					16'h616: mem_616 <= mem_data_write_bram;
					16'h617: mem_617 <= mem_data_write_bram;
					16'h618: mem_618 <= mem_data_write_bram;
					16'h619: mem_619 <= mem_data_write_bram;
					16'h61A: mem_61A <= mem_data_write_bram;
					16'h61B: mem_61B <= mem_data_write_bram;
					16'h61C: mem_61C <= mem_data_write_bram;
					16'h620: mem_620 <= mem_data_write_bram;
					16'h621: mem_621 <= mem_data_write_bram;
					16'h622: mem_622 <= mem_data_write_bram;
					16'h623: mem_623 <= mem_data_write_bram;
					16'h624: mem_624 <= mem_data_write_bram;
					16'h625: mem_625 <= mem_data_write_bram;
					16'h626: mem_626 <= mem_data_write_bram;
					16'h627: mem_627 <= mem_data_write_bram;
					16'h628: mem_628 <= mem_data_write_bram;
					16'h629: mem_629 <= mem_data_write_bram;
					16'h62A: mem_62A <= mem_data_write_bram;
					16'h62B: mem_62B <= mem_data_write_bram;
					16'h62C: mem_62C <= mem_data_write_bram;
					16'h630: mem_630 <= mem_data_write_bram;
					16'h631: mem_631 <= mem_data_write_bram;
					16'h632: mem_632 <= mem_data_write_bram;
					16'h633: mem_633 <= mem_data_write_bram;
					16'h634: mem_634 <= mem_data_write_bram;
					16'h635: mem_635 <= mem_data_write_bram;
					16'h636: mem_636 <= mem_data_write_bram;
					16'h637: mem_637 <= mem_data_write_bram;
					16'h638: mem_638 <= mem_data_write_bram;
					16'h639: mem_639 <= mem_data_write_bram;
					16'h63A: mem_63A <= mem_data_write_bram;
					16'h63B: mem_63B <= mem_data_write_bram;
					16'h63C: mem_63C <= mem_data_write_bram;
				endcase
			end
		end
	end

	always@(posedge clk_25) begin
		if(!rst_n) begin
			vled <= 0;
		end else begin
			mem_00A <= mem_00A + 1;
			if(mem_logical_write_en_bram == 1) begin
				if(mem_address_write_bram == fmmu1_address) begin
					vled <= mem_data_write_bram[0];
				end
			end
		end
	end

	wire[7:0] mem_data_read_eeprom =(mem_address_read[15:0] == 16'h500)? mem_500 :
									(mem_address_read[15:0] == 16'h501)? mem_501 :
									(mem_address_read[15:0] == 16'h502)? mem_502 :
									(mem_address_read[15:0] == 16'h503)? mem_503 :
									(mem_address_read[15:0] == 16'h504)? mem_504 :
									(mem_address_read[15:0] == 16'h505)? mem_505 :
									(mem_address_read[15:0] == 16'h506)? mem_506 :
									(mem_address_read[15:0] == 16'h507)? mem_507 :
									(mem_address_read[15:0] == 16'h508)? mem_508 :
									(mem_address_read[15:0] == 16'h509)? mem_509 :
									(mem_address_read[15:0] == 16'h50a)? mem_50a :
									(mem_address_read[15:0] == 16'h50b)? mem_50b :
									(mem_address_read[15:0] == 16'h50c)? mem_50c :
									(mem_address_read[15:0] == 16'h50d)? mem_50d :
									(mem_address_read[15:0] == 16'h50e)? mem_50e :
									(mem_address_read[15:0] == 16'h50f)? mem_50f : 0;

	assign mem_data_read = (mem_address_read[15:0] >= 16'h500 && mem_address_read[15:0] < 16'h510)? mem_data_read_eeprom : mem_data_read_reg; 

	wire[10:0] EEPROM_ADDRESS = (mem_505 || mem_506 || mem_507)? 11'h7FF : {2'h0, mem_504, 1'h0};
	wire[7:0] EEPROM_DATA;
	reg[10:0] EEPROM_ADDRESS_st;
	reg[1:0] st_read_eeprom;

	always@(posedge clk_25) begin
		if(!rst_n) begin
			st_read_eeprom <= 1;
		end else begin
			case(st_read_eeprom)
				0: begin
					EEPROM_ADDRESS_st <= 0;
					if(mem_write_en_bram == 1 && mem_address_write_bram[15:0] == 16'h504)
						st_read_eeprom <= 1;
				end
				1: st_read_eeprom <= 2;
				2: begin
					if(EEPROM_ADDRESS_st == 0) mem_508 <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 1) mem_509 <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 2) mem_50a <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 3) mem_50b <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 4) mem_50c <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 5) mem_50d <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 6) mem_50e <= EEPROM_DATA;
					if(EEPROM_ADDRESS_st == 7) mem_50f <= EEPROM_DATA;
					EEPROM_ADDRESS_st <= EEPROM_ADDRESS_st + 1;
					st_read_eeprom <= (EEPROM_ADDRESS_st == 3'h7)? 0 : 1;
				end
			endcase
		end
	end

	BRAM_SDP_MACRO #(.BRAM_SIZE("18Kb"), .DEVICE("7SERIES"), .WRITE_WIDTH(8), .READ_WIDTH(8),
		.INIT_00(256'h0000000000000007026281110000077700C700000000009F000004008C000C08),
		.INIT_01(256'h0000000000000000020012000200100002001200020010000000000000000000)
	) //2 KByte
	BRAM_EEPROM(
		.DI(0),
		.WE(1'h0),
		.WRADDR(EEPROM_ADDRESS + EEPROM_ADDRESS_st),
		.WRCLK(clk_25),
		.WREN(0),
		.DO(EEPROM_DATA),
		.RDADDR(EEPROM_ADDRESS + EEPROM_ADDRESS_st),
		.RDCLK(clk_25),
		.RDEN(1), .REGCE(0), .RST(0)
		);



	wire[31:0] mem_address_write_bram = (mem_logical_write_en)? mem_logical_address_write : mem_address_write;
	wire mem_write_en_bram = mem_write_en;
	wire mem_logical_write_en_bram = mem_logical_write_en;
	wire[7:0] mem_data_write_bram = mem_data_write;

/*
	reg[10:0] bram_write_address_w, bram_write_address_r;
	wire[7:0] mem_data_write_bram;
	reg[1:0] st_bram_write;
	reg[31:0] mem_address_write_bram;
	reg mem_write_en_bram;
	reg mem_logical_write_en_bram;

//	input[31:0]mem_address_write,
//	input[7:0]mem_data_write,
//	input mem_write_en
	always@(posedge clk_25) begin
		if(!rst_n) begin
			bram_write_address_w <= 0;
			mem_write_en_bram <= 0;
			mem_logical_write_en_bram <= 0;
			st_bram_write <= 0;
		end else begin
			case(st_bram_write)
				0: begin
					bram_write_address_r <= 0;
					if(mem_write_en || mem_logical_write_en) begin
						bram_write_address_w <= bram_write_address_w + 1;
						if(!bram_write_address_w)
							mem_address_write_bram <= (mem_logical_write_en)? mem_logical_address_write : mem_address_write;
					end
					if(mem_write_end_valid || mem_logical_write_end_valid && bram_write_address_w) begin
						mem_write_en_bram <= mem_write_end_valid;
						mem_logical_write_en_bram <= mem_logical_write_end_valid;
						bram_write_address_r <= 1;
						st_bram_write <= 1;
					end
				end
				1: begin
					bram_write_address_r <= bram_write_address_r + 1;
					mem_address_write_bram <= mem_address_write_bram + 1;
					if(bram_write_address_r < bram_write_address_w) begin
					end else begin
						mem_write_en_bram <= 0;
						mem_logical_write_en_bram <= 0;
						bram_write_address_w <= 0;
						st_bram_write <= 0;
					end
				end
				default:
					st_bram_write <= 0;
			endcase
		end
	end

	BRAM_SDP_MACRO #(.BRAM_SIZE("18Kb"), .DEVICE("7SERIES"), .WRITE_WIDTH(8), .READ_WIDTH(8)) //2 KByte
	BRAM_WRITE(
		.DI(mem_data_write),
		.WE(1'h1),
		.WRADDR(bram_write_address_w),
		.WRCLK(clk_25),
		.WREN(mem_write_en || mem_logical_write_en),
		.DO(mem_data_write_bram),
		.RDADDR(bram_write_address_r),
		.RDCLK(clk_25),
		.RDEN(1), .REGCE(0), .RST(0)
	);*/

endmodule
