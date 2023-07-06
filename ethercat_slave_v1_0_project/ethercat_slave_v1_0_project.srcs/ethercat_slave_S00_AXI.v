module ethercat_slave_v1_0_S00_AXI #
(
	parameter integer C_S_AXI_DATA_WIDTH	= 32,
	parameter integer C_S_AXI_ADDR_WIDTH	= 8
)
(
	output reg[5:0] CHANGE_SLV_REG_NUMBER_WRITE,
	output reg[5:0] CHANGE_SLV_REG_NUMBER_READ,
	output reg CHANGE_SLV_REG_EVENT_WRITE,
	output CHANGE_SLV_REG_EVENT_READ,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG0,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG1,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG2,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG3,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG4,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG5,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG6,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG7,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG8,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG9,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG10,
	output reg[C_S_AXI_DATA_WIDTH-1:0] SLV_REG11,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG0,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG1,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG2,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG3,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG4,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG5,
	input wire[C_S_AXI_DATA_WIDTH-1:0] MST_REG6,
	input wire[C_S_AXI_DATA_WIDTH-1:0] IRQ_DATA,

	input wire  S_AXI_ACLK,
	input wire  S_AXI_ARESETN,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
	input wire [2 : 0] S_AXI_AWPROT,
	input wire  S_AXI_AWVALID,
	output wire  S_AXI_AWREADY,
	input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
	input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input wire  S_AXI_WVALID,
	output wire  S_AXI_WREADY,
	output wire [1 : 0] S_AXI_BRESP,
	output wire  S_AXI_BVALID,
	input wire  S_AXI_BREADY,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
	input wire [2 : 0] S_AXI_ARPROT,
	input wire  S_AXI_ARVALID,
	output wire  S_AXI_ARREADY,
	output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
	output wire [1 : 0] S_AXI_RRESP,
	output wire  S_AXI_RVALID,
	input wire  S_AXI_RREADY
);

	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg axi_awready;
	reg axi_wready;
	reg axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg axi_rvalid;

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = C_S_AXI_ADDR_WIDTH-ADDR_LSB-1;

	wire slv_reg_rden;
	wire slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer byte_index;

	assign S_AXI_AWREADY = axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= 0;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY = axi_arready;
	assign S_AXI_RDATA = axi_rdata;
	assign S_AXI_RRESP = 0;
	assign S_AXI_RVALID	= axi_rvalid;

	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always@(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN) begin
			SLV_REG0 <= 0;
			SLV_REG1 <= 1000; //timeout, us
			SLV_REG2 <= 0;
			SLV_REG3 <= 0;
			SLV_REG4 <= 0;
			SLV_REG5 <= 0;
			SLV_REG6 <= 0;
			SLV_REG7 <= 0;
			SLV_REG8 <= 0;
			SLV_REG9 <= 0;
			SLV_REG10 <= 0;
			SLV_REG11 <= 0;
			CHANGE_SLV_REG_NUMBER_WRITE <= 0;
			CHANGE_SLV_REG_EVENT_WRITE <= 0;
		end else begin
			CHANGE_SLV_REG_EVENT_WRITE <= slv_reg_wren;
			if(slv_reg_wren) begin
//				CHANGE_SLV_REG_NUMBER_WRITE[5:0] <= axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
//				case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
				CHANGE_SLV_REG_NUMBER_WRITE[5:0] <= axi_awaddr[7:2];
				case(axi_awaddr[7:2])
					6'h0: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h1: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h2: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h3: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h4: begin //  
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h5: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h6: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h7: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h8: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h9: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h10: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					6'h11: begin // 
						for(byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
							if(S_AXI_WSTRB[byte_index] == 1)
								SLV_REG11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
					end
					default : ;
				endcase
			end
		end
	end    

	always @(posedge S_AXI_ACLK) begin
		axi_awready	<=	(!S_AXI_ARESETN)? 0 :
						(~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)? 1 : 0;
		axi_awaddr	<=	(!S_AXI_ARESETN)? 0 :
						(~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)? S_AXI_AWADDR : axi_awaddr;
		axi_wready	<=	(!S_AXI_ARESETN)? 0 :
						(~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)? 1 : 0; 
		axi_bvalid	<=	(!S_AXI_ARESETN)? 0 :
						(axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)? 1 :
						(S_AXI_BREADY && axi_bvalid)? 0 : axi_bvalid;
		axi_arready	<=	(!S_AXI_ARESETN)? 0 :
						(~axi_arready && S_AXI_ARVALID)? 1 : 0;
		axi_araddr	<=	(!S_AXI_ARESETN)? 0 :
						(~axi_arready && S_AXI_ARVALID)? S_AXI_ARADDR : axi_araddr;
		axi_rvalid	<=	(!S_AXI_ARESETN)? 0 :
						(axi_arready && S_AXI_ARVALID && ~axi_rvalid)? 1 :
						(axi_rvalid && S_AXI_RREADY)? 0 : axi_rvalid;
		axi_rdata	<=	(!S_AXI_ARESETN)? 0 :
						(slv_reg_rden)? reg_data_out : axi_rdata;
	end

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	assign CHANGE_SLV_REG_EVENT_READ = slv_reg_rden;
	always@(*) begin
		if(!S_AXI_ARESETN) begin
			CHANGE_SLV_REG_NUMBER_READ <= 0;
			reg_data_out <= 0;
		end else begin
//			CHANGE_SLV_REG_NUMBER_READ[OPT_MEM_ADDR_BITS:0] <= axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
//			case(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
			CHANGE_SLV_REG_NUMBER_READ[5:0] <= axi_araddr[7:2];
			case(axi_araddr[7:2])
				6'h0 : reg_data_out <= IRQ_DATA; 
				6'h1 : reg_data_out <= MST_REG0;
				6'h2 : reg_data_out <= MST_REG1;
				6'h3 : reg_data_out <= MST_REG2;
				6'h4 : reg_data_out <= MST_REG3;
				6'h5 : reg_data_out <= MST_REG4;
				6'h6 : reg_data_out <= MST_REG5;
				6'h7 : reg_data_out <= MST_REG6;
				6'h8 : reg_data_out <= 0;
				default : reg_data_out <= 0;
			endcase
		end
	end
endmodule
