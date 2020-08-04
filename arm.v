module arm
(
	output [17:0] sram_addr,
	output sram_ub_n,
	output sram_lb_n,
	output sram_we_n,
	output sram_ce_n,
	output sram_oe_n,

	inout [15:0] sram_dq,// inout
	
	input forwarding_en,
	input clk,
	input rst
);

//wire flush_exe_if_id;
//assign flush_exe_if_id = 1'b0; //debugggggggggggggggggggggg
wire[31:0] alu_result_exe_mem;
wire[31:0] pc_if_id;
wire[31:0] instruction_if_id;
wire freeze;

wire c_id_exe;
wire wb_en_id_exe;
wire mem_write_en_id_exe;
wire mem_read_en_id_exe;
wire s_id_exe;
wire b_id_exe;
wire imm_id_exe;
wire two_src_id;
wire freeze_mem;
wire[3:0] exe_cmd_id_exe;
wire[3:0] dst_id_exe;
wire[3:0] src_2_id;
wire[11:0] shift_operand_id_exe;
wire[23:0] signed_imm_24_id_exe;
wire[31:0] pc_id_exe;
wire[31:0] val_rn_id_exe;
wire[31:0] val_rm_id_exe;
wire[1:0] sel_src_1;
wire[1:0] sel_src_2;
wire[3:0] src_1_id_forwarding;
wire[3:0] src_2_id_forwarding;



//wire branch_tacken_exe_if;
//assign branch_tacken_exe_if = 1'b0; //debugggggggggggggggggggggg
wire[31:0] branch_adder_exe_if;
wire wb_en_exe_mem;
wire mem_read_en_exe_mem;
wire mem_write_en_exe_mem;
wire[3:0] dst_exe_mem;
//wire[31:0] alu_result_exe_mem;
wire[31:0] val_rm_exe_mem;

wire wb_en_mem_wb;
wire mem_read_en_mem_wb;
wire[3:0] dst_mem_wb;
wire[31:0] result_mem_wb;
wire[31:0] data_mem_mem_wb;


wire wb_en_wb_id;
wire[3:0] dst_wb_id;
wire[31:0] result_wb_id;

wire[3:0] sr_status_id;
wire mem_freeze_or_hazard_freeze;

assign mem_freeze_or_hazard_freeze = freeze | freeze_mem;


if_stage if_instance
(
	.pc_o(pc_if_id),
	.instruction_o(instruction_if_id),
	.branch_adder_i(branch_adder_exe_if),

	.clk(clk), 
	.rst(rst), 
	.freeze_i(mem_freeze_or_hazard_freeze), 
	.branch_tacken_i(b_id_exe), 
	.flush_i(b_id_exe)
);
id_stage id_instance
(
	.pc_out(pc_id_exe),
	.val_rn_out(val_rn_id_exe), 
	.val_rm_out(val_rm_id_exe),
	.signed_imm_24_out(signed_imm_24_id_exe),
	.shift_operand_out(shift_operand_id_exe),
	.exe_cmd_out(exe_cmd_id_exe),
	.dst_out(dst_id_exe),
	.src_1(src_1_id_forwarding),
	.src_2(src_2_id_forwarding),
	.src_2_id(src_2_id),
	.wb_en_out(wb_en_id_exe), 
	.mem_write_en_out(mem_write_en_id_exe), 
	.mem_read_en_out(mem_read_en_id_exe),
	.s_out(s_id_exe), 
	.b_out(b_id_exe),
	.imm_out(imm_id_exe),
	.two_src(two_src_id),
	.c_out(c_id_exe),

	.pc_in(pc_if_id),
	.instruction(instruction_if_id), 
	.result_wb(result_wb_id),
	.dst_wb(dst_wb_id), 
	.sr(sr_status_id),
	.freeze(freeze_mem),
	.wb_en_in(wb_en_wb_id), 
	.hazard(freeze), 
	.flush(b_id_exe), 
	.clk(clk), 
	.rst(rst)

);

exe_stage exe_stage_instance
(
	.wb_en_exe_mem(wb_en_exe_mem),
	.mem_read_en_exe_mem(mem_read_en_exe_mem),
	.mem_write_en_exe_mem(mem_write_en_exe_mem),
	.alu_result_exe_mem(alu_result_exe_mem),
	.val_rm_exe_mem(val_rm_exe_mem),
	.branch_adder_exe_if(branch_adder_exe_if),
	.dst_exe_mem(dst_exe_mem),
	.sr_exe_if(sr_status_id),

	.c_in(c_id_exe),
	.wb_en_id_exe(wb_en_id_exe), 
	.mem_read_en_id_exe(mem_read_en_id_exe), 
	.mem_write_en_id_exe(mem_write_en_id_exe), 
	.b_id_exe(b_id_exe), 
	.s_id_exe(s_id_exe),
	.val_rn_id_exe(val_rn_id_exe),
	.pc_id_exe(pc_id_exe),
	.val_rm_id_exe(val_rm_id_exe),
	.alu_result_mem(alu_result_exe_mem),
	.data_wb_wb(result_wb_id),
	.imm_id_exe(imm_id_exe), 
	.shift_operand_id_exe(shift_operand_id_exe),
	.signed_imm_24_id_exe(signed_imm_24_id_exe),
	.sel_src_1(sel_src_1),
	.sel_src_2(sel_src_2),
	.exe_cmd_id_exe(exe_cmd_id_exe),
	.dst_id_exe(dst_id_exe),
	.forwarding_en(forwarding_en),
	.freeze(freeze_mem),
	.clk(clk), 
	.rst(rst)
);


mem_stage mem_stage_instance(
	.clk(clk),
	.rst(rst),
	.mem_w_en_i(mem_write_en_exe_mem),
	.mem_r_en_i(mem_read_en_exe_mem),
	.wb_en_i(wb_en_exe_mem),
	.val_rm_i(val_rm_exe_mem),
	.dest_i(dst_exe_mem),
	.alu_res_i(alu_result_exe_mem),

	.sram_dq(sram_dq),//inout

	.freeze_o(freeze_mem),
	.wb_en_o(wb_en_mem_wb),
	.mem_r_en_o(mem_read_en_mem_wb),
	.dest_o(dst_mem_wb),
	.alu_res_o(result_mem_wb),
	.data_mem_o(data_mem_mem_wb),
	.sram_addr(sram_addr),
	.sram_ub_n(sram_ub_n),
	.sram_lb_n(sram_lb_n),
	.sram_we_n(sram_we_n),
	.sram_ce_n(sram_ce_n),
	.sram_oe_n(sram_oe_n)
);
wb_stage wb_stage_instance(
	.clk(clk),
	.rst(rst),

	.wb_en_o(wb_en_wb_id),
	.wb_dest_o(dst_wb_id),
	.wb_val_o(result_wb_id),

	.wb_en_i(wb_en_mem_wb),
	.mem_r_en_i(mem_read_en_mem_wb),
	.dest_i(dst_mem_wb),
	.alu_res_i(result_mem_wb),
	.data_mem_i(data_mem_mem_wb)
	
);
hazard_detection_unit hazard_detection_instance
(
	.freeze(freeze),

	.rn_id(instruction_if_id[19:16]), 
	.src_2_id(src_2_id),
	.dst_exe(dst_id_exe), 
	.dst_mem(dst_exe_mem),
	.two_src_id(two_src_id), 
	.wb_en_mem(wb_en_exe_mem), 
	.wb_en_exe(wb_en_id_exe),
	.mem_read_en_exe(mem_read_en_id_exe),
	.forwarding_en(forwarding_en)
);
forwarding_unit forwarding_unit_instance
(
	.sel_src_1(sel_src_1),
	.sel_src_2(sel_src_2),

	.dst_mem(dst_exe_mem), 
	.dst_wb(dst_mem_wb),
	.src_1(src_1_id_forwarding),
	.src_2(src_2_id_forwarding),
	.wb_en_mem(wb_en_exe_mem), 
	.wb_en_wb(wb_en_mem_wb)
);
endmodule

