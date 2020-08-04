module sram
(
	inout [15:0]sram_dq,

	input [17:0]addr,
	input wr_en_n,
	input clk,
	input rst

);
	reg[15:0] data [0:4000];
	integer i;
	initial begin
		for(i = 0; i < 40001; i=i+1)
			data[i] = 16'd0;
	end

	assign sram_dq = ((wr_en_n == 1'b1) ? data[addr] : {16{1'bz}});

	//write to mem
	always @(posedge clk) begin
		if(wr_en_n == 1'b0) begin
			data[addr] <= sram_dq;
		end
	end
endmodule