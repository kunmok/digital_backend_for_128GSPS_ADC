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

// verilog_format: off
`timescale 10ps/100fs
/*`timescale 1ns/1ps*/
`default_nettype none
// verilog_format: on

// Weird hack to instantiate the test
`define CREATE_TEST(TEST_NAME, TEST_CLASS) \
  if (selected_test == TEST_NAME) begin \
    test = mem_test_registry::create_test(selected_test, scan_bfm, bfm, mon); \
    TEST_CLASS = new(scan_bfm, bfm, mon); \
    test = TEST_CLASS; \
  end

`define REGISTER_TEST(TEST_NAME, TEST_CLASS) \
  mem_test_registry::register_test(TEST_NAME, TEST_CLASS::factory(null, null, null));


`include "mem_smoke_test.sv"

module tb_dsp_mem;
  /*import mem_afe_bfm_pkg::*;*/
  import mem_rw_bfm_pkg::*;
  import mem_scan_bfm_pkg::*;
  import mem_mon_pkg::*;
  import mem_test_pkg::*;
  /*import fe_test_env_pkg::*;*/

  initial register_tests();
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int WAY_WIDTH = `WAY_WIDTH;
  localparam int NUM_BANKS = `NUM_BANKS;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int FRAME_LENGTH = `FRAME_LENGTH;

  /*localparam time ScanHalfCycle = 25;*/
  /*localparam time ScanHalfCycle = 25ns;
   *localparam time ScanCycle = ScanHalfCycle * 2 * 4;*/
  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;
  /*localparam time AfeCycle = 500ps;
   *localparam time AfeHalfCycle = 250ps;*/
  localparam time ReadCycle = 10ns;
  localparam time ReadHalfCycle = 5ns;
  localparam time WriteCycle = 500ps;
  localparam time WriteHalfCycle = 250ps;

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
  mem_scan_bfm scan_bfm;

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

  // Instantiate memory interface
  mem_rw_if mem_rw_intf ();

  // Declare the AFE BFM instance
  mem_rw_bfm bfm;

  // Instantiate monitor interface
  mem_mon_if mem_mon_intf ();

  // Declare monitor instance
  mem_mon mon;

  // Connect with AFE
  logic i_wclk;
  logic i_rclk;
  logic [WAY_WIDTH-1:0][ADC_WIDTH-1:0] i_data;
  logic o_data;
  // connect with rw interface
  assign i_wclk = mem_rw_intf.wclk;
  assign i_data = mem_rw_intf.data;
  assign i_rclk = mem_rw_intf.rclk;

  // data output is connected to the monitor interface
  assign mem_mon_intf.data_mon = o_data;
  // strobe clock is forwarded to the monitor interface
  assign mem_mon_intf.clk_mon = i_rclk;

  /*generate
   *  for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_conn_afe
   *    assign i_rstb_fe[i] = mem_lane_afe_intf[i].rstb;
   *    assign mem_lane_afe_intf[i].clk = i_clk_fe[i];
   *    assign i_ana_data[i] = mem_lane_afe_intf[i].data;
   *  end
   *endgenerate*/

  // DUT instantiation
  dsp_mem dsp_mem (
      .i_clk_dig_mem(i_wclk),
      .i_dat_mem(i_data),
      .i_clk_read_mem(i_rclk),
      .o_bit_read_mem(o_data),
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
  /*initial i_wclk = 1'b0;*/
  /*initial i_rclk = 1'b0;*/
  /*initial begin
   *  for (int i = 0; i < LANE_WIDTH; i++) begin
   *    i_clk_fe[i] = 1'b0;
   *  end
   *end*/

  always #(ScanHalfCycle) scan_ref_clk <= ~scan_ref_clk;
  /*always #(WriteHalfCycle) i_wclk <= ~i_wclk;*/
  /*always #(ReadHalfCycle) i_rclk <= ~i_rclk;*/
  //  always #(AfeHalfCycle) begin
  //    for (int i = 0; i < LANE_WIDTH; i++) begin
  //      i_clk_fe[i] <= ~i_clk_fe[i];
  //    end
  //  end

  // Parameters for test selection
  string selected_test = "mem_smoke_test";  // Change this to select different tests

  initial begin
    $fsdbDumpfile("mem_smoke_test.fsdb");
    // YOU NEED THIS TO DUMP STRUCT and stuff...
    $fsdbDumpvars(0, tb_dsp_mem, "+all");
  end

  // Declare the test instance and run
  mem_base_test  test;
  mem_smoke_test smoke_test;

  initial begin
    scan_bfm = new(scan_intf.send, scan_clkgen_intf.send, o_scan_intf.recv);
    bfm = new(mem_rw_intf);
    mon = new(mem_mon_intf);
    `CREATE_TEST("mem_smoke_test", smoke_test)
    /*`CREATE_TEST("mem_reset_test", reset_test)
     *`CREATE_TEST("mem_des_test", des_test)
     *`CREATE_TEST("mem_lut_seedmode_test", lut_seedmode_test)*/

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
    /*mem_test_registry::register_test("mem_smoke_test", mem_smoke_test::factory(null));*/
    /*mem_test_registry::register_test("mem_reset_test", mem_reset_test::factory(null, null));
     *mem_test_registry::register_test("mem_des_test", mem_reset_test::factory(null, null));
     *mem_test_registry::register_test("mem_lut_seedmode_test", mem_lut_seedmode_test::factory(
     *                                 null, null));*/
    `REGISTER_TEST("mem_smoke_test", mem_smoke_test);
  endfunction

endmodule

`default_nettype wire

