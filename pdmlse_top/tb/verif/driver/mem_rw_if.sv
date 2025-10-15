

interface mem_rw_if;
  import tb_cfg_pkg::*;

  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int WAY_WIDTH = `WAY_WIDTH;
  localparam int NUM_BANKS = `NUM_BANKS;
  localparam int BANK_DEPTH = `BANK_DEPTH;
  localparam int MEM_WIDTH = `MEM_WIDTH;
  localparam int FRAME_LENGTH = `FRAME_LENGTH;

  logic wclk;
  logic rclk;
  logic [WAY_WIDTH-1:0][ADC_WIDTH-1:0] data;
  test_pattern_e tp_mem[WAY_WIDTH][ADC_WIDTH];
  /*logic [MEM_WIDTH*NUM_BANKS*BANK_DEPTH-1:0] o_rdata;
   *logic [MEM_WIDTH*NUM_BANKS*BANK_DEPTH-1:0] o_rdata_expected;*/
  /*logic [FRAME_LENGTH-1:0] o_frame_expected;*/

  event write_start;
  event read_start;

  task automatic toggle_rclk(input int cycle);
`ifdef DEBUG
    $display("Data task for instance waiting at time %0t", $time);
`endif
    @(read_start);
    @(posedge rclk);
`ifdef DEBUG
    $display("Data task for instance started at time %0t", $time);
`endif
    /*#(delay);*/
    /*data = '1;*/
    repeat (cycle) begin
      @(posedge rclk);
    end
`ifdef DEBUG
    $display("Data task for instance completed at time %0t", $time);
`endif
  endtask

  task automatic send_data(input int cycle, input time delay);
`ifdef DEBUG
    $display("Data task for instance waiting at time %0t", $time);
`endif
    @(write_start);
    @(posedge wclk);
`ifdef DEBUG
    $display("Data task for instance started at time %0t", $time);
`endif
    /*#(delay);*/
    /*data = '1;*/
    repeat (cycle) begin
      @(posedge wclk);
      #(delay);
      generate_data(data);
    end
    /*@(data_end);*/
`ifdef DEBUG
    $display("Data task for instance completed at time %0t", $time);
`endif
  endtask

  function automatic seed_test_patt(input bit seed, input int i, input int j);
    if (i > WAY_WIDTH || j > ADC_WIDTH) begin
      $display("Invalid seed index: %0d %0d", i, j);
      $fatal("Invalid seed index");
    end

    data[i][j] = seed;
`ifdef DEBUG
    $display("[mem_rw_if] Seed input[i][j]: %b", data[i][j]);
`endif
  endfunction

  function automatic config_test_patt(input test_pattern_e tp, input int i, input int j);
    if (i > WAY_WIDTH || j > ADC_WIDTH) begin
      $display("Invalid seed index: %0d %0d", i, j);
      $fatal("Invalid seed index");
    end

    tp_mem[i][j] = tp;
`ifdef DEBUG
    $display("[mem_rw_if] Configured test pattern for input[i][j]: %0d", tp_mem[i][j]);
`endif
  endfunction

  function automatic generate_data(output logic [WAY_WIDTH-1:0][ADC_WIDTH-1:0] o_data);
    for (int i = 0; i < WAY_WIDTH; i++) begin
      for (int j = 0; j < ADC_WIDTH; j++) begin
        case (tp_mem[i][j])
          TP_IDLE: data[i][j] = '0;
          TP_STATIC_0: data[i][j] = '0;
          TP_STATIC_1: data[i][j] = '1;
          TP_CNT: data[i][j] = data[i][j] + 1;
          TP_RANDOM: data[i][j] = $urandom_range(0, 1);
          default: data[i][j] = '0;
        endcase
      end
    end
    o_data = data;
`ifdef DEBUG
    /*$display("Advanced data: %0h %0h", data_des0, data_des1);*/
    /*$display("Test pattern: %0d %0d", tp_des0, tp_des1);*/
    /*$display("Merged datastream: %0h", data);*/
`endif
  endfunction

  function automatic bit [WAY_WIDTH-1:0][ADC_WIDTH-1:0] get_data();
    return data;
  endfunction

  modport master(
      input wclk,
      input rclk,
      output data,
      import toggle_rclk,
      import send_data,
      import config_test_patt,
      import seed_test_patt,
      import get_data,
      import write_start
  );

endinterface
