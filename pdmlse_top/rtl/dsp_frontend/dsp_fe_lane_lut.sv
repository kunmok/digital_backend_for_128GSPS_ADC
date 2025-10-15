//==============================================================================
// Author: Sunjin Choi
// Description: LUT module for ADC Calibration in DSP-FE
// Signals:
// Note: 6-bit input to 6-bit output
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_fe_lane_lut #(
    parameter int INPUT_WIDTH = 6,
    parameter int OUTPUT_WIDTH = 6,
    parameter int REUSE_RANK = 4,
    parameter int PIPELINE_DEPTH = 2
    /*parameter logic [INPUT_WIDTH*OUTPUT_WIDTH-1:0] SEED_TABLE_FLAT = '0*/
    //parameter logic [0:2**INPUT_WIDTH-1][0:OUTPUT_WIDTH-1] SEED_TABLE = '0
    /*parameter logic SEED_TABLE[2**INPUT_WIDTH][OUTPUT_WIDTH] = '{default: '0}*/
    /*parameter logic SEED_TABLE[2**INPUT_WIDTH][OUTPUT_WIDTH] = `LUT_DEFAULT_TABLE*/
) (
    // input signals
    input var logic i_rst,
    input var logic i_clk,
    input var logic i_en,
    input var logic [INPUT_WIDTH-1:0] i_addr_ri_lane[REUSE_RANK],

    // input config signals
    input var logic i_cfg_mode_load,
    input var logic i_cfg_mode_seed,
    input var logic i_cfg_mode_mission,
    input var logic [(2**INPUT_WIDTH)*OUTPUT_WIDTH-1:0] i_cfg_table,

    // output signals
    output var logic [OUTPUT_WIDTH-1:0] o_dat_ro_lane[REUSE_RANK]
);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam [OUTPUT_WIDTH-1:0] LUT_DEFAULT_TABLE[(2**INPUT_WIDTH)] = `LUT_DEFAULT_TABLE;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  //logic lut_table[(2**INPUT_WIDTH)][OUTPUT_WIDTH];
  //logic lut_table_nxt[(2**INPUT_WIDTH)][OUTPUT_WIDTH];
  logic [OUTPUT_WIDTH-1:0] lut_table[(2**INPUT_WIDTH)];
  logic [OUTPUT_WIDTH-1:0] lut_table_nxt[(2**INPUT_WIDTH)];

  logic [OUTPUT_WIDTH-1:0] dat_ro[REUSE_RANK];
  //logic [OUTPUT_WIDTH-1:0] dat_ro_pipe[REUSE_RANK][PIPELINE_DEPTH];
  logic [OUTPUT_WIDTH-1:0] dat_ro_pipe[PIPELINE_DEPTH][REUSE_RANK];
  // ----------------------------------------------------------------------

  //// ----------------------------------------------------------------------
  //// Config
  //// ----------------------------------------------------------------------
  //logic cfg_table_flat[INPUT_WIDTH*OUTPUT_WIDTH];
  //assign cfg_table_flat = i_cfg_table;
  //// ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // LUT
  // ----------------------------------------------------------------------
  // Priority: load-mode > seed-mode > mission-mode
  // TODO: double check
  always_comb begin
    // Default: no update
    lut_table_nxt = lut_table;
    // Load mode: load the table from scan and pack it into a 2D array
    if (i_cfg_mode_load) begin
      /*lut_table_nxt = {>>{i_cfg_table}};*/
      {>>{lut_table_nxt}} = i_cfg_table;
    end
    // Seed mode: load the table from scan and pack it into a 2D array
    else if (i_cfg_mode_seed) begin
      /*lut_table_nxt = {>>{SEED_TABLE_FLAT}};*/
      //lut_table_nxt = SEED_TABLE;
      /*{>>{lut_table_nxt}} = SEED_TABLE;*/
      {>>{lut_table_nxt}} = LUT_DEFAULT_TABLE;
    end
    // Mission mode: no update
    else if (i_cfg_mode_mission) begin
      lut_table_nxt = lut_table;
    end
  end

  // LUT update
  always_ff @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      lut_table <= '{default: '0};
    end
    else begin
      if (i_en) begin
        lut_table <= lut_table_nxt;
      end
    end
  end

  // Output logic
  generate
    for (genvar i = 0; i < REUSE_RANK; i++) begin : g_lutshare
      assign dat_ro[i] = i_cfg_mode_mission ? lut_table[i_addr_ri_lane[i]] : '0;
    end
  endgenerate

  // add pipeline registers after dat_ro
  // to be retimed by genus
  assign dat_ro_pipe[0] = dat_ro;
  generate
    for (genvar j = 1; j < PIPELINE_DEPTH; j++) begin : g_lut_pp
      always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
          dat_ro_pipe[j] <= '{default: '0};
        end
        else if (i_en) begin
          dat_ro_pipe[j] <= dat_ro_pipe[j-1];
        end
      end
    end
  endgenerate
  assign o_dat_ro_lane = dat_ro_pipe[PIPELINE_DEPTH-1];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

