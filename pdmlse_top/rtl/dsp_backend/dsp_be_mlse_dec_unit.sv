//==============================================================================
// Author: Sunjin Choi
// Description: Decision unit for the MLSE equalizer
// Decision unit is responsible for making the final decision on the data
// based on the signal arithmetics and the pattern flags.
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

module dsp_be_mlse_dec_unit (

    input var flag_unit_t [2:0] i_flag_unit_d0m1m2,
    input var ari_unit_t i_ari_unit_dm2,

    output logic o_drx_unit_d0

);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  flag_unit_t flag_unit_d0;
  flag_unit_t flag_unit_dm1;
  flag_unit_t flag_unit_dm2;

  ari_unit_t  ari_unit_dm2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Unpacking Signals
  // ----------------------------------------------------------------------
  assign {flag_unit_d0, flag_unit_dm1, flag_unit_dm2} = i_flag_unit_d0m1m2;
  assign ari_unit_dm2 = i_ari_unit_dm2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Decision Logic
  // ----------------------------------------------------------------------
  /*genvar k;
   *generate
   *  for (k = 2; k < PRLL_RANK; k = k + 1) begin
   *    always @(*) begin
   *      if (flag_unit[k].p3b == 1'b1) drx[k] = ~ari_unit[k-2].dpre;
   *      else if (flag_unit[k].p2 == 1'b1) drx[k] = ari_unit[k-2].dpst;
   *      else if (flag_unit[k-1].p1a == 1'b1) drx[k] = ari_unit[k-2].dpst;
   *      else if (flag_unit[k-1].p1b == 1'b1) drx[k] = ari_unit[k-2].dpre;
   *      else if (flag_unit[k-1].p3o == 1'b1) drx[k] = ari_unit[k-2].dcomp;
   *      else if (flag_unit[k-1].p2 == 1'b1) drx[k] = ~ari_unit[k-2].dpre;
   *      else if (flag_unit[k-1].p4m == 1'b1) drx[k] = 1'b0;
   *      else if (flag_unit[k-1].p4p == 1'b1) drx[k] = 1'b1;
   *      else if (flag_unit[k-2].p3a == 1'b1) drx[k] = ~ari_unit[k-2].dpst;
   *      else if (flag_unit[k-2].p2 == 1'b1) drx[k] = ari_unit[k-2].dpre;
   *      else drx[k] = ari_unit[k-2].dpst;
   *    end
   *  end
   *endgenerate*/

  always_comb begin
    if (flag_unit_d0.p3b == 1'b1) o_drx_unit_d0 = ~ari_unit_dm2.dpre;
    else if (flag_unit_d0.p2 == 1'b1) o_drx_unit_d0 = ari_unit_dm2.dpst;
    else if (flag_unit_dm1.p1a == 1'b1) o_drx_unit_d0 = ari_unit_dm2.dpst;
    else if (flag_unit_dm1.p1b == 1'b1) o_drx_unit_d0 = ari_unit_dm2.dpre;
    else if (flag_unit_dm1.p3o == 1'b1) o_drx_unit_d0 = ari_unit_dm2.dcomp;
    else if (flag_unit_dm1.p2 == 1'b1) o_drx_unit_d0 = ~ari_unit_dm2.dpre;
    else if (flag_unit_dm1.p4m == 1'b1) o_drx_unit_d0 = 1'b0;
    else if (flag_unit_dm1.p4p == 1'b1) o_drx_unit_d0 = 1'b1;
    else if (flag_unit_dm2.p3a == 1'b1) o_drx_unit_d0 = ~ari_unit_dm2.dpst;
    else if (flag_unit_dm2.p2 == 1'b1) o_drx_unit_d0 = ari_unit_dm2.dpre;
    else o_drx_unit_d0 = ari_unit_dm2.dpst;
  end
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

