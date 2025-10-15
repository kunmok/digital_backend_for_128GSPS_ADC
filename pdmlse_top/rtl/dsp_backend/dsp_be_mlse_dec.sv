//==============================================================================
// Author: Wahid Rahman, Kunmo Kim and Sunjin Choi
// Description: 
// Signals:
// Note: 
// This module contains pattern decoder logic with pipeline registers for
// physical distribution of the signals. Both arithmetic struct and flag
// struct are forwarded/computed from the previous pattern filter stage, which
// is then fed to each unit decoder for the bit-level decision.
// ----------------------------------------------------------------------
// Naive pipelining strategy incorporates "replica" pipeline registers for
// physical distribution, in particular, a replica of delayed sample takes an
// early bifurcation if it needs to be used in the t-unit decoder located far
// from the (t-1)-unit decoder. Thus, the delayed sample is replicated and
// forked off early in the pipeline.
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_be_mlse_dec #(
    parameter int PRLL_RANK = 64,
    parameter int PRE_PIPELINE_DEPTH = 3,
    parameter int PST_PIPELINE_DEPTH = 1
) (
    input var logic i_clk,
    input var logic [PRLL_RANK-1:0] i_rst,
    input var logic [PRLL_RANK-1:0] i_en,

    input var logic i_cfg_eq_out_inv,
    input var logic i_cfg_eq_out_endian,

    input var ari_unit_t i_ari[PRLL_RANK],
    input var flag_unit_t i_flag[PRLL_RANK],
    output logic [PRLL_RANK-1:0] o_drx
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // Synchronous reset signals
  logic [PRLL_RANK-1:0] rst_sync;

  // Forwarded arithmetic and flag structs
  // delayed ari, ari_dly[62] ad ari_dly[63] are used
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  // note that these are pre-stage pipeline registers
  ari_unit_t ari_pipe_pre[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  ari_unit_t ari_pipe_pre_dly[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  ari_unit_t ari[PRLL_RANK];
  ari_unit_t ari_dly[PRLL_RANK];

  // delayed flag, flag_dly[62] ad flag_dly[63] are used
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  // note that flag and ari should be delay *matched*
  flag_unit_t flag_pipe_pre[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  flag_unit_t flag_pipe_pre_dly[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  flag_unit_t flag[PRLL_RANK];
  flag_unit_t flag_dly[PRLL_RANK];

  // Assemble delayed samples for each unit decoder
  flag_unit_t [2:0] flag_d0m1m2[PRLL_RANK];
  ari_unit_t ari_dm2[PRLL_RANK];

  // Output of each unit decoder
  logic [PRLL_RANK-1:0] drx_d0;
  // Post-stage pipeline registers
  logic [PRLL_RANK-1:0] drx_pipe_pst[PST_PIPELINE_DEPTH+1];
  // Temp variable for last-stage pipeline to the final output
  logic [PRLL_RANK-1:0] drx_pipe_last;
  logic [PRLL_RANK-1:0] drx_chicken;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_rst_sync
      reset_sync #(
          .ActiveLow(0),
          .SyncRegWidth(2)
      ) reset_sync_alu (
          .i_rst(i_rst[k]),    // scan-controlled
          .i_clk(i_clk),
          .o_rst(rst_sync[k])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Forward Arithmetic Struct
  // ----------------------------------------------------------------------
  assign ari_pipe_pre[0] = i_ari;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_ari_pipe_pre_in_en
      always_ff @(posedge i_clk or posedge rst_sync[k]) begin
        if (rst_sync[k]) begin
          ari_pipe_pre_dly[0][k] <= '{default: '0};
        end
        else if (i_en[k]) begin
          ari_pipe_pre_dly[0][k] <= i_ari[k];
        end
      end
    end  // for k (rank)
  endgenerate

  // Optimization; only forward 63rd and 62th data
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_ari_pipe_pre_en
      for (genvar i = 1; i < PRE_PIPELINE_DEPTH + 1; i = i + 1) begin : g_ari_pipe_pre
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            ari_pipe_pre[i][k] <= '{default: '0};
            ari_pipe_pre_dly[i][k] <= '{default: '0};
          end
          else if (i_en[k]) begin
            ari_pipe_pre[i][k] <= ari_pipe_pre[i-1][k];

            /*ari_pipe_pre_dly[i][PRLL_RANK-1] <= ari_pipe_pre_dly[i-1][PRLL_RANK-1];
             *ari_pipe_pre_dly[i][PRLL_RANK-2] <= ari_pipe_pre_dly[i-1][PRLL_RANK-2];
             *ari_pipe_pre_dly[i][0:PRLL_RANK-3] <= '{default: '0};*/

            if (k == PRLL_RANK - 1 || k == PRLL_RANK - 2) begin
              ari_pipe_pre_dly[i][k] <= ari_pipe_pre_dly[i-1][k];
            end
            else begin
              ari_pipe_pre_dly[i][k] <= '{default: '0};
            end
          end
        end
      end  // for i (pipe)
    end  // for k (rank)
  endgenerate

  assign ari = ari_pipe_pre[PRE_PIPELINE_DEPTH];
  assign ari_dly = ari_pipe_pre_dly[PRE_PIPELINE_DEPTH];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Forward Flag Struct
  // ----------------------------------------------------------------------
  assign flag_pipe_pre[0] = i_flag;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_flag_pipe_pre_in_en
      always_ff @(posedge i_clk or posedge rst_sync[k]) begin
        if (rst_sync[k]) begin
          flag_pipe_pre_dly[0][k] <= '{default: '0};
        end
        else if (i_en[k]) begin
          flag_pipe_pre_dly[0][k] <= i_flag[k];
        end
      end
    end  // for k (rank)
  endgenerate

  // Optimization; only forward 63rd and 62th data
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_flag_pipe_pre_en
      for (genvar i = 1; i < PRE_PIPELINE_DEPTH + 1; i = i + 1) begin : g_flag_pipe_pre
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            flag_pipe_pre[i][k] <= '{default: '0};
            flag_pipe_pre_dly[i][k] <= '{default: '0};
          end
          else if (i_en[k]) begin
            flag_pipe_pre[i][k] <= flag_pipe_pre[i-1][k];

            /*flag_pipe_pre_dly[i][PRLL_RANK-1] <= flag_pipe_pre_dly[i-1][PRLL_RANK-1];
             *flag_pipe_pre_dly[i][PRLL_RANK-2] <= flag_pipe_pre_dly[i-1][PRLL_RANK-2];
             *flag_pipe_pre_dly[i][0:PRLL_RANK-3] <= '{default: '0};*/

            if (k == PRLL_RANK - 1 || k == PRLL_RANK - 2) begin
              flag_pipe_pre_dly[i][k] <= flag_pipe_pre_dly[i-1][k];
            end
            else begin
              flag_pipe_pre_dly[i][k] <= '{default: '0};
            end
          end
        end
      end  // for i (pipe)
    end  // for k (rank)
  endgenerate

  assign flag = flag_pipe_pre[PRE_PIPELINE_DEPTH];
  assign flag_dly = flag_pipe_pre_dly[PRE_PIPELINE_DEPTH];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Instantiate Decoder Units and Assemble Signals
  // ----------------------------------------------------------------------
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_dec_unit
      if (k == 0) begin : g_assym_k_0
        assign flag_d0m1m2[k] = {flag[k], flag_dly[PRLL_RANK-1], flag_dly[PRLL_RANK-2]};
        assign ari_dm2[k] = ari_dly[PRLL_RANK-2];
      end
      else if (k == 1) begin : g_assym_k_1
        assign flag_d0m1m2[k] = {flag[k], flag[k-1], flag_dly[PRLL_RANK-1]};
        assign ari_dm2[k] = ari_dly[PRLL_RANK-1];
      end
      else begin : g_assym_k_2_63
        assign flag_d0m1m2[k] = {flag[k], flag[k-1], flag[k-2]};
        assign ari_dm2[k] = ari[k-2];
      end

      dsp_be_mlse_dec_unit dsp_be_mlse_dec_unit (
          .i_flag_unit_d0m1m2(flag_d0m1m2[k]),
          .i_ari_unit_dm2(ari_dm2[k]),
          .o_drx_unit_d0(drx_d0[k])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Post-Pipeline Registers
  // ----------------------------------------------------------------------
  assign drx_pipe_pst[0] = drx_d0;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_drx_pipe_pst_en
      for (genvar i = 1; i < PST_PIPELINE_DEPTH + 1; i = i + 1) begin : g_drx_pipe_pst
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            drx_pipe_pst[i][k] <= '0;
          end
          else if (i_en[k]) begin
            drx_pipe_pst[i][k] <= drx_pipe_pst[i-1][k];
          end
        end
      end  // for i (pipe)
    end  // for k (rank)
  endgenerate

  /*assign o_drx = drx_pipe_pst[PST_PIPELINE_DEPTH];*/
  assign drx_pipe_last = drx_pipe_pst[PST_PIPELINE_DEPTH];

  // Insert chicken bit to invert output
  assign drx_chicken   = i_cfg_eq_out_inv ? ~drx_pipe_last : drx_pipe_last;

  // Insert another chicken bit to switch endianness
  // By default, 0 is little-endian (LSB is from earlier time step than MSB)
  // If set to 1, then it is big-endian (MSB is from earlier time step than LSB)
  /*assign o_drx = i_cfg_eq_out_endian ? {<<{drx_chicken}} : drx_chicken;*/
  always_comb begin
    if (i_cfg_eq_out_endian) begin
      o_drx = {<<{drx_chicken}};  // Big-endian or custom order
    end
    else begin
      o_drx = drx_chicken;  // Little-endian (or as-is)
    end
  end
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire

