//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note:  *ILM Block*
// Most importantly, resets are synchronized by wclk (or digital clock), which
// means that digital clock should be active during the initial reset
// sequencing. It is then recommended to "flush" the internal registers
// with "0" frame-sync and read-mode sequencing. Then, a sync word is
// configured to identify the memory "snapshot" packet location during the
// serial read. Finally, write-mode is enabled to pipe the data and deasserted
// to freeze the data-stream from the DSP frontend.
//
// NUM_BANKS is set to 32+1 for redundancy reason.
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_mem (
    input var logic i_clk_dig_mem,
    input var logic [`WAY_WIDTH-1:0][`ADC_WIDTH-1:0] i_dat_mem,

    // reset and enable are embedded
    input var  logic i_clk_read_mem,
    output var logic o_bit_read_mem,

    /*// Embedded Two-Phase Scan
     *scan_if.recv i_scan,
     *scan_if.send o_scan*/

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
  // WAY_WIDTH 64, MEM_WIDTH 384, NUM_BANKS 16, BANK_DEPTH 8, FRAME_LENGTH 64
  localparam int WAY_WIDTH = `WAY_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int NUM_BANKS = `NUM_BANKS;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  localparam int FRAME_LENGTH = `FRAME_LENGTH;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  // _d1 for block-level retiming
  logic [WAY_WIDTH-1:0][ADC_WIDTH-1:0] dat_mem_d1;

  // serialized data dump
  logic [MEM_WIDTH-1:0] dat_write_ser;
  logic [MEM_WIDTH-1:0] i_dat_write_bank[NUM_BANKS];
  logic [MEM_WIDTH-1:0] o_dat_write_bank[NUM_BANKS];
  logic i_dat_read_bank[NUM_BANKS];
  logic o_dat_read_bank[NUM_BANKS];

  // connect signals
  logic i_bit_fs_pre;
  logic i_bit_fs_post;
  logic o_bit_fs_pre;
  logic o_bit_fs_post;
  logic bit_flush;

  // gated clock signals
  logic [NUM_BANKS-1:0] rclk_bank;
  logic [NUM_BANKS-1:0] wclk_bank;
  logic rclk_fs_pre;
  logic rclk_fs_post;

  // control signals
  // use packed array for scan conn simplicity
  // scan-controlled reset signals
  logic rst_retime;
  logic [NUM_BANKS-1:0] wrst_bank;
  logic [NUM_BANKS-1:0] rrst_bank;
  logic rrst_fs;
  // scan-controlled enable signals for clock gating ctrl
  logic en_retime;
  logic [NUM_BANKS-1:0] en_bank;
  logic en_fs;

  // scan-controlled asynchronous wreg-to-rreg update mode ctrl
  logic cfg_mode_rupdate;
  // scan-controlled wreg/rreg shift-operation mode ctrl
  logic cfg_mode_wshift;
  logic cfg_mode_rshift;

  // scan-controlled framesync load ctrl
  logic cfg_fs_mode_load;
  logic [FRAME_LENGTH-1:0] cfg_fs_syncword;

  // distribution signals
  // bank-level async rupdate mode ctrl for distribution
  logic [NUM_BANKS-1:0] cfg_bank_mode_rupdate;
  // shift-operation config *globally synchronized* and distributed
  logic [NUM_BANKS-1:0] cfg_bank_mode_wshift_sync;
  logic [NUM_BANKS-1:0] cfg_bank_mode_rshift_sync;
  logic cfg_fs_mode_rshift_sync;

  // synchronous reset for retimers and cfg distributions
  logic rst_sync_retime;
  logic rst_sync_wcfg;
  logic rst_sync_rcfg;
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan Signals
  // ----------------------------------------------------------------------
  scan_if i_scan ();
  scan_if o_scan ();

  // wrap scan
  assign i_scan.sdata = i_sdata;
  assign i_scan.sctrl = {i_sclkp, i_sclkn, i_senable, i_supdate, i_sreset};
  assign o_sdata = o_scan.sdata;
  assign {o_sclkp, o_sclkn, o_senable, o_supdate, o_sreset} = o_scan.sctrl;
  /*assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;*/
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_retime (
      .i_rst(rst_retime),  // scan-controlled
      .i_clk(i_clk_dig_mem),
      /*.i_clk(clk),*/
      .o_rst(rst_sync_retime)
  );

  // redundant rst syncs for global config synchronizers
  // reuse 0th bank's reset for simplicity
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_wcfg (
      .i_rst(wrst_bank[0]),   // scan-controlled
      .i_clk(i_clk_dig_mem),
      .o_rst(rst_sync_wcfg)
  );

  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_rcfg (
      .i_rst(rrst_bank[0]),    // scan-controlled
      .i_clk(i_clk_read_mem),
      .o_rst(rst_sync_rcfg)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Block-Level Retiming
  // ----------------------------------------------------------------------
  always_ff @(posedge i_clk_dig_mem or posedge rst_sync_retime) begin
    if (rst_sync_retime) begin
      dat_mem_d1 <= '{default: '0};
    end
    else begin
      if (en_retime) begin
        dat_mem_d1 <= i_dat_mem;
      end
    end
  end
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Inter-Module (Banks + FS) Shift Cfg Sync
  // ----------------------------------------------------------------------
  // Shift configuration bits should be *synchronous* to the corresponding
  // clocks
  // - write shift: synchronous to write clock
  // - read shift: synchronous to read clock
  // So the corresponding registers are switched to the shift-mode at the
  // same clock cycle, otherwise some bits may be dropped without being
  // properly overseen (== they are not queued)

  always_ff @(posedge i_clk_dig_mem or posedge rst_sync_wcfg) begin
    if (rst_sync_wcfg) begin
      cfg_bank_mode_wshift_sync <= '{default: '0};
    end
    else begin
      cfg_bank_mode_wshift_sync <= {NUM_BANKS{cfg_mode_wshift}};
    end
  end

  always_ff @(posedge i_clk_read_mem or posedge rst_sync_rcfg) begin
    if (rst_sync_rcfg) begin
      cfg_bank_mode_rshift_sync <= '{default: '0};
      cfg_fs_mode_rshift_sync   <= '0;
    end
    else begin
      cfg_bank_mode_rshift_sync <= {NUM_BANKS{cfg_mode_rshift}};
      cfg_fs_mode_rshift_sync   <= cfg_mode_rshift;
    end
  end

  // rupdate mode is asynchronous; no need for sync
  assign cfg_bank_mode_rupdate = {NUM_BANKS{cfg_mode_rupdate}};
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Memory Bank
  // ----------------------------------------------------------------------
  // serialize bits
  generate
    for (genvar i = 0; i < WAY_WIDTH; i = i + 1) begin : g_ser
      assign dat_write_ser[i*ADC_WIDTH+:ADC_WIDTH] = dat_mem_d1[i];
    end
  endgenerate

  // clock gating at top-level
  // this is to remove the genus-DFT issue at bank-level (ILM block)
  // hope the timing is correctly captured
  generate
    for (genvar i = 0; i < NUM_BANKS; i = i + 1) begin : g_clk_gate
      assign rclk_bank[i] = i_clk_read_mem & en_bank[i];
      assign wclk_bank[i] = i_clk_dig_mem & en_bank[i];
    end
  endgenerate

  // instantiate memory banks
  generate
    for (genvar i = 0; i < NUM_BANKS; i = i + 1) begin : g_mem_bank
      dsp_mem_bank mem_bank (
          .i_wclk(wclk_bank[i]),
          .i_rclk(rclk_bank[i]),
          .i_wrst(wrst_bank[i]),
          .i_rrst(rrst_bank[i]),

          .i_cfg_mode_rupdate(cfg_bank_mode_rupdate[i]),
          .i_cfg_mode_wshift (cfg_bank_mode_wshift_sync[i]),
          .i_cfg_mode_rshift (cfg_bank_mode_rshift_sync[i]),

          .i_dat_bank_mem(i_dat_write_bank[i]),
          .o_dat_bank_mem(o_dat_write_bank[i]),
          .i_bit_tail_bank_mem(i_dat_read_bank[i]),
          .o_bit_head_bank_mem(o_dat_read_bank[i])
      );
    end
  endgenerate

  // memory "frame sync" module post-amble
  // run with rclk from the last bank
  dsp_mem_framesync mem_framesync_postamble (
      .i_rclk(rclk_fs_post),
      .i_rrst(rrst_fs),

      .i_cfg_mode_load  (cfg_fs_mode_load),
      .i_cfg_mode_rshift(cfg_fs_mode_rshift_sync),

      .i_cfg_syncword(cfg_fs_syncword),

      .i_bit_tail_fs_mem(i_bit_fs_post),
      .o_bit_head_fs_mem(o_bit_fs_post)
  );

  // memory "frame sync" module pre-amble (same syncword as postamble)
  // run with rclk from the first bank
  dsp_mem_framesync mem_framesync_preamble (
      .i_rclk(rclk_fs_pre),
      .i_rrst(rrst_fs),

      .i_cfg_mode_load  (cfg_fs_mode_load),
      .i_cfg_mode_rshift(cfg_fs_mode_rshift_sync),

      .i_cfg_syncword(cfg_fs_syncword),

      .i_bit_tail_fs_mem(i_bit_fs_pre),
      .o_bit_head_fs_mem(o_bit_fs_pre)
  );

  // connect write paths
  // in -> bank[0] -> bank[1] -> ... -> bank[NUM_BANKS-1] -> [NOCONN]
  // always flip bit orders at bank connections to ease the pin connections
  // downside is the ordering flipping every even-row (every MEM_WIDTH bits)
  /*assign i_dat_write_bank[0] = dat_write_ser;*/
  generate
    for (genvar j = 0; j < MEM_WIDTH; j = j + 1) begin : g_write_bank_0_bitrev
      assign i_dat_write_bank[0][j] = dat_write_ser[MEM_WIDTH-1-j];
    end
  endgenerate

  generate
    for (genvar i = 1; i < NUM_BANKS; i = i + 1) begin : g_write_bank
      for (genvar j = 0; j < MEM_WIDTH; j = j + 1) begin : g_write_bank_bitrev
        assign i_dat_write_bank[i][j] = o_dat_write_bank[i-1][MEM_WIDTH-1-j];
      end
    end
  endgenerate

  //// flip orders btw buffer and last bank (easier pin conn)
  //generate
  //  for (genvar j = 0; j < MEM_WIDTH; j = j + 1) begin : g_write_buf_bitrev
  //    assign i_dat_write_buf[j] = o_dat_read_bank[NUM_BANKS-1][MEM_WIDTH-1-j];
  //  end
  //endgenerate

  // connect read paths
  // preamble -> bank[0] -> bank[1] -> ... -> bank[NUM_BANKS-1] -> postamble
  // bit_flush is used for the initial "flush" of the memory (soft-reset)
  assign bit_flush = 1'b0;
  assign i_bit_fs_pre = bit_flush;
  assign i_dat_read_bank[0] = o_bit_fs_pre;
  generate
    for (genvar i = 1; i < NUM_BANKS; i = i + 1) begin : g_read_bank
      assign i_dat_read_bank[i] = o_dat_read_bank[i-1];
    end
  endgenerate
  assign i_bit_fs_post = o_dat_read_bank[NUM_BANKS-1];
  assign o_bit_read_mem = o_bit_fs_post;

  // forward gated read clocks from first/last banks to the framesyncs
  // this is to ensure that the framesyncs are running at the same clock
  // framesync_postamble <-> last bank
  // framesync_preamble <-> first bank
  assign rclk_fs_pre = rclk_bank[0];
  assign rclk_fs_post = rclk_bank[NUM_BANKS-1];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Memory Control
  // ----------------------------------------------------------------------
  /*  dsp_mem_ctrl #(
 *      .NUM_BANKS(NUM_BANKS),
 *      .FRAME_LENGTH(FRAME_LENGTH)
 *  ) mem_ctrl (
 *      .i_scan(i_scan),
 *      .o_scan(o_scan),
 *
 *      .o_wen(wen),
 *      .o_ren(ren),
 *
 *      .o_rst_retime(rst_retime),
 *      .o_en_retime (en_retime),
 *
 *      .o_rst_bank(rst_bank),
 *      .o_en_bank (en_bank),
 *
 *      .o_rst_fs(rst_fs),
 *      .o_en_fs (en_fs),
 *
 *      .o_cfg_fs_mode_load(cfg_fs_mode_load),
 *      .o_cfg_fs_syncword (cfg_fs_syncword)
 *  );*/

  dsp_mem_ctrl #(
      .NUM_BANKS(NUM_BANKS),
      .FRAME_LENGTH(FRAME_LENGTH)
  ) mem_ctrl (
      .i_scan(i_scan),
      .o_scan(o_scan),

      .o_rst_retime(rst_retime),
      .o_wrst_bank(wrst_bank),
      .o_rrst_bank(rrst_bank),
      .o_rrst_fs(rrst_fs),

      .o_en_retime(en_retime),
      .o_en_bank(en_bank),
      .o_en_fs(en_fs),

      .o_cfg_mode_rupdate(cfg_mode_rupdate),
      .o_cfg_mode_wshift (cfg_mode_wshift),
      .o_cfg_mode_rshift (cfg_mode_rshift),

      .o_cfg_fs_mode_load(cfg_fs_mode_load),
      .o_cfg_fs_syncword (cfg_fs_syncword)
  );

  // ----------------------------------------------------------------------

endmodule


`default_nettype wire
