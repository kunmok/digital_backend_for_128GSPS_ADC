

interface fe_lane_mon_if;
  import tb_cfg_pkg::*;

  // barebone interface for monitor class
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_IN_WIDTH = `DES_IN_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;

  logic clk_in;
  logic clk_mon;

  // data in/mon from DUT
  logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in;
  logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_mon;

  modport monitor(input clk_in, input clk_mon, input data_in, input data_mon);

endinterface
