//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note: 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// *NOTE*
// For high speed (2G/4G) clock modeling, you should set the timescale to be *at least*
// 10ps/100fs precision.

// verilog_format: off
/*`timescale 10ps/100fs*/
/*`timescale 1ns/1ps*/
`timescale 100ps/100fs
`default_nettype none
// verilog_format: on

// Weird hack to instantiate the test
`define CREATE_TEST(TEST_NAME, TEST_CLASS) \
  if (selected_test == TEST_NAME) begin \
    test = fe_test_registry::create_test(selected_test, scan_bfm, afe_bfm, mon); \
    TEST_CLASS = new(scan_bfm, afe_bfm, mon); \
    test = TEST_CLASS; \
  end

`define REGISTER_TEST(TEST_NAME, TEST_CLASS) \
  fe_test_registry::register_test(TEST_NAME, TEST_CLASS::factory(null, null, null));


`include "fe_smoke_test.sv"
`include "fe_reset_test.sv"
`include "fe_des_test.sv"
`include "fe_lut_seedmode_test.sv"
`include "fe_lut_loadmode_test.sv"

module tb_dsp_fe;
  import fe_afe_bfm_pkg::*;
  import fe_scan_bfm_pkg::*;
  import fe_mon_pkg::*;
  import fe_test_pkg::*;
  /*import fe_test_env_pkg::*;*/

  initial register_tests();
  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_IN_WIDTH = `DES_IN_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;

  /*localparam time ScanHalfCycle = 25;*/
  /*localparam time ScanHalfCycle = 25ns;
   *localparam time ScanCycle = ScanHalfCycle * 2 * 4;*/
  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;
  /*localparam time AfeCycle = 500ps;
   *localparam time AfeHalfCycle = 250ps;*/
  localparam time AfeCycle = 2ns;
  localparam time AfeHalfCycle = 1ns;

  // Declare signals
  logic sclkp;
  logic sclkn;

  logic sclk_rst;
  logic sclk_en;
  logic scan_ref_clk;

  // Instantiate the scan interface
  scan_if scan_intf ();
  scan_if o_scan_intf ();

  scan_clkgen_if scan_clkgen_intf ();

  // Declare the scan BFM instance
  fe_scan_bfm scan_bfm;

  // scan clkgen interface <-> scan clkgen
  assign sclk_en = scan_clkgen_intf.scan_clkgen_en;
  assign sclk_rst = scan_clkgen_intf.scan_clkgen_rst;
  assign scan_clkgen_intf.sclkp = sclkp;
  assign scan_clkgen_intf.sclkn = sclkn;

  // scan interface <-> scan clkgen
  assign scan_intf.sctrl.sclkp = sclkp;
  assign scan_intf.sctrl.sclkn = sclkn;

  // Scan Clock Generator Model
  scan_clkgen sclkgen (
      .RefClk(scan_ref_clk),
      .Reset (sclk_rst),
      .ClkEn (sclk_en),
      .SClkP (sclkp),
      .SClkN (sclkn)
  );

  // Instantiate AFE interface
  fe_lane_if fe_lane_intf[LANE_WIDTH] ();

  // Declare the AFE BFM instance
  fe_afe_bfm afe_bfm;

  // Instantiate monitor interface
  fe_lane_mon_if fe_lane_mon_intf[LANE_WIDTH] ();

  // Declare monitor instance
  fe_mon mon;

  // Connect with AFE
  logic [LANE_WIDTH-1:0] i_rstb_fe;
  logic [LANE_WIDTH-1:0] i_clk_fe;
  logic [LANE_WIDTH-1:0][ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] i_ana_data;
  logic [LANE_WIDTH*DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] o_data;
  logic o_clk_mon;

  // clk (2GHz) supplied into afe interface for the reference
  // rstb generated from the afe interface
  generate
    for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_conn_afe
      assign i_rstb_fe[i] = fe_lane_intf[i].rstb;
      assign fe_lane_intf[i].clk = i_clk_fe[i];
      assign i_ana_data[i] = fe_lane_intf[i].data;

      /*assign fe_lane_mon_intf[i].data_in = fe_lane_intf[i].data;*/
      assign fe_lane_mon_intf[i].data_in = i_ana_data[i];
      /*assign fe_lane_mon_intf[i].data_mon = o_data[i*DES_OUT_WIDTH+:DES_OUT_WIDTH];*/
      assign fe_lane_mon_intf[i].clk_in = i_clk_fe[i];
      assign fe_lane_mon_intf[i].clk_mon = o_clk_mon;
    end
  endgenerate

  // per time-step (i+j*LANE_WIDTH)
  generate
    for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_conn_mon
      for (genvar j = 0; j < DES_OUT_WIDTH; j++) begin : gen_conn_mon_redistr
        assign fe_lane_mon_intf[i].data_mon[j] = o_data[i+j*LANE_WIDTH];
      end
    end
  endgenerate

  // DUT instantiation
  dsp_fe_core dsp_fe_core (
      .i_rstb_ref_bdl(i_rstb_fe),
      .i_clk_ref_bdl(i_clk_fe),
      .i_ana_dat_lad_fe(i_ana_data),
      .o_dat_fe(o_data),
      .o_clk_dig_mon(o_clk_mon),
      .o_clk_dig_mem(),
      .o_clk_dig_be(),
      .i_sdata(scan_intf.sdata),
      .i_sclkp(scan_intf.sctrl.sclkp),
      .i_sclkn(scan_intf.sctrl.sclkn),
      .i_senable(scan_intf.sctrl.senable),
      .i_supdate(scan_intf.sctrl.supdate),
      .i_sreset(scan_intf.sctrl.sreset),
      .o_sdata(o_scan_intf.sdata),
      .o_sclkp(o_scan_intf.sctrl.sclkp),
      .o_sclkn(o_scan_intf.sctrl.sclkn),
      .o_senable(o_scan_intf.sctrl.senable),
      .o_supdate(o_scan_intf.sctrl.supdate),
      .o_sreset(o_scan_intf.sctrl.sreset)
  );

  initial scan_ref_clk = 1'b0;
  initial begin
    for (int i = 0; i < LANE_WIDTH; i++) begin
      i_clk_fe[i] = 1'b0;
    end
    /*fork
     *  for (int i = 0; i < LANE_WIDTH; i++) begin
     *    #(AfeHalfCycle) i_clk_fe[i] = ~i_clk_fe[i];
     *  end
     *join_none*/
  end
  always #(ScanHalfCycle) scan_ref_clk <= ~scan_ref_clk;
  always #(AfeHalfCycle) begin
    for (int i = 0; i < LANE_WIDTH; i++) begin
      i_clk_fe[i] <= ~i_clk_fe[i];
    end
  end

  // Parameters for test selection
  /*string selected_test = "fe_lut_seedmode_test";  // Change this to select different tests*/
  string selected_test = "fe_lut_loadmode_test";  // Change this to select different tests

  initial begin
    /*$fsdbDumpfile("fe_lut_loadmode_test.fsdb");*/
    $fsdbDumpfile({selected_test, ".fsdb"});
    // YOU NEED THIS TO DUMP STRUCT and stuff...
    $fsdbDumpvars(0, tb_dsp_fe, "+all");
  end

  // Declare the test instance and drun
  fe_base_test test;
  fe_smoke_test smoke_test;
  fe_reset_test reset_test;
  fe_des_test des_test;
  fe_lut_seedmode_test lut_seedmode_test;
  fe_lut_loadmode_test lut_loadmode_test;

  initial begin
    scan_bfm = new(scan_intf.send, scan_clkgen_intf.send, o_scan_intf.recv);
    afe_bfm = new(fe_lane_intf);
    mon = new(fe_lane_mon_intf);
    `CREATE_TEST("fe_smoke_test", smoke_test)
    `CREATE_TEST("fe_reset_test", reset_test)
    `CREATE_TEST("fe_des_test", des_test)
    `CREATE_TEST("fe_lut_seedmode_test", lut_seedmode_test)
    `CREATE_TEST("fe_lut_loadmode_test", lut_loadmode_test)

    /*else begin
     *  $fatal(1, "Unknown test: %s", selected_test);
     *end*/

    // Create and run the selected test
    // TODO: Error out if not found
    test.run();
    /*$display("run success?");*/

    #(ScanCycle * 30);

    $finish;
  end

  function void register_tests();
    /*fe_test_registry::register_test("fe_smoke_test", fe_smoke_test::factory(null, null, null));
     *fe_test_registry::register_test("fe_reset_test", fe_reset_test::factory(null, null, null));
     *fe_test_registry::register_test("fe_des_test", fe_reset_test::factory(null, null, null));
     *fe_test_registry::register_test("fe_lut_seedmode_test", fe_lut_seedmode_test::factory(null, null
     *                                ));*/
    `REGISTER_TEST("fe_smoke_test", fe_smoke_test);
    `REGISTER_TEST("fe_reset_test", fe_reset_test);
    `REGISTER_TEST("fe_des_test", fe_des_test);
    `REGISTER_TEST("fe_lut_seedmode_test", fe_lut_seedmode_test);
    `REGISTER_TEST("fe_lut_loadmode_test", fe_lut_loadmode_test);
  endfunction

endmodule

`default_nettype wire

