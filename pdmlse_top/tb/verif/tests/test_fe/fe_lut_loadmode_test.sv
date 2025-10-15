

import tb_cfg_pkg::*;
import fe_scan_bfm_pkg::*;
import fe_afe_bfm_pkg::*;
import fe_mon_pkg::*;

class fe_lut_loadmode_test extends fe_test_pkg::fe_base_test;

  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;

  // Constructor
  function new(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon);
    super.new(scan_bfm, afe_bfm, mon);
  endfunction

  task config_lut_loadmode();
    this.scan_bfm.start_scan_clk();

    `PRINT_SCAN_MSG("Configure LUT into load-mode");
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.lane_scan_grp[i][`FeLaneCfgLutModeLoad] = 1'b1;
      this.lane_scan_grp[i][`FeLaneCfgLutModeSeed] = 1'b0;
      this.lane_scan_grp[i][`FeLaneCfgLutModeMission] = 1'b0;
      /*this.lane_scan_grp[i][`FeLaneCfgLutTable] = {>>{`FE_TEST_LUT_SER}};*/
      this.lane_scan_grp[i][`FeLaneCfgLutTable] = `FE_TEST_LUT_SER;
    end
    this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                              this.rod_scan);
    this.scan_bfm.scan_in();

    `PRINT_SCAN_MSG("Configure LUT into mission-mode");
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.lane_scan_grp[i][`FeLaneCfgLutModeLoad] = 1'b0;
      this.lane_scan_grp[i][`FeLaneCfgLutModeSeed] = 1'b0;
      this.lane_scan_grp[i][`FeLaneCfgLutModeMission] = 1'b1;
      this.lane_scan_grp[i][`FeLaneCfgLutTable] = '0;
    end
    this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                              this.rod_scan);
    this.scan_bfm.scan_in();

    this.scan_bfm.stop_scan_clk();
  endtask

  task config_lut_loadmode_monitor();
    for (int i = 0; i < LANE_WIDTH; i++) begin
      /*this.mon.check_config_op_lut(i, `LUT_DEFAULT_TABLE);*/
      this.mon.check_config_op_lut(i, {>>{`FE_TEST_LUT_SER}});
    end
  endtask

  task run();
    test_pattern_e tp_des[DES_OUT_WIDTH];
    logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] seed_des[LANE_WIDTH];
    // wiggle target lane 0 only
    int target_lane = 0;
    // TODO: weird... acting out when num_count > 50 bc of queue size
    int num_count = 50;
    int match = 0;

    setup();

    $display("run lut loadmode test");

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

    `PRINT_STEP_MSG("Enable rest of the DSP FE");
    this.enable_logic();

    `PRINT_STEP_MSG("Resetting FE digital");
    this.reset_fe_dig();

    `PRINT_STEP_MSG("Configure LUT and start operation");
    this.config_lut_loadmode();

    this.config_lut_loadmode_monitor();

    // only test des0
    // lane0, des0 corresponds to the timestep 0 which is o_dat_fe[0]
    /*tp_des[0] = TP_CNT;
     *tp_des[1] = TP_CNT;
     *tp_des[2] = TP_CNT;
     *tp_des[3] = TP_STATIC_0;*/
    tp_des[0] = TP_RANDOM;
    tp_des[1] = TP_CNT;
    tp_des[2] = TP_STATIC_0;
    tp_des[3] = TP_RANDOM;
    /*seed_des[0] = '0;
     *seed_des[1] = 2'b11;
     *seed_des[2] = 3'b111;
     *seed_des[3] = '0;*/
    for (int i = 0; i < LANE_WIDTH; i++) begin
      seed_des[0] = $urandom_range(0, 1 << ADC_WIDTH);
      seed_des[1] = $urandom_range(0, 1 << ADC_WIDTH);
      seed_des[2] = $urandom_range(0, 1 << ADC_WIDTH);
      seed_des[3] = $urandom_range(0, 1 << ADC_WIDTH);
    end

    /*`PRINT_STEP_MSG("Configuring and sending DES cnt test pattern for Lane 0 Des 0");
     *this.afe_bfm.config_test_patt(target_lane, tp_des);
     *this.afe_bfm.seed_test_patt(target_lane, {'0, '0, '0, '0});
     *this.afe_bfm.forward_data_for_cycles(target_lane, num_count);
     *this.afe_bfm.trigger_data(target_lane);*/

    `PRINT_STEP_MSG("Configuring and sending DES cnt test pattern for Lane 0 Des 0");
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.config_test_patt(i, tp_des);
      this.afe_bfm.seed_test_patt(i, seed_des[i]);
      this.afe_bfm.forward_data_for_cycles(i, num_count);
    end
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.afe_bfm.trigger_data(i);
    end

    `PRINT_STEP_MSG("Monitoring DES output");
    /*this.mon.collect_data_in(target_lane, num_count);
     *this.mon.wait_data_mon_for_cycles(target_lane, 8);
     *this.mon.collect_data_mon(target_lane, num_count);*/

    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.mon.collect_data_in(i, num_count);
    end
    this.mon.wait_data_mon_for_cycles(target_lane, 8);
    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.mon.collect_data_mon(i, num_count);
    end

    #(200);
    /*for (int i = 0; i < 2; i++) begin
     *  this.mon.print_data_in_q(i);
     *  this.mon.print_data_mon_q(i);
     *end*/

    for (int i = 0; i < LANE_WIDTH; i++) begin
      this.mon.check_data(i, num_count, match);
      if (match != num_count) begin
        $display("====================================================================");
        $display("TEST FAILED: lane %0d, num_count %0d, match %0d", i, num_count, match);
        $display("====================================================================");
      end
      else begin
        $display("====================================================================");
        $display("TEST PASSED: lane %0d, num_count %0d, match %0d", i, num_count, match);
        $display("====================================================================");
      end
    end


    cleanup();
  endtask

  `CREATE_TEST_FACTORY(fe_lut_loadmode_test)

endclass

