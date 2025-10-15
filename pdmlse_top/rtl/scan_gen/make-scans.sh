#!/bin/bash

#perl scan-to-python.pl scan_defines/fastlock_slice.cfg ../dwayne_fastlock_slice_scan_bits.py $1
perl scan-to-python.pl scan_defines/dsp_fe_clkspine_scan.cfg    ../dsp_fe_clkspine_scan_bits.py $1
perl scan-to-python.pl scan_defines/dsp_fe_lane_des_scan.cfg    ../dsp_fe_lane_des_scan_bits.py $1
perl scan-to-python.pl scan_defines/dsp_fe_lane_scan.cfg        ../dsp_fe_lane_scan_bits.py     $1
perl scan-to-python.pl scan_defines/dsp_fe_rod_scan.cfg         ../dsp_fe_rod_scan_bits.py      $1
perl scan-to-python.pl scan_defines/dsp_mem_scan.cfg            ../dsp_mem_scan_bits.py         $1
perl scan-to-python.pl scan_defines/dsp_be_scan.cfg             ../dsp_be_scan_bits.py          $1

