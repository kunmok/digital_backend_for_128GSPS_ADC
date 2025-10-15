

import tb_cfg_pkg::*;
import fe_scan_bfm_pkg::*;
import fe_afe_bfm_pkg::*;
import fe_mon_pkg::*;

class fe_des_test extends fe_test_pkg::fe_base_test;

  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;

  // Constructor
  function new(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon);
    super.new(scan_bfm, afe_bfm, mon);
  endfunction

  task run();
    test_pattern_e tp_des[DES_OUT_WIDTH];
    setup();

    $display("run des test");

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

    `PRINT_STEP_MSG("Enable clkspine");
    this.enable_clkspine();

    `PRINT_STEP_MSG("Enable des");
    this.enable_des();

    // for simplicity, reset the entire but you don't need to
    `PRINT_STEP_MSG("Resetting FE digital");
    this.reset_fe_dig();

    tp_des[0] = TP_STATIC_0;
    tp_des[1] = TP_STATIC_1;
    tp_des[2] = TP_STATIC_0;
    tp_des[3] = TP_STATIC_1;

    `PRINT_STEP_MSG("Configuring and sending DES test pattern");
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.config_test_patt(i, tp_des);
      this.afe_bfm.forward_data_for_cycles(i, 5);
    end
    // trigger reset (through sv event)
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.trigger_data(i);
    end

    //for (int i = 0; i < LANE_WIDTH; i++) begin
    //  this.afe_bfm.config_test_patt(i, tp_des0, tp_des1);
    //  this.afe_bfm.forward_data(i);
    //end
    //// trigger reset (through sv event)
    //for (int i = 0; i < LANE_WIDTH; i++) begin
    //  this.afe_bfm.trigger_data_for_cycles(i, 5);
    //end

    cleanup();
  endtask

  /*static function fe_des_test factory(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm);
   *  fe_des_test fe_test = new(scan_bfm, afe_bfm);
   *  return fe_test;
   *endfunction*/

  `CREATE_TEST_FACTORY(fe_des_test)

endclass

