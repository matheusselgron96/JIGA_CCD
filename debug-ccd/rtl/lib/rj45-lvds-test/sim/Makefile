PATH:=${PATH}:/opt/altera/intelFPGA/20.1/modelsim_ase/linuxaloem

all: frame serdes rjtester

rjtester: work/rjtester_tb
	vsim -c -do sim.do work.rjtester_tb

work/rjtester_tb: rjtester_tb.vhd work/rjtester
	vcom -work work $<
	touch $@

work/rjtester: ../rjtester.vhd work/framecmp work/framegen work/des work/ser
	vcom -work work $<
	touch $@

frame: work/frame_tb
	vsim -c -do sim.do work.frame_tb

serdes: work/serdes_tb
	vsim -do sim.do -c work.serdes_tb

work/serdes_tb: serdes_tb.vhd work/framecmp work/framegen work/des work/ser
	vcom -work work $<
	touch $@

work/frame_tb: frame_tb.vhd work/framecmp work/framegen
	vcom -work work $<
	touch $@

work/ser: ../serdes/ser.vhd work/.done
	vcom -work work $<
	touch $@

work/des: ../serdes/des.vhd work/.done work/data_recovery
	vcom -work work $<
	touch $@

work/data_recovery: ../serdes/fpga-lib-analog-data_recovery/data_recovery.vhd work/.done
	vcom -work work $<
	touch $@

work/framecmp: ../frame/framecmp.vhd work/.done
	vcom -work work $<
	touch $@

work/framegen: ../frame/framegen.vhd work/.done
	vcom -work work $<
	touch $@

work/.done:
	vlib work
	touch $@

