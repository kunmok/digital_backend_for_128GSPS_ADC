// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module ChipTop (
    // FROM LAST-LEVEL CHIPTOP
    input  wire scan_ana_clk,
    input  wire scan_ana_en,
    input  wire scan_ana_in,
    input  wire scan_ana_rst,
    output wire scan_ana_out,

    input  wire scan_dig_clkn,
    input  wire scan_dig_clkp,
    input  wire scan_dig_en,
    input  wire scan_dig_in,
    input  wire scan_dig_rst,
    input  wire scan_dig_update,
    output wire scan_dig_out,

    // FROM DSP MEMORY
    input  wire ictl_scan_mem_clk,
    output wire octl_scan_mem_out,

`ifdef SIMULATION
    // ONLY USED FOR SIMULATION
    // In order to facilitate chip-top level simulation, iclk, irstb, idat*
    // are injected from chiptop to dsptop
    input wire [15:0] iclk_deser,
    input wire [15:0] irstb_deser,
    input wire [ 5:0] idat_deser0,
    input wire [ 5:0] idat_deser1,
    input wire [ 5:0] idat_deser2,
    input wire [ 5:0] idat_deser3,
    input wire [ 5:0] idat_deser4,
    input wire [ 5:0] idat_deser5,
    input wire [ 5:0] idat_deser6,
    input wire [ 5:0] idat_deser7,
    input wire [ 5:0] idat_deser8,
    input wire [ 5:0] idat_deser9,
    input wire [ 5:0] idat_deser10,
    input wire [ 5:0] idat_deser11,
    input wire [ 5:0] idat_deser12,
    input wire [ 5:0] idat_deser13,
    input wire [ 5:0] idat_deser14,
    input wire [ 5:0] idat_deser15,
    input wire [ 5:0] idat_deser16,
    input wire [ 5:0] idat_deser17,
    input wire [ 5:0] idat_deser18,
    input wire [ 5:0] idat_deser19,
    input wire [ 5:0] idat_deser20,
    input wire [ 5:0] idat_deser21,
    input wire [ 5:0] idat_deser22,
    input wire [ 5:0] idat_deser23,
    input wire [ 5:0] idat_deser24,
    input wire [ 5:0] idat_deser25,
    input wire [ 5:0] idat_deser26,
    input wire [ 5:0] idat_deser27,
    input wire [ 5:0] idat_deser28,
    input wire [ 5:0] idat_deser29,
    input wire [ 5:0] idat_deser30,
    input wire [ 5:0] idat_deser31,
`endif

    // FROM DSP MONITOR
    output wire odat_drx_sample,
    output wire oclk_dsp_fe
);

  // TO DSP
  wire [15:0] oclk_deser;
  wire [15:0] orstb_deser;
  wire [5:0] odat_deser0;
  wire [5:0] odat_deser1;
  wire [5:0] odat_deser2;
  wire [5:0] odat_deser3;
  wire [5:0] odat_deser4;
  wire [5:0] odat_deser5;
  wire [5:0] odat_deser6;
  wire [5:0] odat_deser7;
  wire [5:0] odat_deser8;
  wire [5:0] odat_deser9;
  wire [5:0] odat_deser10;
  wire [5:0] odat_deser11;
  wire [5:0] odat_deser12;
  wire [5:0] odat_deser13;
  wire [5:0] odat_deser14;
  wire [5:0] odat_deser15;
  wire [5:0] odat_deser16;
  wire [5:0] odat_deser17;
  wire [5:0] odat_deser18;
  wire [5:0] odat_deser19;
  wire [5:0] odat_deser20;
  wire [5:0] odat_deser21;
  wire [5:0] odat_deser22;
  wire [5:0] odat_deser23;
  wire [5:0] odat_deser24;
  wire [5:0] odat_deser25;
  wire [5:0] odat_deser26;
  wire [5:0] odat_deser27;
  wire [5:0] odat_deser28;
  wire [5:0] odat_deser29;
  wire [5:0] odat_deser30;
  wire [5:0] odat_deser31;

  // For SCAN_MEM
  // wire ictl_scan_mem_clk;
  // wire octl_scan_mem_out;

  // For SCAN_DIG
  wire ictl_scan_dig_clkn;
  wire ictl_scan_dig_clkp;
  wire ictl_scan_dig_en;
  wire ictl_scan_dig_in;
  wire ictl_scan_dig_rst;
  wire ictl_scan_dig_update;
  wire octl_scan_dig_out;

  // For SCAN_ANA
  wire ictl_scan_ana_clk;
  wire ictl_scan_ana_en;
  wire ictl_scan_ana_in;
  wire ictl_scan_ana_rst;
  wire octl_scan_ana_out;

  wire [7:0] dp_fe_hpf_biasn;
  wire [7:0] dp_fe_hpf_biasp;
  wire [7:0] dp_abuf_cm_vref;
  wire [7:0] dp_ctle_cm_vref;
  wire [7:0] dp_hpf_biasn_0;
  wire [7:0] dp_hpf_biasn_1;
  wire [7:0] dp_hpf_biasn_2;
  wire [7:0] dp_hpf_biasn_3;
  wire [7:0] dp_hpf_biasn_4;
  wire [7:0] dp_hpf_biasn_5;
  wire [7:0] dp_hpf_biasn_6;
  wire [7:0] dp_hpf_biasn_7;
  wire [7:0] dp_hpf_biasp_0;
  wire [7:0] dp_hpf_biasp_1;
  wire [7:0] dp_hpf_biasp_2;
  wire [7:0] dp_hpf_biasp_3;
  wire [7:0] dp_hpf_biasp_4;
  wire [7:0] dp_hpf_biasp_5;
  wire [7:0] dp_hpf_biasp_6;
  wire [7:0] dp_hpf_biasp_7;
  wire [7:0] dp_tnh1_casc_bias_0;
  wire [7:0] dp_tnh1_casc_bias_1;
  wire [7:0] dp_tnh1_casc_bias_2;
  wire [7:0] dp_tnh1_casc_bias_3;
  wire [7:0] dp_tnh1_casc_bias_4;
  wire [7:0] dp_tnh1_casc_bias_5;
  wire [7:0] dp_tnh1_casc_bias_6;
  wire [7:0] dp_tnh1_casc_bias_7;
  wire [7:0] dp_tnh1_casc_bias_8;
  wire [7:0] dp_tnh1_casc_bias_9;
  wire [7:0] dp_tnh1_casc_bias_10;
  wire [7:0] dp_tnh1_casc_bias_11;
  wire [7:0] dp_tnh1_casc_bias_12;
  wire [7:0] dp_tnh1_casc_bias_13;
  wire [7:0] dp_tnh1_casc_bias_14;
  wire [7:0] dp_tnh1_casc_bias_15;
  wire [1:0] dp_tnh1_bias_0;
  wire [1:0] dp_tnh1_bias_1;
  wire [1:0] dp_tnh1_bias_2;
  wire [1:0] dp_tnh1_bias_3;
  wire [1:0] dp_tnh1_bias_4;
  wire [1:0] dp_tnh1_bias_5;
  wire [1:0] dp_tnh1_bias_6;
  wire [1:0] dp_tnh1_bias_7;
  wire [1:0] dp_tnh1_bias_8;
  wire [1:0] dp_tnh1_bias_9;
  wire [1:0] dp_tnh1_bias_10;
  wire [1:0] dp_tnh1_bias_11;
  wire [1:0] dp_tnh1_bias_12;
  wire [1:0] dp_tnh1_bias_13;
  wire [1:0] dp_tnh1_bias_14;
  wire [1:0] dp_tnh1_bias_15;
  wire [1:0] dp_sf_bias_0;
  wire [1:0] dp_sf_bias_1;
  wire [1:0] dp_sf_bias_2;
  wire [1:0] dp_sf_bias_3;
  wire [1:0] dp_sf_bias_4;
  wire [1:0] dp_sf_bias_5;
  wire [1:0] dp_sf_bias_6;
  wire [1:0] dp_sf_bias_7;
  wire [1:0] dp_sf_bias_8;
  wire [1:0] dp_sf_bias_9;
  wire [1:0] dp_sf_bias_10;
  wire [1:0] dp_sf_bias_11;
  wire [1:0] dp_sf_bias_12;
  wire [1:0] dp_sf_bias_13;
  wire [1:0] dp_sf_bias_14;
  wire [1:0] dp_sf_bias_15;
  wire [7:0] dp_tnh2_casc_bias_0;
  wire [7:0] dp_tnh2_casc_bias_1;
  wire [7:0] dp_tnh2_casc_bias_2;
  wire [7:0] dp_tnh2_casc_bias_3;
  wire [7:0] dp_tnh2_casc_bias_4;
  wire [7:0] dp_tnh2_casc_bias_5;
  wire [7:0] dp_tnh2_casc_bias_6;
  wire [7:0] dp_tnh2_casc_bias_7;
  wire [7:0] dp_tnh2_casc_bias_8;
  wire [7:0] dp_tnh2_casc_bias_9;
  wire [7:0] dp_tnh2_casc_bias_10;
  wire [7:0] dp_tnh2_casc_bias_11;
  wire [7:0] dp_tnh2_casc_bias_12;
  wire [7:0] dp_tnh2_casc_bias_13;
  wire [7:0] dp_tnh2_casc_bias_14;
  wire [7:0] dp_tnh2_casc_bias_15;
  wire [1:0] dp_tnh2_bias_0;
  wire [1:0] dp_tnh2_bias_1;
  wire [1:0] dp_tnh2_bias_2;
  wire [1:0] dp_tnh2_bias_3;
  wire [1:0] dp_tnh2_bias_4;
  wire [1:0] dp_tnh2_bias_5;
  wire [1:0] dp_tnh2_bias_6;
  wire [1:0] dp_tnh2_bias_7;
  wire [1:0] dp_tnh2_bias_8;
  wire [1:0] dp_tnh2_bias_9;
  wire [1:0] dp_tnh2_bias_10;
  wire [1:0] dp_tnh2_bias_11;
  wire [1:0] dp_tnh2_bias_12;
  wire [1:0] dp_tnh2_bias_13;
  wire [1:0] dp_tnh2_bias_14;
  wire [1:0] dp_tnh2_bias_15;
  wire [1:0] dp_vtc_bias_0;
  wire [1:0] dp_vtc_bias_1;
  wire [1:0] dp_vtc_bias_2;
  wire [1:0] dp_vtc_bias_3;
  wire [1:0] dp_vtc_bias_4;
  wire [1:0] dp_vtc_bias_5;
  wire [1:0] dp_vtc_bias_6;
  wire [1:0] dp_vtc_bias_7;
  wire [1:0] dp_vtc_bias_8;
  wire [1:0] dp_vtc_bias_9;
  wire [1:0] dp_vtc_bias_10;
  wire [1:0] dp_vtc_bias_11;
  wire [1:0] dp_vtc_bias_12;
  wire [1:0] dp_vtc_bias_13;
  wire [1:0] dp_vtc_bias_14;
  wire [1:0] dp_vtc_bias_15;

  wire dp_en_div_4to1;
  wire dp_ringosc_en;
  wire [8:0] dp_amux;
  wire [15:0] dp_sel_clk_inv;

  wire [1:0] cp_sel;
  wire [5:0] cp_16G_ctrl_0;
  wire [5:0] cp_16G_ctrl_1;
  wire [5:0] cp_16G_ctrl_2;
  wire [5:0] cp_16G_ctrl_3;
  wire [5:0] cp_16G_ctrl_4;
  wire [5:0] cp_16G_ctrl_5;
  wire [5:0] cp_16G_ctrl_6;
  wire [5:0] cp_16G_ctrl_7;
  wire [7:0] cp_16G_ctrln;
  wire [7:0] cp_16G_ctrlp;
  wire [5:0] cp_8G_ctrl_0;
  wire [5:0] cp_8G_ctrl_1;
  wire [5:0] cp_8G_ctrl_2;
  wire [5:0] cp_8G_ctrl_3;
  wire [5:0] cp_8G_ctrl_4;
  wire [5:0] cp_8G_ctrl_5;
  wire [5:0] cp_8G_ctrl_6;
  wire [5:0] cp_8G_ctrl_7;
  wire [5:0] cp_8G_ctrl_8;
  wire [5:0] cp_8G_ctrl_9;
  wire [5:0] cp_8G_ctrl_10;
  wire [5:0] cp_8G_ctrl_11;
  wire [5:0] cp_8G_ctrl_12;
  wire [5:0] cp_8G_ctrl_13;
  wire [5:0] cp_8G_ctrl_14;
  wire [5:0] cp_8G_ctrl_15;

  AnalogTop_Ver6 AnalogTop (
      .ictl_scan_ana_clk(ictl_scan_ana_clk),
      .ictl_scan_ana_en (ictl_scan_ana_en),
      .ictl_scan_ana_in (ictl_scan_ana_in),
      .ictl_scan_ana_rst(ictl_scan_ana_rst),
      .octl_scan_ana_out(octl_scan_ana_out),

      .ictl_scan_dig_clkn(ictl_scan_dig_clkn),
      .ictl_scan_dig_clkp(ictl_scan_dig_clkp),
      .ictl_scan_dig_en(ictl_scan_dig_en),
      .ictl_scan_dig_in(ictl_scan_dig_in),
      .ictl_scan_dig_rst(ictl_scan_dig_rst),
      .ictl_scan_dig_update(ictl_scan_dig_update),
      .octl_scan_dig_out(octl_scan_dig_out),

      .scan_ana_clk(scan_ana_clk),
      .scan_ana_en (scan_ana_en),
      .scan_ana_in (scan_ana_in),
      .scan_ana_rst(scan_ana_rst),
      .scan_ana_out(scan_ana_out),

      .scan_dig_clkn(scan_dig_clkn),
      .scan_dig_clkp(scan_dig_clkp),
      .scan_dig_en(scan_dig_en),
      .scan_dig_in(scan_dig_in),
      .scan_dig_rst(scan_dig_rst),
      .scan_dig_update(scan_dig_update),
      .scan_dig_out(scan_dig_out),

      .oclk_deser  (oclk_deser),
      .orstb_deser (orstb_deser),
      .odat_deser0 (odat_deser0),
      .odat_deser1 (odat_deser1),
      .odat_deser2 (odat_deser2),
      .odat_deser3 (odat_deser3),
      .odat_deser4 (odat_deser4),
      .odat_deser5 (odat_deser5),
      .odat_deser6 (odat_deser6),
      .odat_deser7 (odat_deser7),
      .odat_deser8 (odat_deser8),
      .odat_deser9 (odat_deser9),
      .odat_deser10(odat_deser10),
      .odat_deser11(odat_deser11),
      .odat_deser12(odat_deser12),
      .odat_deser13(odat_deser13),
      .odat_deser14(odat_deser14),
      .odat_deser15(odat_deser15),
      .odat_deser16(odat_deser16),
      .odat_deser17(odat_deser17),
      .odat_deser18(odat_deser18),
      .odat_deser19(odat_deser19),
      .odat_deser20(odat_deser20),
      .odat_deser21(odat_deser21),
      .odat_deser22(odat_deser22),
      .odat_deser23(odat_deser23),
      .odat_deser24(odat_deser24),
      .odat_deser25(odat_deser25),
      .odat_deser26(odat_deser26),
      .odat_deser27(odat_deser27),
      .odat_deser28(odat_deser28),
      .odat_deser29(odat_deser29),
      .odat_deser30(odat_deser30),
      .odat_deser31(odat_deser31),


`ifdef SIMULATION
      // ONLY USED FOR SIMULATION
      // In order to facilitate chip-top level simulation, iclk, irstb, idat*
      // are injected from chiptop to anatop to dsptop
      .iclk_deser  (iclk_deser),
      .irstb_deser (irstb_deser),
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
`endif


      .dp_fe_hpf_biasn(dp_fe_hpf_biasn),
      .dp_fe_hpf_biasp(dp_fe_hpf_biasp),
      .dp_ctle_cm_vref(dp_ctle_cm_vref),
      .dp_abuf_cm_vref(dp_abuf_cm_vref),

      .dp_hpf_biasn_0(dp_hpf_biasn_0),
      .dp_hpf_biasn_1(dp_hpf_biasn_1),
      .dp_hpf_biasn_2(dp_hpf_biasn_2),
      .dp_hpf_biasn_3(dp_hpf_biasn_3),
      .dp_hpf_biasn_4(dp_hpf_biasn_4),
      .dp_hpf_biasn_5(dp_hpf_biasn_5),
      .dp_hpf_biasn_6(dp_hpf_biasn_6),
      .dp_hpf_biasn_7(dp_hpf_biasn_7),
      .dp_hpf_biasp_0(dp_hpf_biasp_0),
      .dp_hpf_biasp_1(dp_hpf_biasp_1),
      .dp_hpf_biasp_2(dp_hpf_biasp_2),
      .dp_hpf_biasp_3(dp_hpf_biasp_3),
      .dp_hpf_biasp_4(dp_hpf_biasp_4),
      .dp_hpf_biasp_5(dp_hpf_biasp_5),
      .dp_hpf_biasp_6(dp_hpf_biasp_6),
      .dp_hpf_biasp_7(dp_hpf_biasp_7),

      .dp_tnh1_casc_bias_0(dp_tnh1_casc_bias_0),
      .dp_tnh1_casc_bias_1(dp_tnh1_casc_bias_1),
      .dp_tnh1_casc_bias_2(dp_tnh1_casc_bias_2),
      .dp_tnh1_casc_bias_3(dp_tnh1_casc_bias_3),
      .dp_tnh1_casc_bias_4(dp_tnh1_casc_bias_4),
      .dp_tnh1_casc_bias_5(dp_tnh1_casc_bias_5),
      .dp_tnh1_casc_bias_6(dp_tnh1_casc_bias_6),
      .dp_tnh1_casc_bias_7(dp_tnh1_casc_bias_7),
      .dp_tnh1_casc_bias_8(dp_tnh1_casc_bias_8),
      .dp_tnh1_casc_bias_9(dp_tnh1_casc_bias_9),
      .dp_tnh1_casc_bias_10(dp_tnh1_casc_bias_10),
      .dp_tnh1_casc_bias_11(dp_tnh1_casc_bias_11),
      .dp_tnh1_casc_bias_12(dp_tnh1_casc_bias_12),
      .dp_tnh1_casc_bias_13(dp_tnh1_casc_bias_13),
      .dp_tnh1_casc_bias_14(dp_tnh1_casc_bias_14),
      .dp_tnh1_casc_bias_15(dp_tnh1_casc_bias_15),
      .dp_tnh1_bias_0(dp_tnh1_bias_0),
      .dp_tnh1_bias_1(dp_tnh1_bias_1),
      .dp_tnh1_bias_2(dp_tnh1_bias_2),
      .dp_tnh1_bias_3(dp_tnh1_bias_3),
      .dp_tnh1_bias_4(dp_tnh1_bias_4),
      .dp_tnh1_bias_5(dp_tnh1_bias_5),
      .dp_tnh1_bias_6(dp_tnh1_bias_6),
      .dp_tnh1_bias_7(dp_tnh1_bias_7),
      .dp_tnh1_bias_8(dp_tnh1_bias_8),
      .dp_tnh1_bias_9(dp_tnh1_bias_9),
      .dp_tnh1_bias_10(dp_tnh1_bias_10),
      .dp_tnh1_bias_11(dp_tnh1_bias_11),
      .dp_tnh1_bias_12(dp_tnh1_bias_12),
      .dp_tnh1_bias_13(dp_tnh1_bias_13),
      .dp_tnh1_bias_14(dp_tnh1_bias_14),
      .dp_tnh1_bias_15(dp_tnh1_bias_15),

      .dp_tnh2_casc_bias_0(dp_tnh2_casc_bias_0),
      .dp_tnh2_casc_bias_1(dp_tnh2_casc_bias_1),
      .dp_tnh2_casc_bias_2(dp_tnh2_casc_bias_2),
      .dp_tnh2_casc_bias_3(dp_tnh2_casc_bias_3),
      .dp_tnh2_casc_bias_4(dp_tnh2_casc_bias_4),
      .dp_tnh2_casc_bias_5(dp_tnh2_casc_bias_5),
      .dp_tnh2_casc_bias_6(dp_tnh2_casc_bias_6),
      .dp_tnh2_casc_bias_7(dp_tnh2_casc_bias_7),
      .dp_tnh2_casc_bias_8(dp_tnh2_casc_bias_8),
      .dp_tnh2_casc_bias_9(dp_tnh2_casc_bias_9),
      .dp_tnh2_casc_bias_10(dp_tnh2_casc_bias_10),
      .dp_tnh2_casc_bias_11(dp_tnh2_casc_bias_11),
      .dp_tnh2_casc_bias_12(dp_tnh2_casc_bias_12),
      .dp_tnh2_casc_bias_13(dp_tnh2_casc_bias_13),
      .dp_tnh2_casc_bias_14(dp_tnh2_casc_bias_14),
      .dp_tnh2_casc_bias_15(dp_tnh2_casc_bias_15),
      .dp_tnh2_bias_0(dp_tnh2_bias_0),
      .dp_tnh2_bias_1(dp_tnh2_bias_1),
      .dp_tnh2_bias_2(dp_tnh2_bias_2),
      .dp_tnh2_bias_3(dp_tnh2_bias_3),
      .dp_tnh2_bias_4(dp_tnh2_bias_4),
      .dp_tnh2_bias_5(dp_tnh2_bias_5),
      .dp_tnh2_bias_6(dp_tnh2_bias_6),
      .dp_tnh2_bias_7(dp_tnh2_bias_7),
      .dp_tnh2_bias_8(dp_tnh2_bias_8),
      .dp_tnh2_bias_9(dp_tnh2_bias_9),
      .dp_tnh2_bias_10(dp_tnh2_bias_10),
      .dp_tnh2_bias_11(dp_tnh2_bias_11),
      .dp_tnh2_bias_12(dp_tnh2_bias_12),
      .dp_tnh2_bias_13(dp_tnh2_bias_13),
      .dp_tnh2_bias_14(dp_tnh2_bias_14),
      .dp_tnh2_bias_15(dp_tnh2_bias_15),

      .dp_sf_bias_0 (dp_sf_bias_0),
      .dp_sf_bias_1 (dp_sf_bias_1),
      .dp_sf_bias_2 (dp_sf_bias_2),
      .dp_sf_bias_3 (dp_sf_bias_3),
      .dp_sf_bias_4 (dp_sf_bias_4),
      .dp_sf_bias_5 (dp_sf_bias_5),
      .dp_sf_bias_6 (dp_sf_bias_6),
      .dp_sf_bias_7 (dp_sf_bias_7),
      .dp_sf_bias_8 (dp_sf_bias_8),
      .dp_sf_bias_9 (dp_sf_bias_9),
      .dp_sf_bias_10(dp_sf_bias_10),
      .dp_sf_bias_11(dp_sf_bias_11),
      .dp_sf_bias_12(dp_sf_bias_12),
      .dp_sf_bias_13(dp_sf_bias_13),
      .dp_sf_bias_14(dp_sf_bias_14),
      .dp_sf_bias_15(dp_sf_bias_15),

      .dp_vtc_bias_0 (dp_vtc_bias_0),
      .dp_vtc_bias_1 (dp_vtc_bias_1),
      .dp_vtc_bias_2 (dp_vtc_bias_2),
      .dp_vtc_bias_3 (dp_vtc_bias_3),
      .dp_vtc_bias_4 (dp_vtc_bias_4),
      .dp_vtc_bias_5 (dp_vtc_bias_5),
      .dp_vtc_bias_6 (dp_vtc_bias_6),
      .dp_vtc_bias_7 (dp_vtc_bias_7),
      .dp_vtc_bias_8 (dp_vtc_bias_8),
      .dp_vtc_bias_9 (dp_vtc_bias_9),
      .dp_vtc_bias_10(dp_vtc_bias_10),
      .dp_vtc_bias_11(dp_vtc_bias_11),
      .dp_vtc_bias_12(dp_vtc_bias_12),
      .dp_vtc_bias_13(dp_vtc_bias_13),
      .dp_vtc_bias_14(dp_vtc_bias_14),
      .dp_vtc_bias_15(dp_vtc_bias_15),

      .dp_en_div_4to1(dp_en_div_4to1),
      .dp_ringosc_en(dp_ringosc_en),
      .dp_amux(dp_amux),
      .dp_sel_clk_inv(dp_sel_clk_inv),

      .cp_sel(cp_sel),
      .cp_16G_ctrl_0(cp_16G_ctrl_0),
      .cp_16G_ctrl_1(cp_16G_ctrl_1),
      .cp_16G_ctrl_2(cp_16G_ctrl_2),
      .cp_16G_ctrl_3(cp_16G_ctrl_3),
      .cp_16G_ctrl_4(cp_16G_ctrl_4),
      .cp_16G_ctrl_5(cp_16G_ctrl_5),
      .cp_16G_ctrl_6(cp_16G_ctrl_6),
      .cp_16G_ctrl_7(cp_16G_ctrl_7),
      .cp_16G_ctrln(cp_16G_ctrln),
      .cp_16G_ctrlp(cp_16G_ctrlp),
      .cp_8G_ctrl_0(cp_8G_ctrl_0),
      .cp_8G_ctrl_1(cp_8G_ctrl_1),
      .cp_8G_ctrl_2(cp_8G_ctrl_2),
      .cp_8G_ctrl_3(cp_8G_ctrl_3),
      .cp_8G_ctrl_4(cp_8G_ctrl_4),
      .cp_8G_ctrl_5(cp_8G_ctrl_5),
      .cp_8G_ctrl_6(cp_8G_ctrl_6),
      .cp_8G_ctrl_7(cp_8G_ctrl_7),
      .cp_8G_ctrl_8(cp_8G_ctrl_8),
      .cp_8G_ctrl_9(cp_8G_ctrl_9),
      .cp_8G_ctrl_10(cp_8G_ctrl_10),
      .cp_8G_ctrl_11(cp_8G_ctrl_11),
      .cp_8G_ctrl_12(cp_8G_ctrl_12),
      .cp_8G_ctrl_13(cp_8G_ctrl_13),
      .cp_8G_ctrl_14(cp_8G_ctrl_14),
      .cp_8G_ctrl_15(cp_8G_ctrl_15)
  );

  dsp_top dsp_top (
      .irstb_deser(orstb_deser),
      .iclk_deser (oclk_deser),

      .idat_deser0 (odat_deser0),
      .idat_deser1 (odat_deser1),
      .idat_deser2 (odat_deser2),
      .idat_deser3 (odat_deser3),
      .idat_deser4 (odat_deser4),
      .idat_deser5 (odat_deser5),
      .idat_deser6 (odat_deser6),
      .idat_deser7 (odat_deser7),
      .idat_deser8 (odat_deser8),
      .idat_deser9 (odat_deser9),
      .idat_deser10(odat_deser10),
      .idat_deser11(odat_deser11),
      .idat_deser12(odat_deser12),
      .idat_deser13(odat_deser13),
      .idat_deser14(odat_deser14),
      .idat_deser15(odat_deser15),
      .idat_deser16(odat_deser16),
      .idat_deser17(odat_deser17),
      .idat_deser18(odat_deser18),
      .idat_deser19(odat_deser19),
      .idat_deser20(odat_deser20),
      .idat_deser21(odat_deser21),
      .idat_deser22(odat_deser22),
      .idat_deser23(odat_deser23),
      .idat_deser24(odat_deser24),
      .idat_deser25(odat_deser25),
      .idat_deser26(odat_deser26),
      .idat_deser27(odat_deser27),
      .idat_deser28(odat_deser28),
      .idat_deser29(odat_deser29),
      .idat_deser30(odat_deser30),
      .idat_deser31(odat_deser31),

      .i_scan_dig_clkp(ictl_scan_dig_clkp),
      .i_scan_dig_clkn(ictl_scan_dig_clkn),
      .i_scan_dig_reset(ictl_scan_dig_rst),
      .i_scan_dig_enable(ictl_scan_dig_en),
      .i_scan_dig_update(ictl_scan_dig_update),
      .i_scan_dig_in(ictl_scan_dig_in),

      .i_scan_mem_clk(ictl_scan_mem_clk),

      .o_scan_dig_out(octl_scan_dig_out),
      .o_scan_mem_out(octl_scan_mem_out),

      .o_drx_sample(odat_drx_sample),
      .o_clk_dsp_fe(oclk_dsp_fe)
  );

  ScanTop scan (
      .scan_clk(ictl_scan_ana_clk),
      .scan_en(ictl_scan_ana_en),
      .scan_in(ictl_scan_ana_in),
      .scan_reset(ictl_scan_ana_rst),
      .scan_out(octl_scan_ana_out),
      .dp_fe_hpf_biasn(dp_fe_hpf_biasn),
      .dp_fe_hpf_biasp(dp_fe_hpf_biasp),
      .dp_ctle_cm_vref(dp_ctle_cm_vref),
      .dp_abuf_cm_vref(dp_abuf_cm_vref),

      .dp_hpf_biasn_0(dp_hpf_biasn_0),
      .dp_hpf_biasn_1(dp_hpf_biasn_1),
      .dp_hpf_biasn_2(dp_hpf_biasn_2),
      .dp_hpf_biasn_3(dp_hpf_biasn_3),
      .dp_hpf_biasn_4(dp_hpf_biasn_4),
      .dp_hpf_biasn_5(dp_hpf_biasn_5),
      .dp_hpf_biasn_6(dp_hpf_biasn_6),
      .dp_hpf_biasn_7(dp_hpf_biasn_7),
      .dp_hpf_biasp_0(dp_hpf_biasp_0),
      .dp_hpf_biasp_1(dp_hpf_biasp_1),
      .dp_hpf_biasp_2(dp_hpf_biasp_2),
      .dp_hpf_biasp_3(dp_hpf_biasp_3),
      .dp_hpf_biasp_4(dp_hpf_biasp_4),
      .dp_hpf_biasp_5(dp_hpf_biasp_5),
      .dp_hpf_biasp_6(dp_hpf_biasp_6),
      .dp_hpf_biasp_7(dp_hpf_biasp_7),

      .dp_tnh1_casc_bias_0(dp_tnh1_casc_bias_0),
      .dp_tnh1_casc_bias_1(dp_tnh1_casc_bias_1),
      .dp_tnh1_casc_bias_2(dp_tnh1_casc_bias_2),
      .dp_tnh1_casc_bias_3(dp_tnh1_casc_bias_3),
      .dp_tnh1_casc_bias_4(dp_tnh1_casc_bias_4),
      .dp_tnh1_casc_bias_5(dp_tnh1_casc_bias_5),
      .dp_tnh1_casc_bias_6(dp_tnh1_casc_bias_6),
      .dp_tnh1_casc_bias_7(dp_tnh1_casc_bias_7),
      .dp_tnh1_casc_bias_8(dp_tnh1_casc_bias_8),
      .dp_tnh1_casc_bias_9(dp_tnh1_casc_bias_9),
      .dp_tnh1_casc_bias_10(dp_tnh1_casc_bias_10),
      .dp_tnh1_casc_bias_11(dp_tnh1_casc_bias_11),
      .dp_tnh1_casc_bias_12(dp_tnh1_casc_bias_12),
      .dp_tnh1_casc_bias_13(dp_tnh1_casc_bias_13),
      .dp_tnh1_casc_bias_14(dp_tnh1_casc_bias_14),
      .dp_tnh1_casc_bias_15(dp_tnh1_casc_bias_15),
      .dp_tnh1_bias_0(dp_tnh1_bias_0),
      .dp_tnh1_bias_1(dp_tnh1_bias_1),
      .dp_tnh1_bias_2(dp_tnh1_bias_2),
      .dp_tnh1_bias_3(dp_tnh1_bias_3),
      .dp_tnh1_bias_4(dp_tnh1_bias_4),
      .dp_tnh1_bias_5(dp_tnh1_bias_5),
      .dp_tnh1_bias_6(dp_tnh1_bias_6),
      .dp_tnh1_bias_7(dp_tnh1_bias_7),
      .dp_tnh1_bias_8(dp_tnh1_bias_8),
      .dp_tnh1_bias_9(dp_tnh1_bias_9),
      .dp_tnh1_bias_10(dp_tnh1_bias_10),
      .dp_tnh1_bias_11(dp_tnh1_bias_11),
      .dp_tnh1_bias_12(dp_tnh1_bias_12),
      .dp_tnh1_bias_13(dp_tnh1_bias_13),
      .dp_tnh1_bias_14(dp_tnh1_bias_14),
      .dp_tnh1_bias_15(dp_tnh1_bias_15),

      .dp_tnh2_casc_bias_0(dp_tnh2_casc_bias_0),
      .dp_tnh2_casc_bias_1(dp_tnh2_casc_bias_1),
      .dp_tnh2_casc_bias_2(dp_tnh2_casc_bias_2),
      .dp_tnh2_casc_bias_3(dp_tnh2_casc_bias_3),
      .dp_tnh2_casc_bias_4(dp_tnh2_casc_bias_4),
      .dp_tnh2_casc_bias_5(dp_tnh2_casc_bias_5),
      .dp_tnh2_casc_bias_6(dp_tnh2_casc_bias_6),
      .dp_tnh2_casc_bias_7(dp_tnh2_casc_bias_7),
      .dp_tnh2_casc_bias_8(dp_tnh2_casc_bias_8),
      .dp_tnh2_casc_bias_9(dp_tnh2_casc_bias_9),
      .dp_tnh2_casc_bias_10(dp_tnh2_casc_bias_10),
      .dp_tnh2_casc_bias_11(dp_tnh2_casc_bias_11),
      .dp_tnh2_casc_bias_12(dp_tnh2_casc_bias_12),
      .dp_tnh2_casc_bias_13(dp_tnh2_casc_bias_13),
      .dp_tnh2_casc_bias_14(dp_tnh2_casc_bias_14),
      .dp_tnh2_casc_bias_15(dp_tnh2_casc_bias_15),
      .dp_tnh2_bias_0(dp_tnh2_bias_0),
      .dp_tnh2_bias_1(dp_tnh2_bias_1),
      .dp_tnh2_bias_2(dp_tnh2_bias_2),
      .dp_tnh2_bias_3(dp_tnh2_bias_3),
      .dp_tnh2_bias_4(dp_tnh2_bias_4),
      .dp_tnh2_bias_5(dp_tnh2_bias_5),
      .dp_tnh2_bias_6(dp_tnh2_bias_6),
      .dp_tnh2_bias_7(dp_tnh2_bias_7),
      .dp_tnh2_bias_8(dp_tnh2_bias_8),
      .dp_tnh2_bias_9(dp_tnh2_bias_9),
      .dp_tnh2_bias_10(dp_tnh2_bias_10),
      .dp_tnh2_bias_11(dp_tnh2_bias_11),
      .dp_tnh2_bias_12(dp_tnh2_bias_12),
      .dp_tnh2_bias_13(dp_tnh2_bias_13),
      .dp_tnh2_bias_14(dp_tnh2_bias_14),
      .dp_tnh2_bias_15(dp_tnh2_bias_15),

      .dp_sf_bias_0 (dp_sf_bias_0),
      .dp_sf_bias_1 (dp_sf_bias_1),
      .dp_sf_bias_2 (dp_sf_bias_2),
      .dp_sf_bias_3 (dp_sf_bias_3),
      .dp_sf_bias_4 (dp_sf_bias_4),
      .dp_sf_bias_5 (dp_sf_bias_5),
      .dp_sf_bias_6 (dp_sf_bias_6),
      .dp_sf_bias_7 (dp_sf_bias_7),
      .dp_sf_bias_8 (dp_sf_bias_8),
      .dp_sf_bias_9 (dp_sf_bias_9),
      .dp_sf_bias_10(dp_sf_bias_10),
      .dp_sf_bias_11(dp_sf_bias_11),
      .dp_sf_bias_12(dp_sf_bias_12),
      .dp_sf_bias_13(dp_sf_bias_13),
      .dp_sf_bias_14(dp_sf_bias_14),
      .dp_sf_bias_15(dp_sf_bias_15),

      .dp_vtc_bias_0 (dp_vtc_bias_0),
      .dp_vtc_bias_1 (dp_vtc_bias_1),
      .dp_vtc_bias_2 (dp_vtc_bias_2),
      .dp_vtc_bias_3 (dp_vtc_bias_3),
      .dp_vtc_bias_4 (dp_vtc_bias_4),
      .dp_vtc_bias_5 (dp_vtc_bias_5),
      .dp_vtc_bias_6 (dp_vtc_bias_6),
      .dp_vtc_bias_7 (dp_vtc_bias_7),
      .dp_vtc_bias_8 (dp_vtc_bias_8),
      .dp_vtc_bias_9 (dp_vtc_bias_9),
      .dp_vtc_bias_10(dp_vtc_bias_10),
      .dp_vtc_bias_11(dp_vtc_bias_11),
      .dp_vtc_bias_12(dp_vtc_bias_12),
      .dp_vtc_bias_13(dp_vtc_bias_13),
      .dp_vtc_bias_14(dp_vtc_bias_14),
      .dp_vtc_bias_15(dp_vtc_bias_15),

      .cp_sel(cp_sel),
      .cp_16G_ctrl_0(cp_16G_ctrl_0),
      .cp_16G_ctrl_1(cp_16G_ctrl_1),
      .cp_16G_ctrl_2(cp_16G_ctrl_2),
      .cp_16G_ctrl_3(cp_16G_ctrl_3),
      .cp_16G_ctrl_4(cp_16G_ctrl_4),
      .cp_16G_ctrl_5(cp_16G_ctrl_5),
      .cp_16G_ctrl_6(cp_16G_ctrl_6),
      .cp_16G_ctrl_7(cp_16G_ctrl_7),
      .cp_16G_ctrln(cp_16G_ctrln),
      .cp_16G_ctrlp(cp_16G_ctrlp),
      .cp_8G_ctrl_0(cp_8G_ctrl_0),
      .cp_8G_ctrl_1(cp_8G_ctrl_1),
      .cp_8G_ctrl_2(cp_8G_ctrl_2),
      .cp_8G_ctrl_3(cp_8G_ctrl_3),
      .cp_8G_ctrl_4(cp_8G_ctrl_4),
      .cp_8G_ctrl_5(cp_8G_ctrl_5),
      .cp_8G_ctrl_6(cp_8G_ctrl_6),
      .cp_8G_ctrl_7(cp_8G_ctrl_7),
      .cp_8G_ctrl_8(cp_8G_ctrl_8),
      .cp_8G_ctrl_9(cp_8G_ctrl_9),
      .cp_8G_ctrl_10(cp_8G_ctrl_10),
      .cp_8G_ctrl_11(cp_8G_ctrl_11),
      .cp_8G_ctrl_12(cp_8G_ctrl_12),
      .cp_8G_ctrl_13(cp_8G_ctrl_13),
      .cp_8G_ctrl_14(cp_8G_ctrl_14),
      .cp_8G_ctrl_15(cp_8G_ctrl_15),

      .dp_en_div_4to1(dp_en_div_4to1),
      .dp_ringosc_en(dp_ringosc_en),
      .dp_amux(dp_amux),
      .dp_sel_clk_inv(dp_sel_clk_inv)
  );

endmodule

