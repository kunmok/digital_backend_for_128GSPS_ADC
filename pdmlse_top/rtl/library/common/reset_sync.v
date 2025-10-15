//==============================================================================
// Author: Sunjin Choi (Stolen from ISG Common Cells)
// Description: Reset Synchronizer
// It synchronizes asynchronous reset to the incoming clock signal. 
// Asynchronous reset design is preferred over synchronous as the mapped netlist
// would not insert any reset-related logics into the datapath. However, its
// vulnerability to disastrous reset-clock timing mismatch can incur
// metastability or cycle slips. This module can be instantiated inside the
// block to avoid such cases. See Cummings paper for more details...!
// Signals:
//    i_rst : asynchronous reset signal
//    i_clk : input clock
//    o_rst : output reset signal synchronized to input clock
// Parameters:
//    ActiveLow : 0 for active low reset, 1 for active high reset
//    SyncRegWidth: length of synchronizer flip-flop, typically 2
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module reset_sync #(
    parameter int ActiveLow = 0,
    parameter int SyncRegWidth = 2
) (
    // input signals
    i_rst,
    i_clk,

    // output signals
    o_rst
);

  //-----------------------------------------------------------------------------------
  //  Parameters
  //-----------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------
  //  Inputs / Outputs
  //-----------------------------------------------------------------------------------
  // input signals
  input wire i_rst;
  input wire i_clk;

  // output signals
  output wire o_rst;
  //-----------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------
  //  Signals
  //-----------------------------------------------------------------------------------
  reg [SyncRegWidth-1:0] sync_reg;
  //-----------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------
  //  Assigns
  //-----------------------------------------------------------------------------------
  assign o_rst = sync_reg[0];
  //-----------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------
  //  Reset Sync
  //-----------------------------------------------------------------------------------
  generate
    if (ActiveLow) begin : g_active_hilo
      always @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) sync_reg <= {SyncRegWidth{1'b0}};
        else sync_reg <= {1'b1, sync_reg[SyncRegWidth-1:1]};
      end
    end
    else begin
      always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) sync_reg <= {SyncRegWidth{1'b1}};
        else sync_reg <= {1'b0, sync_reg[SyncRegWidth-1:1]};
      end
    end
  endgenerate
  //-----------------------------------------------------------------------------------

endmodule

`default_nettype wire
