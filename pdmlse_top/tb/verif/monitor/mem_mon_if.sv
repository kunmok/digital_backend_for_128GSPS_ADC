

interface mem_mon_if;
  import tb_cfg_pkg::*;

  localparam int WAY_WIDTH = `WAY_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int NUM_BANKS = `NUM_BANKS;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  localparam int FRAME_LENGTH = `FRAME_LENGTH;

  logic clk_in;
  logic clk_mon;

  logic [WAY_WIDTH-1:0][ADC_WIDTH-1:0] data_in;
  logic data_mon;

  modport monitor(input clk_in, input clk_mon, input data_in, input data_mon);

endinterface
