//==============================================================================
// Author: Sunjin Choi (improved from eos_serdes_clock_gen)
// Description: Div-2 Clock Generator for Serdes frontend/backend
// Asynchronously-resettable synchronous clock divider
// It is synthesized with the faster timing paths than sync_clk_div to be
// closed timing at 8GHz in 45SPCLO process
// Signals:
// 	  i_clk_ref : input reference clock   
// 	  i_rst : asynchronous reset signal
// 	  i_en : clock gating enable signal
// 	  o_clk : output clocks
// Note: o_clk[i] is gated clock with dividing factor 2^i
// Flip flops are intended to be synthesized with identical foundry-provided
// clock gating cells, but do CHECK the mapped netlist.
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module serdes_clk_gen (

    // input signals
    i_clk_ref,
    i_rst,
    i_en,

    // output signals
    o_clk

);

  // ----------------------------------------------------------------------
  // Parameters
  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Inputs / Outputs
  // ----------------------------------------------------------------------
  // input signals
  input wire i_clk_ref;
  input wire i_rst;
  input wire i_en;

  // output signals
  output wire [1:0] o_clk;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  reg  div_cnt;
  wire o_clk_ref;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Assigns
  // ----------------------------------------------------------------------
  assign o_clk_ref = i_clk_ref & i_en;
  assign o_clk = {div_cnt, o_clk_ref};
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Clock Divider
  // ----------------------------------------------------------------------
  always @(posedge o_clk_ref or posedge i_rst) begin
    if (i_rst) begin
      div_cnt <= 1'b0;
    end
    else begin
      div_cnt <= ~div_cnt;
    end
  end

  /*always @(posedge o_clk_ref or posedge i_rst) begin
   *  if (i_rst) begin
   *    div_cnt[0] <= 1'b0;
   *  end
   *  else begin
   *    div_cnt[0] <= ~div_cnt[0];
   *  end
   *end*/

  /*always @(posedge div_cnt[0] or posedge i_rst) begin
   *  if (i_rst) begin
   *    div_cnt[1] <= 1'b0;
   *  end
   *  else begin
   *    div_cnt[1] <= ~div_cnt[1];
   *  end
   *end*/
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire
