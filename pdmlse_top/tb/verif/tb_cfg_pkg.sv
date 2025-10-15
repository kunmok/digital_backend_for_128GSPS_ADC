

// ** NOTE**
// If set to 20ns, then 20ns / 8.0 = 2.5ns so 1ns/1ps would *not* work!!
// You have to set to a more precise timescale e.g., 10ps/100fs
/*`define SCAN_CYCLE 200ns*/
`define SCAN_CYCLE 20ns
/*`define SCAN_CYCLE 10ns*/
`define CLK_TO_DATA_DELAY_ARRAY {default: 0.1ps}
`define CLK_TO_RST_DELAY_ARRAY {default: 0.1ps}


package tb_cfg_pkg;

  typedef enum int {
    TP_IDLE,
    TP_STATIC_0,
    TP_STATIC_1,
    TP_CNT,
    TP_RANDOM
  } test_pattern_e;

endpackage


`define TB_SCAN_CFG_DONE \
$display(""); \
$display("===================================================================================================="); \
$display("======================================== SCAN TB CONFIG DONE ======================================="); \
$display("===================================================================================================="); \
$display(":: check if chip config (scan_in function) is done after this message ::"); \
$display("");


`define CHIP_SCAN_CFG_START \
$display(""); \
$display("===================================================================================================="); \
$display("======================================== SCAN CHIP CONFIG START ====================================="); \
$display("===================================================================================================="); \
$display(":: check if tb config (update_scan function) is done before this message ::"); \
$display("");

`define CHIP_SCAN_CFG_DONE \
$display(""); \
$display("===================================================================================================="); \
$display("======================================== SCAN CHIP CONFIG DONE ====================================="); \
$display("===================================================================================================="); \
$display("");


`define PRINT_STEP_MSG(STR) \
$display(""); \
$display("****************************************************************************************************"); \
$display("**** STEP: %s ****", STR); \
$display("****************************************************************************************************"); \
$display("");


`define PRINT_SCAN_MSG(STR) \
$display(""); \
$display("****************************************************************************************************"); \
$display("**** SCAN: %s ****", STR); \
$display("****************************************************************************************************"); \
$display("");
