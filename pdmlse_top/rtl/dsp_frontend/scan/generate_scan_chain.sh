#!/usr/bin/env bash

# error out if gen-scan-chain.pl is not found from path
if ! command -v gen-scan-chain.pl &> /dev/null
then
	echo "gen-scan-chain.pl could not be found"
	exit
fi


gen-scan-chain.pl \
	./cfg/dsp_fe_lane_des_scan.cfg \
	./dsp_fe_lane_des_scan.v \
	./dsp_fe_lane_des_scan_defs.v \
	FeLaneDes


gen-scan-chain.pl \
	./cfg/dsp_fe_lane_scan.cfg \
	./dsp_fe_lane_scan.v \
	./dsp_fe_lane_scan_defs.v \
	FeLane


gen-scan-chain.pl \
	./cfg/dsp_fe_clkspine_scan.cfg \
	./dsp_fe_clkspine_scan.v \
	./dsp_fe_clkspine_scan_defs.v \
	FeClkspine


gen-scan-chain.pl \
	./cfg/dsp_fe_rod_scan.cfg \
	./dsp_fe_rod_scan.v \
	./dsp_fe_rod_scan_defs.v \
	FeRod
