#
# Copyright (c) 2017 Lucas Brasilino
# Intelligent Systems Engineering/SICE Indiana University
#

# Vivado Launch Script
#### Change design settings here #######
set design axi_ethernet_bridge
set top axi_ethernet_bridge
set device xc7z020clg484-1
set proj_dir ./ip_proj
set ip_version 1.00
set lib_name Network
set display_name "Bridge for AXI Ethernet Subsystem"
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode All [current_project]
set_property top ${top} [current_fileset]
#####################################
# Project Structure & IP Build
#####################################
read_verilog "./hdl/axi_ethernet_bridge.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project

set_property name ${design} [ipx::current_core]
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {ISE/SICE/Indiana University} [ipx::current_core]
set_property company_url {http://engineering.indiana.edu} [ipx::current_core]
set_property vendor {ISE} [ipx::current_core]
set_property taxonomy {{/InLocus/Network}} [ipx::current_core]
set_property version ${ip_version} [ipx::current_core]
set_property display_name ${display_name} [ipx::current_core]
set_property description ${design} [ipx::current_core]

ipx::infer_user_parameters [ipx::current_core]

ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog
close_project
file delete -force ${proj_dir}
