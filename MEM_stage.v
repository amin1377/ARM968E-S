module mem_stage (
	input clk,
	input rst,
	input mem_w_en_i,
	input mem_r_en_i,
	input wb_en_i,
	input [31:0] val_rm_i,
	input [3:0] dest_i,
	input [31:0] alu_res_i,


	inout [15:0] sram_dq,//inout


	output freeze_o,
	output wb_en_o,
	output mem_r_en_o,
	output [3:0] dest_o,
	output [31:0] alu_res_o,
	output [31:0] data_mem_o,
	output [17:0] sram_addr,
	output sram_ub_n,
	output sram_lb_n,
	output sram_we_n,
	output sram_ce_n,
	output sram_oe_n
);

	wire [31:0] data_mem_w;
	wire sram_controller_freeze_o;

	assign freeze_o = sram_controller_freeze_o;

	sram_controller#(.cache_num_sets(64)) sram_controller_instance
	(
		.sram_dq(sram_dq), //inout

		.data_out(data_mem_w),
		.sram_addr(sram_addr),
		.sram_ub_n(sram_ub_n),
		.sram_lb_n(sram_lb_n),
		.sram_we_n(sram_we_n),
		.sram_ce_n(sram_ce_n),
		.sram_oe_n(sram_oe_n),
		.freeze(sram_controller_freeze_o),

		.addr(alu_res_i),
		.write_data(val_rm_i),
		.wr_en(mem_w_en_i),
		.rd_en(mem_r_en_i),
		.clk(clk),
		.rst(rst)

	);

	mem_wb_reg mem_wb_reg_instance
	(
		.clk(clk),
		.rst(rst),
		.wb_en_i(wb_en_i),
		.mem_r_en_i(mem_r_en_i),
		.alu_res_i(alu_res_i),
		.data_mem_i(data_mem_w),
		.dest_i(dest_i),
		.freeze(sram_controller_freeze_o),

		.wb_en_o(wb_en_o),
		.mem_r_en_o(mem_r_en_o),
		.alu_res_o(alu_res_o),
		.data_mem_o(data_mem_o),
		.dest_o(dest_o)
	);

endmodule 


module sram_controller
(
	inout[15:0] sram_dq, //inout


	output reg[31:0] data_out,
	output reg[17:0] sram_addr,
	output sram_ub_n, 
	output sram_lb_n,
	output reg sram_we_n,
	output sram_ce_n,
	output sram_oe_n,
	output reg freeze,

	input[31:0] addr,
	input[31:0] write_data,
	input wr_en,
	input rd_en,
	input clk,
	input rst

);

	//parameters
	parameter cache_num_sets = 64;

	//local parameters
	localparam s0 = 4'd0;
	localparam s1_w = 4'd1;
	localparam s2_w = 4'd2;
	localparam s3_w = 4'd3;
	localparam s1_r = 4'd4;
	localparam s2_r = 4'd5;
	localparam s3_r = 4'd6;
	localparam s4_r = 4'd7;
	localparam s5_r = 4'd8;
	localparam s6_r = 4'd9;
	localparam s7_r = 4'd10;
	localparam s8_r = 4'd11;
	localparam s9_r = 4'd12;
	localparam s10_r = 4'd13;
	wire[5:0] index;
	wire[10:0] tag;
	reg[3:0] curren_state = 4'd0;
	reg[3:0] next_state = 4'd0;
	reg ld_l = 1'b0;
	reg ld_h = 1'b0;
	reg [31:0] read_data;
	wire [31:0]inc_addr;
	reg [15:0] _sram_dq;
	assign sram_oe_n = 1'b0;
	assign sram_ub_n = 1'b0;
	assign sram_lb_n = 1'b0;
	assign sram_ce_n = 1'b0;

	// address for higher 16 bit
	assign inc_addr = addr + 18'd2;
	assign sram_dq = _sram_dq;

	//set cache index and tag
	assign index = addr[7:2];
	assign tag = addr[18:8];

	//cache contents
	reg[31:0] cache_block_0_data[0:(cache_num_sets - 1)];
	reg[31:0] cache_block_1_data[0:(cache_num_sets - 1)];
	reg[10:0] cache_block_0_tag[0:(cache_num_sets - 1)];
	reg[10:0] cache_block_1_tag[0:(cache_num_sets - 1)];
	reg cache_block_0_used[0:(cache_num_sets - 1)];
	reg cache_block_1_used[0:(cache_num_sets - 1)];
	reg cache_block_0_valid[0:(cache_num_sets - 1)];
	reg cache_block_1_valid[0:(cache_num_sets - 1)];
	reg cache_ld_block_0;
	reg cache_ld_block_1;
	wire[31:0] next_block_addr;
	wire[31:0] next_block_inc_addr;
	wire miss_block_0;
	wire miss_block_1;
	wire miss;

	assign next_block_addr = addr + 32'd4;
	assign next_block_inc_addr = addr + 32'd6;

	//register data comming from sram
	always @(posedge clk) begin
		if(rst != 1'b1) begin
			if(ld_l == 1'b1) 
				read_data[15:0] <= sram_dq;
			if(ld_h == 1'b1)
				read_data[31:16] <= sram_dq;
		end
	end

	//transfer next_state to curren_state 
	always @(posedge clk) begin
		if(rst == 1'b1)
			curren_state <= s0;
		else
			curren_state <= next_state;
	end

	//cache_miss_check
	assign miss_block_0 = (cache_block_0_tag[index] !== tag);
	assign miss_block_1 = (cache_block_1_tag[index] !== tag);
	assign miss = ((~cache_block_0_valid[index]) | miss_block_0) & ((~cache_block_1_valid[index]) | miss_block_1);


	//cache_register_update
	integer i;
	always @(posedge clk, posedge rst) begin
		if(rst == 1'b1)begin
			for(i = 0; i < cache_num_sets; i = i+1) begin
				cache_block_0_valid[i] <= 1'b0;
				cache_block_1_valid[i] <= 1'b0;
				cache_block_0_used[index] <= 1'b0;
				cache_block_1_used[index] <= 1'b0;
			end

		end
		else begin
			if(cache_ld_block_0 == 1'b1) begin
				cache_block_0_tag[index] <= tag;
				cache_block_0_data[index] <= read_data;
				cache_block_0_valid[index] <= 1'b1;
			end
			if(cache_ld_block_1 == 1'b1) begin
				cache_block_1_tag[index] <= tag;
				cache_block_1_data[index] <= read_data;
				cache_block_1_valid[index] <= 1'b1;
			end
			case({cache_ld_block_0, cache_ld_block_1})
				2'b01 :begin
					cache_block_0_used[index] <= 1'b0;
					cache_block_1_used[index] <= 1'b1;
				end
				2'b10 :begin
					cache_block_0_used[index] <= 1'b1;
					cache_block_1_used[index] <= 1'b0;
				end
				2'b11 :begin
					cache_block_0_used[index] <= 1'b0;
					cache_block_1_used[index] <= 1'b1;
				end
			endcase
		end
	end

	//make data_out
	always @(*) begin
		case({miss_block_0, miss_block_1})
			2'b00 : 
				data_out = cache_block_0_data[index];
			2'b01 :
				data_out = cache_block_0_data[index];
			2'b10 :
				data_out = cache_block_1_data[index];
			2'b11 :
				data_out = cache_block_0_data[index];
		endcase

	end


	//controller output (except next_state)
	always @(*) begin
		sram_addr = addr[18:1];
		_sram_dq = {16{1'bz}};
		freeze = 1'b0;
		sram_we_n = 1'b1;
		ld_l = 1'b0;
		ld_h = 1'b0;
		cache_ld_block_0 = 1'b0;
		cache_ld_block_1 = 1'b0;
		case(curren_state)
			s0 : begin
				case({wr_en, rd_en})
					2'b00 : begin
						freeze = 1'b0;
					end
					2'b01 : begin
						if(miss == 1'b1)
							freeze = 1'b1;
					end
					2'b10 : begin
						freeze = 1'b1;
					end
					2'b11 : begin
						freeze = 1'b1;
					end
					default : begin
						freeze = 1'b0;
					end
				endcase
			end
			s1_w : begin
				freeze = 1'b1;
				_sram_dq = write_data[15:0];
				sram_addr = addr[18:1];
				sram_we_n = 1'b0;
				ld_l = 1'b1;
			end
			s2_w : begin
				freeze = 1'b1;
				_sram_dq = write_data[31:16];
				sram_addr = inc_addr[18:1];
				sram_we_n = 1'b0;
				ld_h = 1'b1;
			end
			s3_w : begin
				case({miss_block_1, miss_block_0}) 
					2'b00 : begin
						cache_ld_block_0 = 1'b1;
						cache_ld_block_1 = 1'b1;
					end
					2'b01 : begin
						cache_ld_block_1 = 1'b1;
					end
					2'b10 : begin
						cache_ld_block_0 = 1'b1;
					end
					2'b11 : begin
						if(cache_block_0_used[index] == 0)
							cache_ld_block_0 = 1'b1;
						else
							cache_ld_block_1 = 1'b1;
					end
				endcase
				freeze = 1'b0;
			end

			//read_first_block
			s1_r : begin
				freeze = 1'b1;
				sram_addr = addr[18:1];
			end
			s2_r : begin
				sram_addr = addr[18:1];
				freeze = 1'b1;
				ld_l = 1'b1;
			end
			s3_r : begin
				freeze = 1'b1;
				sram_addr = inc_addr[18:1];
			end
			s4_r : begin
				freeze = 1'b1;
				sram_addr = inc_addr[18:1];
				ld_h = 1'b1;
			end

			//read_second_block
			s5_r : begin
				freeze = 1'b1;
				if(cache_block_0_used[index] == 0)
					cache_ld_block_0 = 1'b1;
				else
					cache_ld_block_1 = 1'b1;
				sram_addr = next_block_addr[18:1];
			end
			s6_r : begin
				sram_addr = next_block_addr[18:1];
				freeze = 1'b1;
				ld_l = 1'b1;
			end
			s7_r : begin
				freeze = 1'b1;
				sram_addr = next_block_inc_addr[18:1];
			end
			s8_r : begin
				freeze = 1'b1;
				sram_addr = next_block_inc_addr[18:1];
				ld_h = 1'b1;
			end
			s9_r : begin
				freeze = 1'b1;
				if(cache_block_0_used[index] == 0)
					cache_ld_block_0 = 1'b1;
				else
					cache_ld_block_1 = 1'b1;
			end


			s10_r : begin
				freeze = 1'b0;
			end
		endcase
	end

	//make next_state
	always @(*) begin
		next_state = s0;
		case(curren_state)
			s0 : begin
				case({wr_en, rd_en})
					2'b00 : begin
						next_state = s0;
					end
					2'b01 : begin
						if(miss == 1'b1)
							next_state = s1_r;
					end
					2'b10 : begin
						next_state = s1_w;
					end
					2'b11 : begin
						next_state = s1_w;
					end
					default : begin
						next_state = s0;
					end
				endcase
			end
			s1_w : begin
				next_state = s2_w;
			end
			s2_w : begin
				next_state = s3_w;
			end
			s3_w : begin
				next_state = s0;
			end


			s1_r : begin
				next_state = s2_r;
			end
			s2_r : begin
				next_state = s3_r;
			end
			s3_r : begin
				next_state = s4_r;
			end
			s4_r : begin
				next_state = s5_r;
			end
			s5_r : begin
				next_state = s6_r;
			end
			s6_r : begin
				next_state = s7_r;
			end
			s7_r : begin
				next_state = s8_r;
			end
			s8_r : begin
				next_state = s9_r;
			end
			s9_r : begin
				next_state = s10_r;
			end
			s10_r : begin
				next_state = s0;
			end
		endcase
	end
endmodule


module mem_wb_reg (
	input clk,
	input rst,
	input wb_en_i,
	input mem_r_en_i,
	input [31:0] alu_res_i,
	input [31:0] data_mem_i,
	input [3:0] dest_i,
	input freeze,

	output wb_en_o,
	output mem_r_en_o,
	output [31:0] alu_res_o,
	output [31:0] data_mem_o,
	output [3:0] dest_o
);
	rege #(1) wb_reg (
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.freeze(freeze),
		.d(wb_en_i),
		.q(wb_en_o)
	);

	rege #(1) mem_r_en_reg (
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.freeze(freeze),
		.d(mem_r_en_i),
		.q(mem_r_en_o)
	);
	rege #(32) alu_res_reg (
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.freeze(freeze),
		.d(alu_res_i),
		.q(alu_res_o)	
	);
	rege #(32) data_mem_reg(
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.freeze(freeze),
		.d(data_mem_i),
		.q(data_mem_o)
	);
	rege #(4) dest_reg (
		.clk(clk),
		.rst(rst),
		.en(1'b1),
		.freeze(freeze),
		.d(dest_i),
		.q(dest_o)
	);
endmodule

module rege #(parameter length=8) 
(
	input clk,
	input rst,
	input en,
	input freeze,
	input[length-1:0] d,
	output reg [length-1:0]q
);
	always @(posedge clk) begin
		if (rst) begin
			q <= {length{1'b0}};
		end
		else if ((en == 1'b1) && (freeze == 1'b0)) begin
			q <= d;
		end
	end
endmodule