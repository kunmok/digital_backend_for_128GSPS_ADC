//==============================================================================
// Author: Sunjin Choi
// Description: Memory bank
// Signals:
// Note: *ILM Block*
// See *inline note* for shift register snake connection
// Assume read-clk is always active during the read-mode, and likewise for the
// write-mode
// Five available modes:
// - write-hold: no update (active wclk, cfg_mode_wshift_sync=0)
// - write-shift: shift-in the data (active wclk, cfg_mode_wshift_sync=1)
// - read-hold: no update (active rclk, cfg_mode_rupdate=0, cfg_mode_rshift_sync=0)
// - read-update: update from the write registers (active rclk, cfg_mode_rupdate=1, cfg_mode_rshift_sync=0)
// - read-shift: shift-in the data (active rclk, cfg_mode_rupdate=0, cfg_mode_rshift_sync=1)
// Note that break-before-make is desired when switching btw read-update and read-shift
// Hidden Mode: 
// - With tail set to 0, en/ren set to 1 and rclk toggling, the memory data
// will be flushed to 0.
// - With sel_wclk set to 0 and no rclk is supplied, the entire logic is gated
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_mem_bank (
    input var logic i_wclk,
    input var logic i_rclk,

    input var logic i_wrst,
    input var logic i_rrst,

    input var logic i_cfg_mode_rupdate,
    input var logic i_cfg_mode_wshift,
    input var logic i_cfg_mode_rshift,

    input var logic [`MEM_WIDTH-1:0] i_dat_bank_mem,
    output var logic [`MEM_WIDTH-1:0] o_dat_bank_mem,
    input var logic i_bit_tail_bank_mem,
    output var logic o_bit_head_bank_mem

);

  // ----------------------------------------------------------------------
  // Local Parameters
  // ----------------------------------------------------------------------
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic rst_sync_write;
  logic rst_sync_read;

  logic cfg_mode_wshift_sync;
  logic cfg_mode_rshift_sync;

  logic [MEM_WIDTH-1:0] mem_wreg[BANK_DEPTH];
  logic [MEM_WIDTH-1:0] mem_wreg_nxt[BANK_DEPTH];
  logic [MEM_WIDTH-1:0] mem_wreg_pipe[BANK_DEPTH];

  logic [MEM_WIDTH * BANK_DEPTH - 1:0] mem_wreg_flat;
  logic [MEM_WIDTH * BANK_DEPTH - 1:0] mem_rreg;
  logic [MEM_WIDTH * BANK_DEPTH - 1:0] mem_rreg_s1;
  logic [MEM_WIDTH * BANK_DEPTH - 1:0] mem_rreg_nxt;

  // temp variable to remove width ambiguity, or self-determined width rule
  // (See Genus Datapath Synthesis Guide for details)
  logic [MEM_WIDTH * BANK_DEPTH:0] mem_rreg_s1_tmp;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  // reset is synchronized to write clock
  // since read clock is *mostly* asynchronous
  // NOTE: bank reset is not synchronized to read clock
  // bank reset *should* be asserted/deasserted only when i_wclk is stable
  // and i_rclk is not toggling
  // -> Change to clk after select
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_write (
      .i_rst(i_wrst),  // scan-controlled
      .i_clk(i_wclk),
      /*.i_clk(clk),*/
      .o_rst(rst_sync_write)
  );

  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_read (
      .i_rst(i_rrst),  // scan-controlled
      .i_clk(i_rclk),
      /*.i_clk(clk),*/
      .o_rst(rst_sync_read)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Intra-Module Shift Cfg Sync
  // ----------------------------------------------------------------------
  // Shift configuration bits should be *synchronous* to the corresponding
  // clocks
  // - write shift: synchronous to write clock
  // - read shift: synchronous to read clock
  // So the corresponding registers are switched to the shift-mode at the
  // same clock cycle, otherwise some bits may be dropped without being
  // properly overseen (== they are not queued)
  always_ff @(posedge i_wclk or posedge rst_sync_write) begin
    if (rst_sync_write) begin
      cfg_mode_wshift_sync <= 1'b0;
    end
    else begin
      cfg_mode_wshift_sync <= i_cfg_mode_wshift;
    end
  end

  always_ff @(posedge i_rclk or posedge rst_sync_read) begin
    if (rst_sync_read) begin
      cfg_mode_rshift_sync <= 1'b0;
    end
    else begin
      cfg_mode_rshift_sync <= i_cfg_mode_rshift;
    end
  end
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Memory
  // ----------------------------------------------------------------------
  /*// 1b sel_wclk to select between write and read clock
   *assign clk = i_sel_wclk ? i_wclk : i_rclk;*/

  // *inline note*
  // Memory connection (write registers == wregs, read registers == rregs)
  // Decision: maintain rreg chain order, and flip wreg chain order
  // Reason: simplify the rreg chaining and wreg->rreg conn RTL & CTS
  //
  // This means the connections are made as follows:
  // - rreg chain: (straightforward, no flipping needed)
  // rreg[0][0] -> rreg[0][1] -> ... -> rreg[0][LANE_WIDTH-1] -> rreg[1][0] ->
  // rreg[1][1] -> ... -> rreg[1][LANE_WIDTH-1] -> ... -> rreg[BANK_DEPTH-1][LANE_WIDTH-1]
  //
  // - wreg chain: (flipped order, to simplify CTS)
  // wreg[0][0] -> wreg[1][LANE_WIDTH-1] -> wreg[2][0] -> wrgg[3][LANE_WIDTH-1] -> ...
  // wreg[0][LANE_WIDTH-1] -> wreg[1][0] -> wreg[2][LANE_WIDTH-1] -> wreg[3][0] -> ...
  //
  // - wreg to rreg conn: (straightforward, no flipping needed)
  // wreg[i][j] -> rreg[i][j]
  //
  // Note that read-order is *flipped* at every WAY_WIDTH=384 bit read

  // memory update on write-mode
  assign mem_wreg_pipe[0] = i_dat_bank_mem;
  /*generate
   *  for (genvar i = 1; i < BANK_DEPTH; i++) begin : gen_mem
   *    assign mem_wreg_pipe[i] = mem_wreg[i-1];
   *  end
   *endgenerate*/

  generate
    for (genvar i = 1; i < BANK_DEPTH; i++) begin : gen_mem_pipe
      for (genvar j = 0; j < MEM_WIDTH; j++) begin : gen_mem_pipe_bit
        if (i % 2 == 1) begin : gen_mem_pipe_bit_odd
          always_comb begin
            mem_wreg_pipe[i][j] = mem_wreg[i-1][j];
          end
        end
        else begin : gen_mem_pipe_bit_even
          always_comb begin
            mem_wreg_pipe[i][j] = mem_wreg[i-1][MEM_WIDTH-1-j];
          end
        end
      end
    end
  endgenerate

  // during write-operation, *active* wclk is assumed
  // two available modes:
  // - write-hold: no update (active wclk, cfg_mode_wshift_sync=0)
  // - write-shift: shift-in the data (active wclk, cfg_mode_wshift_sync=1)
  always_comb begin
    // default: no update
    mem_wreg_nxt = mem_wreg;
    if (cfg_mode_wshift_sync) begin
      mem_wreg_nxt = mem_wreg_pipe;
    end
  end

  // remove module-level clock gating
  // hoping it removes genus-DFT issues
  // this actually *solves* the problem!! mem_wreg_rregs are no longer mapped
  // to the scan registers and avoids the need of explicitly defining the DFT
  // chain
  always_ff @(posedge i_wclk or posedge rst_sync_write) begin
    if (rst_sync_write) begin
      mem_wreg <= '{default: '0};
    end
    else begin
      mem_wreg <= mem_wreg_nxt;
    end
  end

  // flatten for read-mode
  // TODO(sunjin): verify this
  // bits filled from right to left; dat_flat[LSB] is dat_lda[0][0][0][0]
  // dat_flat[MSB] is dat_lda[BANK_DEPTH-1][LANE_WIDTH-1][DES_OUT_WIDTH-1][ADC_WIDTH-1]
  /*assign mem_flat = {<<{mem}};*/
  generate
    for (genvar i = 0; i < BANK_DEPTH; i++) begin : gen_mem_wreg_flat
      assign mem_wreg_flat[i*MEM_WIDTH+:MEM_WIDTH] = mem_wreg[i];
    end
  endgenerate

  // shift-left by one bit and fill with the previous bit from the last bank
  // TODO(sunjin): verify this
  // use temp variable to remove width ambiguity
  /*assign mem_rreg_s1 = (mem_rreg << 1) + i_bit_tail_bank_mem;*/
  assign mem_rreg_s1_tmp = (mem_rreg << 1) + i_bit_tail_bank_mem;
  assign mem_rreg_s1 = mem_rreg_s1_tmp[MEM_WIDTH*BANK_DEPTH-1:0];

  // read-mode registers are essentially the shadow registers
  // they are explicitly updated with the corresponding scan config
  // read-shift config is synchronized to make sure the shift operation of all
  // read registers starts at the same clock cycle
  //
  // during read-operation, *active* rclk is assumed
  // three available modes:
  // - read-hold: no update (active rclk, cfg_mode_rupdate=0, cfg_mode_rshift_sync=0)
  // - read-update: update from the write registers (active rclk, cfg_mode_rupdate=1, cfg_mode_rshift_sync=0)
  // - read-shift: shift-in the data (active rclk, cfg_mode_rupdate=0, cfg_mode_rshift_sync=1)
  // note that break-before-make is desired when switching btw read-update and read-shift
  always_comb begin
    /*mem_rreg_nxt = mem_wreg_flat;*/
    mem_rreg_nxt = mem_rreg;
    if (i_cfg_mode_rupdate) begin  // update-mode takes priority over shift-mode
      mem_rreg_nxt = mem_wreg_flat;
    end
    else if (cfg_mode_rshift_sync) begin
      mem_rreg_nxt = mem_rreg_s1;
    end
  end

  /*always_ff @(posedge i_rclk or posedge rst_sync_read) begin
   *  if (rst_sync_read) begin
   *    mem_rreg <= '0;
   *  end
   *  else begin
   *    if (i_en) begin  // separate enable for power saving?
   *      mem_rreg <= mem_rreg_nxt;
   *    end
   *  end
   *end*/

  // remove module-level clock gating
  // hoping it removes genus-DFT issues
  always_ff @(posedge i_rclk or posedge rst_sync_read) begin
    if (rst_sync_read) begin
      mem_rreg <= '0;
    end
    else begin
      mem_rreg <= mem_rreg_nxt;
    end
  end

  // output tap from the last depth
  assign o_dat_bank_mem = mem_wreg[BANK_DEPTH-1];
  assign o_bit_head_bank_mem = mem_rreg[MEM_WIDTH*BANK_DEPTH-1];

endmodule


`default_nettype wire
