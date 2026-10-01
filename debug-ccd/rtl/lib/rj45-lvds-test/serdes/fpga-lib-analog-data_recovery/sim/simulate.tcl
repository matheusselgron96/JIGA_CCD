vlib work
vcom ../data_recovery.vhd
vcom data_recovery_tb.vhd
vsim work.data_recovery_tb
log -r /*
do wave.do
run 100 us
wave zoom full
