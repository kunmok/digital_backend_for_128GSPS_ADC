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

module dsp_be_bert #(
    parameter int PRLL_RANK = 64
) (

    input var logic i_clk,
    input var logic i_rst,

    input var logic [PRLL_RANK-1:0] i_drx,

    input var logic [`TOT_PGEN_CFG_LENGTH-1:0] i_cfg_pgen,

    input var logic [`BERT_WAY_WIDTH-1:0] i_cfg_snap_en,
    input var logic [`BERT_WAY_WIDTH-1:0] i_cfg_mode_ber,
    input var logic [`BERT_WAY_WIDTH-1:0] i_cfg_ber_count_en,
    input var logic [`SHUTOFF_SEL_WIDTH-1:0] i_cfg_ber_shutoff_sel,
    input var logic i_cfg_ber_in_inv,

    // from BERT with PRBS7
    output logic [`BERT_WAY_WIDTH-1:0] o_prbs_seed_good_prbs7,
    output logic [`TOT_SNAP_LENGTH-1:0] o_snap_out_prbs7,
    output logic o_ber_shutoff_prbs7,
    output logic [`TOT_BER_COUNT_WIDTH-1:0] o_ber_count_prbs7,
    output logic [`BER_COUNT_WIDTH-1:0] o_bit_count_prbs7,

    // from BERT with PRBS15
    output logic [`BERT_WAY_WIDTH-1:0] o_prbs_seed_good_prbs15,
    output logic [`TOT_SNAP_LENGTH-1:0] o_snap_out_prbs15,
    output logic o_ber_shutoff_prbs15,
    output logic [`TOT_BER_COUNT_WIDTH-1:0] o_ber_count_prbs15,
    output logic [`BER_COUNT_WIDTH-1:0] o_bit_count_prbs15,

    // from BERT with PRBS31
    output logic [`BERT_WAY_WIDTH-1:0] o_prbs_seed_good_prbs31,
    output logic [`TOT_SNAP_LENGTH-1:0] o_snap_out_prbs31,
    output logic o_ber_shutoff_prbs31,
    output logic [`TOT_BER_COUNT_WIDTH-1:0] o_ber_count_prbs31,
    output logic [`BER_COUNT_WIDTH-1:0] o_bit_count_prbs31
);

  // ----------------------------------------------------------------------
  // Parameters
  // ----------------------------------------------------------------------
  // Define these at "params/dsp_be.svh" for centralized management
  // Note that each should be precisely matching with the corresponding
  // rx_bert local parameters since they dictate the width of the connecting
  // signals
  // TODO: double check the consistency during synthesis, since it will manifest
  // as corresponding width mismatch

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

  // Constants
  localparam int PRBS7_LENGTH = 7;  // just to make var alphabetic
  localparam int PRBS15_LENGTH = 15;  // just to make var alphabetic
  localparam int PRBS31_LENGTH = 31;  // just to make var alphabetic
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic rst_sync_bert_prbs7;
  logic rst_sync_bert_prbs15;
  logic rst_sync_bert_prbs31;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_bert_prbs7 (
      .i_rst(i_rst),  // scan-controlled
      .i_clk(i_clk),
      .o_rst(rst_sync_bert_prbs7)
  );

  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_bert_prbs15 (
      .i_rst(i_rst),  // scan-controlled
      .i_clk(i_clk),
      .o_rst(rst_sync_bert_prbs15)
  );

  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_bert_prbs31 (
      .i_rst(i_rst),  // scan-controlled
      .i_clk(i_clk),
      .o_rst(rst_sync_bert_prbs31)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // BERT Instantiation
  // ----------------------------------------------------------------------
  rx_bert #(
      .DataWidth(PRLL_RANK),
      .Ways(BERT_WAY_WIDTH),
      .PRBSLength(PRBS7_LENGTH),
      .SnapLength(SNAP_LENGTH),
      .PattLength(PATT_LENGTH),
      .BERCountWidth(BER_COUNT_WIDTH)
  ) rx_bert_prbs7 (
      .clk  (i_clk),
      .reset(rst_sync_bert_prbs7),

      .data_in(i_drx),

      .pgen_cfg(i_cfg_pgen),
      .snap_en(i_cfg_snap_en),
      .ber_mode(i_cfg_mode_ber),
      .ber_count_enable(i_cfg_ber_count_en),
      .ber_shutoff_sel(i_cfg_ber_shutoff_sel),
      .ber_invert_data(i_cfg_ber_in_inv),

      .prbs_seed_good(o_prbs_seed_good_prbs7),

      .snap_out(o_snap_out_prbs7),

      .ber_shutoff(o_ber_shutoff_prbs7),
      .ber_count  (o_ber_count_prbs7),
      .bit_count  (o_bit_count_prbs7)
  );

  rx_bert #(
      .DataWidth(PRLL_RANK),
      .Ways(BERT_WAY_WIDTH),
      .PRBSLength(PRBS15_LENGTH),
      .SnapLength(SNAP_LENGTH),
      .PattLength(PATT_LENGTH),
      .BERCountWidth(BER_COUNT_WIDTH)
  ) rx_bert_prbs15 (
      .clk  (i_clk),
      .reset(rst_sync_bert_prbs15),

      .data_in(i_drx),

      .pgen_cfg(i_cfg_pgen),
      .snap_en(i_cfg_snap_en),
      .ber_mode(i_cfg_mode_ber),
      .ber_count_enable(i_cfg_ber_count_en),
      .ber_shutoff_sel(i_cfg_ber_shutoff_sel),
      .ber_invert_data(i_cfg_ber_in_inv),

      .prbs_seed_good(o_prbs_seed_good_prbs15),

      .snap_out(o_snap_out_prbs15),

      .ber_shutoff(o_ber_shutoff_prbs15),
      .ber_count  (o_ber_count_prbs15),
      .bit_count  (o_bit_count_prbs15)
  );

  rx_bert #(
      .DataWidth(PRLL_RANK),
      .Ways(BERT_WAY_WIDTH),
      .PRBSLength(PRBS31_LENGTH),
      .SnapLength(SNAP_LENGTH),
      .PattLength(PATT_LENGTH),
      .BERCountWidth(BER_COUNT_WIDTH)
  ) rx_bert_prbs31 (
      .clk  (i_clk),
      .reset(rst_sync_bert_prbs31),

      .data_in(i_drx),

      .pgen_cfg(i_cfg_pgen),
      .snap_en(i_cfg_snap_en),
      .ber_mode(i_cfg_mode_ber),
      .ber_count_enable(i_cfg_ber_count_en),
      .ber_shutoff_sel(i_cfg_ber_shutoff_sel),
      .ber_invert_data(i_cfg_ber_in_inv),

      .prbs_seed_good(o_prbs_seed_good_prbs31),

      .snap_out(o_snap_out_prbs31),

      .ber_shutoff(o_ber_shutoff_prbs31),
      .ber_count  (o_ber_count_prbs31),
      .bit_count  (o_bit_count_prbs31)
  );
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire

