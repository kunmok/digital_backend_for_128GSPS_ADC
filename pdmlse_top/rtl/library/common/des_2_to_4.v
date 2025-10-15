//==============================================================================
// Author: Sunjin Choi
// Description: 2-8 Deserializer with embedded clock divider
// It receives 2-bit deserialized data from DDR RX frontend and further
// deserialize to 8-bit chunk for downstream backend operations
// Signals:
// 	  i_clk_ref : input reference clock   
// 	  i_rst : asynchronous reset signal
// 	  i_en : clock gating enable signal
// 	  o_clk : output clocks
//    i_clk : input clock 
//    i_dat : input data
//    o_dat : deserialized output data
// Note: out[0] is earlier than out[1]
// For example,
// i_dat    : _D0_D1_D2_D3_D4_D5_...
// i_clk    : _HH_LL_HH_LL_HH_LL_...
// o_dat[0] : _XX_XX_D0_D0_D2_D2_...
// o_dat[1] : _XX_XX_D1_D1_D3_D3_... 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module des_2_to_4 (

    // input signals
    i_clk_ref,
    i_rst,
    i_en,
    i_dat,

    // output signals
    o_clk,
    o_clk_div_2,
    o_dat

);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam DivWidth = 1;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Inputs / Outputs
  // ----------------------------------------------------------------------
  // input signals
  input wire i_clk_ref;
  input wire i_rst;
  input wire i_en;
  input wire [1:0] i_dat;

  // output signals
  output wire o_clk;
  output wire o_clk_div_2;
  output wire [3:0] o_dat;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  wire [DivWidth:0] div_clk;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Assigns
  // ----------------------------------------------------------------------
  assign o_clk = div_clk[0];
  assign o_clk_div_2 = div_clk[1];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Clock Divider
  // ----------------------------------------------------------------------
  /*sync_clk_div #(
   *    .CntWidth(DivWidth)
   *) clk_div (
   *    .i_en(i_en),
   *    .i_clk_ref(i_clk_ref),
   *    .i_rst(i_rst),
   *    .o_clk(div_clk)
   *);*/

  serdes_clk_gen clk_div (
      .i_en(i_en),
      .i_clk_ref(i_clk_ref),
      .i_rst(i_rst),
      .o_clk(div_clk)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Even Path 1-2 Deserializer
  // ----------------------------------------------------------------------
  des_1_to_2 des_2e (
      .i_clk(div_clk[1]),
      .i_dat(i_dat[0]),
      .o_dat({o_dat[2], o_dat[0]})
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Odd Path 1-2 Deserializer
  // ----------------------------------------------------------------------
  des_1_to_2 des_2o (
      .i_clk(div_clk[1]),
      .i_dat(i_dat[1]),
      .o_dat({o_dat[3], o_dat[1]})
  );
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire
