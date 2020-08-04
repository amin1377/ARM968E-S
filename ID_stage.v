module id_stage
(
	output[31:0] pc_out,
		val_rn_out, 
		val_rm_out,
	output[23:0] signed_imm_24_out,
	output[11:0] shift_operand_out,
	output[3:0] exe_cmd_out,
		dst_out,
		src_1, 
		src_2,
		src_2_id,
	output wb_en_out,
	output mem_write_en_out,
	output mem_read_en_out,
	output s_out,
	output b_out,
	output imm_out,
	output two_src,
	output c_out,

	input [31:0] pc_in,
	input [31:0] instruction,
	input [31:0] result_wb,
	input[3:0] dst_wb, 
		sr,
	input freeze, 
		wb_en_in, 
		hazard, 
		flush, 
		clk, 
		rst
);

	wire hc_sel;
	wire wb_en_w;
	wire cond_check;
	wire s;
	wire b;
	wire mem_write_en;
	wire mem_read_en;
	wire[3:0] exe_cmd;
	wire[3:0] reg_file_second_addr;
	wire[31:0] val_rn;
	wire[31:0] val_rm;
	assign src_2_id = reg_file_second_addr;
	assign reg_file_second_addr = (mem_write_en == 1'b0) ? instruction[3:0] : instruction[15:12];
	assign two_src = (mem_write_en | (~instruction[25]));
	register_file register_file_instance
	(
		.reg_1(val_rn), 
		.reg_2(val_rm),
		.result_wb(result_wb), 
		.src_1(instruction[19:16]), 
		.src_2(reg_file_second_addr),
		.dst_wb(dst_wb),
		.wb_en(wb_en_in), 
		.clk(clk), 
		.rst(rst) 
	);
	condition_check condition_check_instance
	(
		.cond_check(cond_check),
		.sr(sr),
		.cond(instruction[31:28]) 
	);
	
	controller_unit cu_instance(
		.hc_sel(hc_sel),
		.mode(instruction[27:26]),
		.opcode(instruction[24:21]),
		.s_in(instruction[20]),
		.execmd(exe_cmd),
		.mem_r_en(mem_read_en),
		.mem_w_en(mem_write_en),
		.wb_en(wb_en_w),
		.b_out(b),
		.s_out(s)
	);
	assign hc_sel = cond_check | hazard;
	id_ex_reg id_ex_reg_instance(
    	.rst(rst),
    	.clk(clk),
    	.freeze(freeze),
    	.wb_en(wb_en_w),
    	.mem_r_en(mem_read_en),
    	.mem_w_en(mem_write_en),
    	.exe_cmd(exe_cmd),
    	.b(b),
    	.s(s),
    	.pc(pc_in),
    	.val_rn(val_rn),
    	.val_rm(val_rm),
    	.shift_operand(instruction[11:0]),
    	.imm(instruction[25]),
    	.signed_imm_24(instruction[23:0]),
    	.dest(instruction[15:12]),
   		.flush(flush),
   		.c_in(sr[1]),
   		.src_1_i(instruction[19:16]), 
   		.src_2_i(reg_file_second_addr),

   		.src_1_o(src_1),
   		.src_2_o(src_2),
    	.wb_en_out(wb_en_out),
   		.mem_r_en_out(mem_read_en_out),
    	.mem_w_en_out(mem_write_en_out),
    	.exe_cmd_out(exe_cmd_out),
    	.b_out(b_out),
    	.s_out(s_out),
    	.pc_out(pc_out),
    	.val_rn_out(val_rn_out),
    	.val_rm_out(val_rm_out),
    	.shift_operand_out(shift_operand_out),
    	.imm_out(imm_out),
    	.signed_imm_24_out(signed_imm_24_out),
    	.dest_out(dst_out),
   		.c_out(c_out)
	);

endmodule


module register_file
(
	output[31:0] reg_1, reg_2,
	input[31:0] result_wb, 
	input[3:0] src_1, src_2, dst_wb,
	input wb_en, clk, rst 
);
	reg[31:0] reg_file[0:14];
	assign reg_1 = reg_file[src_1];
	assign reg_2 = reg_file[src_2];
	integer i;
	initial begin
		for(i = 0; i < 15; i=i+1) 
			reg_file[i] = 32'd0;
	end
	always @(negedge clk, posedge rst) begin
		if(rst == 1'b1) begin
			for(i = 0; i < 15; i = i+1)
			reg_file[i] = 32'd0;
		end
		else if(wb_en == 1'b1) begin
			reg_file[dst_wb] <= result_wb;
		end
	end
endmodule
module condition_check
(
	output reg cond_check,
	input[3:0] sr,
	input[3:0] cond 
);
	localparam N = 3;
	localparam Z = 2;
	localparam C = 1;
	localparam V = 0;
	localparam eq=4'd0;
	localparam ne=4'd1;
	localparam cs_hs=4'd2;
	localparam cc_lo=4'd3;
	localparam mi=4'd4;
	localparam pl=4'd5;
	localparam vs=4'd6;
	localparam vc=4'd7;
	localparam hi=4'd8;
	localparam ls=4'd9;
	localparam ge=4'd10;
	localparam lt=4'd11;
	localparam gt=4'd12;
	localparam le=4'd13;
	localparam al=4'd14;
	//localparam nop=4'd15;

	//cond_check is active low
	always @(*) begin
		cond_check = 1'b1;
		case(cond) 
			eq : begin
				if(sr[Z] == 1'b1)
					cond_check = 1'b0;
			end
			ne : begin
				if(sr[Z] == 1'b0)
					cond_check = 1'b0;
			end
			cs_hs: begin
				if(sr[C] == 1'b1)
					cond_check = 1'b0;
			end
			cc_lo : begin
				if(sr[C] == 1'b0)
					cond_check = 1'b0;
			end
			mi : begin
				if(sr[N] == 1'b1)
					cond_check = 1'b0;
			end
			pl : begin
				if(sr[N] == 1'b0)
					cond_check = 1'b0;
			end
			vs : begin
				if(sr[V] == 1'b1)
					cond_check = 1'b0;
			end
			vc : begin
				if(sr[V] == 1'b0)
					cond_check = 1'b0;
			end
			hi : begin
				if((sr[C] == 1'b1) && (sr[Z] == 1'b0))
					cond_check = 1'b0;
			end
			ls : begin
				if((sr[C] == 1'b0) || (sr[Z] == 1'b1))
					cond_check = 1'b0;
			end
			ge : begin
				if(sr[N] == sr[V])
					cond_check = 1'b0;
			end
			lt : begin
				if(sr[N] != sr[V])
					cond_check = 1'b0;
			end
			gt : begin
				if((sr[Z] == 1'b0) && (sr[N] == sr[V]))
					cond_check = 1'b0;
			end
			le : begin
				if((sr[Z] == 1'b1) || (sr[N] != sr[V]))
					cond_check = 1'b0;
			end
			al : begin
				cond_check = 1'b0;
			end
			default : 
				cond_check = 1'b1;

		endcase
	end
endmodule

module id_ex_reg
(
    input rst,
    input clk,
    input freeze,
    input wb_en,
    input mem_r_en,
    input mem_w_en,
    input [3:0]exe_cmd,
    input b,
    input s,
    input [31:0]pc,
    input [31:0]val_rn,
    input [31:0]val_rm,
    input [11:0]shift_operand,
    input imm,
    input [23:0]signed_imm_24,
    input [3:0]dest,
    input flush,
    input c_in,
    input[3:0] src_1_i,
    input[3:0] src_2_i,

    output reg[3:0] src_1_o,
    output reg[3:0] src_2_o,
    output reg wb_en_out,
    output reg mem_r_en_out,
    output reg mem_w_en_out,
    output reg [3:0]exe_cmd_out,
    output reg b_out,
    output reg s_out,
    output reg [31:0]pc_out,
    output reg [31:0]val_rn_out,
    output reg [31:0]val_rm_out,
    output reg [11:0]shift_operand_out,
    output reg imm_out,
    output reg [23:0]signed_imm_24_out,
    output reg [3:0]dest_out,
    output reg c_out
);
always @(posedge clk) begin
    if((rst == 1'b1) || (flush == 1'b1) ) begin
        wb_en_out<=0;
        mem_r_en_out<=0;
        mem_w_en_out<=0;
        exe_cmd_out<=0;
        b_out<=0;
        s_out<=0;
        pc_out<=0;
        val_rn_out<=0;
        val_rm_out<=0;
        shift_operand_out<=0;
        imm_out<=0;
        signed_imm_24_out<=0;
        dest_out<=0;
        c_out <= 0;
        src_1_o <= 0;
        src_2_o <= 0;

    end
    else if(freeze != 1'b1) begin
    	src_2_o <= src_2_i;
    	src_1_o <= src_1_i;
        wb_en_out<= wb_en;
        mem_r_en_out<=mem_r_en;
        mem_w_en_out<=mem_w_en;
        exe_cmd_out<=exe_cmd;
        b_out<=b;
        s_out<=s;
        pc_out<=pc;
        val_rn_out<=val_rn;
        val_rm_out<=val_rm;
        shift_operand_out<=shift_operand;
        imm_out<=imm;
        signed_imm_24_out<=signed_imm_24;
        dest_out<=dest;
        c_out <= c_in;
    end
end
endmodule

module controller_unit (
	input hc_sel,
	input [1:0] mode,
	input [3:0] opcode,
	input s_in,

	output [3:0] execmd,
	output mem_r_en,
	output mem_w_en,
	output wb_en,
	output b_out,
	output s_out
);
	wire [3:0] execmd_w ;
	wire mem_r_en_w ;
	wire mem_w_en_w ;
	wire wb_en_w ;
	wire b_out_w ;
	wire s_out_w ;

	controller ctrl (
		.mode(mode),
		.opcode(opcode),
		.s_in(s_in),
		.execmd(execmd_w),
		.mem_r_en(mem_r_en_w),
		.mem_w_en(mem_w_en_w),
		.wb_en(wb_en_w),
		.b_out(b_out_w),
		.s_out(s_out_w)
	);

	assign execmd = (hc_sel == 1'b1) ? 1'b0 : execmd_w ;
	assign mem_r_en = (hc_sel == 1'b1) ? 1'b0 : mem_r_en_w ;
	assign mem_w_en = (hc_sel == 1'b1) ? 1'b0 : mem_w_en_w ;
	assign wb_en = (hc_sel == 1'b1) ? 1'b0 : wb_en_w ;
	assign b_out = (hc_sel == 1'b1) ? 1'b0 : b_out_w ;
	assign s_out = (hc_sel == 1'b1) ? 1'b0 : s_out_w ;

endmodule

module controller (
	input [1:0] mode,
	input [3:0] opcode,
	input s_in,

	output reg [3:0] execmd,
	output reg mem_r_en,
	output reg mem_w_en,
	output reg wb_en,
	output reg b_out,
	output reg s_out
);

parameter ari_cmd	= 2'b00 ;
parameter mem_cmd	= 2'b01 ;
parameter b_cmd		= 2'b10 ;
parameter co_cmd	= 2'b11 ;

//parameter nop		= 4'b0000 ; // not implemented
parameter mov_i		= 4'b1101 ;
parameter mvn_i		= 4'b1111 ;
parameter add_i		= 4'b0100 ;
parameter adc_i		= 4'b0101 ;
parameter sub_i		= 4'b0010 ;
parameter sbc_i		= 4'b0110 ;
parameter and_i		= 4'b0000 ;
parameter orr_i		= 4'b1100 ;
parameter eor_i		= 4'b0001 ;
parameter cmp_i		= 4'b1010 ;
parameter tst_i		= 4'b1000 ;
parameter ldr_i		= 4'b0100 ;
parameter str_i		= 4'b0100 ;
parameter b_i	 	= 1'b0 ;

parameter mov_a		= 4'b0001 ;
parameter mvn_a		= 4'b1001 ;
parameter add_a		= 4'b0010 ;
parameter adc_a		= 4'b0011 ;
parameter sub_a		= 4'b0100 ;
parameter sbc_a		= 4'b0101 ;
parameter and_a		= 4'b0110 ;
parameter orr_a		= 4'b0111 ;
parameter eor_a		= 4'b1000 ;
parameter cmp_a		= 4'b0100 ;
parameter tst_a		= 4'b0110 ;
parameter ldr_a		= 4'b0010 ;
parameter str_a		= 4'b0010 ;
//parameter b_a	 	= 4'bxxxx ;


	always @(*) begin
		execmd = 4'b0000;
		mem_r_en = 1'b0;
		mem_w_en = 1'b0;
		wb_en = 1'b0;
		b_out = 1'b0;
		s_out = 1'b0;
		case (mode)
			ari_cmd	: begin 
				case (opcode)
					//nop : begin
					// 	execmd = 4'bzzzz;
					// 	wb_en = 1'b0;
					// 	s_out = 1'b0;
					// end
					mov_i	: begin 
						execmd = mov_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					mvn_i	: begin 
						execmd = mvn_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					add_i	: begin 
						execmd = add_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					adc_i	: begin 
						execmd = adc_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					sub_i	: begin 
						execmd = sub_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					sbc_i	: begin 
						execmd = sbc_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					and_i	: begin 
						execmd = and_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					orr_i	: begin 
						execmd = orr_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					eor_i	: begin 
						execmd = eor_a ;
						s_out = s_in ;
						wb_en = 1'b1;
					end
					cmp_i	: begin 
						if (s_in) begin 
							execmd = cmp_a ;
							s_out = 1'b1 ;
							wb_en = 1'b0;
						end
					end
					tst_i	: begin 
						if (s_in) begin 
							execmd = tst_a ;
							s_out = 1'b1 ;
							wb_en = 1'b0;
						end
					end
					default : begin
						execmd = mov_a ;
						s_out = 1'bz ;
						wb_en = 1'b0;
					end
				endcase
			end

			mem_cmd	: begin 
				if (s_in == 1'b1) begin 
					execmd = ldr_a ;
					s_out = 1'b1 ;
					mem_r_en = 1'b1 ;
					wb_en = 1'b1 ;
				end
				else if(s_in == 1'b0) begin 
					execmd = str_a ;
					s_out = 1'b0;
					mem_w_en = 1'b1;
				end	
			end

			b_cmd	: begin 
				if (opcode[3] == b_i) begin 
					//execmd = b_a ; // dont care
					b_out = 1'b1;
				end
			end
		endcase
	end
		

endmodule
