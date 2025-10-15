//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note:
// i_dat_lda_rod_fe[lane][des] is at ("lane"+"des"*16)-th timestep
// e.g., i_dat_lda_rod_fe[0][0] is at 0-th timestep
// e.g., i_dat_lda_rod_fe[0][1] is at 16-th timestep
// e.g., i_dat_lda_rod_fe[1][0] is at 1-th timestep
// e.g., i_dat_lda_rod_fe[1][1] is at 17-th timestep
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

// N-stage pipeline register arrays
// Once the port locations are properly defined, then those registers will be
// placed according to the tool
module dsp_fe_reorder #(
    parameter int LANE_WIDTH = 16,
    parameter int ADC_WIDTH = 6,
    parameter int DES_OUT_WIDTH = 4,
    parameter int PIPELINE_DEPTH = 3
) (
    // input signals
    /*input var logic i_rst,*/
    input var logic i_clk,
    /*input var logic i_en,*/
    input var logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] i_dat_lda_rod_fe[LANE_WIDTH],
    /*output var logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] o_dat_lda_rod_fe[LANE_WIDTH],*/
    output var logic [DES_OUT_WIDTH*LANE_WIDTH-1:0][ADC_WIDTH-1:0] o_dat_rod_fe,

    // clock forwarding to downstream modules
    /*output var logic o_clk_dig_brdg,*/
    output var logic o_clk_dig_mem,
    output var logic o_clk_dig_be,
    output var logic o_clk_dig_mon,

    // Embedded Two-Phase Scan
    scan_if.recv i_scan,
    scan_if.send o_scan

);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic rst_rod;
  logic en_rod;
  logic rst_sync_rod;

  //// Use aux variables to reorder the bits
  //logic [DES_OUT_WIDTH*LANE_WIDTH-1:0][ADC_WIDTH-1:0] dat_rod_flat;
  //// Reordered bits
  //logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] dat_lda_rod_d0[LANE_WIDTH];

  //// Pipeline registers after bit reordering (for genus retiming)
  //logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] dat_lda_rod_pipe[PIPELINE_DEPTH][LANE_WIDTH];

  // reordered bus
  logic [DES_OUT_WIDTH*LANE_WIDTH-1:0][ADC_WIDTH-1:0] dat_rod;
  //// Reordered bits
  //logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] dat_lda_rod_d0[LANE_WIDTH];

  // Pipeline registers after bit reordering
  logic [DES_OUT_WIDTH*LANE_WIDTH-1:0][ADC_WIDTH-1:0] dat_rod_pipe[PIPELINE_DEPTH];

  /*// Pipeline registers
   *logic [RX_LANEWIDTH-1:0][ADC_BITWIDTH-1:0][3:0] sync_arr_pipe[PIPELINE_DEPTH];*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_rod (
      .i_rst(rst_rod),  // scan-controlled
      .i_clk(i_clk),
      .o_rst(rst_sync_rod)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Bit Reordering Pipeline
  // ----------------------------------------------------------------------
  //// dat_lda_rod_flatorder[lane+des*LANE_WIDTH] = i_dat_lda_rod_fe[lane][des]
  //// o_dat_lda_rod_fe[lane][des] = dat_lda_rod_flatorder[lane*DES_OUT_WIDTH+des]
  //generate
  //  for (genvar idx_lane = 0; idx_lane < LANE_WIDTH; idx_lane++) begin : g_lane_flat
  //    for (genvar idx_des = 0; idx_des < DES_OUT_WIDTH; idx_des++) begin : g_des_flat
  //      assign dat_rod_flat[idx_lane+idx_des*LANE_WIDTH] = i_dat_lda_rod_fe[idx_lane][idx_des];
  //      assign dat_lda_rod_d0[idx_lane][idx_des] = dat_rod_flat[idx_lane*DES_OUT_WIDTH+idx_des];
  //    end
  //  end
  //endgenerate

  // i_dat_lda_rod_fe[lane][des] in lane+des*LANE_WIDTH-th timestep
  // dat_rod[idx] in idx-th timestep
  generate
    for (genvar idx_lane = 0; idx_lane < LANE_WIDTH; idx_lane++) begin : g_lane_flat
      for (genvar idx_des = 0; idx_des < DES_OUT_WIDTH; idx_des++) begin : g_des_flat
        assign dat_rod[idx_lane+idx_des*LANE_WIDTH] = i_dat_lda_rod_fe[idx_lane][idx_des];
      end
    end
  endgenerate

  // Pipeline registers
  assign dat_rod_pipe[0] = dat_rod;
  generate
    for (genvar i = 1; i < PIPELINE_DEPTH; i++) begin : g_pipe
      always_ff @(posedge i_clk or posedge rst_sync_rod) begin
        if (rst_sync_rod) begin
          dat_rod_pipe[i] <= '{default: '0};
        end
        else begin
          if (en_rod) dat_rod_pipe[i] <= dat_rod_pipe[i-1];
        end
      end
    end
  endgenerate
  assign o_dat_rod_fe  = dat_rod_pipe[PIPELINE_DEPTH-1];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Clock Forwarding
  // ----------------------------------------------------------------------

  /*assign o_clk_dig_brdg = i_clk;*/
  assign o_clk_dig_mem = i_clk;
  assign o_clk_dig_be  = i_clk;
  assign o_clk_dig_mon = i_clk;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan
  // ----------------------------------------------------------------------
  // scan[]: rst_rod
  // scan[]: en_rod

  logic sclkp;
  logic sclkn;
  logic senable;
  logic supdate;
  logic sreset;
  logic sin;
  logic sout;
  logic [`FeRodScanChainLength-1:0] scan_bits_wr;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_fe_rod_scan fe_rod_scan (
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

  assign rst_rod = scan_bits_wr[`FeRodRst];
  assign en_rod  = scan_bits_wr[`FeRodEn];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

