module mac_tx_v1_0_M00_AXI #
( 
	parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,// Base address of targeted slave
	parameter integer C_M_AXI_BURST_LEN	= 256,// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_ID_WIDTH	= 1,// Thread ID Width
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,// Width of Address Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 64,// Width of Data Bus
	parameter integer C_M_AXI_ARUSER_WIDTH	= 1// Width of User Read Address Bus
)
(
    output wire[31:0] data0,
    output wire[31:0] data1,
    output wire[31:0] data2,
		
	input wire  M_AXI_ACLK,// Global Clock Signal.
	input wire  M_AXI_ARESETN,// Global Reset Singal. This Signal is Active Low

	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,// Master Interface Read Address.
	output wire [7 : 0] M_AXI_ARLEN,// Burst length. The burst length gives the exact number of transfers in a burst
    output wire [2 : 0] M_AXI_ARSIZE,// Burst size. This signal indicates the size of each transfer in the burst
	output wire [1 : 0] M_AXI_ARBURST,
	output wire  M_AXI_ARLOCK,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
	output wire [3 : 0] M_AXI_ARCACHE,
	output wire [2 : 0] M_AXI_ARPROT,
	output wire [3 : 0] M_AXI_ARQOS,// Quality of Service, QoS identifier sent for each read transaction
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,// Optional User-defined signal in the read address channel.
	output wire  M_AXI_ARVALID,
	output wire  M_AXI_RREADY,	
	input wire  M_AXI_ARREADY,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,// Master Read Data
	input wire  M_AXI_RLAST,// Read last. This signal indicates the last transfer in a read burst
	input wire  M_AXI_RVALID,

    output[63:0]dma_tx_data,
    input[31:0]dma_tx_address,
    input[10:0]dma_tx_size, //bytes
    input dma_tx_start,
    output reg dma_tx_stop,
    output dma_tx_start_qword
);
	
    parameter [1:0] IDLE = 2'b00,
                    INIT_READ = 2'b10,  
                    INIT_COMPARE = 2'b11;
    reg [1:0] mst_exec_state;

	reg axi_arvalid;
	reg axi_rready;
	reg[7:0] read_index;
	reg	start_single_burst_read;
	reg	reads_done;
	reg	burst_read_active;
	wire rnext;
	reg init_txn_edge;

	wire init_txn_pulse = dma_tx_start;
	assign M_AXI_ARADDR	= dma_tx_address;
    assign dma_tx_data = M_AXI_RDATA;
	assign dma_tx_start_qword = rnext;

	
    function integer clogb2 (input integer bit_depth);             
    begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	       bit_depth = bit_depth >> 1;                                 
	    end   
    endfunction                                                     

	assign M_AXI_WLAST	= 0;//axi_wlast;
	assign M_AXI_ARID	= 'b0;
	wire[7:0] NUMBER_QWORDS = dma_tx_size[10:3] + ((dma_tx_size[2:0])? 1 : 0);
	assign M_AXI_ARLEN	= NUMBER_QWORDS - 1;

	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARLOCK	= 1'b0;
	assign M_AXI_ARCACHE	= 4'b0011;
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b0;//1;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_RREADY	= axi_rready;
    assign rnext = M_AXI_RVALID && axi_rready;                            

    always @(posedge M_AXI_ACLK) begin                                                              
        axi_arvalid <=  (!M_AXI_ARESETN || init_txn_pulse)? 0 :
                        (~axi_arvalid && start_single_burst_read)? 1 :
                        (M_AXI_ARREADY && axi_arvalid)? 0 : axi_arvalid; 
        axi_rready <=   (!M_AXI_ARESETN || init_txn_pulse)? 0 :
                        (M_AXI_RVALID && ~axi_rready)? 1 : 0;
        burst_read_active <= (!M_AXI_ARESETN || init_txn_pulse)? 0 :
                             (start_single_burst_read)? 1 :
                             (M_AXI_RVALID && axi_rready && M_AXI_RLAST)? 0 : burst_read_active;
        read_index <=   (!M_AXI_ARESETN || init_txn_pulse || start_single_burst_read)? 0 :
                        (rnext)? read_index + 1 : read_index;
        reads_done <=   (!M_AXI_ARESETN || init_txn_pulse)? 0 :
                        (M_AXI_RVALID && axi_rready && (read_index == (NUMBER_QWORDS - 1)))? 1 : reads_done;
    end                                                                

//    assign data0 = {24'h0, 3'h0, start_single_burst_read, 2'h0,mst_exec_state};
//    assign data1 = dma_tx_address[31:0];
//    assign data2 = {13'h0, burst_read_active, axi_rready, axi_arvalid, read_index, NUMBER_QWORDS};
	
    always@(posedge M_AXI_ACLK) begin  
        if(!M_AXI_ARESETN) begin
            mst_exec_state      <= IDLE;
            start_single_burst_read  <= 0;
            dma_tx_stop <= 0;
        end else begin
            case(mst_exec_state)                                                                               
                IDLE: begin
                    dma_tx_stop <= 0;                                                                                    
	                if(init_txn_pulse)
	                   mst_exec_state  <= INIT_READ;
	            end                                                                                     
                INIT_READ: begin
                    if(reads_done)                                                                                 
                        mst_exec_state <= INIT_COMPARE;                                                             
                    else                                                                                         
                        start_single_burst_read <= (~axi_arvalid && ~burst_read_active && ~start_single_burst_read)? 1 : 0;                                                          
                end          
                INIT_COMPARE:                                                                                     
                    begin                           
                        dma_tx_stop <= 1;                                                                
                        mst_exec_state <= IDLE;                                                               
                    end                                                                                             
                default :                                                                                         
                    mst_exec_state  <= IDLE;                                                              
            endcase                                                                                             
        end                                                                                                   
    end                                                                               
endmodule