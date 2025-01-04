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
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARADDR] [get_bd_pins axi_bram_ctrl_0/s_axi_araddr]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARLEN] [get_bd_pins axi_bram_ctrl_0/s_axi_arlen]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARSIZE] [get_bd_pins axi_bram_ctrl_0/s_axi_arsize]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_arburst] [get_bd_pins AXI_Corr_0/M_AXI_ARBURST]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARLOCK] [get_bd_pins axi_bram_ctrl_0/s_axi_arlock]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARCACHE] [get_bd_pins axi_bram_ctrl_0/s_axi_arcache]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARPROT] [get_bd_pins axi_bram_ctrl_0/s_axi_arprot]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARVALID] [get_bd_pins axi_bram_ctrl_0/s_axi_arvalid]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_ARREADY] [get_bd_pins axi_bram_ctrl_0/s_axi_arready]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_RDATA] [get_bd_pins axi_bram_ctrl_0/s_axi_rdata]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_RRESP] [get_bd_pins axi_bram_ctrl_0/s_axi_rresp]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_RLAST] [get_bd_pins axi_bram_ctrl_0/s_axi_rlast]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_RVALID] [get_bd_pins axi_bram_ctrl_0/s_axi_rvalid]
connect_bd_net [get_bd_pins AXI_Corr_0/M_AXI_RREADY] [get_bd_pins axi_bram_ctrl_0/s_axi_rready]
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
save_bd_design

# wrapper adder
set dir [pwd]
make_wrapper -files [get_files $dir/AXI_correlator/AXI_correlator.srcs/sources_1/bd/AXI_CORR_design/AXI_CORR_design.bd] -top

add_files -norecurse $dir/AXI_correlator/AXI_correlator.gen/sources_1/bd/AXI_CORR_design/hdl/AXI_CORR_design_wrapper.vhd
update_compile_order -fileset sources_1
close_bd_design [get_bd_designs AXI_CORR_design]

