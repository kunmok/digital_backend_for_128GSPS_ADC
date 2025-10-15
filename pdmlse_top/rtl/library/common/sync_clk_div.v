//==============================================================================
// Author: Sunjin Choi (improved from eos_serdes_clock_gen)
// Description: Synchronous Active-Low Clock Divider
// Asynchronously-resettable counter-based synchronous clock divider
// Parameter:
//    CntWidth : 1 corresponds to 1:2, 2 to 1:4, 3 to 1:8, so on and so forth
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

module sync_clk_div (

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
  parameter CntWidth = 2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Inputs / Outputs
  // ----------------------------------------------------------------------
  // input signals
  input wire i_clk_ref;
  input wire i_rst;
  input wire i_en;

  // output signals
  output wire [CntWidth:0] o_clk;
  // ----------------------------------------------------------------------



  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  reg [CntWidth-1:0] div_cnt;
  reg o_clk_ref;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Assigns
  // ----------------------------------------------------------------------
  assign o_clk = {div_cnt[CntWidth-1:0], o_clk_ref};
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Clock Divider
  // ----------------------------------------------------------------------
  always @(posedge i_clk_ref or posedge i_rst) begin
    if (i_rst) begin
      div_cnt   <= {CntWidth[1'b0]};
      o_clk_ref <= 1'b0;
    end
    else if (i_en) begin
      div_cnt   <= div_cnt + 1'b1;
      o_clk_ref <= i_clk_ref;
    end
  end
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire
