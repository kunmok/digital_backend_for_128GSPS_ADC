//==============================================================================
// Author: Sunjin Choi
// Description: 1-2 Deserializer
// Intended to be mapped to correct latches and flip flops by Genus
// Signals:
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

// WARNING: `ifdef BEHAVIORAL part was added AFTER tapeout
// tapeout-ed version does not include that part
// though in principle it should not affect physical design
// You should think of a way to take this part out and construct
// simulation-only deserializer model?

module des_1_to_2 (
    // input signals
    i_clk,
    i_dat,
    // output signals
    o_dat
);

  // ----------------------------------------------------------------------
  // Inputs / Outputs
  // ----------------------------------------------------------------------
  input wire i_clk;
  input wire i_dat;

  output reg [1:0] o_dat;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  reg i_dat_latch;
  // ----------------------------------------------------------------------

  // ** Let the tool to inference the right latch **
  // This can drastically help hold violations
  // ----------------------------------------------------------------------
  // Latch
  // ----------------------------------------------------------------------
  always @(*) begin : des_latch
	if (i_clk) i_dat_latch <= i_dat;
  end
  // maybe always_latch?? roll back to previous always @(*)
  // genus: Generated logic differs from the expected logic 
  /*always_comb begin : des_latch
   *  if (i_clk) i_dat_latch = i_dat;
   *end*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Flip-Flops
  // ----------------------------------------------------------------------
  always @(posedge i_clk) begin : des_ff_0
    o_dat[0] <= i_dat_latch;
  end

  always @(posedge i_clk) begin : des_ff_1
    o_dat[1] <= i_dat;
  end
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire
