module exe_stage
(
	output wb_en_exe_mem,
	output mem_read_en_exe_mem,
	output mem_write_en_exe_mem,
	output [31:0] alu_result_exe_mem,
	output [31:0] val_rm_exe_mem,
	output [31:0] branch_adder_exe_if,
	output [3:0] dst_exe_mem,
	output[3:0] sr_exe_if,

	input c_in,
	input wb_en_id_exe,
	input mem_read_en_id_exe,
	input mem_write_en_id_exe,
	input b_id_exe,
	input s_id_exe,
	input[31:0] val_rn_id_exe,
	input[31:0] pc_id_exe,
	input[31:0] val_rm_id_exe,
	input[31:0] alu_result_mem,
	input[31:0] data_wb_wb,
	input imm_id_exe, 
	input[11:0] shift_operand_id_exe,
	input[23:0] signed_imm_24_id_exe,
	input[1:0] sel_src_1,
	input[1:0] sel_src_2,
	input[3:0] exe_cmd_id_exe,
	input[3:0] dst_id_exe,
	input forwarding_en,
	input freeze,
	input clk,
	input rst
);
	localparam mov_a = 4'b0001 ;
	localparam mvn_a = 4'b1001 ;
	localparam add_a = 4'b0010 ;
	localparam adc_a = 4'b0011 ;
	localparam sub_a = 4'b0100 ;
	localparam sbc_a = 4'b0101 ;
	localparam and_a = 4'b0110 ;
	localparam orr_a = 4'b0111 ;
	localparam eor_a = 4'b1000 ;
	localparam cmp_a = 4'b0100 ; //same as sub_a
	localparam tst_a = 4'b0110 ; //same as and_a
	localparam ldr_a = 4'b0010 ; //same as add_a
	localparam str_a = 4'b0010 ; //same as add_a

	wire or_out;
	wire signed [31:0] val_1, val_2;
	wire [31:0] signed_extend_imm;
	reg[31:0] src_1_mux_out;
	reg[31:0] src_2_mux_out;
	reg [32:0] alu_result;
	wire n, z, c, v;
	assign val_1 = src_1_mux_out;	


	always @(*) begin // src_1_mux
		if(forwarding_en == 1'b0)
			src_1_mux_out = val_rn_id_exe;
		else begin
			case(sel_src_1) 
				2'd0 :
					src_1_mux_out = val_rn_id_exe;
				2'd1 :
					src_1_mux_out = alu_result_mem;
				2'd2 :
					src_1_mux_out = data_wb_wb;
				default :
					src_1_mux_out = val_rn_id_exe;
			endcase
		end
	end


	always @(*) begin // src_2_mux
		if(forwarding_en == 1'b0)
			src_2_mux_out = val_rm_id_exe;
		else begin
			case(sel_src_2) 
				2'd0 :
					src_2_mux_out = val_rm_id_exe;
				2'd1 :
					src_2_mux_out = alu_result_mem;
				2'd2 :
					src_2_mux_out = data_wb_wb;
				default :
					src_2_mux_out = val_rm_id_exe;
			endcase
		end
	end

	//wire[33:0] result_sub;
	//wire cin_sub;
	//assign cin_sub = (exe_cmd_id_exe == sub_a) ? 1'b1 : 1'b0;
	//assign result_sub = {val_1, cin_sub} + {~val_2, cin_sub};

	always @(*) begin
		case (exe_cmd_id_exe) //synthesis parallel_case
			mov_a : alu_result = val_2;
			mvn_a : alu_result = ~val_2;
			add_a : alu_result = val_1 + val_2;
			adc_a : alu_result = val_1 + val_2 + c_in;
			sub_a : alu_result = val_1 - val_2;
			sbc_a : alu_result = val_1 - val_2 - 1'b1;
			and_a : alu_result = val_1 & val_2;
			orr_a : alu_result = val_1 | val_2;
			eor_a : alu_result = val_1 ^ val_2;
			default: 
				alu_result = 33'd0;
		endcase
	end
	//evaluate_status_inputs
	assign n = alu_result[31];
	assign z = (alu_result == 33'd0);
	assign c = alu_result[32];
	assign v = (alu_result[31] ^ c);
	
	assign signed_extend_imm = {{8{signed_imm_24_id_exe[23]}}, signed_imm_24_id_exe};
	assign branch_adder_exe_if = pc_id_exe + signed_extend_imm;
	assign or_out = mem_read_en_id_exe | mem_write_en_id_exe;

	exe_mem_reg exe_mem_reg_instance
	(
	.wb_en_exe_mem_o(wb_en_exe_mem),
	.mem_read_en_exe_mem_o(mem_read_en_exe_mem),
	.mem_write_en_exe_mem_o(mem_write_en_exe_mem),
	.alu_result_exe_mem_o(alu_result_exe_mem),
	.val_rm_exe_mem_o(val_rm_exe_mem),
	.dst_exe_mem_o(dst_exe_mem),

	.wb_en_exe_mem_i(wb_en_id_exe),
	.mem_read_en_exe_mem_i(mem_read_en_id_exe),
	.mem_write_en_exe_mem_i(mem_write_en_id_exe),
    .alu_result_exe_mem_i(alu_result[31:0]),
	.val_rm_exe_mem_i(src_2_mux_out),
	.dst_exe_mem_i(dst_id_exe),
	.freeze(freeze),
	.clk(clk), 
	.rst(rst)
	);

	val2generate val2generate_instance
	(
	.val_rm(src_2_mux_out),
    .shift_operand(shift_operand_id_exe),
    .imm(imm_id_exe),
    .or_out(or_out),

    .val2(val_2)
	);
	status_reg_mod status_reg_instance
	(
		.sr(sr_exe_if),

		.wr_en(s_id_exe),
		.n(n), 
		.z(z), 
		.c(c), 
		.v(v), 
		.clk(clk), 
		.rst(rst)
	);



endmodule


module exe_mem_reg
(
	output reg wb_en_exe_mem_o,
	output reg mem_read_en_exe_mem_o,
	output reg mem_write_en_exe_mem_o,
	output reg [31:0] alu_result_exe_mem_o,
	output reg [31:0] val_rm_exe_mem_o,
	output reg [3:0] dst_exe_mem_o,

	input wb_en_exe_mem_i,
	input mem_read_en_exe_mem_i,
	input mem_write_en_exe_mem_i,
	input[31:0] alu_result_exe_mem_i,
	input[31:0] val_rm_exe_mem_i,
	input[3:0] dst_exe_mem_i,

	input freeze, clk, rst

);
	always @(posedge clk) begin
		if (rst == 1'b1) begin
			wb_en_exe_mem_o <= 1'b0;
			mem_write_en_exe_mem_o <= 1'b0;
			mem_read_en_exe_mem_o <= 1'b0;
		end
		else if(freeze != 1'b1) begin
			wb_en_exe_mem_o <= wb_en_exe_mem_i;
			mem_read_en_exe_mem_o <= mem_read_en_exe_mem_i;
			mem_write_en_exe_mem_o <= mem_write_en_exe_mem_i;
			alu_result_exe_mem_o <= alu_result_exe_mem_i;
			val_rm_exe_mem_o <= val_rm_exe_mem_i;
			dst_exe_mem_o <= dst_exe_mem_i;
		end
	end
endmodule


module val2generate
(
    input [31:0]val_rm,
    input [11:0]shift_operand,
    input imm,
    input or_out,
    output reg[31:0] val2
);


reg[63:0] temp;
reg[63:0] shifttemp;
wire[4:0] rotate_imm_mul_2;
assign rotate_imm_mul_2 = (shift_operand[11:8] << 1);

always @(*) begin
    temp = 64'd0;
	shifttemp = 64'd0;
	val2 = 32'd0;
    if(or_out == 1) begin
        val2 = {{20{shift_operand[11]}},shift_operand};
    end
    else if(imm == 1) begin
        val2 = {{24{1'b0}},shift_operand[7:0]};
        temp[63:32] = val2;
        shifttemp = temp >> rotate_imm_mul_2;
        val2 = (shifttemp[63:32] | shifttemp[31:0]);
    end
    else if(imm == 0 && shift_operand[4] == 0) begin
        case(shift_operand[6:5])
        	2'b00: val2 = val_rm << (shift_operand[11:7]);
        	2'b01: val2 = val_rm >> (shift_operand[11:7]);
        	2'b10: val2 = val_rm >>> (shift_operand[11:7]);
        	2'b11: begin
        		temp[63:32] = val_rm;
        		shifttemp = temp >> shift_operand[11:7];
        		val2 = (shifttemp[63:32] | shifttemp[31:0]);
        	end
        endcase
    end
end
endmodule 
module status_reg_mod
(
	output[3:0] sr,
	input wr_en ,n, z, c, v, clk, rst
);
	parameter N = 31;
	parameter Z = 30;
	parameter C = 29;
	parameter V = 28;
	reg[31:0] status_reg;
	always @(negedge clk) begin
		if(rst == 1'b1)
			status_reg <= 32'd0;
		else if(wr_en == 1'b1) begin
			status_reg[N] <= n;
			status_reg[Z] <= z;
			status_reg[C] <= c;
			status_reg[V] <= v;
		end
	end
	assign sr = status_reg[31:28];
endmodule

