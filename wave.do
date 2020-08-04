onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group IF -radix decimal /tb/duv/if_instance/pc_o
add wave -noupdate -expand -group IF /tb/duv/if_instance/instruction_o
add wave -noupdate -expand -group IF /tb/duv/if_instance/branch_adder_i
add wave -noupdate -expand -group IF /tb/duv/if_instance/clk
add wave -noupdate -expand -group IF /tb/duv/if_instance/rst
add wave -noupdate -expand -group IF /tb/duv/if_instance/freeze_i
add wave -noupdate -expand -group IF /tb/duv/if_instance/branch_tacken_i
add wave -noupdate -expand -group IF /tb/duv/if_instance/flush_i
add wave -noupdate -expand -group ID -childformat {{{/tb/duv/id_instance/register_file_instance/reg_file[0]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[1]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[2]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[3]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[4]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[5]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[6]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[7]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[8]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[9]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[10]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[11]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[12]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[13]} -radix decimal} {{/tb/duv/id_instance/register_file_instance/reg_file[14]} -radix decimal}} -expand -subitemconfig {{/tb/duv/id_instance/register_file_instance/reg_file[0]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[1]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[2]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[3]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[4]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[5]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[6]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[7]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[8]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[9]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[10]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[11]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[12]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[13]} {-radix decimal} {/tb/duv/id_instance/register_file_instance/reg_file[14]} {-radix decimal}} /tb/duv/id_instance/register_file_instance/reg_file
add wave -noupdate -expand -group ID /tb/duv/id_instance/pc_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/val_rn_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/val_rm_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/signed_imm_24_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/shift_operand_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/exe_cmd_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/dst_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/src_1
add wave -noupdate -expand -group ID /tb/duv/id_instance/src_2
add wave -noupdate -expand -group ID /tb/duv/id_instance/src_2_id
add wave -noupdate -expand -group ID /tb/duv/id_instance/wb_en_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/mem_write_en_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/mem_read_en_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/s_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/b_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/imm_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/two_src
add wave -noupdate -expand -group ID /tb/duv/id_instance/c_out
add wave -noupdate -expand -group ID /tb/duv/id_instance/pc_in
add wave -noupdate -expand -group ID /tb/duv/id_instance/instruction
add wave -noupdate -expand -group ID /tb/duv/id_instance/result_wb
add wave -noupdate -expand -group ID /tb/duv/id_instance/dst_wb
add wave -noupdate -expand -group ID /tb/duv/id_instance/sr
add wave -noupdate -expand -group ID /tb/duv/id_instance/wb_en_in
add wave -noupdate -expand -group ID /tb/duv/id_instance/hazard
add wave -noupdate -expand -group ID /tb/duv/id_instance/flush
add wave -noupdate -expand -group ID /tb/duv/id_instance/clk
add wave -noupdate -expand -group ID /tb/duv/id_instance/rst
add wave -noupdate -group exe /tb/duv/exe_stage_instance/wb_en_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/mem_read_en_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/mem_write_en_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/alu_result_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/val_rm_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/branch_adder_exe_if
add wave -noupdate -group exe /tb/duv/exe_stage_instance/dst_exe_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/sr_exe_if
add wave -noupdate -group exe /tb/duv/exe_stage_instance/c_in
add wave -noupdate -group exe /tb/duv/exe_stage_instance/wb_en_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/mem_read_en_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/mem_write_en_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/b_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/s_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/val_rn_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/pc_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/val_rm_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/alu_result_mem
add wave -noupdate -group exe /tb/duv/exe_stage_instance/data_wb_wb
add wave -noupdate -group exe /tb/duv/exe_stage_instance/imm_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/shift_operand_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/signed_imm_24_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/sel_src_1
add wave -noupdate -group exe /tb/duv/exe_stage_instance/sel_src_2
add wave -noupdate -group exe /tb/duv/exe_stage_instance/exe_cmd_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/dst_id_exe
add wave -noupdate -group exe /tb/duv/exe_stage_instance/forwarding_en
add wave -noupdate -group exe /tb/duv/exe_stage_instance/clk
add wave -noupdate -group exe /tb/duv/exe_stage_instance/rst
add wave -noupdate -group mem /tb/duv/mem_stage_instance/clk
add wave -noupdate -group mem /tb/duv/mem_stage_instance/rst
add wave -noupdate -group mem /tb/duv/mem_stage_instance/data_memory/mem
add wave -noupdate -group mem /tb/duv/mem_stage_instance/mem_w_en_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/mem_r_en_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/wb_en_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/val_rm_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/dest_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/alu_res_i
add wave -noupdate -group mem /tb/duv/mem_stage_instance/wb_en_o
add wave -noupdate -group mem /tb/duv/mem_stage_instance/mem_r_en_o
add wave -noupdate -group mem /tb/duv/mem_stage_instance/dest_o
add wave -noupdate -group mem /tb/duv/mem_stage_instance/alu_res_o
add wave -noupdate -group mem /tb/duv/mem_stage_instance/data_mem_o
add wave -noupdate -group wb /tb/duv/wb_stage_instance/clk
add wave -noupdate -group wb /tb/duv/wb_stage_instance/rst
add wave -noupdate -group wb /tb/duv/wb_stage_instance/wb_en_i
add wave -noupdate -group wb /tb/duv/wb_stage_instance/mem_r_en_i
add wave -noupdate -group wb /tb/duv/wb_stage_instance/dest_i
add wave -noupdate -group wb /tb/duv/wb_stage_instance/alu_res_i
add wave -noupdate -group wb /tb/duv/wb_stage_instance/data_mem_i
add wave -noupdate -group wb /tb/duv/wb_stage_instance/wb_en_o
add wave -noupdate -group wb /tb/duv/wb_stage_instance/wb_dest_o
add wave -noupdate -group wb /tb/duv/wb_stage_instance/wb_val_o
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/freeze
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/rn_id
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/src_2_id
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/dst_exe
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/dst_mem
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/two_src_id
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/wb_en_mem
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/wb_en_exe
add wave -noupdate -group hazard /tb/duv/hazard_detection_instance/forwarding_en
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/sel_src_1
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/sel_src_2
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/dst_mem
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/dst_wb
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/src_1
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/src_2
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/wb_en_mem
add wave -noupdate -group forwarding /tb/duv/forwarding_unit_instance/wb_en_wb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3242 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 386
configure wave -valuecolwidth 167
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {3195 ps} {3295 ps}
