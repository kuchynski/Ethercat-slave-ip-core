module mac_rx_v1_0_M00_AXI #
( 
	parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,// Base address of targeted slave
	parameter integer C_M_AXI_BURST_LEN	= 256,// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_ID_WIDTH	= 1,// Thread ID Width
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,// Width of Address Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 64,// Width of Data Bus
	parameter integer C_M_AXI_AWUSER_WIDTH	= 1,// Width of User Write Address Bus
	parameter integer C_M_AXI_WUSER_WIDTH	= 8// Width of User Write Data Bus
) 
(
	output wire[31:0] data0,
	output wire[31:0] data1,
	output wire[31:0] data2,
		
	input wire  M_AXI_ACLK,// Global Clock Signal.
	input wire  M_AXI_ARESETN,// Global Reset Singal. This Signal is Active Low
	
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,// Master Interface Write Address ID
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,// Master Interface Write Address
	output wire [7 : 0] M_AXI_AWLEN,// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [2 : 0] M_AXI_AWSIZE,// Burst size. This signal indicates the size of each transfer in the burst
	output wire [1 : 0] M_AXI_AWBURST,
	output wire  M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,// Quality of Service, QoS identifier sent for each write transaction.
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
	output wire  M_AXI_AWVALID,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,// Master Interface Write Data.
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output wire  M_AXI_WLAST,// Write last. This signal indicates the last transfer in a write burst.
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,// Optional User-defined signal in the write data channel.
	output wire  M_AXI_WVALID,
	output wire  M_AXI_BREADY,
	input wire  M_AXI_WREADY,
	input wire  M_AXI_AWREADY,
	input wire  M_AXI_BVALID,
	
	input[63:0]dma_rx_data,
	input[31:0]dma_rx_address,
	input[10:0]dma_rx_size, //bytes
	input dma_rx_start,
	output reg dma_rx_stop,
	output dma_rx_start_qword
);

	function integer clogb2 (input integer bit_depth);
	begin
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			bit_depth = bit_depth >> 1;
	end
	endfunction

	parameter [1:0] IDLE = 2'b00,
					INIT_WRITE   = 2'b01, 
					INIT_COMPARE = 2'b11;
	reg [1:0] mst_exec_state;

	reg axi_awvalid;
	reg axi_wlast;
	reg axi_wvalid;
	reg axi_bready;
	reg[7:0] write_index;
	reg	start_single_burst_write;
	reg	writes_done, writes_done1, writes_done2;
	reg	burst_write_active;
	wire wnext;
	wire init_txn_pulse = dma_rx_start;

	wire[10:0] MAX_NUMBER_FRAMES = 0;

	assign M_AXI_AWID	= 'b0;
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0011;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	assign M_AXI_BREADY	= axi_bready;

	wire[7:0] NUMBER_QWORDS = dma_rx_size[10:3] + ((dma_rx_size[2:0])? 1 : 0);
	assign M_AXI_AWLEN	= NUMBER_QWORDS - 1;
	assign M_AXI_AWADDR	= dma_rx_address;
	assign M_AXI_WDATA = dma_rx_data;
	
	always@(posedge M_AXI_ACLK) begin
		if(!M_AXI_ARESETN) begin
			mst_exec_state <= IDLE;
			start_single_burst_write <= 0;
			writes_done2 <= 0;
			dma_rx_stop <= 0;
		end else begin
			case(mst_exec_state)
				IDLE: begin
					start_single_burst_write <= 0;
					dma_rx_stop <= 0;
					if(init_txn_pulse)
						mst_exec_state <= INIT_WRITE;
				end
				INIT_WRITE: begin
					if(writes_done) begin
						writes_done2 <= 1;
						mst_exec_state <= INIT_COMPARE;
					end else
						start_single_burst_write <= (~axi_awvalid && ~start_single_burst_write && ~burst_write_active)? 1 : 0;
				end
				INIT_COMPARE: begin
					dma_rx_stop <= 1; 
					start_single_burst_write <= 0;
					mst_exec_state <= IDLE;
				end
				default :
					mst_exec_state <= IDLE;
			endcase
		end
	end

	assign wnext = M_AXI_WREADY & axi_wvalid;
	assign dma_rx_start_qword = wnext;

	always @(posedge M_AXI_ACLK) begin  
		axi_awvalid	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :
						(~axi_awvalid && start_single_burst_write)? 1 :
						(M_AXI_AWREADY && axi_awvalid)? 0 : axi_awvalid; 
		axi_wvalid	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :
						(~axi_wvalid && start_single_burst_write)? 1 :
						(wnext && axi_wlast)? 0 : axi_wvalid;
		axi_wlast	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :
						((((write_index == (NUMBER_QWORDS-2)) && (NUMBER_QWORDS >= 2)) && wnext) || (NUMBER_QWORDS == 1 ))? 1 :
						(wnext)? 0 :
						(axi_wlast && (NUMBER_QWORDS == 1))? 0 : axi_wlast;
		write_index	<=	(!M_AXI_ARESETN || init_txn_pulse || start_single_burst_write)? 0 :
						(wnext && (write_index != (NUMBER_QWORDS-1)))? write_index + 1 : write_index;
		axi_bready	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :
						(M_AXI_BVALID && ~axi_bready)? 1 :
						(axi_bready)? 0 : axi_bready;
		burst_write_active	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :
								(start_single_burst_write)? 1 : 
								(M_AXI_BVALID && axi_bready)? 0 : burst_write_active;
		writes_done	<=	(!M_AXI_ARESETN || init_txn_pulse)? 0 :	(M_AXI_BVALID && axi_bready)? 1 : writes_done;
	end

endmodule