`timescale 1ns / 1ps
module cpu_ethercat_slave #(
)(
	input clk,
	input clk_25,
	input rst_n,

	input wire MII_TX0_CLK,
	output wire[3:0] MII_TX0_DATA,
	output wire MII_TX0_ENA,
	input wire MII_RX0_CLK,
	input wire[3:0] MII_RX0_DATA,
	input wire MII_RX0_ENA,
	input wire MII_RX0_ERR,
	input wire MII_LINK0,
	output wire MII_MDC,
	output wire MII_MDIO,
	output wire MII_RST,
	output wire MII_CRS,
	input wire MII_TX1_CLK,
	output wire[3:0] MII_TX1_DATA,
	output wire MII_TX1_ENA,
	input wire MII_RX1_CLK,
	input wire[3:0] MII_RX1_DATA,
	input wire MII_RX1_ENA,
	input wire MII_RX1_ERR,
	input wire MII_LINK1,

	output vled,

	input[5:0] CHANGE_SLV_REG_NUMBER_WRITE,
	inout[5:0] CHANGE_SLV_REG_NUMBER_READ, 
	input CHANGE_SLV_REG_EVENT_WRITE,
	input CHANGE_SLV_REG_EVENT_READ,
	input[31:0] SLV_REG_REQUEST_0, 
	input[31:0] SLV_REG_REQUEST_1,
	input[31:0] SLV_REG_REQUEST_2,
	input[31:0] SLV_REG_REQUEST_3,
	input[31:0] SLV_REG_TIME_START_CYCLE,
	input IRQ_MASK,    
	output IRQ,
	output[31:0] data0,
	output[31:0] data1,
	output[31:0] data2,
	output[31:0] data3,
	output[31:0] data4,
	output[31:0] data5,
	output[31:0] data6,
	output[31:0] data7,

	output[63:0] dma_rx_data,
	output[31:0] dma_rx_address,
	output[10:0] dma_rx_size,
	output dma_rx_start,
	input dma_rx_stop,
	input dma_rx_start_qword,

	input[63:0]dma_tx_data,
	output[31:0]dma_tx_address,
	output[10:0]dma_tx_size,
	output dma_tx_start,
	input dma_tx_stop,
	input dma_tx_start_qword
);

	assign data0 = 0;
	assign data1 = 0;
	assign data2 = 0;
	assign data3 = 0;
	assign data4 = 0;
	assign data5 = 0;
	assign data6 = 0;
	assign data7 = 0;
	assign dma_tx_address = 0;
	assign dma_tx_size = 0;
	assign dma_rx_data = 0;
	assign IRQ = 0;
	assign dma_rx_address = 0;
	assign dma_rx_size = 0;
	assign dma_rx_start = 0;
	assign dma_tx_start = 0;

	wire[3:0] PU_RX_DATA, PU_TX_DATA;
	wire PU_RX_DV, PU_TX_EN;
	wire[1:0] connect_state =	(MII_LINK0 && !MII_LINK1)? 0 : 
								(!MII_LINK0 && MII_LINK1)? 1 : 
								(MII_LINK0 && MII_LINK1)? 2 : 3;
	wire[1:0] connect0_state = (connect_state == 0)? 1 : (connect_state == 2)? 2 : 0;

	mac_connect connect0( // PHY0
		.rst_n(rst_n),
		.state(connect0_state),

		.rx0_e(0), .rx0_dv(0), .rx0_data(0),
		.rx1_e(1),
		.rx1_dv(PU_TX_EN),
		.rx1_data(PU_TX_DATA),
		.rx1_clk(clk_25),
		.rx2_e(1),
		.rx2_dv(MII_RX1_ENA),
		.rx2_data(MII_RX1_DATA),
		.rx2_clk(MII_RX1_CLK),

		.tx_en(MII_TX0_ENA),
		.tx_data(MII_TX0_DATA),
		.tx_clk(MII_TX0_CLK) 
	);

	wire[1:0] connect1_state = (connect_state == 1)? 1 : (connect_state == 2)? 1 : 0;

	mac_connect connect1( // PHY1
		.rst_n(rst_n),
		.state(connect1_state),

		.rx0_e(0), .rx0_dv(0), .rx0_data(0),
		.rx1_e(1),
		.rx1_dv(PU_TX_EN),
		.rx1_data(PU_TX_DATA),
		.rx1_clk(clk_25),
		.rx2_e(0), .rx2_dv(0), .rx2_data(0), .rx2_clk(0),

		.tx_en(MII_TX1_ENA),
		.tx_data(MII_TX1_DATA),
		.tx_clk(MII_TX1_CLK) 
	);

	wire[1:0] connect2_state = (connect_state == 0)? 1 : (connect_state == 2)? 1 : (connect_state == 1)? 2 : 0;
	mac_connect connect2( // PHY1
		.rst_n(rst_n),
		.state(connect2_state),

		.rx0_e(0), .rx0_dv(0), .rx0_data(0),
		.rx1_e(1),
		.rx1_dv(MII_RX0_ENA),
		.rx1_data(MII_RX0_DATA),
		.rx1_clk(MII_RX0_CLK),
		.rx2_e(1),
		.rx2_dv(MII_RX1_ENA),
		.rx2_data(MII_RX1_DATA),
		.rx2_clk(MII_RX1_CLK),

		.tx_en(PU_RX_DV),
		.tx_data(PU_RX_DATA),
		.tx_clk(clk_25) 
	);

	wire[31:0] mem_address_read, mem_address_write, mem_logical_address_read, mem_logical_address_write;
	wire[7:0] mem_data_write, mem_data_read, mem_logical_data_read;
	wire mem_write_end_valid, mem_logical_write_end_valid, mem_write_en, mem_logical_write_en, mem_logical_read_en;
	wire[15:0] fp_address;
	wire[31:0] fmmu0_address, fmmu1_address, fmmu2_address, fmmu3_address;

	slave_pu(
		.rst_n(rst_n),
		.clk(clk),
		.clk_25(clk_25),

		.rx_dv(PU_RX_DV),
		.rx_data(PU_RX_DATA),
		.tx_en(PU_TX_EN),
		.tx_data(PU_TX_DATA),

		.fp_address(fp_address),
		.fmmu0_address(fmmu0_address),
		.fmmu1_address(fmmu1_address),
		.fmmu2_address(fmmu2_address),
		.fmmu3_address(fmmu3_address),

		.mem_address_read(mem_address_read),
		.mem_address_write(mem_address_write),
		.mem_logical_address_read(mem_logical_address_read),
		.mem_logical_address_write(mem_logical_address_write),
		.mem_data_write(mem_data_write),
		.mem_data_read(mem_data_read),
		.mem_logical_data_read(mem_logical_data_read),
		.mem_write_end_valid(mem_write_end_valid),
		.mem_logical_write_end_valid(mem_logical_write_end_valid),
		.mem_write_en(mem_write_en),
		.mem_logical_read_en(mem_logical_read_en),
		.mem_logical_write_en(mem_logical_write_en));

	slave_memory(
		.rst_n(rst_n),
		.clk(clk),
		.clk_25(clk_25),

		.link({MII_LINK1, MII_LINK0}),
		.fp_address(fp_address),
		.fmmu0_address(fmmu0_address),
		.fmmu1_address(fmmu1_address),
		.fmmu2_address(fmmu2_address),
		.fmmu3_address(fmmu3_address),

		.vled(vled),

		.mem_address_read(mem_address_read),
		.mem_address_write(mem_address_write),
		.mem_logical_address_read(mem_logical_address_read),
		.mem_logical_address_write(mem_logical_address_write),
		.mem_data_write(mem_data_write),
		.mem_data_read(mem_data_read),
		.mem_logical_data_read(mem_logical_data_read),
		.mem_write_end_valid(mem_write_end_valid),
		.mem_logical_write_end_valid(mem_logical_write_end_valid),
		.mem_write_en(mem_write_en),
		.mem_logical_read_en(mem_logical_read_en),
		.mem_logical_write_en(mem_logical_write_en));

	integer i; 

	//_____________________________MUTEX _____________________________________________________________________________________________________
/*	localparam integer NUMBER_MUTEX = 2;
	localparam integer MAX_FRAME_SIZE = 1500;
	localparam integer TICK_PER_US = 100;

	reg[1:0] mutex[NUMBER_MUTEX-1:0];
	reg[2:0] mutex_set[NUMBER_MUTEX-1:0];

	always@(posedge clk) begin
		if(!rst_n) begin
			for(i = 0; i < NUMBER_MUTEX; i = i+1)
				mutex[i] <= 3;
		end else begin
            for(i = 0; i < NUMBER_MUTEX; i = i+1)
                if(mutex[i] == 3)
                    mutex[i] = (mutex_set[i][0])? 0 : (mutex_set[i][1])? 1 : (mutex_set[i][2])? 2 : mutex[i];
                else if((!mutex_set[i][0] && mutex[i]==0) || (!mutex_set[i][1] && mutex[i]==1) || (!mutex_set[i][2] && mutex[i]==2))
                    mutex[i] = 3;
        end
    end*/

    // MDIO -------------------  MDIO -------------------  MDIO -------------------  MDIO -------------------  MDIO -------------------

    reg[31:0] st_rst2; 
    assign MII_MDC = 0;
    assign MII_MDIO = 1'hZ;
    
    assign MII_RST = st_rst2[30];//st_rst[9];
	always@(posedge clk_25) begin
        st_rst2 <= (!st_rst2[30])? st_rst2 + 1: st_rst2;
    end
endmodule
