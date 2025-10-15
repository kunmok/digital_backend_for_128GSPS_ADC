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

// 4-stage pipeline register arrays
// Once the port locations are properly defined, then those registers will be
// placed according to the tool
module dsp_fe_sync #(
    parameter int ADC_BITWIDTH = 6,
    parameter int RX_LANEWIDTH = 16,
    parameter int NUM_PIPELINE = 4
) (
    // input signals
    input var logic i_rst,
    input var logic i_clk,
    input var logic i_en,
    input var logic [RX_LANEWIDTH-1:0][ADC_BITWIDTH-1:0][3:0] i_sync_arr,
    output var logic [RX_LANEWIDTH-1:0][ADC_BITWIDTH-1:0][3:0] o_sync_arr

    // output signals
    // TODO: output clk or not according to the floorplan
);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // TODO to reset sync or not
  logic rst_sync_pipe;
  // Pipeline registers
  logic [RX_LANEWIDTH-1:0][ADC_BITWIDTH-1:0][3:0] sync_arr_pipe_d[NUM_PIPELINE];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Pipeline registers
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) rst_sync (
      .i_rst(i_rst),
      .i_clk(i_clk),
      .o_rst(rst_sync_pipe)
  );

  assign o_sync_arr = sync_arr_pipe_d[NUM_PIPELINE-1];
  assign sync_arr_pipe_d[0] = i_sync_arr;

  generate
    for (genvar i = 1; i < NUM_PIPELINE; i++) begin : g_pipe
      always_ff @(posedge i_clk or negedge rst_sync_pipe) begin
        if (!rst_sync_pipe) begin
          sync_arr_pipe_d[i] <= '0;
        end
        else begin
          if (i_en) sync_arr_pipe_d[i] <= sync_arr_pipe_d[i-1];
        end
      end
    end
  endgenerate


endmodule

`default_nettype wire

