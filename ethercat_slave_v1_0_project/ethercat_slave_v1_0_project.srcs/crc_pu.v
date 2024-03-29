`timescale 1ns / 1ps

module crc_pu(
	input clk,
	input[7:0] d,
	input init,
	input en,
	output[31:0] crc_out
	);

	reg[31:0] c;

	assign crc_out = ~{ c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], 
						c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15], 
						c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23], 
						c[24], c[25], c[26], c[27], c[28], c[29], c[30], c[31]};
	
	always@(posedge clk) begin
		if(init)  
			c <= 32'hFFFFFFFF;
		else if(en) 
			c <= {
					d[2] ^ c[23] ^ c[29],
					d[0] ^ d[3] ^ c[22] ^ c[28] ^ c[31],
					d[0] ^ d[1] ^ d[4] ^ c[21] ^ c[27] ^ c[30] ^ c[31],
					d[1] ^ d[2] ^ d[5] ^ c[20] ^ c[26] ^ c[29] ^ c[30],
					d[0] ^ d[2] ^ d[3] ^ d[6] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31],
					d[1] ^ d[3] ^ d[4] ^ d[7] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30],
					d[4] ^ d[5] ^ c[17] ^ c[26] ^ c[27],
					d[0] ^ d[5] ^ d[6] ^ c[16] ^ c[25] ^ c[26] ^ c[31],            
					d[1] ^ d[6] ^ d[7] ^ c[15] ^ c[24] ^ c[25] ^ c[30],
					d[7] ^ c[14] ^ c[24],
					d[2] ^ c[13] ^ c[29],
					d[3] ^ c[12] ^ c[28],
					d[0] ^ d[4] ^ c[11] ^ c[27] ^ c[31],
					d[0] ^ d[1] ^ d[5] ^ c[10] ^ c[26] ^ c[30] ^ c[31],
					d[1] ^ d[2] ^ d[6] ^ c[9] ^ c[25] ^ c[29] ^ c[30],
					d[2] ^ d[3] ^ d[7] ^ c[8] ^ c[24] ^ c[28] ^ c[29],
					d[0] ^ d[2] ^ d[3] ^ d[4] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31],
					d[0] ^ d[1] ^ d[3] ^ d[4] ^ d[5] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31],
					d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31],
					d[1] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ d[7] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30],
					d[3] ^ d[4] ^ d[6] ^ d[7] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28],
					d[2] ^ d[4] ^ d[5] ^ d[7] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29],
					d[2] ^ d[3] ^ d[5] ^ d[6] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29],
					d[3] ^ d[4] ^ d[6] ^ d[7] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28],            
					d[0] ^ d[2] ^ d[4] ^ d[5] ^ d[7] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31],
					d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31],
					d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[6] ^ d[7] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31],
					d[1] ^ d[3] ^ d[4] ^ d[5] ^ d[7] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30],
					d[0] ^ d[4] ^ d[5] ^ d[6] ^ c[25] ^ c[26] ^ c[27] ^ c[31],
					d[0] ^ d[1] ^ d[5] ^ d[6] ^ d[7] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31],
					d[0] ^ d[1] ^ d[6] ^ d[7] ^ c[24] ^ c[25] ^ c[30] ^ c[31],
					d[1] ^ d[7] ^ c[24] ^ c[30] };
	end

endmodule
