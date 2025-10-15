

interface fe_lane_if;
  import tb_cfg_pkg::*;

  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_IN_WIDTH = `DES_IN_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;

  logic rstb;
  logic clk;
  // "data" models the generated output stream from AFE (in unit of lane)
  // which is at the end, the 1:2 deserializer output
  logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data;

  event reset_start;
  event data_start;
  event mon_start;
  /*event data_end;*/

  // internal data
  // test pattern should be generated for 4 individual datastreams
  // each correspond to the output of 2:4 deserializer
  // accordingly, 4 streams are packed into *data* signal
  // and streams {data_des[1], data_des[0]} at even time, {data_des[3], data_des[2]} at odd time
  /*bit [ADC_WIDTH-1:0] data_des0;
   *bit [ADC_WIDTH-1:0] data_des1;
   *bit [ADC_WIDTH-1:0] data_des2;
   *bit [ADC_WIDTH-1:0] data_des3;
   *test_pattern_e tp_des0;
   *test_pattern_e tp_des1;
   *test_pattern_e tp_des2;
   *test_pattern_e tp_des3;*/

  // group the above
  logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_des;
  /*test_pattern_e [DES_OUT_WIDTH-1:0] tp_des;*/
  test_pattern_e tp_des[DES_OUT_WIDTH];

  // You should be very careful of where to do fork-join & fork-join-none when using this event
  // construct
  /*task automatic toggle_reset(input event reset_start, input time delay);*/
  task automatic toggle_reset(input time delay);
`ifdef DEBUG
    $display("Reset task for instance waiting at time %0t", $time);
`endif
    /*wait (reset_start.triggered);*/
    @(reset_start);
`ifdef DEBUG
    $display("Reset task for instance started at time %0t", $time);
`endif
    rstb = 0;
    @(posedge clk);
    #delay rstb = 1;
    @(posedge clk);
`ifdef DEBUG
    $display("Reset completed for instance at time %0t", $time);
`endif
  endtask

  /*task automatic send_data(input event data_start, input int cycle, input time delay);*/
  task automatic send_data(input int cycle, input time delay);
`ifdef DEBUG
    $display("Data task for instance waiting at time %0t", $time);
`endif
    @(data_start);
    @(posedge clk);
`ifdef DEBUG
    $display("Data task for instance started at time %0t", $time);
`endif
    /*#(delay);*/
    /*data = '1;*/
    repeat (cycle) begin
      @(posedge clk);
      #(delay);
      generate_data_des01(data);
      @(posedge clk);
      #(delay);
      generate_data_des23(data);
    end
    /*@(data_end);*/
`ifdef DEBUG
    $display("Data task for instance completed at time %0t", $time);
`endif
  endtask

  /*task automatic send_data(input event data_start, input event data_end, input time delay);
   *  $display("Data task for instance waiting at time %0t", $time);
   *  @(data_start);
   *  @(posedge clk);
   *  $display("Data task for instance started at time %0t", $time);
   *  #(delay);
   *  [>data = '1;<]
   *  generate_data();
   *  @(data_end);
   *  $display("Data task for instance completed at time %0t", $time);
   *endtask*/

  function automatic seed_test_patt_des(input logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] tp_seed);
    data_des = tp_seed;
`ifdef DEBUG
    $display("[fe_lane_if] Seed datastream: [3] %0b, [2] %0b, [1] 0%b, [0] 0%b", data_des[3],
             data_des[2], data_des[1], data_des[0]);
`endif
  endfunction

  function automatic config_test_patt_des(input test_pattern_e tp[DES_OUT_WIDTH]);
    tp_des = tp;
`ifdef DEBUG
    $display("[fe_lane_if] Configuring test pattern (time %0t)", $time);
    print_test_pattern_info(tp_des[0], 0);
    print_test_pattern_info(tp_des[1], 1);
    print_test_pattern_info(tp_des[2], 2);
    print_test_pattern_info(tp_des[3], 3);
`endif
  endfunction

  function automatic generate_data_des01(output logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] o_data);
    case (tp_des[0])
      TP_IDLE: data_des[0] = '0;
      TP_STATIC_0: data_des[0] = '0;
      TP_STATIC_1: data_des[0] = '1;
      TP_CNT: data_des[0] = data_des[0] + 1;
      TP_RANDOM: data_des[0] = $urandom;
      default: data_des[0] = '0;
    endcase
    case (tp_des[1])
      TP_IDLE: data_des[1] = '0;
      TP_STATIC_0: data_des[1] = '0;
      TP_STATIC_1: data_des[1] = '1;
      TP_CNT: data_des[1] = data_des[1] + 1;
      TP_RANDOM: data_des[1] = $urandom;
      default: data_des[1] = '0;
    endcase
    for (int i = 0; i < ADC_WIDTH; i++) begin
      o_data[i] = {data_des[1][i], data_des[0][i]};
    end
`ifdef DEBUG
    $display("[fe_lane_if] Generated data: [des0] %0b [des1] %0b (time %0t)", data_des[0],
             data_des[1], $time);
    print_test_pattern_info(tp_des[0], 0);
    print_test_pattern_info(tp_des[1], 1);
    $display("[fe_lane_if] Output data: %0b (time %0t)", o_data, $time);
`endif
  endfunction

  function automatic generate_data_des23(output logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] o_data);
    case (tp_des[2])
      TP_IDLE: data_des[2] = '0;
      TP_STATIC_0: data_des[2] = '0;
      TP_STATIC_1: data_des[2] = '1;
      TP_CNT: data_des[2] = data_des[2] + 1;
      TP_RANDOM: data_des[2] = $urandom;
      default: data_des[2] = '0;
    endcase
    case (tp_des[3])
      TP_IDLE: data_des[3] = '0;
      TP_STATIC_0: data_des[3] = '0;
      TP_STATIC_1: data_des[3] = '1;
      TP_CNT: data_des[3] = data_des[3] + 1;
      TP_RANDOM: data_des[3] = $urandom;
      default: data_des[3] = '0;
    endcase
    for (int i = 0; i < ADC_WIDTH; i++) begin
      o_data[i] = {data_des[3][i], data_des[2][i]};
    end
`ifdef DEBUG
    $display("[fe_lane_if] Generated data: [des2] %0b [des3] %0b (time %0t)", data_des[2],
             data_des[3], $time);
    print_test_pattern_info(tp_des[2], 2);
    print_test_pattern_info(tp_des[3], 3);
    $display("[fe_lane_if] Output data: %0b (time %0t)", o_data, $time);
`endif
  endfunction

  function automatic print_test_pattern_info(input test_pattern_e tp, int des_idx);
    case (tp)
      TP_IDLE:
      $display("[fe_lane_if] Test pattern of des_idx %0d : IDLE (time %0t)", des_idx, $time);
      TP_STATIC_0:
      $display("[fe_lane_if] Test pattern of des_idx %0d : STATIC 0 (time %0t)", des_idx, $time);
      TP_STATIC_1:
      $display("[fe_lane_if] Test pattern of des_idx %0d : STATIC 1 (time %0t)", des_idx, $time);
      TP_CNT:
      $display("[fe_lane_if] Test pattern of des_idx %0d : COUNTER (time %0t)", des_idx, $time);
      TP_RANDOM:
      $display("[fe_lane_if] Test pattern of des_idx %0d : RANDOM (time %0t)", des_idx, $time);
      default: $display("UNKNOWN");
    endcase
  endfunction

  function automatic bit [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] get_data();
    return data;
  endfunction

  modport master(
      output rstb,
      input clk,
      output data,
      import toggle_reset,
      import send_data,
      import config_test_patt_des,
      import seed_test_patt_des,
      import get_data,
      import reset_start,
      import data_start,
      import mon_start
  );

  modport slave(input rstb, output clk, input data);

  /*modport monitor(
   *    input clk_mon,
   *    output data,
   *    input data_mon,
   *    output data_mon_sample,
   *    import get_data,
   *    import mon_start
   *);*/

endinterface
