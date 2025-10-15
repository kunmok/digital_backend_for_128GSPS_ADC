//==============================================================================
// Author: Wahid Rahman, Kunmo Kim and Sunjin Choi
// Description: 
// Signals:
// Note: 
// This module contains pattern filter logic with pipeline registers for
// physical distribution of the signals. Arithmetic struct is forwarded dto
// each unit decoder for the pattern flag generation.
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

module dsp_be_patt_filt #(
    parameter int PRLL_RANK = 64,
    parameter int PRE_PIPELINE_DEPTH = 3,
    parameter int PST_PIPELINE_DEPTH = 2
) (
    input var logic i_clk,
    input var logic [PRLL_RANK-1:0] i_rst,
    input var logic [PRLL_RANK-1:0] i_en,

    input var logic i_cfg_eq_p1a_en,
    input var logic i_cfg_eq_p1b_en,
    input var logic i_cfg_eq_p2_en,
    input var logic i_cfg_eq_p3o_en,
    input var logic i_cfg_eq_p3a_en,
    input var logic i_cfg_eq_p3b_en,
    input var logic i_cfg_eq_p4p_en,
    input var logic i_cfg_eq_p4m_en,

    input var ari_unit_t i_ari[PRLL_RANK],

    output ari_unit_t  o_ari [PRLL_RANK],
    output flag_unit_t o_flag[PRLL_RANK]
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
  // Used for pre-stage pipelining
  ari_unit_t ari_pipe_pre[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  ari_unit_t ari_pipe_pre_dly[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  ari_unit_t ari[PRLL_RANK];
  ari_unit_t ari_dly[PRLL_RANK];

  // Assemble delayed samples for each unit pattern filter
  ari_unit_t [2:0] ari_d0m1m2[PRLL_RANK];

  // Output of each unit pattern filter
  flag_unit_t flag_d0[PRLL_RANK];

  // Post-stage pipelining
  flag_unit_t flag_pipe_pst[PST_PIPELINE_DEPTH+1][PRLL_RANK];
  ari_unit_t ari_pipe_pst[PST_PIPELINE_DEPTH+1][PRLL_RANK];
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
  // Instantiate Pattern Filter Units and Assemble Signals
  // ----------------------------------------------------------------------
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_patt_filt_unit
      if (k == 0) begin : g_assym_k_0
        assign ari_d0m1m2[k] = {ari[0], ari_dly[PRLL_RANK-1], ari_dly[PRLL_RANK-2]};
      end
      else if (k == 1) begin : g_assym_k_1
        assign ari_d0m1m2[k] = {ari[1], ari[0], ari_dly[PRLL_RANK-1]};
      end
      else begin : g_assym_k_2_63
        assign ari_d0m1m2[k] = {ari[k], ari[k-1], ari[k-2]};
      end

      dsp_be_patt_filt_unit dsp_be_patt_filt_unit (
          /*.i_clk(i_clk),
           *.i_rst(i_rst),*/
          .i_ari_unit_d0m1m2(ari_d0m1m2[k]),

          .i_cfg_eq_p1a_en(i_cfg_eq_p1a_en),
          .i_cfg_eq_p1b_en(i_cfg_eq_p1b_en),
          .i_cfg_eq_p2_en (i_cfg_eq_p2_en),
          .i_cfg_eq_p3o_en(i_cfg_eq_p3o_en),
          .i_cfg_eq_p3a_en(i_cfg_eq_p3a_en),
          .i_cfg_eq_p3b_en(i_cfg_eq_p3b_en),
          .i_cfg_eq_p4p_en(i_cfg_eq_p4p_en),
          .i_cfg_eq_p4m_en(i_cfg_eq_p4m_en),

          .o_flag_unit_d0(flag_d0[k])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  //// ----------------------------------------------------------------------
  //// Forward Outputs
  //// ----------------------------------------------------------------------
  //assign o_ari = ari;
  //assign o_flag = flag_d0;
  //// ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Post-Pipeline Registers
  // ----------------------------------------------------------------------
  // Arithmetic pipeline
  assign ari_pipe_pst[0] = ari;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_ari_pipe_pst_en
      for (genvar i = 1; i < PST_PIPELINE_DEPTH + 1; i = i + 1) begin : g_ari_pipe_pst
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            ari_pipe_pst[i][k] <= '{default: '0};
          end
          else if (i_en[k]) begin
            ari_pipe_pst[i][k] <= ari_pipe_pst[i-1][k];
          end
        end
      end  // for i (rank)
    end  // for k (pipe)
  endgenerate

  assign o_ari = ari_pipe_pst[PST_PIPELINE_DEPTH];

  // Flag pipeline
  assign flag_pipe_pst[0] = flag_d0;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_flag_pipe_pst_en
      for (genvar i = 1; i < PST_PIPELINE_DEPTH + 1; i = i + 1) begin : g_flag_pipe_pst
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            flag_pipe_pst[i][k] <= '{default: '0};
          end
          else if (i_en[k]) begin
            flag_pipe_pst[i][k] <= flag_pipe_pst[i-1][k];
          end
        end
      end  // for i (rank)
    end  // for k (pipe)
  endgenerate

  assign o_flag = flag_pipe_pst[PST_PIPELINE_DEPTH];
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire
