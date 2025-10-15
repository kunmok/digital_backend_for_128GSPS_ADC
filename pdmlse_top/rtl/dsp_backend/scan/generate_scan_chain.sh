#!/usr/bin/env bash

# error out if gen-scan-chain.pl is not found from path
if ! command -v gen-scan-chain.pl &> /dev/null
then
	echo "gen-scan-chain.pl could not be found"
	exit
fi

gen-scan-chain.pl \
	./cfg/dsp_be_scan.cfg \
	./dsp_be_scan.v \
	./dsp_be_scan_defs.v \
	Be

