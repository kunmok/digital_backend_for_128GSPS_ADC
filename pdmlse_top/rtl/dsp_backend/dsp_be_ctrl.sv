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

module dsp_be_ctrl #(
    parameter int PRLL_RANK = 64
) (

    // input signals
    scan_if.recv i_scan,
    scan_if.send o_scan,

    // EQ Control
    output logic [PRLL_RANK-1:0] o_rst_alu,
    output logic [PRLL_RANK-1:0] o_rst_filt,
    output logic [PRLL_RANK-1:0] o_rst_dec,

    output logic [PRLL_RANK-1:0] o_en_alu,
    output logic [PRLL_RANK-1:0] o_en_filt,
    output logic [PRLL_RANK-1:0] o_en_dec,

    output logic o_cfg_eq_in_inv,
    output logic o_cfg_eq_out_inv,
    output logic o_cfg_eq_out_endian,

    output logic o_cfg_eq_p1a_en,
    output logic o_cfg_eq_p1b_en,
    output logic o_cfg_eq_p2_en,
    output logic o_cfg_eq_p3o_en,
    output logic o_cfg_eq_p3a_en,
    output logic o_cfg_eq_p3b_en,
    output logic o_cfg_eq_p4p_en,
    output logic o_cfg_eq_p4m_en,

    output logic [8*PRLL_RANK-1:0] o_cfg_eq_hm1,  // fxp6p2 X PRLL_RANK
    output logic [8*PRLL_RANK-1:0] o_cfg_eq_hp1,  // fxp6p2 X PRLL_RANK
    output logic [8*PRLL_RANK-1:0] o_cfg_eq_hx,   // fxp6p2 X PRLL_RANK

    // BERT Control & Readout
    output logic o_rst_bert,

    output logic [`TOT_PGEN_CFG_LENGTH-1:0] o_cfg_pgen,

    output logic [`BERT_WAY_WIDTH-1:0] o_cfg_snap_en,
    output logic [`BERT_WAY_WIDTH-1:0] o_cfg_mode_ber,
    output logic [`BERT_WAY_WIDTH-1:0] o_cfg_ber_count_en,
    output logic [`SHUTOFF_SEL_WIDTH-1:0] o_cfg_ber_shutoff_sel,
    output logic o_cfg_ber_in_inv,

    // from BERT with PRBS7
    input var logic [`BERT_WAY_WIDTH-1:0] i_prbs_seed_good_prbs7,
    input var logic [`TOT_SNAP_LENGTH-1:0] i_snap_out_prbs7,
    input var logic i_ber_shutoff_prbs7,
    input var logic [`TOT_BER_COUNT_WIDTH-1:0] i_ber_count_prbs7,
    input var logic [`BER_COUNT_WIDTH-1:0] i_bit_count_prbs7,

    // from BERT with PRBS15
    input var logic [`BERT_WAY_WIDTH-1:0] i_prbs_seed_good_prbs15,
    input var logic [`TOT_SNAP_LENGTH-1:0] i_snap_out_prbs15,
    input var logic i_ber_shutoff_prbs15,
    input var logic [`TOT_BER_COUNT_WIDTH-1:0] i_ber_count_prbs15,
    input var logic [`BER_COUNT_WIDTH-1:0] i_bit_count_prbs15,

    // from BERT with PRBS31
    input var logic [`BERT_WAY_WIDTH-1:0] i_prbs_seed_good_prbs31,
    input var logic [`TOT_SNAP_LENGTH-1:0] i_snap_out_prbs31,
    input var logic i_ber_shutoff_prbs31,
    input var logic [`TOT_BER_COUNT_WIDTH-1:0] i_ber_count_prbs31,
    input var logic [`BER_COUNT_WIDTH-1:0] i_bit_count_prbs31
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
  logic [`BeScanChainLength-1:0] scan_bits_wr;
  logic [`BeScanChainLength-1:0] scan_bits_rd;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_be_scan be_scan (
      .SClkP(sclkp),
      .SClkN(sclkn),
      .SReset(sreset),
      .SEnable(senable),
      .SUpdate(supdate),
      .SIn(sin),
      .SOut(sout),
      .ScanBitsRd(scan_bits_rd),
      .ScanBitsWr(scan_bits_wr)
  );

  /*assign o_wen = scan_bits_wr[`MemWEn];
   *assign o_ren = scan_bits_wr[`MemREn];
   *assign o_rst_retime = scan_bits_wr[`MemRetimeRst];
   *assign o_en_retime = scan_bits_wr[`MemRetimeEn];
   *assign o_rst_bank = scan_bits_wr[`MemBankRst];
   *assign o_en_bank = scan_bits_wr[`MemBankEn];*/

  // RST/EN
  assign o_rst_alu = scan_bits_wr[`BeRstAlu];
  assign o_rst_filt = scan_bits_wr[`BeRstFilt];
  assign o_rst_dec = scan_bits_wr[`BeRstDec];

  assign o_en_alu = scan_bits_wr[`BeEnAlu];
  assign o_en_filt = scan_bits_wr[`BeEnFilt];
  assign o_en_dec = scan_bits_wr[`BeEnDec];

  // EQ
  assign o_cfg_eq_in_inv = scan_bits_wr[`BeCfgEqInInv];
  assign o_cfg_eq_out_inv = scan_bits_wr[`BeCfgEqOutInv];
  assign o_cfg_eq_out_endian = scan_bits_wr[`BeCfgEqOutEndian];

  // EQ PATT En
  assign o_cfg_eq_p1a_en = scan_bits_wr[`BeCfgEqP1aEn];
  assign o_cfg_eq_p1b_en = scan_bits_wr[`BeCfgEqP1bEn];
  assign o_cfg_eq_p2_en = scan_bits_wr[`BeCfgEqP2En];
  assign o_cfg_eq_p3o_en = scan_bits_wr[`BeCfgEqP3oEn];
  assign o_cfg_eq_p3a_en = scan_bits_wr[`BeCfgEqP3aEn];
  assign o_cfg_eq_p3b_en = scan_bits_wr[`BeCfgEqP3bEn];
  assign o_cfg_eq_p4p_en = scan_bits_wr[`BeCfgEqP4pEn];
  assign o_cfg_eq_p4m_en = scan_bits_wr[`BeCfgEqP4mEn];

  // EQ Coefficients
  assign o_cfg_eq_hm1 = scan_bits_wr[`BeCfgEqHm1];
  assign o_cfg_eq_hp1 = scan_bits_wr[`BeCfgEqHp1];
  assign o_cfg_eq_hx = scan_bits_wr[`BeCfgEqHx];

  // BERT Control
  assign o_rst_bert = scan_bits_wr[`BeRstBert];
  assign o_cfg_pgen = scan_bits_wr[`BeCfgPgen];
  assign o_cfg_snap_en = scan_bits_wr[`BeCfgSnapEn];
  assign o_cfg_mode_ber = scan_bits_wr[`BeCfgModeBer];
  assign o_cfg_ber_count_en = scan_bits_wr[`BeCfgBerCountEn];
  assign o_cfg_ber_shutoff_sel = scan_bits_wr[`BeCfgBerShutoffSel];
  assign o_cfg_ber_in_inv = scan_bits_wr[`BeCfgBerInInv];

  // BERT Readout PRBS7 Checker
  assign scan_bits_rd[`BePrbsSeedGoodPrbs7] = i_prbs_seed_good_prbs7;
  assign scan_bits_rd[`BeSnapOutPrbs7] = i_snap_out_prbs7;
  assign scan_bits_rd[`BeBerShutoffPrbs7] = i_ber_shutoff_prbs7;
  assign scan_bits_rd[`BeBerCountPrbs7] = i_ber_count_prbs7;
  assign scan_bits_rd[`BeBitCountPrbs7] = i_bit_count_prbs7;

  // BERT Readout PRBS15 Checker
  assign scan_bits_rd[`BePrbsSeedGoodPrbs15] = i_prbs_seed_good_prbs15;
  assign scan_bits_rd[`BeSnapOutPrbs15] = i_snap_out_prbs15;
  assign scan_bits_rd[`BeBerShutoffPrbs15] = i_ber_shutoff_prbs15;
  assign scan_bits_rd[`BeBerCountPrbs15] = i_ber_count_prbs15;
  assign scan_bits_rd[`BeBitCountPrbs15] = i_bit_count_prbs15;

  // BERT Readout PRBS31 Checker
  assign scan_bits_rd[`BePrbsSeedGoodPrbs31] = i_prbs_seed_good_prbs31;
  assign scan_bits_rd[`BeSnapOutPrbs31] = i_snap_out_prbs31;
  assign scan_bits_rd[`BeBerShutoffPrbs31] = i_ber_shutoff_prbs31;
  assign scan_bits_rd[`BeBerCountPrbs31] = i_ber_count_prbs31;
  assign scan_bits_rd[`BeBitCountPrbs31] = i_bit_count_prbs31;
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

