//==============================================================================
// Author: Sunjin Choi
// Description: DSP Frontend
// Signals:
// Note: *ILM Block*
// Integrate Analog TDC Buffer with DSP Frontend Core
// Bit ordering conventions -- differ by case
// - ADC data is ordered in favor of the high-speed layout constraint
// i_ana_dat_lad_fe[lane][adc][des] is at ("lane"+"des"*16)-th timestep
// and does not necessarily match with the physical ordering b.c. the layout
// needed to be fine-tuned for the high-speed constraint
// e.g., i_ana_dat_lad_fe[0][i][0] is at 0-th timestep
// e.g., i_ana_dat_lad_fe[0][i][1] is at 16-th timestep
// e.g., i_ana_dat_lad_fe[1][i][0] is at 1-th timestep
// e.g., i_ana_dat_lad_fe[1][i][1] is at 17-th timestep
// - output data is ordered in favor of downstream equalizer physical design
// and simplicity of time ordering
// o_dat_rod_fe[idx] is at idx-th timestep
// e.g., o_dat_rod_fe[0] is at 0-th timestep
// e.g., o_dat_rod_fe[1] is at 1-th timestep
// e.g., o_dat_rod_fe[16] is at 16-th timestep
// e.g., o_dat_rod_fe[17] is at 17-th timestep
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_fe (
    // clk/rstb forwarded from analog (each idx corresponds to a lane)
    input var logic [15:0] irstb_deser,
    input var logic [15:0] iclk_deser,

    // input 6b signals from ADC
    // each suffix corresponds to a sub-lane where i/i+16 is the same lane
    // i.e., sharing the 1:2 deserializer and streamed into 2:4 deserializer
    input var logic [5:0] idat_deser0,
    input var logic [5:0] idat_deser1,
    input var logic [5:0] idat_deser2,
    input var logic [5:0] idat_deser3,
    input var logic [5:0] idat_deser4,
    input var logic [5:0] idat_deser5,
    input var logic [5:0] idat_deser6,
    input var logic [5:0] idat_deser7,
    input var logic [5:0] idat_deser8,
    input var logic [5:0] idat_deser9,
    input var logic [5:0] idat_deser10,
    input var logic [5:0] idat_deser11,
    input var logic [5:0] idat_deser12,
    input var logic [5:0] idat_deser13,
    input var logic [5:0] idat_deser14,
    input var logic [5:0] idat_deser15,
    input var logic [5:0] idat_deser16,
    input var logic [5:0] idat_deser17,
    input var logic [5:0] idat_deser18,
    input var logic [5:0] idat_deser19,
    input var logic [5:0] idat_deser20,
    input var logic [5:0] idat_deser21,
    input var logic [5:0] idat_deser22,
    input var logic [5:0] idat_deser23,
    input var logic [5:0] idat_deser24,
    input var logic [5:0] idat_deser25,
    input var logic [5:0] idat_deser26,
    input var logic [5:0] idat_deser27,
    input var logic [5:0] idat_deser28,
    input var logic [5:0] idat_deser29,
    input var logic [5:0] idat_deser30,
    input var logic [5:0] idat_deser31,

    // output signals
    /*output var logic [`DES_OUT_WIDTH-1:0][`ADC_WIDTH-1:0] o_dat_lda_fe[`LANE_WIDTH],*/
    /*output var logic [`LANE_WIDTH-1:0][`DES_OUT_WIDTH-1:0][`ADC_WIDTH-1:0] o_dat_lda_fe,*/
    output var logic [`LANE_WIDTH*`DES_OUT_WIDTH-1:0][`ADC_WIDTH-1:0] o_dat_fe,

    // Clockspine outputs
    /*output var logic o_clk_dig_brdg,*/
    output var logic o_clk_dig_mem,
    output var logic o_clk_dig_be,
    output var logic o_clk_dig_mon,

    //// Embedded Two-Phase Scan
    //scan_if.recv i_scan,
    //scan_if.send o_scan

    // Unwrapped scan (to avoid any SV port issues)
    input var logic i_sdata,
    input var logic i_sclkp,
    input var logic i_sclkn,
    input var logic i_senable,
    input var logic i_supdate,
    input var logic i_sreset,

    output var logic o_sdata,
    output var logic o_sclkp,
    output var logic o_sclkn,
    output var logic o_senable,
    output var logic o_supdate,
    output var logic o_sreset

);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_IN_WIDTH = `DES_IN_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic [15:0] rstb_deser_fe;
  logic [15:0] clk_deser_fe;

  logic [5:0] dat_deser0_fe;
  logic [5:0] dat_deser1_fe;
  logic [5:0] dat_deser2_fe;
  logic [5:0] dat_deser3_fe;
  logic [5:0] dat_deser4_fe;
  logic [5:0] dat_deser5_fe;
  logic [5:0] dat_deser6_fe;
  logic [5:0] dat_deser7_fe;
  logic [5:0] dat_deser8_fe;
  logic [5:0] dat_deser9_fe;
  logic [5:0] dat_deser10_fe;
  logic [5:0] dat_deser11_fe;
  logic [5:0] dat_deser12_fe;
  logic [5:0] dat_deser13_fe;
  logic [5:0] dat_deser14_fe;
  logic [5:0] dat_deser15_fe;
  logic [5:0] dat_deser16_fe;
  logic [5:0] dat_deser17_fe;
  logic [5:0] dat_deser18_fe;
  logic [5:0] dat_deser19_fe;
  logic [5:0] dat_deser20_fe;
  logic [5:0] dat_deser21_fe;
  logic [5:0] dat_deser22_fe;
  logic [5:0] dat_deser23_fe;
  logic [5:0] dat_deser24_fe;
  logic [5:0] dat_deser25_fe;
  logic [5:0] dat_deser26_fe;
  logic [5:0] dat_deser27_fe;
  logic [5:0] dat_deser28_fe;
  logic [5:0] dat_deser29_fe;
  logic [5:0] dat_deser30_fe;
  logic [5:0] dat_deser31_fe;

  logic [LANE_WIDTH-1:0][ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] ana_dat_lad_fe;
  // ----------------------------------------------------------------------


  // TODO: instantiate TDC Buffer
  // idat_deser, odat_deser, irst_deser, orst_deser, iclk_deser, oclk_deser

  AA_TDC_BUFFERS_x16 AA_TDC_BUFFERS_x16 (
      .irstb_deser(irstb_deser),
      .iclk_deser (iclk_deser),

      .idat_deser0 (idat_deser0),
      .idat_deser1 (idat_deser1),
      .idat_deser2 (idat_deser2),
      .idat_deser3 (idat_deser3),
      .idat_deser4 (idat_deser4),
      .idat_deser5 (idat_deser5),
      .idat_deser6 (idat_deser6),
      .idat_deser7 (idat_deser7),
      .idat_deser8 (idat_deser8),
      .idat_deser9 (idat_deser9),
      .idat_deser10(idat_deser10),
      .idat_deser11(idat_deser11),
      .idat_deser12(idat_deser12),
      .idat_deser13(idat_deser13),
      .idat_deser14(idat_deser14),
      .idat_deser15(idat_deser15),
      .idat_deser16(idat_deser16),
      .idat_deser17(idat_deser17),
      .idat_deser18(idat_deser18),
      .idat_deser19(idat_deser19),
      .idat_deser20(idat_deser20),
      .idat_deser21(idat_deser21),
      .idat_deser22(idat_deser22),
      .idat_deser23(idat_deser23),
      .idat_deser24(idat_deser24),
      .idat_deser25(idat_deser25),
      .idat_deser26(idat_deser26),
      .idat_deser27(idat_deser27),
      .idat_deser28(idat_deser28),
      .idat_deser29(idat_deser29),
      .idat_deser30(idat_deser30),
      .idat_deser31(idat_deser31),

      .orstb_deser(rstb_deser_fe),
      .oclk_deser (clk_deser_fe),

      .odat_deser0 (dat_deser0_fe),
      .odat_deser1 (dat_deser1_fe),
      .odat_deser2 (dat_deser2_fe),
      .odat_deser3 (dat_deser3_fe),
      .odat_deser4 (dat_deser4_fe),
      .odat_deser5 (dat_deser5_fe),
      .odat_deser6 (dat_deser6_fe),
      .odat_deser7 (dat_deser7_fe),
      .odat_deser8 (dat_deser8_fe),
      .odat_deser9 (dat_deser9_fe),
      .odat_deser10(dat_deser10_fe),
      .odat_deser11(dat_deser11_fe),
      .odat_deser12(dat_deser12_fe),
      .odat_deser13(dat_deser13_fe),
      .odat_deser14(dat_deser14_fe),
      .odat_deser15(dat_deser15_fe),
      .odat_deser16(dat_deser16_fe),
      .odat_deser17(dat_deser17_fe),
      .odat_deser18(dat_deser18_fe),
      .odat_deser19(dat_deser19_fe),
      .odat_deser20(dat_deser20_fe),
      .odat_deser21(dat_deser21_fe),
      .odat_deser22(dat_deser22_fe),
      .odat_deser23(dat_deser23_fe),
      .odat_deser24(dat_deser24_fe),
      .odat_deser25(dat_deser25_fe),
      .odat_deser26(dat_deser26_fe),
      .odat_deser27(dat_deser27_fe),
      .odat_deser28(dat_deser28_fe),
      .odat_deser29(dat_deser29_fe),
      .odat_deser30(dat_deser30_fe),
      .odat_deser31(dat_deser31_fe)

  );

  // ----------------------------------------------------------------------
  // Glue Connection btw TDC Buffer and DSP FE Core
  // ----------------------------------------------------------------------
  // Convention:
  // 1. idat_deser<i> corresponds to i-th timestep of the
  // time-interleaved interface
  // 2. ana_dat_lad_fe[lane][adc][des] corresponds to the (<lane>+<des>*16)-th
  // timestep
  // i.e., ana_dat_lad_fe[0][i][0] corresponds to 0-th timestep
  // i.e., ana_dat_lad_fe[0][i][1] corresponds to 16-th timestep
  // i.e., ana_dat_lad_fe[1][i][0] corresponds to 1-th timestep
  // i.e., ana_dat_lad_fe[1][i][1] corresponds to 17-th timestep
  // i.e., ana_dat_lad_fe[2][i][0] corresponds to 2-th timestep
  // i.e., ana_dat_lad_fe[2][i][1] corresponds to 18-th timestep
  // i.e., ana_dat_lad_fe[3][i][0] corresponds to 3-th timestep
  // i.e., ana_dat_lad_fe[3][i][1] corresponds to 19-th timestep
  // ...

  generate
    for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_adc_dsp_conn
      // [0][0] -> 0, [0][1] -> 16
      assign ana_dat_lad_fe[0][i][0]  = dat_deser0_fe[i];
      assign ana_dat_lad_fe[0][i][1]  = dat_deser16_fe[i];
      // [1][0] -> 1, [1][1] -> 17
      assign ana_dat_lad_fe[1][i][0]  = dat_deser1_fe[i];
      assign ana_dat_lad_fe[1][i][1]  = dat_deser17_fe[i];
      // [2][0] -> 2, [2][1] -> 18
      assign ana_dat_lad_fe[2][i][0]  = dat_deser2_fe[i];
      assign ana_dat_lad_fe[2][i][1]  = dat_deser18_fe[i];
      // [3][0] -> 3, [3][1] -> 19
      assign ana_dat_lad_fe[3][i][0]  = dat_deser3_fe[i];
      assign ana_dat_lad_fe[3][i][1]  = dat_deser19_fe[i];
      // [4][0] -> 4, [4][1] -> 20
      assign ana_dat_lad_fe[4][i][0]  = dat_deser4_fe[i];
      assign ana_dat_lad_fe[4][i][1]  = dat_deser20_fe[i];
      // [5][0] -> 5, [5][1] -> 21
      assign ana_dat_lad_fe[5][i][0]  = dat_deser5_fe[i];
      assign ana_dat_lad_fe[5][i][1]  = dat_deser21_fe[i];
      // [6][0] -> 6, [6][1] -> 22
      assign ana_dat_lad_fe[6][i][0]  = dat_deser6_fe[i];
      assign ana_dat_lad_fe[6][i][1]  = dat_deser22_fe[i];
      // [7][0] -> 7, [7][1] -> 23
      assign ana_dat_lad_fe[7][i][0]  = dat_deser7_fe[i];
      assign ana_dat_lad_fe[7][i][1]  = dat_deser23_fe[i];

      // [8][0] -> 8, [8][1] -> 24
      assign ana_dat_lad_fe[8][i][0]  = dat_deser8_fe[i];
      assign ana_dat_lad_fe[8][i][1]  = dat_deser24_fe[i];
      // [9][0] -> 9, [9][1] -> 25
      assign ana_dat_lad_fe[9][i][0]  = dat_deser9_fe[i];
      assign ana_dat_lad_fe[9][i][1]  = dat_deser25_fe[i];
      // [10][0] -> 10, [10][1] -> 26
      assign ana_dat_lad_fe[10][i][0] = dat_deser10_fe[i];
      assign ana_dat_lad_fe[10][i][1] = dat_deser26_fe[i];
      // [11][0] -> 11, [11][1] -> 27
      assign ana_dat_lad_fe[11][i][0] = dat_deser11_fe[i];
      assign ana_dat_lad_fe[11][i][1] = dat_deser27_fe[i];
      // [12][0] -> 12, [12][1] -> 28
      assign ana_dat_lad_fe[12][i][0] = dat_deser12_fe[i];
      assign ana_dat_lad_fe[12][i][1] = dat_deser28_fe[i];
      // [13][0] -> 13, [13][1] -> 29
      assign ana_dat_lad_fe[13][i][0] = dat_deser13_fe[i];
      assign ana_dat_lad_fe[13][i][1] = dat_deser29_fe[i];
      // [14][0] -> 14, [14][1] -> 30
      assign ana_dat_lad_fe[14][i][0] = dat_deser14_fe[i];
      assign ana_dat_lad_fe[14][i][1] = dat_deser30_fe[i];
      // [15][0] -> 15, [15][1] -> 31
      assign ana_dat_lad_fe[15][i][0] = dat_deser15_fe[i];
      assign ana_dat_lad_fe[15][i][1] = dat_deser31_fe[i];
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Frontend Core
  // ----------------------------------------------------------------------
  dsp_fe_core fe_core (
      .i_rstb_ref_bdl(rstb_deser_fe),
      .i_clk_ref_bdl (clk_deser_fe),

      .i_ana_dat_lad_fe(ana_dat_lad_fe),
      .o_dat_fe(o_dat_fe),

      /*.o_clk_dig_brdg(),*/
      .o_clk_dig_mem(o_clk_dig_mem),
      .o_clk_dig_be (o_clk_dig_be),
      .o_clk_dig_mon(o_clk_dig_mon),

      .i_sdata  (i_sdata),
      .i_sclkp  (i_sclkp),
      .i_sclkn  (i_sclkn),
      .i_senable(i_senable),
      .i_supdate(i_supdate),
      .i_sreset (i_sreset),

      .o_sdata  (o_sdata),
      .o_sclkp  (o_sclkp),
      .o_sclkn  (o_sclkn),
      .o_senable(o_senable),
      .o_supdate(o_supdate),
      .o_sreset (o_sreset)
  );
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

