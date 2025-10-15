//==============================================================================
// Author: Wahid Rahman, Kunmo Kim and Sunjin Choi
// Description: Backend Equalizer Top-level
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

module dsp_be_eq #(
    parameter int PRLL_RANK = 64,
    parameter int ALU_PRE_PP_DEPTH = 3,
    parameter int ALU_PST_PP_DEPTH = 1,
    parameter int FILT_PRE_PP_DEPTH = 3,
    parameter int FILT_PST_PP_DEPTH = 2,
    parameter int DEC_PRE_PP_DEPTH = 3,
    parameter int DEC_PST_PP_DEPTH = 1
) (
    input var logic i_clk,
    /*input var logic i_rst,*/

    input var logic [PRLL_RANK-1:0] i_rst_alu,
    input var logic [PRLL_RANK-1:0] i_rst_filt,
    input var logic [PRLL_RANK-1:0] i_rst_dec,

    input var logic [PRLL_RANK-1:0] i_en_alu,
    input var logic [PRLL_RANK-1:0] i_en_filt,
    input var logic [PRLL_RANK-1:0] i_en_dec,

    input var logic i_cfg_eq_in_inv,
    input var logic i_cfg_eq_out_inv,
    input var logic i_cfg_eq_out_endian,

    input var logic i_cfg_eq_p1a_en,
    input var logic i_cfg_eq_p1b_en,
    input var logic i_cfg_eq_p2_en,
    input var logic i_cfg_eq_p3o_en,
    input var logic i_cfg_eq_p3a_en,
    input var logic i_cfg_eq_p3b_en,
    input var logic i_cfg_eq_p4p_en,
    input var logic i_cfg_eq_p4m_en,

    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hm1,  // fxp6p2 X PRLL_RANK
    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hp1,  // fxp6p2 X PRLL_RANK
    input var logic [8*PRLL_RANK-1:0] i_cfg_eq_hx,   // fxp6p2 X PRLL_RANK

    input var logic [PRLL_RANK-1:0][5:0] i_dat_be,  // PRLL_RANK X fxp6p0
    output var logic [PRLL_RANK-1:0] o_drx

    /*// Monitor signals
     *w_Dpre,  // PRLL_RANK x Boolean
     *w_Dpst,  // PRLL_RANK x Boolean
     *w_Dcomp,  // PRLL_RANK x Boolean
     *w_Dxp,  // PRLL_RANK x Boolean
     *w_Dxn  // PRLL_RANK x Boolean*/
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  ari_unit_t ari[PRLL_RANK];
  ari_unit_t ari_fwd[PRLL_RANK];
  flag_unit_t flag[PRLL_RANK];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Module Instantiations
  // ----------------------------------------------------------------------
  dsp_be_mlse_alu #(
      .PRLL_RANK(PRLL_RANK),
      .PRE_PIPELINE_DEPTH(ALU_PRE_PP_DEPTH),
      .PST_PIPELINE_DEPTH(ALU_PST_PP_DEPTH)
  ) dsp_be_mlse_alu (
      .i_clk(i_clk),
      .i_rst(i_rst_alu),
      .i_en (i_en_alu),

      .i_cfg_eq_in_inv(i_cfg_eq_in_inv),
      .i_cfg_eq_hm1(i_cfg_eq_hm1),
      .i_cfg_eq_hp1(i_cfg_eq_hp1),
      .i_cfg_eq_hx(i_cfg_eq_hx),

      .i_dat_be(i_dat_be),
      .o_ari(ari)
  );

  dsp_be_patt_filt #(
      .PRLL_RANK(PRLL_RANK),
      .PRE_PIPELINE_DEPTH(FILT_PRE_PP_DEPTH),
      .PST_PIPELINE_DEPTH(FILT_PST_PP_DEPTH)
  ) dsp_be_patt_filt (
      .i_clk(i_clk),
      .i_rst(i_rst_filt),
      .i_en (i_en_filt),

      .i_cfg_eq_p1a_en(i_cfg_eq_p1a_en),
      .i_cfg_eq_p1b_en(i_cfg_eq_p1b_en),
      .i_cfg_eq_p2_en (i_cfg_eq_p2_en),
      .i_cfg_eq_p3o_en(i_cfg_eq_p3o_en),
      .i_cfg_eq_p3a_en(i_cfg_eq_p3a_en),
      .i_cfg_eq_p3b_en(i_cfg_eq_p3b_en),
      .i_cfg_eq_p4p_en(i_cfg_eq_p4p_en),
      .i_cfg_eq_p4m_en(i_cfg_eq_p4m_en),

      .i_ari (ari),
      .o_ari (ari_fwd),
      .o_flag(flag)
  );

  dsp_be_mlse_dec #(
      .PRLL_RANK(PRLL_RANK),
      .PRE_PIPELINE_DEPTH(DEC_PRE_PP_DEPTH),
      .PST_PIPELINE_DEPTH(DEC_PST_PP_DEPTH)
  ) dsp_be_mlse_dec (
      .i_clk(i_clk),
      .i_rst(i_rst_dec),
      .i_en (i_en_dec),

      .i_cfg_eq_out_inv(i_cfg_eq_out_inv),
      .i_cfg_eq_out_endian(i_cfg_eq_out_endian),

      .i_ari (ari_fwd),
      .i_flag(flag),
      .o_drx (o_drx)
  );
  // ----------------------------------------------------------------------

  /*generate
   *  for (genvar k = 0; k < PRLL_RANK; k = k + 1) begin
   *    assign w_Dpre[k]  = ari[k].dpre;
   *    assign w_Dpst[k]  = ari[k].dpst;
   *    assign w_Dcomp[k] = ari[k].dcomp;
   *    assign w_Dxp[k]   = ari[k].dxp;
   *    assign w_Dxn[k]   = ari[k].dxn;
   *  end
   *endgenerate*/

endmodule

`default_nettype wire
