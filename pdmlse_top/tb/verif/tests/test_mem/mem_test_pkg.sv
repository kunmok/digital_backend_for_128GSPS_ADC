

package mem_test_pkg;
  import tb_cfg_pkg::*;
  import mem_scan_bfm_pkg::*;
  import mem_rw_bfm_pkg::*;
  import mem_mon_pkg::*;

  `include "base_test.sv"

  class mem_base_test extends base_test;

    localparam time ScanCycle = `SCAN_CYCLE;

    mem_scan_bfm scan_bfm;
    mem_rw_bfm bfm;
    mem_mon mon;

    mem_scan_t mem_scan;

    bit success;
    bit failure;

    // Constructor
    function new(mem_scan_bfm scan_bfm, mem_rw_bfm bfm, mem_mon mon);
      this.scan_bfm = scan_bfm;
      this.bfm = bfm;
      this.mon = mon;
      this.mem_scan = '0;

      this.success = 1'b0;
      this.failure = 1'b0;
    endfunction

    virtual task setup();
      super.setup();
      $display("Setting up mem base test...");
    endtask

    virtual task cleanup();
      super.cleanup();
      $display("Cleaning up mem base test...");
    endtask

    virtual task run();
    endtask

    task enable_bank();
      this.scan_bfm.start_scan_clk();

      // enable clkspine and reset
      `PRINT_SCAN_MSG("Enabling memory banks")

      this.scan_bfm.stop_scan_clk();
    endtask

    //task reset_fe_dig();
    //  this.scan_bfm.start_scan_clk();

    //  // issue lane (glue, lut), lane des (retime) and rod reset
    //  `PRINT_SCAN_MSG("Resetting FE DIG (lane, lane des, rod)")
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    this.lane_scan_grp[i][`FeLaneRstGlue] = 1'b1;
    //    this.lane_scan_grp[i][`FeLaneRstLut]  = 1'b1;
    //  end
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    this.lane_des_scan_grp[i][`FeLaneDesRstRetime] = 1'b1;
    //  end
    //  this.rod_scan[`FeRodRst] = 1'b1;
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  // release lane (glue, lut), lane des (retime) and rod reset
    //  `PRINT_SCAN_MSG("Releasing FE DIG (lane, lane des, rod) reset")
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    this.lane_scan_grp[i][`FeLaneRstGlue] = 1'b0;
    //    this.lane_scan_grp[i][`FeLaneRstLut]  = 1'b0;
    //  end
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    this.lane_des_scan_grp[i][`FeLaneDesRstRetime] = 1'b0;
    //  end
    //  this.rod_scan[`FeRodRst] = 1'b0;
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  this.scan_bfm.stop_scan_clk();
    //endtask

    //task enable_clkspine();
    //  this.scan_bfm.start_scan_clk();

    //  // enable clkspine and reset
    //  `PRINT_SCAN_MSG("Enabling clkspine and reset")
    //  this.cs_scan[`FeClkspineEn]  = 1'b1;
    //  this.cs_scan[`FeClkspineRst] = 1'b1;
    //  /*this.rod_scan[`FeRodEn] = 1'b1;*/
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  // release clkspine reset
    //  `PRINT_SCAN_MSG("Releasing clkspine reset")
    //  this.cs_scan[`FeClkspineRst] = 1'b0;
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  this.scan_bfm.stop_scan_clk();
    //endtask

    //task enable_des();
    //  this.scan_bfm.start_scan_clk();

    //  `PRINT_SCAN_MSG("Enabling des and des-retime")
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    this.lane_des_scan_grp[i][`FeLaneDesEn] = 1'b1;
    //    this.lane_des_scan_grp[i][`FeLaneDesEnRetime] = 1'b1;
    //  end
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  this.scan_bfm.stop_scan_clk();
    //endtask

    //task enable_logic();
    //  this.scan_bfm.start_scan_clk();

    //  `PRINT_SCAN_MSG("Enable lane glue and lut")
    //  for (int i = 0; i < LANE_WIDTH; i++) begin
    //    /*this.lane_des_scan_grp[i][`FeLaneDesEn] = 1'b1;*/
    //    /*this.lane_des_scan_grp[i][`FeLaneDesEnRetime] = 1'b1;*/
    //    this.lane_scan_grp[i][`FeLaneEnGlue] = 1'b1;
    //    this.lane_scan_grp[i][`FeLaneEnLut]  = 1'b1;
    //  end
    //  this.rod_scan[`FeRodEn] = 1'b1;
    //  this.scan_bfm.update_scan(this.lane_scan_grp, this.lane_des_scan_grp, this.cs_scan,
    //                            this.rod_scan);
    //  this.scan_bfm.scan_in();

    //  this.scan_bfm.stop_scan_clk();
    //endtask

  endclass

  class mem_test_registry;

    typedef mem_base_test mem_factory_t;

    static mem_factory_t mem_test_factory[string];

    // Register a test with the registry
    static function void register_test(string test_name, mem_factory_t factory);
      mem_test_factory[test_name] = factory;
    endfunction

    // Create an instance of a test by name
    static function mem_base_test create_test(string test_name, mem_scan_bfm scan_bfm,
                                              mem_rw_bfm bfm, mem_mon mon);
      if (mem_test_factory.exists(test_name)) begin
        mem_base_test mem_test = mem_test_factory[test_name];
        mem_test = new(scan_bfm, bfm, mon);
        $display("test created");
        return mem_test;
      end
      else begin
        $fatal("Test '%s' not found in registry!", test_name);
      end
    endfunction

  endclass

endpackage

`define CREATE_TEST_FACTORY(TEST_CLASS) \
  static function TEST_CLASS factory(mem_scan_bfm scan_bfm, mem_rw_bfm bfm, mem_mon mon); \
    TEST_CLASS mem_test = new(scan_bfm, bfm, mon); \
    return mem_test; \
  endfunction \

