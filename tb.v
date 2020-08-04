module tb();
  reg clk;
  reg rst;
  reg forwarding_en;

  wire  wb_en_id_exe;
  wire  mem_write_en_id_exe;
  wire  mem_read_en_id_exe;
  wire  s_id_exe;
  wire  b_id_exe;
  wire  imm_id_exe;
  wire [3:0] exe_cmd_id_exe;
  wire [3:0] dst_id_exe;
  wire [11:0] shift_operand_id_exe;
  wire [23:0] signed_imm_24_id_exe;
  wire [31:0] pc_id_exe;
  wire [31:0] val_rn_id_exe;
  wire [31:0] val_rm_id_exe;

  wire [15:0] sram_dq;
  wire [17:0] sram_addr;
  wire sram_we_n;

  sram sram_instance
  (
    .sram_dq(sram_dq),

    .addr(sram_addr),
    .wr_en_n(sram_we_n),
    .clk(clk),
    .rst(rst)

  );

  arm duv
  (
    //output[31:0] alu_result_exe_mem,
    .sram_addr(sram_addr),
    //output sram_ub_n,
    //output sram_lb_n,
    .sram_we_n(sram_we_n),
    //output sram_ce_n,
    //output sram_oe_n,

    .sram_dq(sram_dq),// inout
    
    .forwarding_en(forwarding_en),
    .clk(clk),
    .rst(rst)
  );

  always #5 clk = ~clk;
  initial begin
    forwarding_en = 1;
    clk=0;
    rst=0;
    #100
    rst = 1'b1;
    #100
    rst = 1'b0;
    #50000
    $stop;
  end
endmodule