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

module dsp_mem_framesync (

    // input signals
    input var logic i_rclk,
    input var logic i_rrst,
    /*input var logic i_en,*/
    /*input var logic i_ren,*/

    input var logic i_cfg_mode_load,
    input var logic i_cfg_mode_rshift,
    input var logic [`FRAME_LENGTH-1:0] i_cfg_syncword,

    input var  logic i_bit_tail_fs_mem,
    output var logic o_bit_head_fs_mem
);


  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam int FRAME_LENGTH = `FRAME_LENGTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic rst_sync_fs;
  logic cfg_mode_rshift_sync;

  logic [FRAME_LENGTH-1:0] framesync;
  logic [FRAME_LENGTH-1:0] framesync_s1;
  logic [FRAME_LENGTH-1:0] framesync_nxt;

  // temp variable to remove width ambiguity, or self-determined width rule
  // (See Genus Datapath Synthesis Guide for details)
  logic [FRAME_LENGTH:0] framesync_s1_tmp;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  // reset is synchronized to read clock
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_fs (
      .i_rst(i_rrst),  // scan-controlled
      .i_clk(i_rclk),
      .o_rst(rst_sync_fs)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Intra-Module Shift Cfg Sync
  // ----------------------------------------------------------------------
  // Shift configuration bits should be *synchronous* to the corresponding
  // clocks as the banks
  // - read shift: synchronous to read clock
  // So the corresponding registers are switched to the shift-mode at the
  // same clock cycle, otherwise some bits may be dropped without being
  // properly overseen (== they are not queued)
  always_ff @(posedge i_rclk or posedge rst_sync_fs) begin
    if (rst_sync_fs) begin
      cfg_mode_rshift_sync <= 1'b0;
    end
    else begin
      cfg_mode_rshift_sync <= i_cfg_mode_rshift;
    end
  end
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Frame Sync Generation
  // ----------------------------------------------------------------------
  // shift-left by one bit and fill with the previous bit from the tail
  // use temp variable to remove width ambiguity
  assign framesync_s1_tmp = (framesync << 1) + i_bit_tail_fs_mem;
  assign framesync_s1 = framesync_s1_tmp[FRAME_LENGTH-1:0];

  always_comb begin
    framesync_nxt = framesync;
    if (i_cfg_mode_load) begin  // load mode takes priority over read shift
      framesync_nxt = i_cfg_syncword;
    end
    else if (cfg_mode_rshift_sync) begin
      framesync_nxt = framesync_s1;
    end
  end

  always_ff @(posedge i_rclk or posedge rst_sync_fs) begin
    if (rst_sync_fs) begin
      framesync <= '0;
    end
    else begin
      framesync <= framesync_nxt;
    end
  end

  assign o_bit_head_fs_mem = framesync[FRAME_LENGTH-1];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

