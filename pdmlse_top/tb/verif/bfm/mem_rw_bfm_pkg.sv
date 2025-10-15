//==============================================================================
// Author: Sunjin Choi
// Description: Encapsulates DSP-FE interface and checker
// Signals:
// Note: 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`default_nettype none
// verilog_format: on

package mem_rw_bfm_pkg;
  import tb_cfg_pkg::*;

  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int WAY_WIDTH = `WAY_WIDTH;
  localparam int NUM_BANKS = `NUM_BANKS;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int FRAME_LENGTH = `FRAME_LENGTH;

  /*localparam time CLK_TO_DATA_DELAY[LANE_WIDTH] = `CLK_TO_DATA_DELAY_ARRAY;
   *localparam time CLK_TO_RST_DELAY[LANE_WIDTH] = `CLK_TO_RST_DELAY_ARRAY;*/

  class mem_rw_bfm;

    virtual mem_rw_if.master mem_rw_intf;

    function new(virtual mem_rw_if.master mem_rw_intf);
      this.mem_rw_intf = mem_rw_intf;
    endfunction

    /*    task automatic config_test_patt(input int lane_idx, input test_pattern_e patt_des0,
 *                                    input test_pattern_e patt_des1, input test_pattern_e patt_des2,
 *                                    input test_pattern_e patt_des3);
 *      this.fe_lane_intf[lane_idx].config_test_patt_des0(patt_des0);
 *      this.fe_lane_intf[lane_idx].config_test_patt_des1(patt_des1);
 *      this.fe_lane_intf[lane_idx].config_test_patt_des2(patt_des2);
 *      this.fe_lane_intf[lane_idx].config_test_patt_des3(patt_des3);
 *    endtask
 *
 *    task automatic seed_test_patt(input int lane_idx, input bit [ADC_WIDTH-1:0] seed_des0,
 *                                  input bit [ADC_WIDTH-1:0] seed_des1,
 *                                  input bit [ADC_WIDTH-1:0] seed_des2,
 *                                  input bit [ADC_WIDTH-1:0] seed_des3);
 *      this.fe_lane_intf[lane_idx].seed_test_patt_des0(seed_des0);
 *      this.fe_lane_intf[lane_idx].seed_test_patt_des1(seed_des1);
 *      this.fe_lane_intf[lane_idx].seed_test_patt_des2(seed_des2);
 *      this.fe_lane_intf[lane_idx].seed_test_patt_des3(seed_des3);
 *    endtask
 *
 *    task automatic forward_data_for_cycles(input int lane_idx, input int cycle);
 *      fork
 *        this.fe_lane_intf[lane_idx].send_data(this.fe_lane_intf[lane_idx].data_start, cycle,
 *                                              CLK_TO_DATA_DELAY[lane_idx]);
 *        $display("Sending data for lane %0d", lane_idx);
 *      join_none
 *    endtask
 *
 *    task automatic trigger_data(input int lane_idx);
 *      fork
 *        ->this.fe_lane_intf[lane_idx].data_start;
 *        $display("Triggering data for lane %0d", lane_idx);
 *      join
 *    endtask*/

  endclass : mem_rw_bfm

endpackage : mem_rw_bfm_pkg


`default_nettype wire

