update_compile_order -fileset sources_1
set_property file_type {VHDL 2008} [get_files  C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip_src/AXI_corr/src/planner.vhd]
set_property file_type {VHDL 2008} [get_files  C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip_src/AXI_corr/src/AXI_master.vhd]
set_property file_type {VHDL 2008} [get_files  C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip_src/AXI_corr/src/reader.vhd]
set_property file_type {VHDL 2008} [get_files  C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip_src/AXI_corr/src/bram_buf.vhd]
set_property file_type {VHDL 2008} [get_files  C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip_src/AXI_corr/src/correlator.vhd]
update_compile_order -fileset sources_1

ipx::package_project -root_dir C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current false -force
ipx::unload_core c:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory C:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip c:/Homework/Master_Degree/Term1/SBIS/AXI_correlator/ip/component.xml
update_compile_order -fileset sources_1
set_property vendor SigCorr [ipx::current_core]
set_property name AXI_Correlator [ipx::current_core]
set_property version 0.2 [ipx::current_core]
set_property display_name AXI_Correlator_v0_2 [ipx::current_core]
set_property description {Correlator for AXI} [ipx::current_core]
set_property previous_version_for_upgrade xilinx.com:user:AXI_corr_TOP:1.0 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
