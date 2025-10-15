//==============================================================================
// Author: Sunjin Choi
// Description: DSP Frontend Lane Module
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

module dsp_fe_lane #(
    parameter int ADC_WIDTH = 6,
    /*parameter int DES_IN_WIDTH = 2,*/
    parameter int DES_OUT_WIDTH = 4
) (
    /*// clk and rst
     *input var logic i_rst_ref,
     *input var logic i_clk_ref,*/

    // clk from digital clockspine
    input var logic i_clk,

    // input signals
    /*input var  logic [ DES_IN_WIDTH-1:0][ADC_WIDTH-1:0] i_ana_dat_fe,*/
    /*input var logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] i_ana_dat_ad_lane_fe,*/
    input var logic [DES_OUT_WIDTH-1:0] i_dat_ad_lane_fe[ADC_WIDTH],
    output var logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] o_dat_da_lut_lane_fe,

    // TODO: good decision?
    // share en/rst with prior fanout distribution
    output var logic o_rst_glue,
    output var logic o_en_glue,

    // embedded scan i/o
    scan_if.recv i_scan,
    scan_if.send o_scan

);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam int LUT_PIPELINE_DEPTH = `LUT_PIPELINE_DEPTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  /*logic [DES_OUT_WIDTH-1:0] dat_ad_des4_lane[ADC_WIDTH];*/
  logic [ADC_WIDTH-1:0] addr_da_lut_lane[DES_OUT_WIDTH];
  logic [ADC_WIDTH-1:0] dat_da_lut_lane[DES_OUT_WIDTH];

  logic rst_sync_glue;
  logic rst_sync_lut;
  /*logic [ADC_WIDTH-1:0] clk_dig;*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic rst_glue;
  logic rst_lut;
  //logic en_des;  // TODO(check): individual or group ctrl?
  logic en_glue;
  logic en_lut;
  logic cfg_lut_mode_load;
  logic cfg_lut_mode_seed;
  logic cfg_lut_mode_mission;
  logic [(2**ADC_WIDTH)*ADC_WIDTH-1:0] cfg_lut_table;  // 2**(6)*6 = 384

  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_glue (
      .i_rst(rst_glue),  // scan-controlled reset
      .i_clk(i_clk),
      .o_rst(rst_sync_glue)
  );

  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_lut (
      .i_rst(rst_lut),  // scan-controlled reset
      .i_clk(i_clk),
      .o_rst(rst_sync_lut)
  );
  // ----------------------------------------------------------------------

  // Refactored to a separate module
  //// ----------------------------------------------------------------------
  //// DES
  //// ----------------------------------------------------------------------
  //generate
  //  for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_des_2_4
  //    des_2_to_4 des (
  //        .i_rst(i_rst_ref),
  //        .i_clk_ref(i_clk_ref),
  //        .i_en(en_des),  // TODO(check): individual or group ctrl?
  //        .i_dat(i_ana_dat_ad_lane_fe[i]),
  //        .o_clk(),
  //        .o_clk_div_2(),
  //        .o_dat(dat_ad_des4_lane[i])
  //    );
  //  end
  //endgenerate
  //// ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Retimer + DES-LUT Glue
  // ----------------------------------------------------------------------
  dsp_fe_lane_glue #(
      .ADC_WIDTH(ADC_WIDTH),
      .DES_OUT_WIDTH(DES_OUT_WIDTH)
  ) fe_lane_glue (
      .i_rst(rst_sync_glue),
      .i_clk(i_clk),
      .i_en(en_glue),  // scan-controlled enable
      .i_dat_ad_lane(i_dat_ad_lane_fe),
      .o_dat_da_lane(addr_da_lut_lane)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // LUT
  // ----------------------------------------------------------------------
  dsp_fe_lane_lut #(
      .INPUT_WIDTH(ADC_WIDTH),
      .OUTPUT_WIDTH(ADC_WIDTH),
      .REUSE_RANK(DES_OUT_WIDTH),
      .PIPELINE_DEPTH(LUT_PIPELINE_DEPTH)
      //.SEED_TABLE('0)  // TODO: fill-in
  ) dsp_fe_lane_lut (
      .i_rst(rst_sync_lut),
      .i_clk(i_clk),
      .i_en(en_lut),  // scan-controlled enable
      .i_addr_ri_lane(addr_da_lut_lane),

      .i_cfg_mode_load(cfg_lut_mode_load),  // scan-controlled
      .i_cfg_mode_seed(cfg_lut_mode_seed),  // scan-controlled
      .i_cfg_mode_mission(cfg_lut_mode_mission),  // scan-controlled
      .i_cfg_table(cfg_lut_table),  // scan-controlled

      .o_dat_ro_lane(dat_da_lut_lane)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Bundle output
  // ----------------------------------------------------------------------
  // transform btw unpacked "d" dimension to packed "d" dimension
  //always_comb begin
  //  {>>{o_dat_da_lut_lane_fe}} = {>>{dat_da_lut_lane}};
  //end

  generate
    for (genvar i = 0; i < DES_OUT_WIDTH; i++) begin : g_bundle_output
      assign o_dat_da_lut_lane_fe[i] = dat_da_lut_lane[i];
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Share Enable/Rst
  // ----------------------------------------------------------------------
  assign o_rst_glue = rst_sync_glue;
  assign o_en_glue  = en_glue;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan
  // ----------------------------------------------------------------------
  // TODO: instantiate scan
  // scan[]: rst_glue
  // scan[]: rst_lut
  // scan[]: en_glue
  // scan[]: en_lut
  // scan[]: cfg_lut_mode_load
  // scan[]: cfg_lut_mode_seed
  // scan[]: cfg_lut_mode_mission
  // scan[]: cfg_lut_table

  logic sclkp;
  logic sclkn;
  logic senable;
  logic supdate;
  logic sreset;
  logic sin;
  logic sout;
  logic [`FeLaneScanChainLength-1:0] scan_bits_wr;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_fe_lane_scan fe_lane_scan (
      .SClkP(sclkp),
      .SClkN(sclkn),
      .SReset(sreset),
      .SEnable(senable),
      .SUpdate(supdate),
      .SIn(sin),
      .SOut(sout),
      .ScanBitsRd(),
      .ScanBitsWr(scan_bits_wr)
  );

  assign rst_glue = scan_bits_wr[`FeLaneRstGlue];
  assign rst_lut = scan_bits_wr[`FeLaneRstLut];
  assign en_glue = scan_bits_wr[`FeLaneEnGlue];
  assign en_lut = scan_bits_wr[`FeLaneEnLut];
  assign cfg_lut_mode_load = scan_bits_wr[`FeLaneCfgLutModeLoad];
  assign cfg_lut_mode_seed = scan_bits_wr[`FeLaneCfgLutModeSeed];
  assign cfg_lut_mode_mission = scan_bits_wr[`FeLaneCfgLutModeMission];
  assign cfg_lut_table = scan_bits_wr[`FeLaneCfgLutTable];
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire
