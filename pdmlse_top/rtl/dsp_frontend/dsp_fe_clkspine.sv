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
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_fe_clkspine #(

) (
    // Input and output
    input var  logic i_clk_ref,
    output var logic o_clk_dig,

    // embedded scan i/o
    scan_if.recv i_scan,
    scan_if.send o_scan

    //// Embedded Two-Phase Scan
    //input var  logic i_sin,
    //input var  logic i_sclkp,
    //input var  logic i_sclkn,
    //input var  logic i_senable,
    //input var  logic i_supdate,
    //input var  logic i_sreset,
    //output var logic o_sout,

    //// Embedded Two-Phase Scan Daisy-Chain
    //output var logic o_sclkp,
    //output var logic o_sclkn,
    //output var logic o_senable,
    //output var logic o_supdate,
    //output var logic o_sreset
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // Unused signals
  logic UNUSED_clk_dig_mul_2;

  // reset sync for clock divider
  logic rst_cs;
  logic en_cs;
  logic rst_sync_cs;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Synchronizer
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_cs (
      .i_rst(rst_cs),  // scan-controlled
      .i_clk(i_clk_ref),
      .o_rst(rst_sync_cs)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Synchronizer
  // ----------------------------------------------------------------------
  serdes_clk_gen clk_div (
      .i_clk_ref(i_clk_ref),
      .i_rst(rst_sync_cs),
      .i_en(en_cs),  // scan-controlled
      .o_clk({o_clk_dig, UNUSED_clk_dig_mul_2})
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan
  // ----------------------------------------------------------------------
  // scan[]: rst_cs
  // scan[]: en_cs

  logic sclkp;
  logic sclkn;
  logic senable;
  logic supdate;
  logic sreset;
  logic sin;
  logic sout;
  logic [`FeClkspineScanChainLength-1:0] scan_bits_wr;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_fe_clkspine_scan fe_clkspine_scan (
      .SClkP(sclkp),
      .SClkN(sclkn),
      .SReset(sreset),
      .SEnable(senable),
      .SUpdate(supdate),
      .SIn(sin),
      .SOut(sout),
      .ScanBitsRd(),
      .ScanBitsWr(scan_bits_wr)
  );

  assign rst_cs = scan_bits_wr[`FeClkspineRst];
  assign en_cs  = scan_bits_wr[`FeClkspineEn];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

