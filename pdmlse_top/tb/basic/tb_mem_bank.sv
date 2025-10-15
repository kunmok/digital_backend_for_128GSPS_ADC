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
`timescale 1ns/10ps
`default_nettype none
// verilog_format: on


typedef logic [`MEM_WIDTH-1:0] mem_dat_t;

class memory_driver;
  /*rand bit [`MEM_WIDTH-1:0] dat;*/
  rand mem_dat_t dat;
endclass

module tb_mem_bank;

  localparam HalfWriteClkCycle = 0.5;
  localparam WriteClkCycle = 1;
  localparam HalfReadClkCycle = 5;
  localparam ReadClkCycle = 10;

  bit wclk;
  bit rclk;
  logic rst;
  logic wen;
  logic ren;
  /*logic [`MEM_WIDTH-1:0] i_dat_bank_mem;
   *logic [`MEM_WIDTH-1:0] o_dat_bank_mem;*/
  mem_dat_t i_dat;
  mem_dat_t o_dat;
  logic i_bit_tail_bank_mem;
  logic o_bit_head_bank_mem;

  assign i_bit_tail_bank_mem = 1'b0;

  memory_driver driver = new;

  dsp_mem_bank mem_bank (
      .i_wclk(wclk),
      .i_rclk(rclk),
      .i_rst(rst),
      .i_wen(wen),
      .i_ren(ren),
      .i_dat_bank_mem(i_dat),
      .o_dat_bank_mem(o_dat),
      .i_bit_tail_bank_mem(i_bit_tail_bank_mem),
      .o_bit_head_bank_mem(o_bit_head_bank_mem)
  );

  always #(HalfWriteClkCycle) wclk = ~wclk;
  always #(HalfReadClkCycle) rclk = ~rclk;

  mem_dat_t dat_q[$];

  task automatic generate_data;
    for (int i = 0; i < `BANK_DEPTH; i++) begin
      begin
        driver.randomize();
        i_dat = driver.dat;
        dat_q.push_back(i_dat);
      end
      #(WriteClkCycle * 1ns);
    end
  endtask

  initial begin
    wen = 1'b0;
    rst = 1'b0;
    ren = 1'b0;
    #(WriteClkCycle / 4.0 * 1ns);
    rst = 1'b1;
    #(WriteClkCycle * 5 * 1ns);
    rst = 1'b0;

    #(WriteClkCycle * 1 * 1ns);
    wen = 1'b1;
    #(WriteClkCycle * 1 * 1ns);
    generate_data();
    #(WriteClkCycle * `BANK_DEPTH * 1ns);
    #(ReadClkCycle * 4.0 * 1ns);
    wen = 1'b0;
    #(ReadClkCycle / 4.0 * 1ns);
    ren = 1'b1;
    #(ReadClkCycle * `BANK_DEPTH * `MEM_WIDTH * 2 * 1ns);
    /*#(WriteClkCycle * `BANK_DEPTH * 2 * 1ns);*/
    $finish;
  end

  initial begin
    $fsdbDumpfile("simple_test_mem_bank.fsdb");
    $fsdbDumpvars(0, tb_mem_bank, "+all");
  end

endmodule

`default_nettype wire

