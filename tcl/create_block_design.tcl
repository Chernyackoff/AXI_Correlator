update_compile_order -fileset sources_1
create_bd_design "AXI_CORR_design"
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv SigCorr:STUDENT:AXI_Corr:0.2 AXI_Corr_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
endgroup
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_0]
set_property location {3 652 -104} [get_bd_cells blk_mem_gen_0]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
set_property location {2 379 -123} [get_bd_cells axi_bram_ctrl_0]
startgroup
set_property -dict [list CONFIG.Enable_32bit_Address {false} CONFIG.Use_Byte_Write_Enable {false} CONFIG.Byte_Size {9} CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Use_RSTA_Pin {false} CONFIG.use_bram_block {Stand_Alone} CONFIG.EN_SAFETY_CKT {false}] [get_bd_cells blk_mem_gen_0]
endgroup
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
set_property location {1 102 -124} [get_bd_cells AXI_Corr_0]
startgroup
set_property -dict [list CONFIG.DATA_WIDTH {32}] [get_bd_cells axi_bram_ctrl_0]
endgroup
update_compile_order -fileset sources_1
connect_bd_intf_net [get_bd_intf_pins AXI_Corr_0/M_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

create_bd_port -dir I -type clk -freq_hz 250000000 refclk
connect_bd_net [get_bd_ports refclk] [get_bd_pins AXI_Corr_0/refclk]
create_bd_port -dir O result
startgroup
connect_bd_net [get_bd_ports result] [get_bd_pins AXI_Corr_0/result_o]
endgroup
startgroup
create_bd_port -dir I -type rst rst
endgroup
connect_bd_net [get_bd_ports rst] [get_bd_pins AXI_Corr_0/rst]

startgroup
create_bd_port -dir I -type rst axi_aresetn
endgroup
connect_bd_net [get_bd_ports axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

set dir [pwd]
startgroup
set_property -dict [list CONFIG.Load_Init_File {true} CONFIG.Coe_File {$dir/src/memory_init.coe}] [get_bd_cells blk_mem_gen_0]
endgroup

# startgroup
# set_property -dict [list CONFIG.Fill_Remaining_Memory_Locations {true} CONFIG.Remaining_Memory_Locations {0AA}] [get_bd_cells blk_mem_gen_0]
# endgroup

save_bd_design

# wrapper adder

make_wrapper -files [get_files $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd] -top

add_files -norecurse $dir/AXI_correlator/AXI_correlator.gen/sources_1/bd/AXI_CORR_design/hdl/AXI_CORR_design_wrapper.vhd
update_compile_order -fileset sources_1

generate_target all [get_files  $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd]
catch { config_ip_cache -export [get_ips -all AXI_CORR_design_AXI_Corr_0_0] }
catch { config_ip_cache -export [get_ips -all AXI_CORR_design_axi_bram_ctrl_0_0] }
catch { config_ip_cache -export [get_ips -all AXI_CORR_design_blk_mem_gen_0_0] }
export_ip_user_files -of_objects [get_files $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd]
launch_runs AXI_CORR_design_AXI_Corr_0_0_synth_1 AXI_CORR_design_axi_bram_ctrl_0_0_synth_1 AXI_CORR_design_blk_mem_gen_0_0_synth_1 -jobs 10
export_simulation -of_objects [get_files $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd] -directory $dir/AXI_correlator/AXI_correlator.ip_user_files/sim_scripts -ip_user_files_dir $dir/AXI_correlator/AXI_correlator.ip_user_files -ipstatic_source_dir $dir/AXI_correlator/AXI_correlator.ip_user_files/ipstatic -lib_map_path [list {modelsim=$dir/AXI_correlator/AXI_correlator.cache/compile_simlib/modelsim} {questa=$dir/AXI_correlator/AXI_correlator.cache/compile_simlib/questa} {riviera=$dir/AXI_correlator/AXI_correlator.cache/compile_simlib/riviera} {activehdl=$dir/AXI_correlator/AXI_correlator.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet


close_bd_design [get_bd_designs AXI_CORR_design]

