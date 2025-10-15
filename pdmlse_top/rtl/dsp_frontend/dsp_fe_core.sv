//==============================================================================
// Author: Sunjin Choi
// Description: DSP Frontend
// Signals:
// Note:
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


// For ease-of-synthesis, ports of this block are in all packed dims
module dsp_fe_core (
    // clk/rst-fwd from analog is per-lane or per-des_1_2
    // input signals
    //input var logic i_rstb_ref_bdl[`LANE_WIDTH],  // TODO(sunjin): double check
    //input var logic i_clk_ref_bdl [`LANE_WIDTH],
    input var logic [`LANE_WIDTH-1:0] i_rstb_ref_bdl,  // TODO(sunjin): double check
    input var logic [`LANE_WIDTH-1:0] i_clk_ref_bdl,

    /*input var logic [`ADC_WIDTH-1:0][`DES_IN_WIDTH-1:0] i_ana_dat_lad_fe[`LANE_WIDTH],*/
    input var logic [`LANE_WIDTH-1:0][`ADC_WIDTH-1:0][`DES_IN_WIDTH-1:0] i_ana_dat_lad_fe,

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

  localparam int REORDER_PIPELINE_DEPTH = `REORDER_PIPELINE_DEPTH;
  localparam int DES_TO_LUT_PIPELINE_DEPTH = `DES_TO_LUT_PIPELINE_DEPTH;

  // Lane physical-to-logical ordering (from bottom to top)
  // 0 -> 8 -> 12 -> 4 -> 13 -> 5 -> 9 -> 1 -> 15 -> 7 -> 11 -> 3 -> 14 -> 6 -> 10 -> 2
  localparam int LanePhysicalOrder[LANE_WIDTH] = `LANE_PHYSICAL_ORDER;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic clk_ref_spine;

  logic clk_dig_fe;
  logic [DES_OUT_WIDTH-1:0] dat_lad_des_fe[LANE_WIDTH][ADC_WIDTH];
  logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] dat_lda_lut_fe[LANE_WIDTH];
  /*logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] _dat_lda_rod_fe[LANE_WIDTH];*/
  logic [DES_OUT_WIDTH*LANE_WIDTH-1:0][ADC_WIDTH-1:0] dat_rod_fe;

  // top-level pipeline registers (last pipe is the essentially retimed)
  logic [DES_OUT_WIDTH-1:0] dat_lad_des_fe_pipe[DES_TO_LUT_PIPELINE_DEPTH][LANE_WIDTH][ADC_WIDTH];
  logic [DES_OUT_WIDTH-1:0] dat_lad_des_fe_rt[LANE_WIDTH][ADC_WIDTH];
  logic rst_glue[LANE_WIDTH];
  logic en_glue[LANE_WIDTH];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scans
  // ----------------------------------------------------------------------
  scan_if i_scan ();
  scan_if o_scan ();

  // wrap scan
  assign i_scan.sdata = i_sdata;
  assign i_scan.sctrl = {i_sclkp, i_sclkn, i_senable, i_supdate, i_sreset};
  assign o_sdata = o_scan.sdata;
  assign {o_sclkp, o_sclkn, o_senable, o_supdate, o_sreset} = o_scan.sctrl;

  // module scans
  scan_if i_scan_des[LANE_WIDTH] ();
  scan_if o_scan_des[LANE_WIDTH] ();
  scan_if i_scan_lane[LANE_WIDTH] ();
  scan_if o_scan_lane[LANE_WIDTH] ();
  scan_if i_scan_cs ();
  scan_if o_scan_cs ();
  scan_if i_scan_rod ();
  scan_if o_scan_rod ();
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan Snake-Chains
  // ----------------------------------------------------------------------
  // Lane physical-to-logical ordering (from bottom to top)
  // 0 -> 8 -> 12 -> 4 -> 13 -> 5 -> 9 -> 1 -> 15 -> 7 -> 11 -> 3 -> 14 -> 6 -> 10 -> 2
  // -> moved to dsp_fe.svh

  // connection (with snake turns):
  // i_scan -> i_scan_des[Lane[0]] (bottom) -> ... -> i_scan_des[Lane[LANE_WIDTH-1]] (top)
  // -> i_scan_cs (top) -> i_scan_lane[Lane[LANE_WIDTH-1]] (top) -> ... -> i_scan_lane[Lane[0]] (bottom)
  // -> i_scan_rod -> o_scan

  assign i_scan_des[LanePhysicalOrder[0]].sdata = i_scan.sdata;
  assign i_scan_des[LanePhysicalOrder[0]].sctrl = i_scan.sctrl;

  generate
    for (genvar i = 1; i < LANE_WIDTH; i++) begin : gen_des_scan_conn
      assign i_scan_des[LanePhysicalOrder[i]].sdata = o_scan_des[LanePhysicalOrder[i-1]].sdata;
      assign i_scan_des[LanePhysicalOrder[i]].sctrl = o_scan_des[LanePhysicalOrder[i-1]].sctrl;
    end
  endgenerate

  assign i_scan_cs.sdata = o_scan_des[LanePhysicalOrder[LANE_WIDTH-1]].sdata;
  assign i_scan_cs.sctrl = o_scan_des[LanePhysicalOrder[LANE_WIDTH-1]].sctrl;

  assign i_scan_lane[LanePhysicalOrder[LANE_WIDTH-1]].sdata = o_scan_cs.sdata;
  assign i_scan_lane[LanePhysicalOrder[LANE_WIDTH-1]].sctrl = o_scan_cs.sctrl;

  generate
    for (genvar i = LANE_WIDTH - 2; i >= 0; i--) begin : gen_lane_scan_conn
      assign i_scan_lane[LanePhysicalOrder[i]].sdata = o_scan_lane[LanePhysicalOrder[i+1]].sdata;
      assign i_scan_lane[LanePhysicalOrder[i]].sctrl = o_scan_lane[LanePhysicalOrder[i+1]].sctrl;
    end
  endgenerate

  assign i_scan_rod.sdata = o_scan_lane[LanePhysicalOrder[0]].sdata;
  assign i_scan_rod.sctrl = o_scan_lane[LanePhysicalOrder[0]].sctrl;

  assign o_scan.sdata = o_scan_rod.sdata;
  assign o_scan.sctrl = o_scan_rod.sctrl;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Clockspine (Scan-embedded)
  // ----------------------------------------------------------------------
  // TODO(check): reset, enable scan-controlled
  // Bottom clock is shared by test divider in analog; Use the top clock
  assign clk_ref_spine = i_clk_ref_bdl[LanePhysicalOrder[LANE_WIDTH-1]];
  dsp_fe_clkspine fe_clkspine (
      .i_clk_ref(clk_ref_spine),
      .o_clk_dig(clk_dig_fe),

      .i_scan(i_scan_cs),
      .o_scan(o_scan_cs)
  );

  /*assign o_clk_dig_brdg = clk_dig_fe;
   *assign o_clk_dig_mem  = clk_dig_fe;
   *assign o_clk_dig_be   = clk_dig_fe;*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // DES-2-TO-4 (Scan-embedded)
  // ----------------------------------------------------------------------
  // TODO(check): reset, enable scan-controlled
  generate
    for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_lane_des_fe
      dsp_fe_lane_des #(
          .ADC_WIDTH(ADC_WIDTH),
          .DES_IN_WIDTH(DES_IN_WIDTH),
          .DES_OUT_WIDTH(DES_OUT_WIDTH)
      ) fe_des (
          .i_rst_ref(~i_rstb_ref_bdl[i]),  // TODO(sunjin): double check
          .i_clk_ref(i_clk_ref_bdl[i]),

          .i_clk(clk_dig_fe),
          .i_ana_dat_ad_des_fe(i_ana_dat_lad_fe[i]),
          .o_dat_ad_des_fe(dat_lad_des_fe[i]),

          .i_scan(i_scan_des[i]),
          .o_scan(o_scan_des[i])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Spare Registers for DES-to-FE-Lane Fanout Distribution
  // ----------------------------------------------------------------------
  // Since genus/innovus normally respects the module boundary, these
  // registers should *not* be wrapped as a separate module
  // resets and enables are shared by lane glue logic (TODO: good decision?)
  assign dat_lad_des_fe_pipe[0] = dat_lad_des_fe;

  generate
    for (genvar j = 1; j < DES_TO_LUT_PIPELINE_DEPTH; j++) begin : gen_fe_pipe
      for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_fe_pipe_lane
        always_ff @(posedge clk_dig_fe) begin
          if (rst_glue[i]) begin
            dat_lad_des_fe_pipe[j][i] <= '{default: '0};
          end
          else if (en_glue[i]) begin
            dat_lad_des_fe_pipe[j][i] <= dat_lad_des_fe_pipe[j-1][i];
          end
        end
      end
    end
  endgenerate

  assign dat_lad_des_fe_rt = dat_lad_des_fe_pipe[DES_TO_LUT_PIPELINE_DEPTH-1];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Lane instantiation (Scan-embedded)
  // ----------------------------------------------------------------------
  // TODO(check): reset, enable scan-controlled
  generate
    for (genvar i = 0; i < LANE_WIDTH; i++) begin : gen_lane_fe
      dsp_fe_lane #(
          .ADC_WIDTH(ADC_WIDTH),
          .DES_OUT_WIDTH(DES_OUT_WIDTH)
      ) fe_lane_unit (
          .i_clk(clk_dig_fe),
          /*.i_dat_ad_lane_fe(dat_lad_des_fe[i]),*/
          .i_dat_ad_lane_fe(dat_lad_des_fe_rt[i]),
          .o_dat_da_lut_lane_fe(dat_lda_lut_fe[i]),

          .o_rst_glue(rst_glue[i]),
          .o_en_glue (en_glue[i]),

          .i_scan(i_scan_lane[i]),
          .o_scan(o_scan_lane[i])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Bit Regrouping (Scan-embedded) + Clock Forwarding
  // ----------------------------------------------------------------------
  // TODO(check): reset, enable scan-controlled
  dsp_fe_reorder #(
      .LANE_WIDTH(LANE_WIDTH),
      .ADC_WIDTH(ADC_WIDTH),
      .DES_OUT_WIDTH(DES_OUT_WIDTH),
      .PIPELINE_DEPTH(REORDER_PIPELINE_DEPTH)
  ) fe_reorder (
      .i_clk(clk_dig_fe),
      .i_dat_lda_rod_fe(dat_lda_lut_fe),
      .o_dat_rod_fe(dat_rod_fe),

      /*.o_clk_dig_brdg(o_clk_dig_brdg),*/
      .o_clk_dig_mem(o_clk_dig_mem),
      .o_clk_dig_be (o_clk_dig_be),
      .o_clk_dig_mon(o_clk_dig_mon),

      .i_scan(i_scan_rod),
      .o_scan(o_scan_rod)
  );

  assign o_dat_fe = dat_rod_fe;
  // ----------------------------------------------------------------------


endmodule

`default_nettype wire

