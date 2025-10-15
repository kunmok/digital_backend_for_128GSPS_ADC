//==============================================================================
// Author: Sunjin Choi
// Description: 
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

module dsp_top (
    input var logic [15:0] irstb_deser,
    input var logic [15:0] iclk_deser,

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

    input var logic i_scan_dig_clkp,
    input var logic i_scan_dig_clkn,
    input var logic i_scan_dig_reset,
    input var logic i_scan_dig_enable,
    input var logic i_scan_dig_update,
    input var logic i_scan_dig_in,

    input var logic i_scan_mem_clk,

    output var logic o_scan_dig_out,
    output var logic o_scan_mem_out,

    output var logic o_drx_sample,
    output var logic o_clk_dsp_fe
);

  // ----------------------------------------------------------------------
  // Localparams
  // ----------------------------------------------------------------------
  localparam int LANE_WIDTH = 16;
  localparam int ADC_WIDTH = 6;
  localparam int DES_IN_WIDTH = 2;
  localparam int DES_OUT_WIDTH = 4;
  localparam int PRLL_RANK = 64;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // unwrapped scan signals for frontend digital (fd)
  logic i_sdata_fd;
  logic i_sclkp_fd;
  logic i_sclkn_fd;
  logic i_senable_fd;
  logic i_supdate_fd;
  logic i_sreset_fd;

  logic o_sdata_fd;
  logic o_sclkp_fd;
  logic o_sclkn_fd;
  logic o_senable_fd;
  logic o_supdate_fd;
  logic o_sreset_fd;

  // unwrapped scan signals for memory digital (md)
  logic i_sdata_md;
  logic i_sclkp_md;
  logic i_sclkn_md;
  logic i_senable_md;
  logic i_supdate_md;
  logic i_sreset_md;

  logic o_sdata_md;
  logic o_sclkp_md;
  logic o_sclkn_md;
  logic o_senable_md;
  logic o_supdate_md;
  logic o_sreset_md;

  // unwrapped scan signals for backend digital (bd)
  logic i_sdata_bd;
  logic i_sclkp_bd;
  logic i_sclkn_bd;
  logic i_senable_bd;
  logic i_supdate_bd;
  logic i_sreset_bd;

  logic o_sdata_bd;
  logic o_sclkp_bd;
  logic o_sclkn_bd;
  logic o_senable_bd;
  logic o_supdate_bd;
  logic o_sreset_bd;

  logic clk_dig_mem;
  logic clk_dig_be;
  logic clk_dig_mon;

  // LANE_WIDTH = 16, ADC_WIDTH = 6, DES_IN_WIDTH = 2
  // ANA <-> DSP-FE
  logic [LANE_WIDTH-1:0][ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] ana_dat_lad_fe;

  // DSP-FE <-> DSP-MEM & DSP-BE
  logic [LANE_WIDTH*DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] dat_adc;

  // DSP-BE EQ/Receiver Out
  logic [PRLL_RANK-1:0] dat_drx;

  // ----------------------------------------------------------------------
  // Scans
  // ----------------------------------------------------------------------
  scan_if i_scan_fd ();
  scan_if o_scan_fd ();

  scan_if i_scan_md ();
  scan_if o_scan_md ();

  scan_if i_scan_bd ();
  scan_if o_scan_bd ();

  // connect input scan to i_scan_fd (frontend scan)
  /*assign i_scan_fd.sdata = i_sdata_fd;
   *assign i_scan_fd.sctrl = {i_sclkp_fd, i_sclkn_fd, i_senable_fd, i_supdate_fd, i_sreset_fd};*/
  assign i_scan_fd.sdata = i_scan_dig_in;
  assign i_scan_fd.sctrl = {
    i_scan_dig_clkp, i_scan_dig_clkn, i_scan_dig_enable, i_scan_dig_update, i_scan_dig_reset
  };

  // connect frontend scan to memory scan
  assign i_scan_md.sdata = o_scan_fd.sdata;
  assign i_scan_md.sctrl = o_scan_fd.sctrl;

  // connect memory scan to backend scan
  assign i_scan_bd.sdata = o_scan_md.sdata;
  assign i_scan_bd.sctrl = o_scan_md.sctrl;

  //// connect o_scan_md to output scan
  /*assign o_sdata_md = o_scan_md.sdata;
   *assign {o_sclkp_md, o_sclkn_md, o_senable_md, o_supdate_md, o_sreset_md} = o_scan_md.sctrl;*/
  //assign o_scan_dig_out = o_scan_md.sdata;

  // connect o_scan_bd to output scan
  assign o_scan_dig_out = o_scan_bd.sdata;

  // unwrap scans
  assign i_sdata_fd = i_scan_fd.sdata;
  assign {i_sclkp_fd, i_sclkn_fd, i_senable_fd, i_supdate_fd, i_sreset_fd} = i_scan_fd.sctrl;

  assign o_scan_fd.sdata = o_sdata_fd;
  assign o_scan_fd.sctrl = {o_sclkp_fd, o_sclkn_fd, o_senable_fd, o_supdate_fd, o_sreset_fd};

  assign i_sdata_md = i_scan_md.sdata;
  assign {i_sclkp_md, i_sclkn_md, i_senable_md, i_supdate_md, i_sreset_md} = i_scan_md.sctrl;

  assign o_scan_md.sdata = o_sdata_md;
  assign o_scan_md.sctrl = {o_sclkp_md, o_sclkn_md, o_senable_md, o_supdate_md, o_sreset_md};

  assign i_sdata_bd = i_scan_bd.sdata;
  assign {i_sclkp_bd, i_sclkn_bd, i_senable_bd, i_supdate_bd, i_sreset_bd} = i_scan_bd.sctrl;

  assign o_scan_bd.sdata = o_sdata_bd;
  assign o_scan_bd.sctrl = {o_sclkp_bd, o_sclkn_bd, o_senable_bd, o_supdate_bd, o_sreset_bd};
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Modules
  // ----------------------------------------------------------------------
  dsp_fe dsp_fe (
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

      .o_dat_fe(dat_adc),
      /*.o_clk_dig_brdg(),*/
      .o_clk_dig_mem(clk_dig_mem),
      .o_clk_dig_be(clk_dig_be),
      .o_clk_dig_mon(clk_dig_mon),

      .i_sdata  (i_sdata_fd),
      .i_sclkp  (i_sclkp_fd),
      .i_sclkn  (i_sclkn_fd),
      .i_senable(i_senable_fd),
      .i_supdate(i_supdate_fd),
      .i_sreset (i_sreset_fd),

      .o_sdata  (o_sdata_fd),
      .o_sclkp  (o_sclkp_fd),
      .o_sclkn  (o_sclkn_fd),
      .o_senable(o_senable_fd),
      .o_supdate(o_supdate_fd),
      .o_sreset (o_sreset_fd)
  );

  dsp_mem dsp_mem (
      .i_clk_dig_mem(clk_dig_mem),
      .i_dat_mem(dat_adc),
      .i_clk_read_mem(i_scan_mem_clk),
      .o_bit_read_mem(o_scan_mem_out),
      .i_sdata(i_sdata_md),
      .i_sclkp(i_sclkp_md),
      .i_sclkn(i_sclkn_md),
      .i_senable(i_senable_md),
      .i_supdate(i_supdate_md),
      .i_sreset(i_sreset_md),
      .o_sdata(o_sdata_md),
      .o_sclkp(o_sclkp_md),
      .o_sclkn(o_sclkn_md),
      .o_senable(o_senable_md),
      .o_supdate(o_supdate_md),
      .o_sreset(o_sreset_md)
  );

  dsp_be dsp_be (
      .i_clk_dig_be(clk_dig_be),
      .i_dat_be(dat_adc),
      .o_drx(dat_drx),
      .i_sdata(i_sdata_bd),
      .i_sclkp(i_sclkp_bd),
      .i_sclkn(i_sclkn_bd),
      .i_senable(i_senable_bd),
      .i_supdate(i_supdate_bd),
      .i_sreset(i_sreset_bd),
      .o_sdata(o_sdata_bd),
      .o_sclkp(o_sclkp_bd),
      .o_sclkn(o_sclkn_bd),
      .o_senable(o_senable_bd),
      .o_supdate(o_supdate_bd),
      .o_sreset(o_sreset_bd)
  );
  // ----------------------------------------------------------------------

  // Subsample dat_drx
  assign o_drx_sample = dat_drx[0];
  // Connect clk_mon to ChipTop
  assign o_clk_dsp_fe = clk_dig_mon;


endmodule

`default_nettype wire

