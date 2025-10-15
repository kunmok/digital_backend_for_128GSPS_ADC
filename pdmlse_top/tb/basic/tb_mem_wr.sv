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
`timescale 10ps/100fs
`default_nettype none
// verilog_format: on


typedef logic [`WAY_WIDTH-1:0][`ADC_WIDTH-1:0] mem_dat_t;
typedef logic [`MEM_WIDTH-1:0] mem_dat_flat_t;

class memory_driver;
  /*rand bit [`MEM_WIDTH-1:0] dat;*/
  rand mem_dat_t dat;
endclass

module tb_mem_wr;

  localparam time ScanCycle = `SCAN_CYCLE;
  localparam time ScanHalfCycle = ScanCycle / 8.0;
  localparam time HalfWriteClkCycle = 250ps;
  localparam time WriteClkCycle = 500ps;
  localparam time HalfReadClkCycle = 5ns;
  localparam time ReadClkCycle = 10ns;

  /*parameter integer ScanChainLength = 103;*/
  parameter integer ScanChainLength = `MemScanChainLength;
  parameter integer MemLength = `NUM_BANKS * `BANK_DEPTH * `MEM_WIDTH + `FRAME_LENGTH * 2;

  bit wclk;
  bit rclk;
  logic rst;
  /*logic [`MEM_WIDTH-1:0] i_dat_bank_mem;
   *logic [`MEM_WIDTH-1:0] o_dat_bank_mem;*/
  mem_dat_t i_dat;
  logic o_bit_mem;

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

  memory_driver driver = new;

  //-----------------------------------------------------------------------------------
  //    Scan Chain Clock Generator
  //-----------------------------------------------------------------------------------
  scan_clkgen ClkG (
      .RefClk(scan_ref_clk),
      .Reset (sreset),
      .ClkEn (sclk_en),
      .SClkP (sclkp),
      .SClkN (sclkn)
  );
  //-----------------------------------------------------------------------------------

  dsp_mem mem (
      .i_clk_dig_mem(wclk),
      .i_dat_mem(i_dat),
      .i_clk_read_mem(rclk),
      .o_bit_read_mem(o_bit_mem),
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

  always #(HalfWriteClkCycle) wclk = ~wclk;
  always #(HalfReadClkCycle) rclk = ~rclk;

  initial scan_ref_clk = 1'b0;
  always #(ScanHalfCycle) scan_ref_clk <= ~scan_ref_clk;

  mem_dat_t dat_q[$];

  task automatic generate_data;
    // fill a bank with pre-fill (+1) to account for extra delay by retiming
    // registers
    for (int i = 0; i < `NUM_BANKS * `BANK_DEPTH + 1; i++) begin
      driver.randomize();
      i_dat = driver.dat;
      /*i_dat = '1;*/
      /*dat_q.push_back(i_dat);*/
      #(WriteClkCycle);
      /*driver.randomize();*/
      /*i_dat = driver.dat;*/
      /*i_dat = '0;*/
      /*dat_q.push_back(i_dat);*/
      /*#(WriteClkCycle * 1ns);*/
    end
  endtask

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

  task simple_scan_test;

    integer i;

    reg [ScanChainLength - 1 : 0] scan_in_data;
    reg [ScanChainLength - 1 : 0] scan_out_data;

    begin
      $display("Starting scan in/out experiment...");

      for (i = 0; i < ScanChainLength; i = i + 1) begin
        scan_in_data[i] = $random;
      end

      start_scan_clk;

      scan_in(scan_in_data, ScanChainLength);

      scan_out(scan_out_data, ScanChainLength);

      if (scan_in_data == scan_out_data) begin
        $display("    scan in/out experiment PASSED");
      end
      else begin
        $display("    scan in/out experiment FAILED");
      end
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

  task mem_enable;
    begin
      // enable memory == clock enable
      scan_in_data[`MemBankEn] = '1;
      scan_in_data[`MemRetimeEn] = 1'b1;
      scan_in_data[`MemFsEn] = 1'b1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;
    end
  endtask

  task mem_reset;
    begin
      scan_in_data[`MemRetimeRst] = '0;
      scan_in_data[`MemBankWRst] = '0;
      scan_in_data[`MemBankRRst] = '0;
      scan_in_data[`MemFsRst] = '0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      scan_in_data[`MemRetimeRst] = '1;
      scan_in_data[`MemBankWRst] = '1;
      scan_in_data[`MemBankRRst] = '1;
      scan_in_data[`MemFsRst] = '1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      scan_in_data[`MemRetimeRst] = '0;
      scan_in_data[`MemBankWRst] = '0;
      scan_in_data[`MemBankRRst] = '0;
      scan_in_data[`MemFsRst] = '0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;
    end
  endtask

  task mem_cfg_framesync;
    begin
      // enable and config framesync word and load
      scan_in_data[`MemCfgFsModeLoad] = 1'b1;
      scan_in_data[`MemCfgFsSyncWord] = '1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      // turn off load mode
      scan_in_data[`MemCfgFsModeLoad] = 1'b0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;
    end
  endtask

  task mem_write;
    begin
      // start memory write (write-shift mode)
      scan_in_data[`MemCfgModeWShift] = 1'b1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      // stop memory write (write-shift mode)
      // delayed scan-update to cycle-match with the target write time
      // for simulation purpose only
      scan_in_data[`MemCfgModeWShift] = 1'b0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;

      // generate data for certain time
      generate_data;

      // stop immediately (scan shadow-reg update)
      scan_update;
    end
  endtask

  task mem_read_start;
    begin
      // commit write register to read register
      scan_in_data[`MemCfgModeRUpdate] = 1'b1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      // turn off
      scan_in_data[`MemCfgModeRUpdate] = 1'b0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;

      // start memory read (read-shift mode)
      scan_in_data[`MemCfgModeRShift] = 1'b1;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;
    end
  endtask

  task mem_read_stop;
    begin
      // stop memory read (read-shift mode)
      scan_in_data[`MemCfgModeRShift] = 1'b0;
      start_scan_clk;
      scan_in(scan_in_data, ScanChainLength);
      stop_scan_clk;
      scan_update;
    end
  endtask

  /*  initial begin
 *    wen = 1'b0;
 *    rst = 1'b0;
 *    ren = 1'b0;
 *    #(WriteClkCycle / 4.0 * 1ns);
 *    rst = 1'b1;
 *    #(WriteClkCycle * 5 * 1ns);
 *    rst = 1'b0;
 *
 *    #(WriteClkCycle * 1 * 1ns);
 *    wen = 1'b1;
 *    #(WriteClkCycle * 1 * 1ns);
 *    generate_data();
 *    #(WriteClkCycle * `BANK_DEPTH * 1ns);
 *    #(ReadClkCycle * 4.0 * 1ns);
 *    wen = 1'b0;
 *    #(ReadClkCycle / 4.0 * 1ns);
 *    ren = 1'b1;
 *    #(ReadClkCycle * `BANK_DEPTH * `MEM_WIDTH * 2 * 1ns);
 *    [>#(WriteClkCycle * `BANK_DEPTH * 2 * 1ns);<]
 *    $finish;
 *  end*/

  initial begin
    #(ScanCycle);
    sreset = 1'b1;
    #(ScanCycle);
    sreset = 1'b0;
    #(ScanCycle);
    mem_enable;
    #(ScanCycle);
    mem_reset;
    #(ScanCycle);
    mem_cfg_framesync;
    #(ScanCycle);
    mem_write;
    mem_read_start;
    #(ReadClkCycle * MemLength);
    mem_read_stop;
    #(ScanCycle * 30);
    $finish;
  end

  /*  initial begin
 *    #(ScanCycle);
 *    sreset = 1'b1;
 *    #(ScanCycle);
 *    sreset = 1'b0;
 *    #(ScanCycle);
 *    simple_scan_test;
 *    #(ScanCycle * 30);
 *    $finish;
 *  end
 **/

  initial begin
    $fsdbDumpfile("basic_tb_mem_wr.fsdb");
    $fsdbDumpvars(0, tb_mem_wr, "+all");
  end

endmodule

`default_nettype wire

