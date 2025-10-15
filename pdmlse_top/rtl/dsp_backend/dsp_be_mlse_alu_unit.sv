//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note: Refer to mlse_comb_rtl.m
// d0, dm1, dm2 refers to the signal corresponding to (current), (current-1), (current-2)
// signals, which essentially is a bundle with previous data values
// e.g., At t=2, d0 refers to the current data, dm1 refers to the data at t=1, and dm2 refers to the data at t=0
// At t=0, dm1 refers to the data at t=-1, and dm2 refers to the data at t=-2
// Due to the parallel time-interleaving architecture, this means a tap on the
// different data lanes or pipeline stages
// ----------------------------------------------------------------------
// hm1, hp1, hx refers to the configuration signals for the equalizer
// operation
// ----------------------------------------------------------------------
// *DO NOT CONFUSE* hm1 and dm1
// ----------------------------------------------------------------------
// Note that the arithmetic operation is performed in the *signed* domain so
// explicit type-casting is performed while physical data tranformation is
// done externally (either through frontend LUT, scan interface or others)
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_be_mlse_alu_unit (

    /*input var logic i_clk,
     *input var logic i_rst,*/

    input var logic [2:0][5:0] i_dat_unit_d0m1m2,

    input var logic [7:0] i_cfg_eq_hm1_unit,
    input var logic [7:0] i_cfg_eq_hp1_unit,
    input var logic [7:0] i_cfg_eq_hx_unit,

    output ari_unit_t o_ari_unit
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // Use "s" for the signed variables
  // Since it is essential to only use "s"-variables for the logic
  // Bit format such as fxp6p0 or fxp6p2 for the fixed-point format
  // fxp6p0 corresponds to S5.0 format in Matlab and previous code
  // fxp6p2 corresponds to S5.2 format in Matlab and previous code

  logic signed [5:0] sdat_d0_fxp6p0;
  logic signed [5:0] sdat_dm1_fxp6p0;
  logic signed [5:0] sdat_dm2_fxp6p0;
  logic signed [7:0] scfg_hm1_fxp6p2;
  logic signed [7:0] scfg_hp1_fxp6p2;
  logic signed [7:0] scfg_hx_fxp6p2;

  // Expanded signals for the arithmetic operations
  logic signed [7:0] sdat_d0_fxp6p2;
  logic signed [7:0] sdat_dm1_fxp6p2;
  logic signed [7:0] sdat_dm2_fxp6p2;

  logic signed [7:0] scfg_hm1plus_fxp6p2;
  logic signed [7:0] scfg_hp1plus_fxp6p2;
  logic signed [7:0] scfg_hxplus_fxp6p2;
  logic signed [7:0] scfg_hm1minus_fxp6p2;
  logic signed [7:0] scfg_hp1minus_fxp6p2;
  logic signed [7:0] scfg_hxminus_fxp6p2;

  // Arithmetic output signal struct
  ari_unit_t ari;

  // Temporary signals to unpack the input data
  logic [5:0] dat_d0;
  logic [5:0] dat_dm1;
  logic [5:0] dat_dm2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Unpack Input Data
  // ----------------------------------------------------------------------
  assign {dat_d0, dat_dm1, dat_dm2} = i_dat_unit_d0m1m2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Type-Casting to Signed
  // ----------------------------------------------------------------------
  // Type-casting to signed; this does not *change* the signal bits
  // but lets any RTL-facing tools to interpret the signal as signed format
  // This is essential for the downstream arithmetic-logic operations
  // Note that this should be double-checked in both the RTL and post-mapped
  // RTLs
  // Use $signed construct from Verilog-2001 since this is what Genus mentions
  // in the Datapath Synthesis Guide

  assign sdat_d0_fxp6p0 = $signed(dat_d0);
  assign sdat_dm1_fxp6p0 = $signed(dat_dm1);
  assign sdat_dm2_fxp6p0 = $signed(dat_dm2);

  assign scfg_hm1_fxp6p2 = $signed(i_cfg_eq_hm1_unit);
  assign scfg_hp1_fxp6p2 = $signed(i_cfg_eq_hp1_unit);
  assign scfg_hx_fxp6p2 = $signed(i_cfg_eq_hx_unit);
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Arithmetic Preparation
  // ----------------------------------------------------------------------
  // Consists of: fxp6p0 to fxp6p2 conversion for the data and arithmetic
  // complement for the configuration signals
  // Choices crafted for QoS and based on Genus Datapath Synthesis Guide
  // Prefer to use simple negation e.g., -x if x is assigned as signed
  // Prefer to use simple padding with signed declaration for fxp6p0 to fxp6p2
  // e.g., $signed({x, 2'b00}) if x is assigned as signed

  assign sdat_d0_fxp6p2 = $signed({sdat_d0_fxp6p0, 2'b00});
  assign sdat_dm1_fxp6p2 = $signed({sdat_dm1_fxp6p0, 2'b00});
  assign sdat_dm2_fxp6p2 = $signed({sdat_dm2_fxp6p0, 2'b00});

  assign scfg_hm1plus_fxp6p2 = scfg_hm1_fxp6p2;
  assign scfg_hp1plus_fxp6p2 = scfg_hp1_fxp6p2;
  assign scfg_hxplus_fxp6p2 = scfg_hx_fxp6p2;

  assign scfg_hm1minus_fxp6p2 = -scfg_hm1_fxp6p2;
  assign scfg_hp1minus_fxp6p2 = -scfg_hp1_fxp6p2;
  assign scfg_hxminus_fxp6p2 = -scfg_hx_fxp6p2;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Arithmetic Operation
  // ----------------------------------------------------------------------
  /*assign ari[i].dcomp = w_vin[i-1] > 0 ? 1'b1 : 1'b0;
   *assign ari[i].dxp   = w_vin[i-1] > i_cfg_eq_hx ? 1'b1 : 1'b0;
   *assign ari[i].dxn   = w_vin[i-1] > -i_cfg_eq_hx ? 1'b1 : 1'b0;*/

  assign ari.dcomp = sdat_dm1_fxp6p2 > 0 ? 1'b1 : 1'b0;
  assign ari.dxp = sdat_dm1_fxp6p2 > scfg_hxplus_fxp6p2 ? 1'b1 : 1'b0;
  assign ari.dxn = sdat_dm1_fxp6p2 > scfg_hxminus_fxp6p2 ? 1'b1 : 1'b0;

  /*always @(*) begin
   *  if (w_vin[i-1] > w_hp1plus) begin
   *    ari[i].dpst = 1'b1;
   *  end
   *  else if (w_vin[i-1] < -i_cfg_eq_hp1) begin
   *    ari[i].dpst = 1'b0;
   *  end
   *  else begin
   *    if (w_vin[i-2] > w_vin[i-1]) begin
   *      ari[i].dpst = 1'b0;
   *    end
   *    else begin
   *      ari[i].dpst = 1'b1;
   *    end
   *  end
   *end*/

  always_comb begin
    if (sdat_dm1_fxp6p2 > scfg_hp1plus_fxp6p2) begin
      ari.dpst = 1'b1;
    end
    else if (sdat_dm1_fxp6p2 < scfg_hp1minus_fxp6p2) begin
      ari.dpst = 1'b0;
    end
    else begin
      if (sdat_dm2_fxp6p2 > sdat_dm1_fxp6p2) begin
        ari.dpst = 1'b0;
      end
      else begin
        ari.dpst = 1'b1;
      end
    end
  end

  /*always @(*) begin
   *  if (w_vin[i-1] > w_hm1plus) begin
   *    ari[i].dpre = 1'b1;
   *  end
   *  else if (w_vin[i-1] < -i_cfg_eq_hm1) begin
   *    ari[i].dpre = 1'b0;
   *  end
   *  else begin
   *    if (w_vin[i-1] > w_vin[i]) begin
   *      ari[i].dpre = 1'b1;
   *    end
   *    else begin
   *      ari[i].dpre = 1'b0;
   *    end
   *  end
   *end*/

  always_comb begin
    if (sdat_dm1_fxp6p2 > scfg_hm1plus_fxp6p2) begin
      ari.dpre = 1'b1;
    end
    else if (sdat_dm1_fxp6p2 < scfg_hm1minus_fxp6p2) begin
      ari.dpre = 1'b0;
    end
    else begin
      if (sdat_dm1_fxp6p2 > sdat_d0_fxp6p2) begin
        ari.dpre = 1'b1;
      end
      else begin
        ari.dpre = 1'b0;
      end
    end
  end
  // ----------------------------------------------------------------------

  assign o_ari_unit = ari;

endmodule

`default_nettype wire

