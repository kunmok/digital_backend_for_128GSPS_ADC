//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note: *ILM Block*
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_be (

    // input signals
    /*input var logic [`DES_OUT_WIDTH-1:0][`ADC_WIDTH-1:0] o_dat_lda_fe[`LANE_WIDTH],*/
    input var logic [`PRLL_RANK-1:0][`ADC_WIDTH-1:0] i_dat_be,
    input var logic i_clk_dig_be,

    output var logic [`PRLL_RANK-1:0] o_drx,
    //// Embedded Two-Phase Scan
    //scan_if.recv i_scan,
    //scan_if.send o_scan

    // Unwrapped scan (to avoid any SV port issues)
    input var logic i_sdata,
    input var logic i_sclkp,
    input var logic i_sclkn,
    input var logic i_senable,
    input var logic i_supdate,
    input var logic i_sreset,

    output var logic o_sdata,
    output var logic o_sclkp,
    output var logic o_sclkn,
    output var logic o_senable,
    output var logic o_supdate,
    output var logic o_sreset

);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  // EQ Parameters
  localparam int PRLL_RANK = `PRLL_RANK;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int ALU_PRE_PP_DEPTH = `ALU_PRE_PP_DEPTH;
  localparam int ALU_PST_PP_DEPTH = `ALU_PST_PP_DEPTH;
  localparam int FILT_PRE_PP_DEPTH = `FILT_PRE_PP_DEPTH;
  localparam int FILT_PST_PP_DEPTH = `FILT_PST_PP_DEPTH;
  localparam int DEC_PRE_PP_DEPTH = `DEC_PRE_PP_DEPTH;
  localparam int DEC_PST_PP_DEPTH = `DEC_PST_PP_DEPTH;

  // BERT Parameters
  // Define these at "params/dsp_be.svh" for centralized management
  // Note that each should be precisely matching with the corresponding
  // rx_bert local parameters since they dictate the width of the connecting
  // signals
  // SNAP_LENGTH == SnapLength in rx_bert (32)
  localparam int SNAP_LENGTH = `SNAP_LENGTH;

  // PATT_LENGTH == PattLength in rx_bert (32)
  localparam int PATT_LENGTH = `PATT_LENGTH;

  // BERT_WAY_WIDTH == Ways in rx_bert (16)
  localparam int BERT_WAY_WIDTH = `BERT_WAY_WIDTH;

  // TOT_SNAP_LENGTH == TotSnapLength in rx_bert
  // TotSnapLength = Ways * SnapLength = 16 * 32 = 512
  localparam int TOT_SNAP_LENGTH = `TOT_SNAP_LENGTH;

  // TOT_PGEN_CFG_LENGTH == TotPgenCfgLength in rx_bert
  // TotPgenCfgLength = Ways * PgenCfgLength = 16 * (4 + SeedLength)
  // = 16 * (4 + max(PattLength, PrbsLength)) = 16 * (4 + 32)
  // = 16 * 36 = 576
  localparam int TOT_PGEN_CFG_LENGTH = `TOT_PGEN_CFG_LENGTH;

  // SHUTOFF_SEL_WIDTH == ShutoffSelWidth in rx_bert (4)
  localparam int SHUTOFF_SEL_WIDTH = `SHUTOFF_SEL_WIDTH;

  // BER_COUNT_WIDTH == BerCountWidth in rx_bert (41)
  localparam int BER_COUNT_WIDTH = `BER_COUNT_WIDTH;

  // TOT_BER_COUNT_WIDTH == TotBerCountWidth in rx_bert which is 16 * 41 = 656
  localparam int TOT_BER_COUNT_WIDTH = `TOT_BER_COUNT_WIDTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // EQ -> BERT
  logic [PRLL_RANK-1:0] drx;

  // EQ Control
  // Scan-controlled reset
  logic [PRLL_RANK-1:0] rst_alu;
  logic [PRLL_RANK-1:0] rst_filt;
  logic [PRLL_RANK-1:0] rst_dec;

  // Scan-controlled enable
  logic [PRLL_RANK-1:0] en_alu;
  logic [PRLL_RANK-1:0] en_filt;
  logic [PRLL_RANK-1:0] en_dec;

  // Chicken bits
  logic cfg_eq_in_inv;
  logic cfg_eq_out_inv;
  logic cfg_eq_out_endian;

  // EQ Configs
  logic cfg_eq_p1a_en;
  logic cfg_eq_p1b_en;
  logic cfg_eq_p2_en;
  logic cfg_eq_p3o_en;
  logic cfg_eq_p3a_en;
  logic cfg_eq_p3b_en;
  logic cfg_eq_p4p_en;
  logic cfg_eq_p4m_en;

  // EQ Coefficients
  logic [8*PRLL_RANK-1:0] cfg_eq_hm1;  // fxp6p2 X PRLL_RANK
  logic [8*PRLL_RANK-1:0] cfg_eq_hp1;  // fxp6p2 X PRLL_RANK
  logic [8*PRLL_RANK-1:0] cfg_eq_hx;  // fxp6p2 X PRLL_RANK

  // BERT Control & Readout
  // Scan-controlled reset
  logic rst_bert;

  // Pattern/PRBS-Generator Configs
  // See pattern_generator_wi_cfg_wrapper for details
  logic [`TOT_PGEN_CFG_LENGTH-1:0] cfg_pgen;

  // Snapshot Enable
  logic [`BERT_WAY_WIDTH-1:0] cfg_snap_en;
  // BERT mode
  logic [`BERT_WAY_WIDTH-1:0] cfg_mode_ber;
  // BERT count enable
  logic [`BERT_WAY_WIDTH-1:0] cfg_ber_count_en;
  // BERT shutoff select (set to 0 for most)
  logic [`SHUTOFF_SEL_WIDTH-1:0] cfg_ber_shutoff_sel;
  // BERT chicken bits
  logic cfg_ber_in_inv;

  // from BERT with PRBS7
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs7;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs7;
  // BERT shutoff flag
  logic ber_shutoff_prbs7;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs7;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs7;

  // from BERT with PRBS15
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs15;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs15;
  // BERT shutoff flag
  logic ber_shutoff_prbs15;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs15;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs15;

  // from BERT with PRBS31
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs31;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs31;
  // BERT shutoff flag
  logic ber_shutoff_prbs31;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs31;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs31;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan Signals
  // ----------------------------------------------------------------------
  scan_if i_scan ();
  scan_if o_scan ();

  // wrap scan
  assign i_scan.sdata = i_sdata;
  assign i_scan.sctrl = {i_sclkp, i_sclkn, i_senable, i_supdate, i_sreset};
  assign o_sdata = o_scan.sdata;
  assign {o_sclkp, o_sclkn, o_senable, o_supdate, o_sreset} = o_scan.sctrl;
  /*assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Equalizer
  // ----------------------------------------------------------------------
  dsp_be_eq #(
      .PRLL_RANK(PRLL_RANK),
      .ALU_PRE_PP_DEPTH(ALU_PRE_PP_DEPTH),
      .ALU_PST_PP_DEPTH(ALU_PST_PP_DEPTH),
      .FILT_PRE_PP_DEPTH(FILT_PRE_PP_DEPTH),
      .FILT_PST_PP_DEPTH(FILT_PST_PP_DEPTH),
      .DEC_PRE_PP_DEPTH(DEC_PRE_PP_DEPTH),
      .DEC_PST_PP_DEPTH(DEC_PST_PP_DEPTH)
  ) be_eq (
      .i_clk(i_clk_dig_be),

      .i_rst_alu (rst_alu),
      .i_rst_filt(rst_filt),
      .i_rst_dec (rst_dec),

      .i_en_alu (en_alu),
      .i_en_filt(en_filt),
      .i_en_dec (en_dec),

      .i_cfg_eq_in_inv(cfg_eq_in_inv),
      .i_cfg_eq_out_inv(cfg_eq_out_inv),
      .i_cfg_eq_out_endian(cfg_eq_out_endian),

      .i_cfg_eq_p1a_en(cfg_eq_p1a_en),
      .i_cfg_eq_p1b_en(cfg_eq_p1b_en),
      .i_cfg_eq_p2_en (cfg_eq_p2_en),
      .i_cfg_eq_p3o_en(cfg_eq_p3o_en),
      .i_cfg_eq_p3a_en(cfg_eq_p3a_en),
      .i_cfg_eq_p3b_en(cfg_eq_p3b_en),
      .i_cfg_eq_p4p_en(cfg_eq_p4p_en),
      .i_cfg_eq_p4m_en(cfg_eq_p4m_en),

      .i_cfg_eq_hm1(cfg_eq_hm1),  // fxp6p2 X PRLL_RANK
      .i_cfg_eq_hp1(cfg_eq_hp1),  // fxp6p2 X PRLL_RANK
      .i_cfg_eq_hx (cfg_eq_hx),   // fxp6p2 X PRLL_RANK

      .i_dat_be(i_dat_be),  // PRLL_RANK X fxp6p0
      .o_drx(drx)
  );

  assign o_drx = drx;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Equalizer
  // ----------------------------------------------------------------------
  dsp_be_bert #(
      .PRLL_RANK(PRLL_RANK)
  ) be_bert (
      .i_clk(i_clk_dig_be),
      .i_rst(rst_bert),

      .i_drx(drx),

      .i_cfg_pgen(cfg_pgen),

      .i_cfg_snap_en(cfg_snap_en),
      .i_cfg_mode_ber(cfg_mode_ber),
      .i_cfg_ber_count_en(cfg_ber_count_en),
      .i_cfg_ber_shutoff_sel(cfg_ber_shutoff_sel),
      .i_cfg_ber_in_inv(cfg_ber_in_inv),

      // from BERT with PRBS7
      .o_prbs_seed_good_prbs7(prbs_seed_good_prbs7),
      .o_snap_out_prbs7(snap_out_prbs7),
      .o_ber_shutoff_prbs7(ber_shutoff_prbs7),
      .o_ber_count_prbs7(ber_count_prbs7),
      .o_bit_count_prbs7(bit_count_prbs7),

      // from BERT with PRBS15
      .o_prbs_seed_good_prbs15(prbs_seed_good_prbs15),
      .o_snap_out_prbs15(snap_out_prbs15),
      .o_ber_shutoff_prbs15(ber_shutoff_prbs15),
      .o_ber_count_prbs15(ber_count_prbs15),
      .o_bit_count_prbs15(bit_count_prbs15),

      // from BERT with PRBS31
      .o_prbs_seed_good_prbs31(prbs_seed_good_prbs31),
      .o_snap_out_prbs31(snap_out_prbs31),
      .o_ber_shutoff_prbs31(ber_shutoff_prbs31),
      .o_ber_count_prbs31(ber_count_prbs31),
      .o_bit_count_prbs31(bit_count_prbs31)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Backend EQ & BERT Control
  // ----------------------------------------------------------------------
  dsp_be_ctrl #(
      .PRLL_RANK(PRLL_RANK)
  ) be_ctrl (
      .i_scan(i_scan),
      .o_scan(o_scan),

      // EQ Control
      .o_rst_alu (rst_alu),
      .o_rst_filt(rst_filt),
      .o_rst_dec (rst_dec),

      .o_en_alu (en_alu),
      .o_en_filt(en_filt),
      .o_en_dec (en_dec),

      .o_cfg_eq_in_inv(cfg_eq_in_inv),
      .o_cfg_eq_out_inv(cfg_eq_out_inv),
      .o_cfg_eq_out_endian(cfg_eq_out_endian),

      .o_cfg_eq_p1a_en(cfg_eq_p1a_en),
      .o_cfg_eq_p1b_en(cfg_eq_p1b_en),
      .o_cfg_eq_p2_en (cfg_eq_p2_en),
      .o_cfg_eq_p3o_en(cfg_eq_p3o_en),
      .o_cfg_eq_p3a_en(cfg_eq_p3a_en),
      .o_cfg_eq_p3b_en(cfg_eq_p3b_en),
      .o_cfg_eq_p4p_en(cfg_eq_p4p_en),
      .o_cfg_eq_p4m_en(cfg_eq_p4m_en),

      .o_cfg_eq_hm1(cfg_eq_hm1),  // fxp6p2 X PRLL_RANK
      .o_cfg_eq_hp1(cfg_eq_hp1),  // fxp6p2 X PRLL_RANK
      .o_cfg_eq_hx (cfg_eq_hx),   // fxp6p2 X PRLL_RANK

      // BERT Control & Readout
      .o_rst_bert(rst_bert),

      .o_cfg_pgen(cfg_pgen),

      .o_cfg_snap_en(cfg_snap_en),
      .o_cfg_mode_ber(cfg_mode_ber),
      .o_cfg_ber_count_en(cfg_ber_count_en),
      .o_cfg_ber_shutoff_sel(cfg_ber_shutoff_sel),
      .o_cfg_ber_in_inv(cfg_ber_in_inv),

      // from BERT with PRBS7
      .i_prbs_seed_good_prbs7(prbs_seed_good_prbs7),
      .i_snap_out_prbs7(snap_out_prbs7),
      .i_ber_shutoff_prbs7(ber_shutoff_prbs7),
      .i_ber_count_prbs7(ber_count_prbs7),
      .i_bit_count_prbs7(bit_count_prbs7),

      // from BERT with PRBS15
      .i_prbs_seed_good_prbs15(prbs_seed_good_prbs15),
      .i_snap_out_prbs15(snap_out_prbs15),
      .i_ber_shutoff_prbs15(ber_shutoff_prbs15),
      .i_ber_count_prbs15(ber_count_prbs15),
      .i_bit_count_prbs15(bit_count_prbs15),

      // from BERT with PRBS31
      .i_prbs_seed_good_prbs31(prbs_seed_good_prbs31),
      .i_snap_out_prbs31(snap_out_prbs31),
      .i_ber_shutoff_prbs31(ber_shutoff_prbs31),
      .i_ber_count_prbs31(ber_count_prbs31),
      .i_bit_count_prbs31(bit_count_prbs31)
  );
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

