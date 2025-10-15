

package fe_test_pkg;
  import tb_cfg_pkg::*;
  import fe_scan_bfm_pkg::*;
  import fe_afe_bfm_pkg::*;
  import fe_mon_pkg::*;

  `include "base_test.sv"

  class fe_base_test extends base_test;

    localparam time ScanCycle = `SCAN_CYCLE;

    localparam int LANE_WIDTH = `LANE_WIDTH;

    fe_scan_bfm scan_bfm;
    fe_afe_bfm afe_bfm;
    fe_mon mon;

    lane_scan_t [LANE_WIDTH-1:0] lane_scan_grp;
    lane_des_scan_t [LANE_WIDTH-1:0] lane_des_scan_grp;
    cs_scan_t cs_scan;
    rod_scan_t rod_scan;

    bit success;
    bit failure;

    // Constructor
    function new(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon);
      this.scan_bfm = scan_bfm;
      this.afe_bfm = afe_bfm;
      this.mon = mon;

      this.lane_scan_grp = '0;
      this.lane_des_scan_grp = '0;
      this.cs_scan = '0;
      this.rod_scan = '0;

      this.success = 1'b0;
      this.failure = 1'b0;
    endfunction

    virtual task setup();
      super.setup();
      $display("Setting up fe base test...");
    endtask

    virtual task cleanup();
      super.cleanup();
      $display("Cleaning up fe base test...");
    endtask

    virtual task run();
    endtask

    task enable_clkspine();
      this.scan_bfm.start_scan_clk();

      // Intended enable/reset sequencing
      // 1. clockspine enable and reset
      // 2. deserializer reset is provided by AFE
      // 3. enable the rest
      // 4. reset the rest

      // enable clkspine and reset
      `PRINT_SCAN_MSG("Enabling clkspine and reset")
      this.cs_scan[`FeClkspineEn]  = 1'b1;
      this.cs_scan[`FeClkspineRst] = 1'b1;
      /*this.rod_scan[`FeRodEn] = 1'b1;*/
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      // release clkspine reset
      `PRINT_SCAN_MSG("Releasing clkspine reset")
      this.cs_scan[`FeClkspineRst] = 1'b0;
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      this.scan_bfm.stop_scan_clk();
    endtask

    task enable_des();
      this.scan_bfm.start_scan_clk();

      `PRINT_SCAN_MSG("Enabling des and des-retime")
      for (int i = 0; i < LANE_WIDTH; i++) begin
        this.lane_des_scan_grp[i][`FeLaneDesEn] = 1'b1;
        this.lane_des_scan_grp[i][`FeLaneDesEnRetime] = 1'b1;
      end
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      this.scan_bfm.stop_scan_clk();
    endtask

    task enable_logic();
      this.scan_bfm.start_scan_clk();

      `PRINT_SCAN_MSG("Enable lane glue and lut")
      for (int i = 0; i < LANE_WIDTH; i++) begin
        /*this.lane_des_scan_grp[i][`FeLaneDesEn] = 1'b1;*/
        /*this.lane_des_scan_grp[i][`FeLaneDesEnRetime] = 1'b1;*/
        this.lane_scan_grp[i][`FeLaneEnGlue] = 1'b1;
        this.lane_scan_grp[i][`FeLaneEnLut]  = 1'b1;
      end
      this.rod_scan[`FeRodEn] = 1'b1;
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      this.scan_bfm.stop_scan_clk();
    endtask

    task reset_fe_dig();
      this.scan_bfm.start_scan_clk();

      // issue lane (glue, lut), lane des (retime) and rod reset
      `PRINT_SCAN_MSG("Resetting FE DIG (lane, lane des, rod)")
      for (int i = 0; i < LANE_WIDTH; i++) begin
        this.lane_scan_grp[i][`FeLaneRstGlue] = 1'b1;
        this.lane_scan_grp[i][`FeLaneRstLut]  = 1'b1;
      end
      for (int i = 0; i < LANE_WIDTH; i++) begin
        this.lane_des_scan_grp[i][`FeLaneDesRstRetime] = 1'b1;
      end
      this.rod_scan[`FeRodRst] = 1'b1;
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      // release lane (glue, lut), lane des (retime) and rod reset
      `PRINT_SCAN_MSG("Releasing FE DIG (lane, lane des, rod) reset")
      for (int i = 0; i < LANE_WIDTH; i++) begin
        this.lane_scan_grp[i][`FeLaneRstGlue] = 1'b0;
        this.lane_scan_grp[i][`FeLaneRstLut]  = 1'b0;
      end
      for (int i = 0; i < LANE_WIDTH; i++) begin
        this.lane_des_scan_grp[i][`FeLaneDesRstRetime] = 1'b0;
      end
      this.rod_scan[`FeRodRst] = 1'b0;
      this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
                                this.rod_scan);
      this.scan_bfm.scan_in();

      this.scan_bfm.stop_scan_clk();
    endtask


  endclass

  class fe_test_registry;

    typedef fe_base_test fe_factory_t;

    static fe_factory_t fe_test_factory[string];

    // Register a test with the registry
    static function void register_test(string test_name, fe_factory_t factory);
      fe_test_factory[test_name] = factory;
    endfunction

    // Create an instance of a test by name
    static function fe_base_test create_test(string test_name, fe_scan_bfm scan_bfm,
                                             fe_afe_bfm afe_bfm, fe_mon mon);
      if (fe_test_factory.exists(test_name)) begin
        fe_base_test fe_test = fe_test_factory[test_name];
        fe_test = new(scan_bfm, afe_bfm, mon);
        $display("test created");
        return fe_test;
      end
      else begin
        $fatal("Test '%s' not found in registry!", test_name);
      end
    endfunction

  endclass

endpackage

`define CREATE_TEST_FACTORY(TEST_CLASS) \
  static function TEST_CLASS factory(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon); \
    TEST_CLASS fe_test = new(scan_bfm, afe_bfm, mon); \
    return fe_test; \
  endfunction \

