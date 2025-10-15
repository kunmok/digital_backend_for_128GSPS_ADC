//`include "wr_genclk.v"
// verilog_format: off
`default_nettype none
`timescale 1ps / 1ps
// verilog_format: on

module tb_be_testvec;

`ifdef BERSHORT
  localparam NUM_SAMPLES = 32'd10048;  // BER = 1E4
`endif
`ifdef BERLONG
  localparam NUM_SAMPLES = 32'd100096;  // BER = 1E5
`endif

  // IMPORTANT: NUM_CYCLES_SKIP SHOULD BE LARGER THAN THE TOTAL_PIPELINE_DEPTH!!

  localparam TB_HALF_PERIOD = 500;  // ps
  localparam int MAX_SAMPLES = 1000000;
  /*localparam int NUM_CYCLES_SKIP = 4;*/

  localparam int ALU_PRE_PP_DEPTH = `ALU_PRE_PP_DEPTH;
  localparam int ALU_PST_PP_DEPTH = `ALU_PST_PP_DEPTH;
  localparam int FILT_PRE_PP_DEPTH = `FILT_PRE_PP_DEPTH;
  localparam int FILT_PST_PP_DEPTH = `FILT_PST_PP_DEPTH;
  localparam int DEC_PRE_PP_DEPTH = `DEC_PRE_PP_DEPTH;
  localparam int DEC_PST_PP_DEPTH = `DEC_PST_PP_DEPTH;

  localparam int ALU_PP_DEPTH = ALU_PRE_PP_DEPTH + ALU_PST_PP_DEPTH;
  localparam int FILT_PP_DEPTH = FILT_PRE_PP_DEPTH + FILT_PST_PP_DEPTH;
  localparam int DEC_PP_DEPTH = DEC_PRE_PP_DEPTH + DEC_PST_PP_DEPTH;
  localparam int TOTAL_PP_DEPTH = FILT_PP_DEPTH + DEC_PP_DEPTH + ALU_PP_DEPTH;

  localparam int NUM_CYCLES_SKIP = TOTAL_PP_DEPTH + 1;

  longint num_samples;
  longint num_samples_trimmed;
  longint target_ber;

  string testvector_dir;

  // DUT port connections
  // Inputs
  reg dut_i_clk;
  reg [63:0][5:0] dut_i_adcdat;

  // Outputs
  wire [63:0] dut_o_Drx;

  // Expected outputs
  reg [63:0] dut_o_Drx_exp;

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

  /*  reg [63:0] vec_mon_Dpre[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_mon_Dpst[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_mon_Dcomp[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_mon_Dxp[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_mon_Dxn[0:NUM_SAMPLES-1];
 *
 *  reg [63:0] vec_exp_Dpre[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_exp_Dpst[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_exp_Dcomp[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_exp_Dxp[0:NUM_SAMPLES-1];
 *  reg [63:0] vec_exp_Dxn[0:NUM_SAMPLES-1];*/

  //-----------------------------------------------------------------------------------
  // Scan Interface
  //-----------------------------------------------------------------------------------
  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;

  /*parameter integer ScanChainLength = 103;*/
  parameter integer ScanChainLength = `BeScanChainLength;

  reg [ScanChainLength - 1 : 0] scan_in_data;
  reg [ScanChainLength - 1 : 0] scan_out_data;

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

  initial begin
    if (NUM_CYCLES_SKIP <= TOTAL_PP_DEPTH) begin
      $fatal(1, "NUM_CYCLES_SKIP should be larger than TOTAL_PP_DEPTH, currently %d and %d",
             NUM_CYCLES_SKIP, TOTAL_PP_DEPTH);
    end
  end

  // Dut Controls
  task automatic scan_reset;
    scan_in_data = '0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_enable;
    scan_in_data[`BeEnAlu]  = '1;
    scan_in_data[`BeEnFilt] = '1;
    scan_in_data[`BeEnDec]  = '1;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_reset;
    scan_in_data[`BeRstAlu]  = '1;
    scan_in_data[`BeRstFilt] = '1;
    scan_in_data[`BeRstDec]  = '1;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;

    scan_in_data[`BeRstAlu]  = '0;
    scan_in_data[`BeRstFilt] = '0;
    scan_in_data[`BeRstDec]  = '0;
    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  task automatic be_cfg_eq;
    input [7:0] cfg_eq_hm1;
    input [7:0] cfg_eq_hp1;
    input [7:0] cfg_eq_hx;

    scan_in_data[`BeCfgEqInInv] = '0;
    scan_in_data[`BeCfgEqOutInv] = '0;
    scan_in_data[`BeCfgEqOutEndian] = '0;
    scan_in_data[`BeCfgEqP1aEn] = '1;
    scan_in_data[`BeCfgEqP1bEn] = '1;
    scan_in_data[`BeCfgEqP2En] = '0;
    scan_in_data[`BeCfgEqP3oEn] = '1;
    scan_in_data[`BeCfgEqP3aEn] = '1;
    scan_in_data[`BeCfgEqP3bEn] = '1;
    scan_in_data[`BeCfgEqP4pEn] = '1;
    scan_in_data[`BeCfgEqP4mEn] = '1;

    scan_in_data[`BeCfgEqHm1] = {64{cfg_eq_hm1}};
    scan_in_data[`BeCfgEqHp1] = {64{cfg_eq_hp1}};
    scan_in_data[`BeCfgEqHx] = {64{cfg_eq_hx}};

    start_scan_clk;
    scan_in(scan_in_data, ScanChainLength);
    stop_scan_clk;
    scan_update;
  endtask

  // sim runtime
  initial begin
    test_i_hm1 = 8'b00011000;
    test_i_hp1 = 8'b00011000;
    test_i_hx  = 8'b00100001;

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
    be_cfg_eq(test_i_hm1, test_i_hp1, test_i_hx);
    #(ScanCycle);

    if ($value$plusargs("TARGET_BER=%d", target_ber)) begin
      $display("TARGET BER: %d", target_ber);
      get_num_samples(target_ber, num_samples);
      $display("NUMBER OF SAMPLES: %d", num_samples);
    end
    else begin
      $fatal(1, "[ERROR] Target BER not supplied, should be either 1e4 or 1e5");
    end

    if ($value$plusargs("TESTVECTOR_DIR=%s", testvector_dir)) begin
      $display("TESTVECTOR_DIR: %s", testvector_dir);
    end
    else begin
      $fatal(1, "[ERROR] Testvector directory not supplied");
    end

    if (target_ber == 1e5) begin
      num_samples_trimmed = num_samples - 64;
      // 0=0.0..63=0.63, 64=1.0..127=1.63
      $readmemb({testvector_dir, "/testvec_adc_out_bin_S5p0_ver5_nospace.txt"},
                  vec_test_i_adcdatarr, 0, num_samples_trimmed - 1);
      $readmemb({testvector_dir, "/testvec_Drx_out_bin_ver5p5.txt"}, vec_exp_o_Drx, 0,
                  num_samples_trimmed - 1 - 128);
    end
    else if (target_ber == 1e4) begin
      // 0=0.0..63=0.63, 64=1.0..127=1.63
      $readmemb({testvector_dir, "/testvec_adc_out_bin_S5p0_ver3_nospace.txt"},
                  vec_test_i_adcdatarr);
      $readmemb({testvector_dir, "/testvec_Drx_out_bin_ver4.txt"}, vec_exp_o_Drx);
    end
    @(posedge dut_i_clk);
    tb_start_check = 1'b1;
  end

  // initialize
  initial begin
    vec_sample_idx = 32'd0;
    err_flag = 1'b0;
    dut_i_clk = 1'b0;
    finish_flag = 1'b0;
  end

  // exit handler
  initial begin
    fork
      begin
        wait (finish_flag);
        $display("Terminating Simulation at Vector Sample %d", vec_sample_idx);
        $finish;
      end
    join_any
  end

  // Prepare inputs
  always @(posedge dut_i_clk) begin
    for (int i = 0; i < 64; i = i + 1) begin
      dut_i_adcdat[i] <= vec_test_i_adcdatarr[64*vec_sample_idx+i];
    end
  end

  // Prepare outputs
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin
      always @(negedge dut_i_clk) begin
        dut_o_Drx_exp[i] <= vec_exp_o_Drx[64*(vec_sample_idx-TOTAL_PP_DEPTH)+i];
      end
    end
  endgenerate

  always @(negedge dut_i_clk) begin
    dut_o_Drx_diff <= dut_o_Drx ^ dut_o_Drx_exp;
    if (tb_rst) begin
      vec_sample_idx <= 32'd0;
      err_flag <= 1'b0;
    end
    else if (tb_start_check) begin
      err_flag <= err_flag;  // Latch it
      vec_sample_idx <= vec_sample_idx + 1;

      if (err_flag == 1'b1) begin
        if (dut_o_Drx_exp != 'x) begin
          $display("=============================");
          $display("TEST FAIL! MISMATCH WITH TEST VECTOR OUTPUT");
          $display("=============================\n");
          finish_flag <= 1'b1;
        end
        else begin
          $display("=============================");
          $display("CHECK EXPECTED OUTPUTS at VECTOR SAMPLE %d", vec_sample_idx);
          $display("TEST SUCCESS UNTIL THIS POINT!");
          $display("=============================\n");
          finish_flag <= 1'b1;
        end
      end
      else begin
        if (vec_sample_idx > num_samples) begin
          $display("=============================");
          $display("TEST SUCCESS! COMPLETED WITH NO ERRORS");
          $display("=============================\n");
          finish_flag <= 1'b1;
        end
      end
    end

    if (vec_sample_idx > NUM_CYCLES_SKIP && (vec_sample_idx < num_samples - 1)) begin
      // use 4-state inequality
      if (dut_o_Drx === dut_o_Drx_exp) begin
        $display("DUT OUTPUT MATCHES! VECTOR SAMPLE ID = %d", vec_sample_idx);
        $display("DUT OUTPUT          : %b", dut_o_Drx);
        $display("DUT OUTPUT_EXPECTED : %b", dut_o_Drx_exp);
        $display("XOR                 : %b\n", dut_o_Drx_diff);
      end
      else if (dut_o_Drx_exp === 'x) begin
        $display("EXPERIMENT DONE! VECTOR SAMPLE ID = %d", vec_sample_idx);
        finish_flag <= 1'b1;
      end
      else begin
        err_flag <= 1'b1;
        $display("=============================");
        $display("ERROR! ERROR! ERROR! VECTOR SAMPLE ID = %d", vec_sample_idx);
        $display("DUT OUTPUT          : %b", dut_o_Drx);
        $display("DUT OUTPUT_EXPECTED : %b", dut_o_Drx_exp);
        $display("XOR                 : %b", dut_o_Drx_diff);
        $display("=============================\n");
      end
    end
  end

  dsp_be dsp_be (
      .i_clk_dig_be(dut_i_clk),
      .i_dat_be(dut_i_adcdat),
      .o_drx(dut_o_Drx),
      .i_sdata(sin),
      .i_sclkp(sclkp),
      .i_sclkn(sclkn),
      .i_senable(senable),
      .i_supdate(supdate),
      .i_sreset(sreset),
      .o_sdata(sout),
      .o_sclkp(),
      .o_sclkn(),
      .o_senable(),
      .o_supdate(),
      .o_sreset()
  );

  initial begin
    $fsdbDumpfile("basic_tb_be_testvec.fsdb");
    $fsdbDumpvars(0, tb_be_testvec, "+all");
  end

endmodule

`default_nettype wire
