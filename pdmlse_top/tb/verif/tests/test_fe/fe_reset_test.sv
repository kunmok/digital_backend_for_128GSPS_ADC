

import fe_scan_bfm_pkg::*;
import fe_afe_bfm_pkg::*;
import fe_mon_pkg::*;

class fe_reset_test extends fe_test_pkg::fe_base_test;

  localparam int LANE_WIDTH = `LANE_WIDTH;

  int scan_length;
  int scan_idx;
  fe_scan_flat_t scan_in_random;
  fe_scan_flat_t scan_out_monitor;

  /*lane_scan_t [LANE_WIDTH-1:0] lane_scan_grp;
   *lane_des_scan_t [LANE_WIDTH-1:0] lane_des_scan_grp;
   *cs_scan_t cs_scan;
   *rod_scan_t rod_scan;*/

  // Constructor
  function new(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon);
    super.new(scan_bfm, afe_bfm, mon);
    /*this.lane_scan_grp = '0;
     *this.lane_des_scan_grp = '0;
     *this.cs_scan = '0;
     *this.rod_scan = '0;*/
  endfunction

  task run();
    setup();

    $display("run reset test");

    // !! event construct requires a precise fork-join/join-nones !!
    //fork
    //  this.afe_bfm.forward_reset_by_event(reset_start);
    //join_none
    //->reset_start;
    // forward reset from afe to digital
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.forward_reset(i);
    end
    // trigger reset (through sv event)
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.trigger_reset(i);
    end

    this.scan_bfm.issue_sreset();

    this.enable_clkspine();

    this.reset_fe_dig();

    /*    for (int i = 0; i < LANE_WIDTH; i++) begin
 *      this.afe_bfm.forward_data(i);
 *    end
 *    // trigger reset (through sv event)
 *    for (int i = 0; i < LANE_WIDTH; i++) begin
 *      this.afe_bfm.trigger_data_for_cycles(i, 5);
 *    end
 **/

    cleanup();
  endtask

  /*static function fe_reset_test factory(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm);
   *  fe_reset_test fe_test = new(scan_bfm, afe_bfm);
   *  return fe_test;
   *endfunction*/

  `CREATE_TEST_FACTORY(fe_reset_test)

endclass

