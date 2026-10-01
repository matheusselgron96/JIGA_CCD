onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /data_recovery_tb/DUT/clk0
add wave -noupdate /data_recovery_tb/DUT/clk90
add wave -noupdate /data_recovery_tb/DUT/serial_data_i
add wave -noupdate /data_recovery_tb/DUT/data_phase0_reg
add wave -noupdate /data_recovery_tb/DUT/data_phase90_reg
add wave -noupdate /data_recovery_tb/DUT/data_phase180_reg
add wave -noupdate /data_recovery_tb/DUT/data_phase270_reg
add wave -noupdate -group xor_p /data_recovery_tb/DUT/xor_p_clk0_reg
add wave -noupdate -group xor_p /data_recovery_tb/DUT/xor_p_clk90_reg
add wave -noupdate -group xor_p /data_recovery_tb/DUT/xor_p_clk180_reg
add wave -noupdate -group xor_p /data_recovery_tb/DUT/xor_p_clk270_reg
add wave -noupdate -group xor_n /data_recovery_tb/DUT/xor_n_clk0_reg
add wave -noupdate -group xor_n /data_recovery_tb/DUT/xor_n_clk90_reg
add wave -noupdate -group xor_n /data_recovery_tb/DUT/xor_n_clk180_reg
add wave -noupdate -group xor_n /data_recovery_tb/DUT/xor_n_clk270_reg
add wave -noupdate -group data_out /data_recovery_tb/DUT/data_phase0_reg(4)
add wave -noupdate -group data_out /data_recovery_tb/DUT/data_phase90_reg(4)
add wave -noupdate -group data_out /data_recovery_tb/DUT/data_phase180_reg(4)
add wave -noupdate -group data_out /data_recovery_tb/DUT/data_phase270_reg(4)
add wave -noupdate /data_recovery_tb/DUT/selected_bit_reg
add wave -noupdate /data_recovery_tb/DUT/bit_sel_reg
add wave -noupdate /data_recovery_tb/DUT/flag_start_reg
add wave -noupdate /data_recovery_tb/parallel_data_o
add wave -noupdate /data_recovery_tb/DUT/st_dr_reg
add wave -noupdate /data_recovery_tb/DUT/dv_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {10140000 ps} 0} {{Cursor 2} {13796053 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 176
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {31500 ns}
