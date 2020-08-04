module wb_stage (
	input clk,
	input rst,

	input wb_en_i,
	input mem_r_en_i,
	input [3:0] dest_i,
	input [31:0] alu_res_i,
	input [31:0] data_mem_i,

	output wb_en_o,
	output [3:0] wb_dest_o,
	output [31:0] wb_val_o
	
);
	mux2to1 #(32) mux_wb(
		.sel(mem_r_en_i),
		.muxin0(alu_res_i),
		.muxin1(data_mem_i),
		.muxout(wb_val_o)
	);
	assign wb_dest_o = dest_i;
	assign wb_en_o = wb_en_i;

endmodule

module mux2to1 #(parameter length = 8) 
(
  input sel,
  input[length-1:0] muxin0,
  input[length-1:0] muxin1,
  output[length-1:0] muxout
);
  assign muxout = ((sel == 1'b0) ? muxin0 : muxin1);
endmodule









