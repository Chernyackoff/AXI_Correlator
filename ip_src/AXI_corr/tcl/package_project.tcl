ipx::package_project -root_dir ../../ip/AXI_Corr -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current false -force
ipx::unload_core ../../ip/AXI_Corr/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory ../../ip/AXI_Corr ../../ip/AXI_Corr/component.xml
set_property vendor SigCorr [ipx::current_core]
set_property name AXI_Corr [ipx::current_core]
set_property library STUDENT [ipx::current_core]
set_property version 0.2 [ipx::current_core]
set_property display_name AXI_Corr [ipx::current_core]
set_property description {Correlator for AXI} [ipx::current_core]

update_compile_order -fileset sources_1
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project
set_property  ip_repo_paths  {../../ip/AXI_Corr } [current_project]
update_ip_catalog