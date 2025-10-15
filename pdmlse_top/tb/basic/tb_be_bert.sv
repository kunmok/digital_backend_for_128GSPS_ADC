//`include "wr_genclk.v"
// verilog_format: off
`default_nettype none
`timescale 1ps / 1ps
// verilog_format: on

module tb_be_bert;


  // DUT port connections
  // Inputs
  reg dut_i_clk;

  // Testbench wires/regs
  reg tb_rst;  // Reset for testbench, not DUT
  reg tb_start_check;

  reg err_flag;
  reg err_flag_comb;
  reg [31:0] vec_sample_idx;  // Which clock sample
  reg finish_flag;

  reg [7:0] test_i_hm1;
  reg [7:0] test_i_hp1;
  reg [7:0] test_i_hx;

  /*reg [7:0] vec_test_i_hm1[0:NUM_SAMPLES-1];
   *reg [7:0] vec_test_i_hp1[0:NUM_SAMPLES-1];
   *reg [7:0] vec_test_i_hx[0:NUM_SAMPLES-1];*/

  reg [5:0] vec_test_i_adcdatarr[0:NUM_SAMPLES-1];

  reg [63:0] vec_exp_o_Drx[0:NUM_SAMPLES-1];
  reg [63:0] vec_exp_o_Drx_dlymatch[0:1][0:NUM_SAMPLES-1];
  reg [63:0] dut_o_Drx_diff;

  //-----------------------------------------------------------------------------------
  // DUT Control
  //-----------------------------------------------------------------------------------
  // BERT Control & Readout
  // Scan-controlled reset
  logic rst_bert;

  // Pattern/PRBS-Generator Configs
  // See pattern_generator_wi_cfg_wrapper for details
  logic [`TOT_PGEN_CFG_LENGTH-1:0] cfg_pgen;

  // Snapshot Enable
  logic [`BERT_WAY_WIDTH-1:0] cfg_snap_en;
  // BERT mode
  logic [`BERT_WAY_WIDTH-1:0] cfg_mode_ber;
  // BERT count enable
  logic [`BERT_WAY_WIDTH-1:0] cfg_ber_count_en;
  // BERT shutoff select (set to 0 for most)
  logic [`SHUTOFF_SEL_WIDTH-1:0] cfg_ber_shutoff_sel;
  // BERT chicken bits
  logic cfg_ber_in_inv;

  // from BERT with PRBS7
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs7;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs7;
  // BERT shutoff flag
  logic ber_shutoff_prbs7;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs7;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs7;

  // from BERT with PRBS15
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs15;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs15;
  // BERT shutoff flag
  logic ber_shutoff_prbs15;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs15;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs15;

  // from BERT with PRBS31
  // PRBS seed good flag
  logic [`BERT_WAY_WIDTH-1:0] prbs_seed_good_prbs31;
  // Snapshot output
  logic [`TOT_SNAP_LENGTH-1:0] snap_out_prbs31;
  // BERT shutoff flag
  logic ber_shutoff_prbs31;
  // BERT count
  logic [`TOT_BER_COUNT_WIDTH-1:0] ber_count_prbs31;
  // Bit count
  logic [`BER_COUNT_WIDTH-1:0] bit_count_prbs31;


  typedef enum bit [2:0] {
    DISABLE  = 3'b000,
    PRBSSEED = 3'b110,
    PRBSRUN  = 3'b010
  } pgen_cfg_e;

  //-----------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------
  // TX
  //-----------------------------------------------------------------------------------
  reg [ScanChainLength - 1 : 0] scan_in_data;
  reg [ScanChainLength - 1 : 0] scan_out_data;

  /*  logic tx_clk;
 *  logic tx_rst;
 *  logic tx_in;
 *  logic tx_out;
 *  logic tx_cnt_phase;
 *  logic tx_cnt_load;
 *  logic tx_cnt_word;
 *  logic tx_in_en;
 *  logic tx_last_word;
 *  logic tx_auto_align;
 *  logic tx_auto_align_locked;
 *  logic tx_auto_align_cnt;
 *  logic tx_slice_data_sel;
 *
 *  assign tx_cnt_load = '0;
 *  assign tx_cnt_word = '1;
 *  assign tx_in_en = '1;
 *  assign tx_auto_align = '1;
 *  assign tx_slice_data_sel = '0;
 *
 *  var_ratio_des #(
 *      .OutWidth(64),
 *      .NumberSlices(1),
 *      .SliceSerDesRatio(1),
 *      .MinDivideRatio(1),
 *      .DivideRatioWidth(64)
 *  ) tx_des (
 *      .clk(tx_clk),
 *      .rst(tx_rst),
 *      .in(tx_in),
 *      .out(tx_out),
 *      .cnt_phase(tx_cnt_phase),
 *      .cnt_load(tx_cnt_load),
 *      .cnt_word(tx_cnt_word),
 *      .in_en(tx_in_en),
 *      .last_word(tx_last_word),
 *      .auto_align(tx_auto_align),
 *      .auto_align_locked(tx_auto_align_locked),
 *      .auto_align_cnt(tx_auto_align_cnt),
 *      .slice_data_sel(tx_slice_data_sel)
 *  );*/

  logic tx_clk;
  logic tx_rst;
  logic tx_pgen_cfg;
  logic [63:0] tx_pgen_seed;
  logic tx_prbs_seed_good;
  logic [63:0] tx_out;

  logic [63:0] dut_o_tx;

  // Harness
  pattern_generator_cfg_wrapper #(
      .OutBits   (64),
      .PattLength(32),
      .PRBSLength(7)
  ) tx_pgen (
      .clk           (tx_clk),
      .reset         (tx_rst),
      .cfg           (tx_pgen_cfg),
      .pgen_seed_in  (tx_pgen_seed),
      .prbs_seed_good(tx_prbs_seed_good),
      .data_out      (tx_out)
  );

  pgen_cfg_e tx_pgen_cfg;

  assign tx_pgen_seed = '1;
  assign tx_pgen_cfg = PRBSRUN;

  assign tx_clk = dut_i_clk;
  assign tx_rst = tb_rst;
  assign dut_o_tx = tx_out;

  //-----------------------------------------------------------------------------------
  // Scan Interface
  //-----------------------------------------------------------------------------------
  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;

  /*parameter integer ScanChainLength = 103;*/
  parameter integer ScanChainLength = `BeScanChainLength;

  reg [ScanChainLength - 1 : 0] scan_in_data;
  reg [ScanChainLength - 1 : 0] scan_out_data;

  // Harness-side
  logic scan_ref_clk;
  logic sclk_en;
  logic sreset;
  logic sclkp;
  logic sclkn;
  logic senable;
  logic sin;
  logic supdate;
  logic sout;

  scan_clkgen ClkG (
      .RefClk(scan_ref_clk),
      .Reset (sreset),
      .ClkEn (sclk_en),
      .SClkP (sclkp),
      .SClkN (sclkn)
  );

  initial scan_ref_clk = 1'b0;
  always #(ScanHalfCycle) scan_ref_clk <= ~scan_ref_clk;

  // DUT-side
  scan_if i_scan ();
  pgen_cfg_e rx_cfg_pgen;

  // wrap scan
  assign i_scan.sdata = sin;
  assign i_scan.sctrl = {sclkp, sclkn, senable, supdate, sreset};

  task start_scan_clk;
    begin
      sclk_en = 1'b1;
      #(ScanCycle);
    end
  endtask

  task stop_scan_clk;
    begin
      sclk_en = 1'b0;
      #(ScanCycle);
    end
  endtask

  // Scan in some number of bits
  task scan_in;

    input [9999:0] scan_in_data;
    input [31:0] length;
    integer scan_pos;
    integer i;

    begin
      senable = 1'b1;
      // MSB bits are scanned in first            
      for (i = 0; i < length; i = i + 1) begin
        scan_pos = length - 1 - i;
        sin = scan_in_data[scan_pos];
        /*$display("%d", sin);*/
        #(ScanCycle);
      end

      senable = 1'b0;
    end
  endtask

  // Scan out some number of bits
  task scan_out;

    output reg [9999:0] scan_out_data;
    input [31:0] length;
    integer scan_pos;
    integer i;

    begin
      senable = 1'b1;

      // MSB bits are scanned out first
      for (i = 0; i < length; i = i + 1) begin
        scan_pos = length - 1 - i;
        scan_out_data[scan_pos] = sout;
        /*$display("%d", sout);*/
        #(ScanCycle);
      end

      senable = 1'b0;
      /*$display("%d", scan_out_data);*/
    end
  endtask

  // Scan update
  task scan_update;
    begin
      supdate = 1'b1;
      #(ScanCycle);
      supdate = 1'b0;
      #(ScanCycle);
    end
  endtask

  // Scan enable
  task scan_enable;
    begin
      senable = 1'b1;
      #(ScanCycle);
      senable = 1'b0;
      #(ScanCycle);
    end
  endtask
  //-----------------------------------------------------------------------------------


  // ----------------------- Testbench ------------------------
  always begin
    #(TB_HALF_PERIOD) dut_i_clk = ~dut_i_clk;
  end

  task automatic get_num_samples(input longint target_ber, output longint num_samples);
    begin
      if (target_ber == 1e4) begin
        num_samples = 10048;
      end
      else if (target_ber == 1e5) begin
        num_samples = 100096;
      end
      else begin
        $fatal(1, "[ERROR] Target BER supported is either 1e4 or 1e5, %d is supplied", target_ber);
      end
    end
  endtask

  // Dut Controls
  task automatic scan_reset;
    scan_in_data = '0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_enable;
    scan_in_data[`BeCfgSnapEn] = '1;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_reset;
    scan_in_data[`BeRstBert] = '1;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;

    scan_in_data[`BeRstBert] = '0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_cfg_bert;
    scan_in_data[`BeCfgModeBer] = 1'b1;
    scan_in_data[`BeCfgBerShutoffSel] = '0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_cfg_pgen_seed;
    scan_in_data[`BeCfgPgen] = {1'b0, PRBSSEED, 32'0}
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_cfg_pgen_run;
    scan_in_data[`BeCfgPgen] = {1'b0, PRBSRUN, 32'0}
    scan_in_data['BeCfgBerCountEn] = 1'b1;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_cfg_bert_stop;
    scan_in_data['BeCfgBerCountEn] = 1'b0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  // sim runtime
  initial begin
    #(ScanCycle);
    sreset = 1'b1;
    #(ScanCycle);
    sreset = 1'b0;
    #(ScanCycle);
    scan_reset;
    #(ScanCycle);
    be_enable;
    #(ScanCycle);
    be_reset;
    #(ScanCycle);
    be_cfg_bert;
    #(ScanCycle);
    be_cfg_pgen_seed;
    #(ScanCycle);
    be_cfg_pgen_run;
    #(ScanCycle);
    be_cfg_bert_stop;
    #(ScanCycle);
  end

  // initialize
  initial begin
    dut_i_clk = 1'b0;
  end

  dsp_be_bert #(
      .PRLL_RANK(PRLL_RANK)
  ) be_bert (
      .i_clk(dut_i_clk),
      .i_rst(rst_bert),

      .i_drx(dut_o_tx),

      .i_cfg_pgen(cfg_pgen),

      .i_cfg_snap_en(cfg_snap_en),
      .i_cfg_mode_ber(cfg_mode_ber),
      .i_cfg_ber_count_en(cfg_ber_count_en),
      .i_cfg_ber_shutoff_sel(cfg_ber_shutoff_sel),
      .i_cfg_ber_in_inv(cfg_ber_in_inv),

      // from BERT with PRBS7
      .o_prbs_seed_good_prbs7(prbs_seed_good_prbs7),
      .o_snap_out_prbs7(snap_out_prbs7),
      .o_ber_shutoff_prbs7(ber_shutoff_prbs7),
      .o_ber_count_prbs7(ber_count_prbs7),
      .o_bit_count_prbs7(bit_count_prbs7),

      // from BERT with PRBS15
      .o_prbs_seed_good_prbs15(prbs_seed_good_prbs15),
      .o_snap_out_prbs15(snap_out_prbs15),
      .o_ber_shutoff_prbs15(ber_shutoff_prbs15),
      .o_ber_count_prbs15(ber_count_prbs15),
      .o_bit_count_prbs15(bit_count_prbs15),

      // from BERT with PRBS31
      .o_prbs_seed_good_prbs31(prbs_seed_good_prbs31),
      .o_snap_out_prbs31(snap_out_prbs31),
      .o_ber_shutoff_prbs31(ber_shutoff_prbs31),
      .o_ber_count_prbs31(ber_count_prbs31),
      .o_bit_count_prbs31(bit_count_prbs31)
  );

  dsp_be_ctrl #(
      .PRLL_RANK(PRLL_RANK)
  ) be_ctrl (
      .i_scan(i_scan),
      .o_scan(),

      // EQ Control
      .o_rst_alu (),
      .o_rst_filt(),
      .o_rst_dec (),

      .o_en_alu (),
      .o_en_filt(),
      .o_en_dec (),

      .o_cfg_eq_in_inv(),
      .o_cfg_eq_out_inv(),
      .o_cfg_eq_out_endian(),

      .o_cfg_eq_p1a_en(),
      .o_cfg_eq_p1b_en(),
      .o_cfg_eq_p2_en (),
      .o_cfg_eq_p3o_en(),
      .o_cfg_eq_p3a_en(),
      .o_cfg_eq_p3b_en(),
      .o_cfg_eq_p4p_en(),
      .o_cfg_eq_p4m_en(),

      .o_cfg_eq_hm1(),  // fxp6p2 X PRLL_RANK
      .o_cfg_eq_hp1(),  // fxp6p2 X PRLL_RANK
      .o_cfg_eq_hx (),  // fxp6p2 X PRLL_RANK

      // BERT Control & Readout
      .o_rst_bert(rst_bert),

      .o_cfg_pgen(cfg_pgen),

      .o_cfg_snap_en(cfg_snap_en),
      .o_cfg_mode_ber(cfg_mode_ber),
      .o_cfg_ber_count_en(cfg_ber_count_en),
      .o_cfg_ber_shutoff_sel(cfg_ber_shutoff_sel),
      .o_cfg_ber_in_inv(cfg_ber_in_inv),

      // from BERT with PRBS7
      .i_prbs_seed_good_prbs7(prbs_seed_good_prbs7),
      .i_snap_out_prbs7(snap_out_prbs7),
      .i_ber_shutoff_prbs7(ber_shutoff_prbs7),
      .i_ber_count_prbs7(ber_count_prbs7),
      .i_bit_count_prbs7(bit_count_prbs7),

      // from BERT with PRBS15
      .i_prbs_seed_good_prbs15(prbs_seed_good_prbs15),
      .i_snap_out_prbs15(snap_out_prbs15),
      .i_ber_shutoff_prbs15(ber_shutoff_prbs15),
      .i_ber_count_prbs15(ber_count_prbs15),
      .i_bit_count_prbs15(bit_count_prbs15),

      // from BERT with PRBS31
      .i_prbs_seed_good_prbs31(prbs_seed_good_prbs31),
      .i_snap_out_prbs31(snap_out_prbs31),
      .i_ber_shutoff_prbs31(ber_shutoff_prbs31),
      .i_ber_count_prbs31(ber_count_prbs31),
      .i_bit_count_prbs31(bit_count_prbs31)
  );

  initial begin
    $fsdbDumpfile("basic_tb_be_bert.fsdb");
    $fsdbDumpvars(0, tb_be_bert, "+all");
  end

endmodule

`default_nettype wire
