# IP Library for ADC-based SERDES Digital Backend

This repository contains an IP library for the digital backend of ADC-based SERDES systems. 
This includes:

- Fast clock divider (`serdes_clk_gen.v`)
- General programmable clock divider (`sync_clk_div.v`)
- Reset synchronizer (`reset_sync.v`)
- 1:2 deserializer (`des_1_to_2.v`)
- 2:4 deserializer (`des_2_to_4.v`)

Scan unit cells (`scan_cell/`) and BERT IP cores (`bert/`) are not included in this repository.
These are available from the original author upon request.
If you are interested in these components, email the author at [Kunmo Kim](mailto:kunmok@berkeley.edu) and [Sunjin Choi](mailto:sunjin_choi@berkeley.edu).



