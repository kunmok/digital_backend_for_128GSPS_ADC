//==============================================================================
// Author: Sunjin Choi
// Description: Pattern filter unit for MLSE
// This module generates the flags based on the pattern matching logic and
// signal arithmetics from the previous stage.
// Signals:
// Note: 
// d0, dm1, dm2 refers to the signal corresponding to (current), (current-1), (current-2)
// signals, which essentially is a bundle with previous data values
// e.g., At t=2, d0 refers to the current data, dm1 refers to the data at t=1, and dm2 refers to the data at t=0
// At t=0, dm1 refers to the data at t=-1, and dm2 refers to the data at t=-2
// Due to the parallel time-interleaving architecture, this means a tap on the
// different data lanes or pipeline stages
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_be_patt_filt_unit (

    /*input var logic i_clk,
     *input var logic i_rst,*/

    input var ari_unit_t [2:0] i_ari_unit_d0m1m2,

    input var logic i_cfg_eq_p1a_en,
    input var logic i_cfg_eq_p1b_en,
    input var logic i_cfg_eq_p2_en,
    input var logic i_cfg_eq_p3o_en,
    input var logic i_cfg_eq_p3a_en,
    input var logic i_cfg_eq_p3b_en,
    input var logic i_cfg_eq_p4p_en,
    input var logic i_cfg_eq_p4m_en,

    output flag_unit_t o_flag_unit_d0
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  ari_unit_t  ari_unit_d0;
  ari_unit_t  ari_unit_dm1;
  ari_unit_t  ari_unit_dm2;

  flag_unit_t flag_unit_d0;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Unpacking Signals
  // ----------------------------------------------------------------------
  assign {ari_unit_d0, ari_unit_dm1, ari_unit_dm2} = i_ari_unit_d0m1m2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Pattern Matching Logic
  // ----------------------------------------------------------------------
  // Pattern 1-a flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if ((ari[k-2].dpre == ari[k-1].dpre)    &&
   *          (ari[k-1].dpre == ari[k].dpre)  &&
   *          (ari[k-1].dpre != ari[k-1].dpst)) begin
   *        flag_unit[k].p1a = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p1a = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if ((ari_unit_dm2.dpre == ari_unit_dm1.dpre) &&
        (ari_unit_dm1.dpre == ari_unit_d0.dpre) &&
        (ari_unit_dm1.dpre != ari_unit_dm1.dpst)) begin
      flag_unit_d0.p1a = 1'b1;
    end
    else begin
      flag_unit_d0.p1a = 1'b0;
    end
  end

  // Pattern 1-b flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if ((ari[k-2].dpst == ari[k-1].dpst)    &&
   *          (ari[k-1].dpst == ari[k].dpst)  &&
   *          (ari[k-1].dpre != ari[k-1].dpst)) begin
   *        flag_unit[k].p1b = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p1b = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if ((ari_unit_dm2.dpst == ari_unit_dm1.dpst) &&
            (ari_unit_dm1.dpst == ari_unit_d0.dpst) &&
            (ari_unit_dm1.dpre != ari_unit_dm1.dpst)) begin
      flag_unit_d0.p1b = 1'b1;
    end
    else begin
      flag_unit_d0.p1b = 1'b0;
    end
  end

  // Pattern 2 flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if ((ari_unit[k-2].dpre != ari_unit[k-2].dpst) &&
   *      (ari_unit[k].dpre != ari_unit[k].dpst) &&
   *      i_cfg_eq_p2_en == 1'b1) begin
   *        flag_unit[k].p2 = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p2 = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if ((ari_unit_dm2.dpre != ari_unit_dm2.dpst) && (ari_unit_d0.dpre != ari_unit_d0.dpst)) begin
      flag_unit_d0.p2 = 1'b1;
    end
    else begin
      flag_unit_d0.p2 = 1'b0;
    end
  end

  // Pattern 3o flag generation
  // Case k = 1:63
  /*generate
   *  for (k = 1; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if (ari_unit[k-1].dpre != ari_unit[k-1].dpst) begin
   *        flag_unit[k].p3o = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p3o = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if (ari_unit_dm1.dpre != ari_unit_dm1.dpst) begin
      flag_unit_d0.p3o = 1'b1;
    end
    else begin
      flag_unit_d0.p3o = 1'b0;
    end
  end

  // Pattern 3a flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if ((ari_unit[k-1].dpre  != ari_unit[k-1].dpst    )   &&
   *          (ari_unit[k-2].dpre  == ari_unit[k-2].dpst    )   &&
   *          (ari_unit[k].dpre    == ari_unit[k].dpst  )   &&
   *          (ari_unit[k-1].dcomp == ari_unit[k-1].dpst    )   &&
   *          (ari_unit[k].dxn == 1'b1     )   &&
   *          (ari_unit[k].dxp == 1'b0     )   ) begin
   *        flag_unit[k].p3a = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p3a = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if ((ari_unit_dm1.dpre  != ari_unit_dm1.dpst    )   &&
          (ari_unit_dm2.dpre  == ari_unit_dm2.dpst    )   &&
          (ari_unit_d0.dpre    == ari_unit_d0.dpst  )   &&
          (ari_unit_dm1.dcomp == ari_unit_dm1.dpst    )   &&
          (ari_unit_d0.dxn == 1'b1     )   &&
          (ari_unit_d0.dxp == 1'b0     )   ) begin
      flag_unit_d0.p3a = 1'b1;
    end
    else begin
      flag_unit_d0.p3a = 1'b0;
    end
  end

  // Pattern 4m flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if (    (ari_unit[k-2].dpre  == ari_unit[k-2].dpst    )   &&
   *              (ari_unit[k-1].dpre  == ari_unit[k-1].dpst    )   &&
   *              (ari_unit[k].dpre    == ari_unit[k].dpst  )   &&
   *              (ari_unit[k-2].dpre  == ari_unit[k].dpre  )   &&
   *              (ari_unit[k-1].dpre  == ari_unit[k].dpre  )   &&
   *              (ari_unit[k-1].dpre  == 1'b1     )   &&
   *              (ari_unit[k-1].dxp   == 1'b0     )   )
   *          begin
   *        flag_unit[k].p4m = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p4m = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if (    (ari_unit_dm2.dpre  == ari_unit_dm2.dpst    )   &&
              (ari_unit_dm1.dpre  == ari_unit_dm1.dpst    )   &&
              (ari_unit_d0.dpre    == ari_unit_d0.dpst  )   &&
              (ari_unit_dm2.dpre  == ari_unit_d0.dpre  )   &&
              (ari_unit_dm1.dpre  == ari_unit_d0.dpre  )   &&
              (ari_unit_dm1.dpre  == 1'b1     )   &&
              (ari_unit_dm1.dxp   == 1'b0     )   )
          begin
      flag_unit_d0.p4m = 1'b1;
    end
    else begin
      flag_unit_d0.p4m = 1'b0;
    end
  end

  // Pattern 3b flag generation
  // Case k=2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if (    (ari_unit[k-1].dpre  != ari_unit[k-1].dpst    )   &&
   *              (ari_unit[k-2].dpre  == ari_unit[k-2].dpst    )   &&
   *              (ari_unit[k].dpre    == ari_unit[k].dpst  )   &&
   *              (ari_unit[k-1].dcomp == ari_unit[k-1].dpre    )   &&
   *              (ari_unit[k-2].dxn   == 1'b1     )   &&
   *              (ari_unit[k-2].dxp   == 1'b0     )   )
   *          begin
   *        flag_unit[k].p3b = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p3b = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if (    (ari_unit_dm1.dpre  != ari_unit_dm1.dpst    )   &&
              (ari_unit_dm2.dpre  == ari_unit_dm2.dpst    )   &&
              (ari_unit_d0.dpre    == ari_unit_d0.dpst  )   &&
              (ari_unit_dm1.dcomp == ari_unit_dm1.dpre    )   &&
              (ari_unit_dm2.dxn   == 1'b1     )   &&
              (ari_unit_dm2.dxp   == 1'b0     )   )
          begin
      flag_unit_d0.p3b = 1'b1;
    end
    else begin
      flag_unit_d0.p3b = 1'b0;
    end
  end

  // Pattern 4p flag generation
  // Case k = 2:63
  /*generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always_comb begin
   *      if (    (ari_unit[k-2].dpre  == ari_unit[k-2].dpst    )   &&
   *              (ari_unit[k-1].dpre  == ari_unit[k-1].dpst    )   &&
   *              (ari_unit[k].dpre    == ari_unit[k].dpst  )   &&
   *              (ari_unit[k-2].dpre  == ari_unit[k].dpre  )   &&
   *              (ari_unit[k-1].dpre  == ari_unit[k].dpre  )   &&
   *              (ari_unit[k-1].dpre  == 1'b0     )   &&
   *              (ari_unit[k-1].dxn   == 1'b1     )   )
   *          begin
   *        flag_unit[k].p4p = 1'b1;
   *      end
   *      else begin
   *        flag_unit[k].p4p = 1'b0;
   *      end
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if (    (ari_unit_dm2.dpre  == ari_unit_dm2.dpst    )   &&
              (ari_unit_dm1.dpre  == ari_unit_dm1.dpst    )   &&
              (ari_unit_d0.dpre    == ari_unit_d0.dpst  )   &&
              (ari_unit_dm2.dpre  == ari_unit_d0.dpre  )   &&
              (ari_unit_dm1.dpre  == ari_unit_d0.dpre  )   &&
              (ari_unit_dm1.dpre  == 1'b0     )   &&
              (ari_unit_dm1.dxn   == 1'b1     )   )
          begin
      flag_unit_d0.p4p = 1'b1;
    end
    else begin
      flag_unit_d0.p4p = 1'b0;
    end
  end
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Forward Outputs
  // ----------------------------------------------------------------------
  /*assign o_flag_unit_d0 = flag_unit_d0;*/

  assign o_flag_unit_d0.p1a = flag_unit_d0.p1a & i_cfg_eq_p1a_en;
  assign o_flag_unit_d0.p1b = flag_unit_d0.p1b & i_cfg_eq_p1b_en;
  assign o_flag_unit_d0.p2  = flag_unit_d0.p2 & i_cfg_eq_p2_en;
  assign o_flag_unit_d0.p3o = flag_unit_d0.p3o & i_cfg_eq_p3o_en;
  assign o_flag_unit_d0.p3a = flag_unit_d0.p3a & i_cfg_eq_p3a_en;
  assign o_flag_unit_d0.p3b = flag_unit_d0.p3b & i_cfg_eq_p3b_en;
  assign o_flag_unit_d0.p4p = flag_unit_d0.p4p & i_cfg_eq_p4p_en;
  assign o_flag_unit_d0.p4m = flag_unit_d0.p4m & i_cfg_eq_p4m_en;
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

