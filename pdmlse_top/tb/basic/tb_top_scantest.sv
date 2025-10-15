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
`default_nettype none
// verilog_format: on

// VERY SIMPLE SCAN_TEST ONLY

module tb_top_scantest;

  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;
  localparam HalfWriteClkCycle = 0.5;
  localparam WriteClkCycle = 1.0;
  localparam HalfReadClkCycle = 5.0;
  localparam ReadClkCycle = 10.0;

  // no-lane (NL) and lane (L)
  parameter integer DspFeNLScanLength = `FeClkspineScanChainLength + `FeRodScanChainLength;
  parameter integer DspFeLScanLength = `FeLaneDesScanChainLength + `FeLaneScanChainLength;
  parameter integer DspFeScanLength = DspFeNLScanLength + DspFeLScanLength * `LANE_WIDTH;
  parameter integer DspMemScanLength = `MemScanChainLength;
  parameter integer DspBeScanLength = `BeScanChainLength;
  parameter integer ScanChainLength = DspFeScanLength + DspMemScanLength + DspBeScanLength;

  localparam int MAX_SCAN_LENGTH = ScanChainLength * 2;

  reg [ScanChainLength - 1 : 0] scan_in_data;
  reg [ScanChainLength - 1 : 0] scan_out_data;

  logic scan_ref_clk;
  logic sclk_en;
  logic sreset;
  logic sclkp;
  logic sclkn;
  logic senable;
  logic sreset;
  logic sin;
  logic supdate;
  logic sout;

  //-----------------------------------------------------------------------------------
  //    Scan Chain Clock Generator
  //-----------------------------------------------------------------------------------
  scan_clkgen ClkG (
      .RefClk(scan_ref_clk),
      .Reset (sreset),
      .ClkEn (sclk_en),
      .SClkP (sclkp),
      .SClkN (sclkn)
  );
  //-----------------------------------------------------------------------------------

  dsp_top top (
      .irstb_deser (),
      .iclk_deser  (),
      .idat_deser0 (),
      .idat_deser1 (),
      .idat_deser2 (),
      .idat_deser3 (),
      .idat_deser4 (),
      .idat_deser5 (),
      .idat_deser6 (),
      .idat_deser7 (),
      .idat_deser8 (),
      .idat_deser9 (),
      .idat_deser10(),
      .idat_deser11(),
      .idat_deser12(),
      .idat_deser13(),
      .idat_deser14(),
      .idat_deser15(),
      .idat_deser16(),
      .idat_deser17(),
      .idat_deser18(),
      .idat_deser19(),
      .idat_deser20(),
      .idat_deser21(),
      .idat_deser22(),
      .idat_deser23(),
      .idat_deser24(),
      .idat_deser25(),
      .idat_deser26(),
      .idat_deser27(),
      .idat_deser28(),
      .idat_deser29(),
      .idat_deser30(),
      .idat_deser31(),

      .o_drx_sample(),
      .o_clk_dsp_fe(),

      .i_scan_dig_in(sin),
      .i_scan_dig_clkp(sclkp),
      .i_scan_dig_clkn(sclkn),
      .i_scan_dig_enable(senable),
      .i_scan_dig_update(supdate),
      .i_scan_dig_reset(sreset),
      .o_scan_dig_out(sout),

      .i_scan_mem_clk(),
      .o_scan_mem_out()
  );

  initial scan_ref_clk = 1'b0;
  always #(ScanHalfCycle) scan_ref_clk <= ~scan_ref_clk;

  task start_scan_clk;
    begin
      sclk_en = 1'b1;
      #(ScanCycle);
    end
  endtask

  task stop_scan_clk;
    begin
      sclk_en = 1'b0;
      #(ScanCycle);
    end
  endtask

  // Scan in some number of bits
  task scan_in;

    input [MAX_SCAN_LENGTH:0] scan_in_data;
    input [31:0] length;
    integer scan_pos;
    integer i;

    begin
      senable = 1'b1;
      // MSB bits are scanned in first            
      for (i = 0; i < length; i = i + 1) begin
        scan_pos = length - 1 - i;
        sin = scan_in_data[scan_pos];
        /*$display("%d", sin);*/
        #(ScanCycle);
      end

      senable = 1'b0;
    end
  endtask

  // Scan out some number of bits
  task scan_out;

    output reg [MAX_SCAN_LENGTH:0] scan_out_data;
    input [31:0] length;
    integer scan_pos;
    integer i;

    begin
      senable = 1'b1;

      // MSB bits are scanned out first 
      for (i = 0; i < length; i = i + 1) begin
        scan_pos = length - 1 - i;
        scan_out_data[scan_pos] = sout;
        /*$display("%d", sout);*/
        #(ScanCycle);
      end

      senable = 1'b0;
      /*$display("%d", scan_out_data);*/
    end
  endtask

  task simple_scan_test;

    integer i;

    reg [ScanChainLength - 1 : 0] scan_in_data;
    reg [ScanChainLength - 1 : 0] scan_out_data;

    begin
      $display("Starting scan in/out experiment...");

      for (i = 0; i < ScanChainLength; i = i + 1) begin
        scan_in_data[i] = $random;
      end

      start_scan_clk;

      scan_in(scan_in_data, ScanChainLength);

      scan_out(scan_out_data, ScanChainLength);

      if (scan_in_data == scan_out_data) begin
        $display("    scan in/out experiment PASSED");
      end
      else begin
        $display("    scan in/out experiment FAILED");
      end
    end
  endtask

  // Scan update
  task scan_update;
    begin
      supdate = 1'b1;
      #(ScanCycle);
      supdate = 1'b0;
      #(ScanCycle);
    end
  endtask

  // Scan enable
  task scan_enable;
    begin
      senable = 1'b1;
      #(ScanCycle);
      senable = 1'b0;
      #(ScanCycle);
    end
  endtask

  initial begin
    // report scan chain length
    $display("DSP-TOP Scan chain length: %d", ScanChainLength);

    #(ScanCycle);
    sreset = 1'b1;
    #(ScanCycle);
    sreset = 1'b0;
    #(ScanCycle);
    simple_scan_test;
    #(ScanCycle * 30);
    $finish;
  end

  initial begin
//    $fsdbDumpfile("tb_top_scantest.fsdb");
//    $fsdbDumpvars(0, tb_top_scantest, "+all");    
    $dumpfile("tb_top_scantest.vcd");
    $dumpvars(0, tb_top_scantest);
//    $dumpvars(0);
  end

endmodule

`default_nettype wire

