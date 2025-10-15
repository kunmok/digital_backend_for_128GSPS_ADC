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

module dsp_mem_ctrl #(
    parameter int NUM_BANKS = 16,
    parameter int FRAME_LENGTH = 64
) (

    // input signals
    scan_if.recv i_scan,
    scan_if.send o_scan,

    output var logic o_rst_retime,
    output var logic [NUM_BANKS-1:0] o_wrst_bank,
    output var logic [NUM_BANKS-1:0] o_rrst_bank,
    output var logic o_rrst_fs,

    output var logic o_en_retime,
    output var logic [NUM_BANKS-1:0] o_en_bank,
    output var logic o_en_fs,

    output var logic o_cfg_mode_rupdate,
    output var logic o_cfg_mode_wshift,
    output var logic o_cfg_mode_rshift,
    output var logic o_cfg_fs_mode_load,
    output var logic [FRAME_LENGTH-1:0] o_cfg_fs_syncword

);

  // ----------------------------------------------------------------------
  // Scan
  // ----------------------------------------------------------------------
  // scan[]:

  logic sclkp;
  logic sclkn;
  logic senable;
  logic supdate;
  logic sreset;
  logic sin;
  logic sout;
  logic [`MemScanChainLength-1:0] scan_bits_wr;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_mem_scan mem_scan (
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

  assign o_rst_retime = scan_bits_wr[`MemRetimeRst];
  assign o_wrst_bank = scan_bits_wr[`MemBankWRst];
  assign o_rrst_bank = scan_bits_wr[`MemBankRRst];
  assign o_rrst_fs = scan_bits_wr[`MemFsRst];

  assign o_en_retime = scan_bits_wr[`MemRetimeEn];
  assign o_en_bank = scan_bits_wr[`MemBankEn];
  assign o_en_fs = scan_bits_wr[`MemFsEn];

  assign o_cfg_mode_rupdate = scan_bits_wr[`MemCfgModeRUpdate];
  assign o_cfg_mode_wshift = scan_bits_wr[`MemCfgModeWShift];
  assign o_cfg_mode_rshift = scan_bits_wr[`MemCfgModeRShift];

  assign o_cfg_fs_mode_load = scan_bits_wr[`MemCfgFsModeLoad];
  assign o_cfg_fs_syncword = scan_bits_wr[`MemCfgFsSyncWord];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

