module if_stage
(
	output [31:0] pc_o, 
		instruction_o,


	input[31:0] branch_adder_i,
	input clk, 
		rst, 
		freeze_i, 
		branch_tacken_i, 
		flush_i
);
	reg[31:0] instruction_mem[0:48];
	reg[31:0] pc;
	wire[31:0] pc_inc;
	wire[31:0] mux_out;
	wire [31:0] instruction;
	if_id_reg if_id_reg_instance(	
	.pc_o(pc_o), 
	.instruction_o(instruction_o),
	.pc_i(pc_inc), 
	.instruction_i(instruction),
	.clk(clk), 
	.rst(rst), 
	.freeze_i(freeze_i), 
	.flush_i(flush_i)
	);
	initial begin
		$readmemb("instruction_mem.txt", instruction_mem);
	end
	wire pc_reg_freeze;
	assign pc_reg_freeze = ((~flush_i) & freeze_i);
	always @(posedge clk) begin
		if (rst) begin
			pc <= 32'd0;
		end
		else if(pc_reg_freeze != 1'b1)begin
			pc <= mux_out;		
		end
	end
	assign mux_out = (branch_tacken_i == 1'b0) ? (pc_inc) : (branch_adder_i);
	assign pc_inc = pc + 32'd1;
	assign instruction = instruction_mem[pc];
endmodule
module if_id_reg
(
	output reg[31:0] pc_o, 
		instruction_o,

	input[31:0] pc_i, 
		instruction_i,
	input clk, 
		rst, 
		freeze_i, 
		flush_i
);
	always @(posedge clk) begin
		if (rst == 1'b1 || flush_i == 1'b1) begin
			pc_o <= 32'd0;
			instruction_o <= 32'b11100000000000000000000000000000;
		end
		else if(freeze_i != 1'b1) begin
			instruction_o <= instruction_i;
			pc_o <= pc_i;
		end
	end
endmodule

