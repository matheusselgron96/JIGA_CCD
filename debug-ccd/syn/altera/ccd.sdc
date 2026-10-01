## Generated SDC file "ccd.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Thu Apr 27 10:17:27 2023"

##
## DEVICE  "5CEBA5F23C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 33.333 -waveform { 0.000 16.666 } [get_ports {altera_reserved_tck}]
create_clock -name {sysclk} -period 25.000 -waveform { 0.000 12.500 } [get_ports {sysclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks

create_generated_clock -name {sdram_clk} -source [get_pins {u0|pll_0|altera_pll_i|general[6].gpll~PLL_OUTPUT_COUNTER|divclk}] -master_clock {u0|pll_0|altera_pll_i|general[6].gpll~PLL_OUTPUT_COUNTER|divclk} [get_ports {sdram_clk_o}]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[0]}] 10 [get_ports {ad_red_e_i[*]}]
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[1]}] 10 [get_ports {ad_red_o_i[*]}]
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[2]}] 10 [get_ports {ad_green_e_i[*]}]
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[3]}] 10 [get_ports {ad_green_o_i[*]}]
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[4]}] 10 [get_ports {ad_blue_e_i[*]}]
set_input_delay -clock { u0|pll_1|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk } -reference_pin [get_ports {ad_data_clk_o[5]}] 10 [get_ports {ad_blue_o_i[*]}]

# Access Time from CLK
# 6 for CL = 2
set sdram_tAC_max 5
# Set Input Delay Setup for SDRAM DQ_i
set_input_delay -clock [get_clocks sdram_clk] -max $sdram_tAC_max [get_ports sdram_dq_o[*]]
# Output Data Hold Time
set sdram_tOH_min 3
# Set Input Delay Hold for SDRAM DQ_i
set_input_delay -clock [get_clocks sdram_clk] -min $sdram_tOH_min [get_ports sdram_dq_o[*]] -add_delay

#**************************************************************
# Set Output Delay
#**************************************************************

# Command Set-up Time
set sdram_tCMS_min 1.5
# Command Hold Time
set sdram_tCMH_min 0.8
# Set Output Delay for SDRAM CAS
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_cas_n_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_cas_n_o}]
# Set Output Delay for SDRAM CS_n
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_cs_n_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_cs_n_o}]
# Set Output Delay for SDRAM DQM
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_dqm_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_dqm_o}]
# Set Output Delay for SDRAM UDQM
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_udqm_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_udqm_o}]
# Set Output Delay for SDRAM RAS_n
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_ras_n_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_ras_n_o}]
# Set Output Delay for SDRAM WE_n
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCMS_min [get_ports {sdram_we_n_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCMH_min [get_ports {sdram_we_n_o}]
# Address Set-up Time
set sdram_tAS_min 1.5
# Address Hold Time
set sdram_tAH_min 0.8
# Set Output Delay for SDRAM Address
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tAS_min [get_ports {sdram_addr_o[*]}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tAH_min [get_ports {sdram_addr_o[*]}]
# Set Output delay for SDRAM Banks
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tAS_min [get_ports {sdram_banks_o[*]}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tAH_min [get_ports {sdram_banks_o[*]}]
# CKE Set-up Time
set sdram_tCKS_min 1.5
# CKE Hold Time
set sdram_tCKH_min 0.8
# Set Output Delay for SDRAM CKE
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tCKS_min [get_ports {sdram_cke_o}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tCKH_min [get_ports {sdram_cke_o}]
# Data-in Set-up Time
set sdram_tDS_min 1.5
# Data-in Hold Time
set sdram_tDH_min 0.8
# Set Output Delay for SDRAM Data
set_output_delay -add_delay -max -clock [get_clocks {sdram_clk}]  $sdram_tDS_min [get_ports {sdram_dq_o[*]}]
set_output_delay -add_delay -min -clock [get_clocks {sdram_clk}]  -$sdram_tDH_min [get_ports {sdram_dq_o[*]}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_ue9:dffpipe16|dffe17a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_te9:dffpipe13|dffe14a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe18|dffe19a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_break:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_break|break_readreg*}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug|*resetlatch}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr[33]}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug|monitor_ready}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr[0]}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug|monitor_error}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr[34]}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_ocimem:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_ocimem|*MonDReg*}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_tck|*sr*}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_sysclk:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_wrapper|poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_sysclk:the_poc_serdes_qsys_nios2_gen2_0_cpu_debug_slave_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*poc_serdes_qsys_nios2_gen2_0_cpu:*|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci|poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug:the_poc_serdes_qsys_nios2_gen2_0_cpu_nios2_oci_debug|monitor_go}]


set_false_path -from [get_ports {board_id_i[*]}] -to *
set_false_path -from [get_ports {altera_reserved_*}] -to *
set_false_path -from * -to [get_ports {altera_reserved_*}]
set_false_path -from [get_ports {lvds_serial_i}] -to [get_ports {lvds_serial_o*}]


set_false_path -from [get_ports {lvds_from_ccd_i}]
set_false_path -from [get_ports {lvds_serial_i}]
set_false_path -from [get_ports {lvds_from_ejection_i}]


set_false_path -from * -to [get_ports {led_o[*]}]

#**************************************************************
# Set Multicycle Path
#**************************************************************


set_multicycle_path -from [get_clocks {sdram_clk}] -to [get_clocks {u0|pll_0|altera_pll_i|general[5].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup -end 2
set_multicycle_path -from [get_clocks {sdram_clk}] -to [get_clocks {u0|pll_0|altera_pll_i|general[5].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold -end 0

#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] 100.000
set_max_delay -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] 100.000
set_max_delay -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|*rdptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}] 100.000
set_max_delay -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|delayed_wrptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}] 100.000





#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] -100.000
set_min_delay -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] -100.000
set_min_delay -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|*rdptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}] -100.000
set_min_delay -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|delayed_wrptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}] -100.000


#**************************************************************
# Set Input Transition
#**************************************************************

#set_location_assignment LC_X2_Y1_N0 -to [get_registers {poc_serdes_qsys:u0|data_recovery:data_recovery_0|data_phase0_reg[0]}]


#**************************************************************
# Set Net Delay
#**************************************************************

set_net_delay -max 2.000 -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}]
set_net_delay -max 2.000 -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}]
set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|*rdptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}]
set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}]
set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|delayed_wrptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}]
set_net_delay -max -value_multiplier 0.800 -get_value_from_clock_period dst_clock_period -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}]


#**************************************************************
# Set Max Skew
#**************************************************************

set_max_skew -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|*rdptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|ws_dgrp|dffpipe*|dffe*}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 
set_max_skew -from [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|delayed_wrptr_g*}] -to [get_keepers {u0|fifo_0|the_dcfifo_with_controls|the_dcfifo|dual_clock_fifo|auto_generated|rs_dgwp|dffpipe*|dffe*}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 


#set_max_skew -from [get_ports {lvds_from_ccd_i}] 3
