//==============================================================================
// Author: Wahid Rahman, Kunmo Kim and Sunjin Choi
// Description: 
// Signals:
// Note: Refer to mlse_comb_rtl.m
// This module contains the ALU for the MLSE combinatorial logic. It takes the
// data sample from the frontend and passes it to the ALU units. It exploits
// PRLL_RANK-way parallelism and thus a deep pipeline is used to achieve the
// high-speed operation with the wide signal redistributions.
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

module dsp_be_mlse_alu #(
    parameter int PRLL_RANK = 64,
    parameter int PRE_PIPELINE_DEPTH = 3,
    parameter int PST_PIPELINE_DEPTH = 1
) (
    input var logic i_clk,
    input var logic [PRLL_RANK-1:0] i_rst,
    input var logic [PRLL_RANK-1:0] i_en,

    input var logic i_cfg_eq_in_inv,

    input var logic [PRLL_RANK-1:0][5:0] i_dat_be,

    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hm1,  // fxp6p2 X PRLL_RANK
    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hp1,  // fxp6p2 X PRLL_RANK
    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hx,   // fxp6p2 X PRLL_RANK

    output ari_unit_t o_ari[PRLL_RANK]
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // Synchronous reset signals
  logic [PRLL_RANK-1:0] rst_sync;

  // Data sample from the frontend in unpacked dimension
  logic [5:0] dat_be[PRLL_RANK];

  // Equalizer configurations to ALU units
  logic [7:0] cfg_eq_hm1_unit[PRLL_RANK];
  logic [7:0] cfg_eq_hp1_unit[PRLL_RANK];
  logic [7:0] cfg_eq_hx_unit[PRLL_RANK];

  // delayed data, data_dly[62] and data_dly[63] are used
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  // note that these are pre-stage pipeline registers
  logic [5:0] dat_pipe_pre[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  logic [5:0] dat_pipe_pre_dly[PRE_PIPELINE_DEPTH+1][PRLL_RANK];
  logic [5:0] dat[PRLL_RANK];
  logic [5:0] dat_dly[PRLL_RANK];

  // Assemble delayed samples for each ALU unit
  logic [2:0][5:0] dat_d0m1m2[PRLL_RANK];

  // Output of each ALU unit
  ari_unit_t ari[PRLL_RANK];
  // Post-stage pipeline registers
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
  // Unpack Data Sample and EQ Configurations
  // ----------------------------------------------------------------------
  // Chicken bit to invert the input data samples
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_unpack_dat_be
      /*assign dat_be[k] = i_dat_be[k];*/
      assign dat_be[k] = i_cfg_eq_in_inv ? ~i_dat_be[k] : i_dat_be[k];
    end
  endgenerate

  // Unpacking for EQ needed since scan comes in packed form
  // Uses indexed-part select (+:) e.g.,
  // reg [31:0] dword -> dword[0+:8] = dword[7:0] (starts LSB from 0th bit)
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_unpack_cfg_eq
      assign cfg_eq_hm1_unit[k] = i_cfg_eq_hm1[8*k+:8];
      assign cfg_eq_hp1_unit[k] = i_cfg_eq_hp1[8*k+:8];
      assign cfg_eq_hx_unit[k]  = i_cfg_eq_hx[8*k+:8];
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Forward Data Sample
  // ----------------------------------------------------------------------
  assign dat_pipe_pre[0] = dat_be;

  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_dat_pipe_pre_in_en
      always_ff @(posedge i_clk or posedge rst_sync[k]) begin
        if (rst_sync[k]) begin
          dat_pipe_pre_dly[0][k] <= '{default: '0};
        end
        else if (i_en[k]) begin
          dat_pipe_pre_dly[0][k] <= dat_be[k];
        end
      end
    end  // for k (rank)
  endgenerate

  // Optimization; only forward 63rd and 62th data
  // 62 corresponds to PRLL_RANK-2
  // 63 corresponds to PRLL_RANK-1
  // Scan-controlled enables control unit-level granularity
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_dat_pipe_pre_en
      for (genvar i = 1; i < PRE_PIPELINE_DEPTH + 1; i = i + 1) begin : g_dat_pipe_pre
        always_ff @(posedge i_clk or posedge rst_sync[k]) begin
          if (rst_sync[k]) begin
            dat_pipe_pre[i][k] <= '{default: '0};
            dat_pipe_pre_dly[i][k] <= '{default: '0};
          end
          else if (i_en[k]) begin
            dat_pipe_pre[i][k] <= dat_pipe_pre[i-1][k];

            /*dat_pipe_pre_dly[i][PRLL_RANK-1] <= dat_pipe_pre_dly[i-1][PRLL_RANK-1];
             *dat_pipe_pre_dly[i][PRLL_RANK-2] <= dat_pipe_pre_dly[i-1][PRLL_RANK-2];
             *dat_pipe_pre_dly[i][0:PRLL_RANK-3] <= '{default: '0};*/

            if (k == PRLL_RANK - 1 || k == PRLL_RANK - 2) begin
              dat_pipe_pre_dly[i][k] <= dat_pipe_pre_dly[i-1][k];
            end
            else begin
              dat_pipe_pre_dly[i][k] <= '{default: '0};
            end
          end
        end
      end  // for i (rank)
    end  // for k (pipe)
  endgenerate

  assign dat = dat_pipe_pre[PRE_PIPELINE_DEPTH];
  assign dat_dly = dat_pipe_pre_dly[PRE_PIPELINE_DEPTH];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Instantiate ALU Units and Assemble Signals
  // ----------------------------------------------------------------------
  generate
    for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin : g_ari_unit
      if (k == 0) begin : g_assym_k_0
        assign dat_d0m1m2[k] = {dat[k], dat_dly[PRLL_RANK-1], dat_dly[PRLL_RANK-2]};
      end
      else if (k == 1) begin : g_assym_k_1
        assign dat_d0m1m2[k] = {dat[k], dat[k-1], dat_dly[PRLL_RANK-1]};
      end
      else begin : g_assym_k_2_63
        assign dat_d0m1m2[k] = {dat[k], dat[k-1], dat[k-2]};
      end

      dsp_be_mlse_alu_unit dsp_be_mlse_alu_unit (
          /*.i_clk(i_clk),
           *.i_rst(i_rst),*/
          .i_dat_unit_d0m1m2(dat_d0m1m2[k]),
          .i_cfg_eq_hm1_unit(cfg_eq_hm1_unit[k]),
          .i_cfg_eq_hp1_unit(cfg_eq_hp1_unit[k]),
          .i_cfg_eq_hx_unit(cfg_eq_hx_unit[k]),
          .o_ari_unit(ari[k])
      );
    end  // for k (rank)
  endgenerate
  // ----------------------------------------------------------------------

  //// ----------------------------------------------------------------------
  //// Forward Outputs
  //// ----------------------------------------------------------------------
  //assign o_ari = ari;
  //// ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Post-Pipeline Registers
  // ----------------------------------------------------------------------
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
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

