module forwarding_unit
(
	output reg[1:0] sel_src_1 = 2'd0,
	output reg[1:0] sel_src_2 = 2'd0,

	input[3:0] dst_mem, 
		dst_wb,
		src_1,
		src_2,
	input wb_en_mem, 
		wb_en_wb
);

	always @(*) begin
		sel_src_1 = 2'd0;
		sel_src_2 = 2'd0;
		case({wb_en_mem, wb_en_wb})
			2'b00 : begin
				sel_src_1 = 2'd0;
				sel_src_2 = 2'd0;
			end
			2'b01 : begin
				if(dst_wb == src_1)
					sel_src_1 = 2'd2;
				if(dst_wb == src_2)
					sel_src_2 = 2'd2;
			end
			2'b10 : begin
				if(dst_mem == src_1)
					sel_src_1 = 2'd1;
				if(dst_mem == src_2)
					sel_src_2 = 2'd1;
			end
			2'b11 : begin
				if(dst_mem == src_1)
					sel_src_1 = 2'd1;
				else if(dst_wb == src_1)
					sel_src_1 = 2'd2;

				if(dst_mem == src_2)
					sel_src_2 = 2'd1;
				else if(dst_wb == src_2)
					sel_src_2 = 2'd2;
			end
			default : begin
				sel_src_1 = 2'd0;
				sel_src_2 = 2'd0;
			end
		endcase

	end
endmodule