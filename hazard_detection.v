module hazard_detection_unit
(
	output reg freeze,

	input[3:0] rn_id, 
		src_2_id,
		dst_exe, 
		dst_mem,
	input two_src_id,
		wb_en_mem,
		wb_en_exe,
		mem_read_en_exe,
		forwarding_en
);
	always @(*) begin
		freeze = 1'b0;
		if(mem_read_en_exe == 1'b1)begin
			if(dst_exe == rn_id)
				freeze = 1'b1;
			else if((two_src_id == 1'b1) && (dst_exe == src_2_id))
				freeze = 1'b1;
		end
		else if(forwarding_en == 1'b0) begin
			if(wb_en_exe == 1'b1) begin
				if(rn_id == dst_exe)
					freeze = 1'b1;
			end
			if(wb_en_mem == 1'b1) begin
				if(rn_id == dst_mem)
					freeze = 1'b1;
			end
			if(two_src_id == 1'b1) begin
				if(wb_en_exe == 1'b1) begin
					if(src_2_id == dst_exe)
						freeze = 1'b1;
				end
			end
			if(wb_en_mem == 1'b1) begin
					if(src_2_id == dst_mem)
						freeze = 1'b1;
			end
	    end
	end
endmodule