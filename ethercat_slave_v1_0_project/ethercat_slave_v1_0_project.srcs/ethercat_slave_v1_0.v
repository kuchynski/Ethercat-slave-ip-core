module ethercat_slave_v1_0 #(
	// Parameters of Axi Slave Bus Interface S00_AXI
	parameter integer C_S00_AXI_DATA_WIDTH	= 32,
	parameter integer C_S00_AXI_ADDR_WIDTH	= 8,

	// Parameters of Axi Master Bus Interface M00_AXI
	parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_M00_AXI_BURST_LEN	= 16,
	parameter integer C_M00_AXI_ID_WIDTH	= 1,
	parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M00_AXI_DATA_WIDTH	= 64,
	parameter integer C_M00_AXI_AWUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_ARUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_WUSER_WIDTH	= 8,
	parameter integer C_M00_AXI_RUSER_WIDTH	= 8,
	parameter integer C_M00_AXI_BUSER_WIDTH	= 1
)
(
	input wire clk_25,

	input wire MII_TX0_CLK,
	output wire[3:0] MII_TX0_DATA,
	output wire MII_TX0_ENA,
	input wire MII_RX0_CLK,
	input wire[3:0] MII_RX0_DATA,
	input wire MII_RX0_ENA,
	input wire MII_RX0_ERR,
	input wire MII_LINK0_n,
	output wire MII_RST,
	output wire MII_MDC,
	output wire MII_MDIO,

	input wire MII_TX1_CLK,
	output wire[3:0] MII_TX1_DATA,
	output wire MII_TX1_ENA,
	input wire MII_RX1_CLK,
	input wire[3:0] MII_RX1_DATA,
	input wire MII_RX1_ENA,
	input wire MII_RX1_ERR,
	input wire MII_LINK1_n,

	output wire IRQ,
	output wire vled,

	input wire  s00_axi_aclk,
	input wire  s00_axi_aresetn,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
	input wire [2 : 0] s00_axi_awprot,
	input wire  s00_axi_awvalid,
	output wire  s00_axi_awready,
	input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
	input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
	input wire  s00_axi_wvalid,
	output wire  s00_axi_wready,
	output wire [1 : 0] s00_axi_bresp,
	output wire  s00_axi_bvalid,
	input wire  s00_axi_bready,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
	input wire [2 : 0] s00_axi_arprot,
	input wire  s00_axi_arvalid,
	output wire  s00_axi_arready,
	output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
	output wire [1 : 0] s00_axi_rresp,
	output wire  s00_axi_rvalid,
	input wire  s00_axi_rready,

	// Ports of Axi Master Bus Interface M00_AXI
	input wire  m00_axi_aclk,
	input wire  m00_axi_aresetn,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
	output wire [7 : 0] m00_axi_awlen,
	output wire [2 : 0] m00_axi_awsize,
	output wire [1 : 0] m00_axi_awburst,
	output wire  m00_axi_awlock,
	output wire [3 : 0] m00_axi_awcache,
	output wire [2 : 0] m00_axi_awprot,
	output wire [3 : 0] m00_axi_awqos,
	output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
	output wire  m00_axi_awvalid,
	input wire  m00_axi_awready,
	output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
	output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	output wire  m00_axi_wlast,
	output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
	output wire  m00_axi_wvalid,
	input wire  m00_axi_wready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
	input wire [1 : 0] m00_axi_bresp,
	input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
	input wire  m00_axi_bvalid,
	output wire  m00_axi_bready,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
	output wire [7 : 0] m00_axi_arlen,
	output wire [2 : 0] m00_axi_arsize,
	output wire [1 : 0] m00_axi_arburst,
	output wire  m00_axi_arlock,
	output wire [3 : 0] m00_axi_arcache,
	output wire [2 : 0] m00_axi_arprot,
	output wire [3 : 0] m00_axi_arqos,
	output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
	output wire  m00_axi_arvalid,
	input wire  m00_axi_arready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
	input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
	input wire [1 : 0] m00_axi_rresp,
	input wire  m00_axi_rlast,
	input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
	input wire  m00_axi_rvalid,
	output wire  m00_axi_rready
);

	wire MII_RX0_CLK_bufg;
	wire MII_RX1_CLK_bufg;
	wire MII_TX0_CLK_bufg;
	wire MII_TX1_CLK_bufg;
	
	BUFG BUFG_inst0(.I(MII_RX0_CLK), .O(MII_RX0_CLK_bufg));
	BUFG BUFG_inst1(.I(MII_RX1_CLK), .O(MII_RX1_CLK_bufg));
	BUFG BUFG_inst2(.I(!MII_TX0_CLK), .O(MII_TX0_CLK_bufg));
	BUFG BUFG_inst3(.I(!MII_TX1_CLK), .O(MII_TX1_CLK_bufg));

	wire[31:0] SLV_REG0, SLV_REG1, SLV_REG2, SLV_REG3, SLV_REG4, SLV_REG5, SLV_REG6, SLV_REG7, SLV_REG8, SLV_REG9, SLV_REG10, SLV_REG11, IRQ_DATA;
	wire[31:0] datac0, datac1, datac2, datac3, datac4, datac5, datac6, datac7;
	wire[31:0] data0, data1, data2;
	wire[31:0] data_r0, data_r1, data_r2, data_r3;
	wire[5:0] CHANGE_SLV_REG_NUMBER_WRITE, CHANGE_SLV_REG_NUMBER_READ;
	wire CHANGE_SLV_REG_EVENT_WRITE, CHANGE_SLV_REG_EVENT_READ;
	wire[63:0] dma_tx_data, dma_rx_data;
	wire[31:0] dma_tx_address, dma_rx_address;
	wire[10:0] dma_tx_size, dma_rx_size;
	wire dma_tx_start, dma_tx_stop, dma_tx_start_qword, dma_rx_start, dma_rx_stop, dma_rx_start_qword;

	cpu_ethercat_slave # (
	) cpu_ethercat_slaveethercat_slave_v1_0_S00_AXI_inst (
		.clk(s00_axi_aclk),
		.clk_25(clk_25),
		.rst_n(s00_axi_aresetn),

		.MII_TX0_CLK(MII_TX0_CLK_bufg),
		.MII_TX0_DATA(MII_TX0_DATA),
		.MII_TX0_ENA(MII_TX0_ENA),
		.MII_RX0_CLK(MII_RX0_CLK_bufg),
		.MII_RX0_DATA(MII_RX0_DATA),
		.MII_RX0_ENA(MII_RX0_ENA),
		.MII_RX0_ERR(MII_RX0_ERR),
		.MII_LINK0(!MII_LINK0_n),
		.MII_RST(MII_RST),
		.MII_MDC(MII_MDC),
		.MII_MDIO(MII_MDIO),

		.MII_TX1_CLK(MII_TX1_CLK_bufg),
		.MII_TX1_DATA(MII_TX1_DATA),
		.MII_TX1_ENA(MII_TX1_ENA),
		.MII_RX1_CLK(MII_RX1_CLK_bufg),
		.MII_RX1_DATA(MII_RX1_DATA),
		.MII_RX1_ENA(MII_RX1_ENA),
		.MII_RX1_ERR(MII_RX1_ERR),
		.MII_LINK1(!MII_LINK1_n),

		.vled(vled),

		.CHANGE_SLV_REG_EVENT_WRITE(CHANGE_SLV_REG_EVENT_WRITE),
		.CHANGE_SLV_REG_EVENT_READ(CHANGE_SLV_REG_EVENT_READ),
		.CHANGE_SLV_REG_NUMBER_WRITE(CHANGE_SLV_REG_NUMBER_WRITE),
		.CHANGE_SLV_REG_NUMBER_READ(CHANGE_SLV_REG_NUMBER_READ),
		.SLV_REG_REQUEST_0(SLV_REG5),
		.SLV_REG_REQUEST_1(SLV_REG6),
		.SLV_REG_REQUEST_2(SLV_REG7),
		.SLV_REG_REQUEST_3(SLV_REG8),
		.IRQ_MASK(SLV_REG2[0]),
		.IRQ(IRQ),

		.data0(datac0),
		.data1(datac1),
		.data2(datac2),
		.data3(datac3),
		.data4(datac4),
		.data5(datac5),
		.data6(datac6),
		.data7(datac7),

		.dma_rx_data(dma_rx_data),
		.dma_rx_address(dma_rx_address),
		.dma_rx_size(dma_rx_size),
		.dma_rx_start(dma_rx_start),
		.dma_rx_stop(dma_rx_stop),
		.dma_rx_start_qword(dma_rx_start_qword),

		.dma_tx_data(dma_tx_data),
		.dma_tx_address(dma_tx_address),
		.dma_tx_size(dma_tx_size),
		.dma_tx_start(dma_tx_start),
		.dma_tx_stop(dma_tx_stop0),
		.dma_tx_start_qword(dma_tx_start_qword)
	);

// Instantiation of Axi Bus Interface S00_AXI
	ethercat_slave_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ethercat_slave_v1_0_S00_AXI_inst (
		.CHANGE_SLV_REG_EVENT_WRITE(CHANGE_SLV_REG_EVENT_WRITE),
		.CHANGE_SLV_REG_EVENT_READ(CHANGE_SLV_REG_EVENT_READ),
		.CHANGE_SLV_REG_NUMBER_WRITE(CHANGE_SLV_REG_NUMBER_WRITE),
		.CHANGE_SLV_REG_NUMBER_READ(CHANGE_SLV_REG_NUMBER_READ),
		.IRQ_DATA(IRQ_DATA),
		.SLV_REG0(SLV_REG0), 
		.SLV_REG1(SLV_REG1),
		.SLV_REG2(SLV_REG2),
		.SLV_REG3(SLV_REG3),
		.SLV_REG4(SLV_REG4),
		.SLV_REG5(SLV_REG5),
		.SLV_REG6(SLV_REG6),
		.SLV_REG7(SLV_REG7),
		.SLV_REG8(SLV_REG8),
		.SLV_REG9(SLV_REG9),
		.SLV_REG10(SLV_REG10),
		.SLV_REG11(SLV_REG11),
		.MST_REG0(datac0),
		.MST_REG1(datac1),
		.MST_REG2(datac2),
		.MST_REG3(datac3),
		.MST_REG4(datac4),
		.MST_REG5(datac5),
		.MST_REG6(datac6),

		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
   

// Instantiation of Axi Bus Interface M00_AXI
	mac_tx_v1_0_M00_AXI # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH)
	) mac_tx_v1_0_M00_AXI_inst (
		.data0(data0),
		.data1(data1),
		.data2(data2),

		.dma_tx_data(dma_tx_data),
		.dma_tx_address(dma_tx_address),
		.dma_tx_size(dma_tx_size),
		.dma_tx_start(dma_tx_start),
		.dma_tx_stop(dma_tx_stop0),
		.dma_tx_start_qword(dma_tx_start_qword),

		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_ARID(m00_axi_arid),
		.M_AXI_ARADDR(m00_axi_araddr),
		.M_AXI_ARLEN(m00_axi_arlen),
		.M_AXI_ARSIZE(m00_axi_arsize),
		.M_AXI_ARBURST(m00_axi_arburst),
		.M_AXI_ARLOCK(m00_axi_arlock),
		.M_AXI_ARCACHE(m00_axi_arcache),
		.M_AXI_ARPROT(m00_axi_arprot),
		.M_AXI_ARQOS(m00_axi_arqos),
		.M_AXI_ARUSER(m00_axi_aruser),
		.M_AXI_ARVALID(m00_axi_arvalid),
		.M_AXI_ARREADY(m00_axi_arready),
		.M_AXI_RDATA(m00_axi_rdata),
		.M_AXI_RLAST(m00_axi_rlast),
		.M_AXI_RVALID(m00_axi_rvalid),
		.M_AXI_RREADY(m00_axi_rready)
	);

// Instantiation of Axi Bus Interface M00_AXI
	mac_rx_v1_0_M00_AXI # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH)
	) mac_rx_v1_0_M00_AXI_inst (

		.dma_rx_data(dma_rx_data),
		.dma_rx_address(dma_rx_address),
		.dma_rx_size(dma_rx_size),
		.dma_rx_start(dma_rx_start),
		.dma_rx_stop(dma_rx_stop),
		.dma_rx_start_qword(dma_rx_start_qword),
		.data0(data_r0),
		.data1(data_r1),
		.data2(data_r2),

		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_AWID(m00_axi_awid),
		.M_AXI_AWADDR(m00_axi_awaddr),
		.M_AXI_AWLEN(m00_axi_awlen),
		.M_AXI_AWSIZE(m00_axi_awsize),
		.M_AXI_AWBURST(m00_axi_awburst),
		.M_AXI_AWLOCK(m00_axi_awlock),
		.M_AXI_AWCACHE(m00_axi_awcache),
		.M_AXI_AWPROT(m00_axi_awprot),
		.M_AXI_AWQOS(m00_axi_awqos),
		.M_AXI_AWUSER(m00_axi_awuser),
		.M_AXI_AWVALID(m00_axi_awvalid),
		.M_AXI_AWREADY(m00_axi_awready),
		.M_AXI_WDATA(m00_axi_wdata),
		.M_AXI_WSTRB(m00_axi_wstrb),
		.M_AXI_WLAST(m00_axi_wlast),
		.M_AXI_WUSER(m00_axi_wuser),
		.M_AXI_WVALID(m00_axi_wvalid),
		.M_AXI_WREADY(m00_axi_wready),
		.M_AXI_BVALID(m00_axi_bvalid),
		.M_AXI_BREADY(m00_axi_bready)
	);

	endmodule
