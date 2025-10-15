module AnalogTop_Ver6 (
    output wire ictl_scan_ana_clk,
    output wire ictl_scan_ana_en,
    output wire ictl_scan_ana_in,
    output wire ictl_scan_ana_rst,
    input  wire octl_scan_ana_out,

    output wire ictl_scan_dig_clkn,
    output wire ictl_scan_dig_clkp,
    output wire ictl_scan_dig_en,
    output wire ictl_scan_dig_in,
    output wire ictl_scan_dig_rst,
    output wire ictl_scan_dig_update,
    input  wire octl_scan_dig_out,

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

    output wire [15:0] oclk_deser,
    output wire [15:0] orstb_deser,
    output wire [ 5:0] odat_deser0,
    output wire [ 5:0] odat_deser1,
    output wire [ 5:0] odat_deser2,
    output wire [ 5:0] odat_deser3,
    output wire [ 5:0] odat_deser4,
    output wire [ 5:0] odat_deser5,
    output wire [ 5:0] odat_deser6,
    output wire [ 5:0] odat_deser7,
    output wire [ 5:0] odat_deser8,
    output wire [ 5:0] odat_deser9,
    output wire [ 5:0] odat_deser10,
    output wire [ 5:0] odat_deser11,
    output wire [ 5:0] odat_deser12,
    output wire [ 5:0] odat_deser13,
    output wire [ 5:0] odat_deser14,
    output wire [ 5:0] odat_deser15,
    output wire [ 5:0] odat_deser16,
    output wire [ 5:0] odat_deser17,
    output wire [ 5:0] odat_deser18,
    output wire [ 5:0] odat_deser19,
    output wire [ 5:0] odat_deser20,
    output wire [ 5:0] odat_deser21,
    output wire [ 5:0] odat_deser22,
    output wire [ 5:0] odat_deser23,
    output wire [ 5:0] odat_deser24,
    output wire [ 5:0] odat_deser25,
    output wire [ 5:0] odat_deser26,
    output wire [ 5:0] odat_deser27,
    output wire [ 5:0] odat_deser28,
    output wire [ 5:0] odat_deser29,
    output wire [ 5:0] odat_deser30,
    output wire [ 5:0] odat_deser31,

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

    input wire [7:0] dp_fe_hpf_biasn,
    input wire [7:0] dp_fe_hpf_biasp,
    input wire [7:0] dp_ctle_cm_vref,
    input wire [7:0] dp_abuf_cm_vref,
    input wire [7:0] dp_hpf_biasn_0,
    input wire [7:0] dp_hpf_biasn_1,
    input wire [7:0] dp_hpf_biasn_2,
    input wire [7:0] dp_hpf_biasn_3,
    input wire [7:0] dp_hpf_biasn_4,
    input wire [7:0] dp_hpf_biasn_5,
    input wire [7:0] dp_hpf_biasn_6,
    input wire [7:0] dp_hpf_biasn_7,
    input wire [7:0] dp_hpf_biasp_0,
    input wire [7:0] dp_hpf_biasp_1,
    input wire [7:0] dp_hpf_biasp_2,
    input wire [7:0] dp_hpf_biasp_3,
    input wire [7:0] dp_hpf_biasp_4,
    input wire [7:0] dp_hpf_biasp_5,
    input wire [7:0] dp_hpf_biasp_6,
    input wire [7:0] dp_hpf_biasp_7,
    input wire [7:0] dp_tnh1_casc_bias_0,
    input wire [7:0] dp_tnh1_casc_bias_1,
    input wire [7:0] dp_tnh1_casc_bias_2,
    input wire [7:0] dp_tnh1_casc_bias_3,
    input wire [7:0] dp_tnh1_casc_bias_4,
    input wire [7:0] dp_tnh1_casc_bias_5,
    input wire [7:0] dp_tnh1_casc_bias_6,
    input wire [7:0] dp_tnh1_casc_bias_7,
    input wire [7:0] dp_tnh1_casc_bias_8,
    input wire [7:0] dp_tnh1_casc_bias_9,
    input wire [7:0] dp_tnh1_casc_bias_10,
    input wire [7:0] dp_tnh1_casc_bias_11,
    input wire [7:0] dp_tnh1_casc_bias_12,
    input wire [7:0] dp_tnh1_casc_bias_13,
    input wire [7:0] dp_tnh1_casc_bias_14,
    input wire [7:0] dp_tnh1_casc_bias_15,
    input wire [1:0] dp_tnh1_bias_0,
    input wire [1:0] dp_tnh1_bias_1,
    input wire [1:0] dp_tnh1_bias_2,
    input wire [1:0] dp_tnh1_bias_3,
    input wire [1:0] dp_tnh1_bias_4,
    input wire [1:0] dp_tnh1_bias_5,
    input wire [1:0] dp_tnh1_bias_6,
    input wire [1:0] dp_tnh1_bias_7,
    input wire [1:0] dp_tnh1_bias_8,
    input wire [1:0] dp_tnh1_bias_9,
    input wire [1:0] dp_tnh1_bias_10,
    input wire [1:0] dp_tnh1_bias_11,
    input wire [1:0] dp_tnh1_bias_12,
    input wire [1:0] dp_tnh1_bias_13,
    input wire [1:0] dp_tnh1_bias_14,
    input wire [1:0] dp_tnh1_bias_15,
    input wire [1:0] dp_sf_bias_0,
    input wire [1:0] dp_sf_bias_1,
    input wire [1:0] dp_sf_bias_2,
    input wire [1:0] dp_sf_bias_3,
    input wire [1:0] dp_sf_bias_4,
    input wire [1:0] dp_sf_bias_5,
    input wire [1:0] dp_sf_bias_6,
    input wire [1:0] dp_sf_bias_7,
    input wire [1:0] dp_sf_bias_8,
    input wire [1:0] dp_sf_bias_9,
    input wire [1:0] dp_sf_bias_10,
    input wire [1:0] dp_sf_bias_11,
    input wire [1:0] dp_sf_bias_12,
    input wire [1:0] dp_sf_bias_13,
    input wire [1:0] dp_sf_bias_14,
    input wire [1:0] dp_sf_bias_15,
    input wire [7:0] dp_tnh2_casc_bias_0,
    input wire [7:0] dp_tnh2_casc_bias_1,
    input wire [7:0] dp_tnh2_casc_bias_2,
    input wire [7:0] dp_tnh2_casc_bias_3,
    input wire [7:0] dp_tnh2_casc_bias_4,
    input wire [7:0] dp_tnh2_casc_bias_5,
    input wire [7:0] dp_tnh2_casc_bias_6,
    input wire [7:0] dp_tnh2_casc_bias_7,
    input wire [7:0] dp_tnh2_casc_bias_8,
    input wire [7:0] dp_tnh2_casc_bias_9,
    input wire [7:0] dp_tnh2_casc_bias_10,
    input wire [7:0] dp_tnh2_casc_bias_11,
    input wire [7:0] dp_tnh2_casc_bias_12,
    input wire [7:0] dp_tnh2_casc_bias_13,
    input wire [7:0] dp_tnh2_casc_bias_14,
    input wire [7:0] dp_tnh2_casc_bias_15,
    input wire [1:0] dp_tnh2_bias_0,
    input wire [1:0] dp_tnh2_bias_1,
    input wire [1:0] dp_tnh2_bias_2,
    input wire [1:0] dp_tnh2_bias_3,
    input wire [1:0] dp_tnh2_bias_4,
    input wire [1:0] dp_tnh2_bias_5,
    input wire [1:0] dp_tnh2_bias_6,
    input wire [1:0] dp_tnh2_bias_7,
    input wire [1:0] dp_tnh2_bias_8,
    input wire [1:0] dp_tnh2_bias_9,
    input wire [1:0] dp_tnh2_bias_10,
    input wire [1:0] dp_tnh2_bias_11,
    input wire [1:0] dp_tnh2_bias_12,
    input wire [1:0] dp_tnh2_bias_13,
    input wire [1:0] dp_tnh2_bias_14,
    input wire [1:0] dp_tnh2_bias_15,
    input wire [1:0] dp_vtc_bias_0,
    input wire [1:0] dp_vtc_bias_1,
    input wire [1:0] dp_vtc_bias_2,
    input wire [1:0] dp_vtc_bias_3,
    input wire [1:0] dp_vtc_bias_4,
    input wire [1:0] dp_vtc_bias_5,
    input wire [1:0] dp_vtc_bias_6,
    input wire [1:0] dp_vtc_bias_7,
    input wire [1:0] dp_vtc_bias_8,
    input wire [1:0] dp_vtc_bias_9,
    input wire [1:0] dp_vtc_bias_10,
    input wire [1:0] dp_vtc_bias_11,
    input wire [1:0] dp_vtc_bias_12,
    input wire [1:0] dp_vtc_bias_13,
    input wire [1:0] dp_vtc_bias_14,
    input wire [1:0] dp_vtc_bias_15,

    input wire dp_en_div_4to1,
    input wire dp_ringosc_en,
    input wire [8:0] dp_amux,
    input wire [15:0] dp_sel_clk_inv,

    input wire [1:0] cp_sel,
    input wire [5:0] cp_16G_ctrl_0,
    input wire [5:0] cp_16G_ctrl_1,
    input wire [5:0] cp_16G_ctrl_2,
    input wire [5:0] cp_16G_ctrl_3,
    input wire [5:0] cp_16G_ctrl_4,
    input wire [5:0] cp_16G_ctrl_5,
    input wire [5:0] cp_16G_ctrl_6,
    input wire [5:0] cp_16G_ctrl_7,
    input wire [7:0] cp_16G_ctrln,
    input wire [7:0] cp_16G_ctrlp,
    input wire [5:0] cp_8G_ctrl_0,
    input wire [5:0] cp_8G_ctrl_1,
    input wire [5:0] cp_8G_ctrl_2,
    input wire [5:0] cp_8G_ctrl_3,
    input wire [5:0] cp_8G_ctrl_4,
    input wire [5:0] cp_8G_ctrl_5,
    input wire [5:0] cp_8G_ctrl_6,
    input wire [5:0] cp_8G_ctrl_7,
    input wire [5:0] cp_8G_ctrl_8,
    input wire [5:0] cp_8G_ctrl_9,
    input wire [5:0] cp_8G_ctrl_10,
    input wire [5:0] cp_8G_ctrl_11,
    input wire [5:0] cp_8G_ctrl_12,
    input wire [5:0] cp_8G_ctrl_13,
    input wire [5:0] cp_8G_ctrl_14,
    input wire [5:0] cp_8G_ctrl_15
);


`ifdef SIMULATION
  // passthrough scan_dig from input (chiptop) to output (dsptop)
  assign ictl_scan_dig_clkn = scan_dig_clkn;
  assign ictl_scan_dig_clkp = scan_dig_clkp;
  assign ictl_scan_dig_en = scan_dig_en;
  assign ictl_scan_dig_in = scan_dig_in;
  assign ictl_scan_dig_rst = scan_dig_rst;
  assign ictl_scan_dig_update = scan_dig_update;
  assign scan_dig_out = octl_scan_dig_out;

  // pass through signals from input (chiptop) to output (dsptop)
  assign oclk_deser = iclk_deser;
  assign orstb_deser = irstb_deser;
  assign odat_deser0 = idat_deser0;
  assign odat_deser1 = idat_deser1;
  assign odat_deser2 = idat_deser2;
  assign odat_deser3 = idat_deser3;
  assign odat_deser4 = idat_deser4;
  assign odat_deser5 = idat_deser5;
  assign odat_deser6 = idat_deser6;
  assign odat_deser7 = idat_deser7;
  assign odat_deser8 = idat_deser8;
  assign odat_deser9 = idat_deser9;
  assign odat_deser10 = idat_deser10;
  assign odat_deser11 = idat_deser11;
  assign odat_deser12 = idat_deser12;
  assign odat_deser13 = idat_deser13;
  assign odat_deser14 = idat_deser14;
  assign odat_deser15 = idat_deser15;
  assign odat_deser16 = idat_deser16;
  assign odat_deser17 = idat_deser17;
  assign odat_deser18 = idat_deser18;
  assign odat_deser19 = idat_deser19;
  assign odat_deser20 = idat_deser20;
  assign odat_deser21 = idat_deser21;
  assign odat_deser22 = idat_deser22;
  assign odat_deser23 = idat_deser23;
  assign odat_deser24 = idat_deser24;
  assign odat_deser25 = idat_deser25;
  assign odat_deser26 = idat_deser26;
  assign odat_deser27 = idat_deser27;
  assign odat_deser28 = idat_deser28;
  assign odat_deser29 = idat_deser29;
  assign odat_deser30 = idat_deser30;
  assign odat_deser31 = idat_deser31;
`endif


endmodule
