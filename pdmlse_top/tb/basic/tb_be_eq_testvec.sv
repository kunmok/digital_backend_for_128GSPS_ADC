//`include "wr_genclk.v"
// verilog_format: off
`default_nettype none
`timescale 1ps / 1ps
// verilog_format: on

module tb_be_eq_testvec;

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

  /*localparam int TOTAL_PP_DEPTH = 3;*/
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
  /*reg dut_i_rst;*/
  reg [63:0] dut_i_rst_alu;
  reg [63:0] dut_i_rst_filt;
  reg [63:0] dut_i_rst_dec;

  reg [63:0] dut_i_en_alu;
  reg [63:0] dut_i_en_filt;
  reg [63:0] dut_i_en_dec;
  reg dut_i_cfg_eq_in_inv;
  reg dut_i_cfg_eq_out_inv;
  reg dut_i_cfg_eq_out_endian;

  reg dut_i_cfg_eq_p2_en;
  reg dut_i_cfg_eq_p1a_en;
  reg dut_i_cfg_eq_p1b_en;
  reg dut_i_cfg_eq_p3o_en;
  reg dut_i_cfg_eq_p3a_en;
  reg dut_i_cfg_eq_p3b_en;
  reg dut_i_cfg_eq_p4p_en;
  reg dut_i_cfg_eq_p4m_en;

  reg [8*64-1:0] dut_i_hm1;
  reg [8*64-1:0] dut_i_hp1;
  reg [8*64-1:0] dut_i_hx;

  reg [63:0][5:0] dut_i_adcdat;

  // Outputs
  wire [63:0] dut_o_Drx;

  // Expected outputs
  reg [63:0] dut_o_Drx_exp;

  // Monitors
  wire [63:0] dut_m_Dpre;
  wire [63:0] dut_m_Dpst;
  wire [63:0] dut_m_Dcomp;
  wire [63:0] dut_m_Dxp;
  wire [63:0] dut_m_Dxn;

  // Testbench wires/regs

  reg tb_cfg_eq_p2_en;
  reg tb_cfg_eq_p1a_en;
  reg tb_cfg_eq_p1b_en;
  reg tb_cfg_eq_p3o_en;
  reg tb_cfg_eq_p3a_en;
  reg tb_cfg_eq_p3b_en;
  reg tb_cfg_eq_p4p_en;
  reg tb_cfg_eq_p4m_en;

  reg tb_rst;  // Reset for testbench, not DUT
  reg [63:0] tb_rst_alu;  // Reset for testbench, not DUT
  reg [63:0] tb_rst_filt;  // Reset for testbench, not DUT
  reg [63:0] tb_rst_dec;  // Reset for testbench, not DUT

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

  initial begin
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
      /*$readmemb("./testvectors/testvec_hm1_bin_S5p2_ver5_nospace.txt", vec_test_i_hm1, 0,
       *          num_samples_trimmed - 1);
       *$readmemb("./testvectors/testvec_h1_bin_S5p2_ver5_nospace.txt", vec_test_i_hp1, 0,
       *          num_samples_trimmed - 1);
       *$readmemb("./testvectors/testvec_hx_bin_S5p2_ver5_nospace.txt", vec_test_i_hx, 0,
       *          num_samples_trimmed - 1);*/

      // give constant instead of vectors, to match with scan-based testbench
      test_i_hm1 = 8'b00011000;
      test_i_hp1 = 8'b00011000;
      test_i_hx = 8'b00100001;

      // 0=0.0..63=0.63, 64=1.0..127=1.63
      $readmemb({testvector_dir, "/testvec_adc_out_bin_S5p0_ver5_nospace.txt"},
                  vec_test_i_adcdatarr, 0, num_samples_trimmed - 1);
      $readmemb({testvector_dir, "/testvec_Drx_out_bin_ver5p5.txt"}, vec_exp_o_Drx, 0,
                  num_samples_trimmed - 1 - 128);
    end
    else if (target_ber == 1e4) begin
      /*$readmemb("./testvectors/testvec_hm1_bin_S5p2_ver3_nospace.txt", vec_test_i_hm1);
       *$readmemb("./testvectors/testvec_h1_bin_S5p2_ver3_nospace.txt", vec_test_i_hp1);
       *$readmemb("./testvectors/testvec_hx_bin_S5p2_ver3_nospace.txt", vec_test_i_hx);*/

      // give constant instead of vectors, to match with scan-based testbench
      test_i_hm1 = 8'b00011000;
      test_i_hp1 = 8'b00011000;
      test_i_hx  = 8'b00100001;

      // 0=0.0..63=0.63, 64=1.0..127=1.63
      $readmemb({testvector_dir, "/testvec_adc_out_bin_S5p0_ver3_nospace.txt"},
                  vec_test_i_adcdatarr);
      $readmemb({testvector_dir, "/testvec_Drx_out_bin_ver4.txt"}, vec_exp_o_Drx);
    end


    //`ifdef CHECK_COMB
    //    if (target_ber == 1e5) begin
    //      num_samples_trimmed = num_samples - 64;
    //      $readmemb("./testvectors/testvec_mon_dpre_ber_1e5_ver5.txt", vec_exp_Dpre, 0,
    //                num_samples_trimmed - 1);
    //      $readmemb("./testvectors/testvec_mon_dpst_ber_1e5_ver5.txt", vec_exp_Dpst, 0,
    //                num_samples_trimmed - 1);
    //      $readmemb("./testvectors/testvec_mon_dcomp_ber_1e5_ver5.txt", vec_exp_Dcomp, 0,
    //                num_samples_trimmed - 1);
    //      $readmemb("./testvectors/testvec_mon_dxp_ber_1e5_ver5.txt", vec_exp_Dxp, 0,
    //                num_samples_trimmed - 1);
    //      $readmemb("./testvectors/testvec_mon_dxn_ber_1e5_ver5.txt", vec_exp_Dxn, 0,
    //                num_samples_trimmed - 1);
    //    end
    //    else if (target_ber == 1e4) begin
    //      $readmemb("./testvectors/testvec_mon_dpre_ber_1e4_ver3.txt", vec_exp_Dpre);
    //      $readmemb("./testvectors/testvec_mon_dpst_ber_1e4_ver3.txt", vec_exp_Dpst);
    //      $readmemb("./testvectors/testvec_mon_dcomp_ber_1e4_ver3.txt", vec_exp_Dcomp);
    //      $readmemb("./testvectors/testvec_mon_dxp_ber_1e4_ver3.txt", vec_exp_Dxp);
    //      $readmemb("./testvectors/testvec_mon_dxn_ber_1e4_ver3.txt", vec_exp_Dxn);
    //    end
    //`endif
  end

  // sim runtime
  initial begin
    vec_sample_idx = 32'd0;

    err_flag = 1'b0;
    dut_i_clk = 1'b0;

    finish_flag = 1'b0;

    dut_i_en_alu = '1;
    dut_i_en_filt = '1;
    dut_i_en_dec = '1;

    dut_i_cfg_eq_in_inv = '0;
    dut_i_cfg_eq_out_inv = '0;
    dut_i_cfg_eq_out_endian = '0;

    tb_rst = 1'b1;
    tb_rst_alu = '1;
    tb_rst_filt = '1;
    tb_rst_dec = '1;
    #(100);
    tb_rst = 1'b0;
    tb_rst_alu = '0;
    tb_rst_filt = '0;
    tb_rst_dec = '0;

    tb_cfg_eq_p2_en = 1'b0;

    tb_cfg_eq_p1a_en = 1'b1;
    tb_cfg_eq_p1b_en = 1'b1;
    tb_cfg_eq_p3o_en = 1'b1;
    tb_cfg_eq_p3a_en = 1'b1;
    tb_cfg_eq_p3b_en = 1'b1;
    tb_cfg_eq_p4p_en = 1'b1;
    tb_cfg_eq_p4m_en = 1'b1;
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
    /*dut_i_rst <= tb_rst;*/
    dut_i_rst_alu <= tb_rst_alu;
    dut_i_rst_filt <= tb_rst_filt;
    dut_i_rst_dec <= tb_rst_dec;

    dut_i_cfg_eq_p2_en <= tb_cfg_eq_p2_en;
    dut_i_cfg_eq_p1a_en <= tb_cfg_eq_p1a_en;
    dut_i_cfg_eq_p1b_en <= tb_cfg_eq_p1b_en;
    dut_i_cfg_eq_p3o_en <= tb_cfg_eq_p3o_en;
    dut_i_cfg_eq_p3a_en <= tb_cfg_eq_p3a_en;
    dut_i_cfg_eq_p3b_en <= tb_cfg_eq_p3b_en;
    dut_i_cfg_eq_p4p_en <= tb_cfg_eq_p4p_en;
    dut_i_cfg_eq_p4m_en <= tb_cfg_eq_p4m_en;

    /*dut_i_hm1 <= vec_test_i_hm1[vec_sample_idx];
     *dut_i_hp1 <= vec_test_i_hp1[vec_sample_idx];
     *dut_i_hx <= vec_test_i_hx[vec_sample_idx];*/

    dut_i_hm1 <= {64{test_i_hm1}};
    dut_i_hp1 <= {64{test_i_hp1}};
    dut_i_hx <= {64{test_i_hx}};

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
    else begin
      err_flag <= err_flag;  // Latch it
      vec_sample_idx <= vec_sample_idx + 1;

      /*if (vec_sample_idx > num_samples) begin
       *  if (err_flag == 1'b0) begin
       *    $display("=============================");
       *    $display("TEST SUCCESS! COMPLETED WITH NO ERRORS");
       *    $display("=============================\n");
       *    [>$finish;<]
       *    finish_flag <= 1'b1;
       *  end
       *  else begin
       *    if (dut_o_Drx_exp != 'x) begin
       *      $display("=============================");
       *      $display("TEST FAIL! MISMATCH WITH TEST VECTOR OUTPUT");
       *      $display("=============================\n");
       *      finish_flag <= 1'b1;
       *    end else begin
       *      $display("=============================");
       *      $display("CHECK EXPECTED OUTPUTS at VECTOR SAMPLE %d", vec_sample_idx);
       *      $display("TEST SUCCESS UNTIL THIS POINT");
       *      $display("=============================\n");
       *      finish_flag <= 1'b1;
       *    end
       *  end*/

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

  dsp_be_eq #(
      .PRLL_RANK(64),
      .ALU_PRE_PP_DEPTH(ALU_PRE_PP_DEPTH),
      .ALU_PST_PP_DEPTH(ALU_PST_PP_DEPTH),
      .FILT_PRE_PP_DEPTH(FILT_PRE_PP_DEPTH),
      .FILT_PST_PP_DEPTH(FILT_PST_PP_DEPTH),
      .DEC_PRE_PP_DEPTH(DEC_PRE_PP_DEPTH),
      .DEC_PST_PP_DEPTH(DEC_PST_PP_DEPTH)
  ) dsp_be_eq (
      .i_clk(dut_i_clk),
      /*.i_rst(dut_i_rst),*/

      .i_rst_alu (dut_i_rst_alu),
      .i_rst_filt(dut_i_rst_filt),
      .i_rst_dec (dut_i_rst_dec),

      .i_en_alu (dut_i_en_alu),
      .i_en_filt(dut_i_en_filt),
      .i_en_dec (dut_i_en_dec),

      .i_cfg_eq_in_inv(dut_i_cfg_eq_in_inv),
      .i_cfg_eq_out_inv(dut_i_cfg_eq_out_inv),
      .i_cfg_eq_out_endian(dut_i_cfg_eq_out_endian),

      /*.i_cfg_eq_p2_en (dut_i_cfg_eq_p2_en),*/
      .i_cfg_eq_p1a_en(dut_i_cfg_eq_p1a_en),
      .i_cfg_eq_p1b_en(dut_i_cfg_eq_p1b_en),
      .i_cfg_eq_p2_en (dut_i_cfg_eq_p2_en),
      .i_cfg_eq_p3o_en(dut_i_cfg_eq_p3o_en),
      .i_cfg_eq_p3a_en(dut_i_cfg_eq_p3a_en),
      .i_cfg_eq_p3b_en(dut_i_cfg_eq_p3b_en),
      .i_cfg_eq_p4p_en(dut_i_cfg_eq_p4p_en),
      .i_cfg_eq_p4m_en(dut_i_cfg_eq_p4m_en),

      .i_cfg_eq_hm1(dut_i_hm1),
      .i_cfg_eq_hp1(dut_i_hp1),
      .i_cfg_eq_hx (dut_i_hx),

      .i_dat_be(dut_i_adcdat),

      .o_drx(dut_o_Drx)  // 64 x Boolean

      /*.w_Dpre(dut_m_Dpre),  // 64 x Boolean
       *.w_Dpst(dut_m_Dpst),  // 64 x Boolean
       *.w_Dcomp(dut_m_Dcomp),  // 64 x Boolean
       *.w_Dxp(dut_m_Dxp),  // 64 x Boolean
       *.w_Dxn(dut_m_Dxn)  // 64 x Boolean*/
  );

  initial begin
    $fsdbDumpfile("basic_tb_be_eq_testvec.fsdb");
    $fsdbDumpvars(0, tb_be_eq_testvec, "+all");
  end

endmodule

`default_nettype wire
