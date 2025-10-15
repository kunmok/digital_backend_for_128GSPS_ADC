

// verilog_format: off
`default_nettype none
// verilog_format: on


package fe_mon_pkg;
  import tb_cfg_pkg::*;

  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;
  localparam int DES_IN_WIDTH = `DES_IN_WIDTH;

  class fe_mon;

    virtual fe_lane_mon_if.monitor fe_lane_mon_intf[LANE_WIDTH];

    // data in and monitor push-in queue
    /*logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_mon_q[$];
     *logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in_even_q[$];
     *logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in_odd_q[$];*/

    typedef logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_mon_q_t[$];
    typedef logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in_q_t[$];
    data_mon_q_t data_mon_q[LANE_WIDTH];
    data_in_q_t data_in_even_q[LANE_WIDTH];
    data_in_q_t data_in_odd_q[LANE_WIDTH];

    // op config (this case, only lut)
    logic [ADC_WIDTH-1:0] lane_lut_table[LANE_WIDTH][2**ADC_WIDTH];

    function new(virtual fe_lane_mon_if.monitor fe_lane_mon_intf[LANE_WIDTH]);
      this.fe_lane_mon_intf = fe_lane_mon_intf;
    endfunction

    /*    task automatic monitor_data_after_cycles(input int lane_idx, input int wait_cycle,
 *                                             input int mon_cycle);
 *      fork
 *        this.fe_lane_intf[lane_idx].config_monitor(wait_cycle, mon_cycle);
 *      join_none
 *    endtask
 *
 *    task automatic trigger_mon(input int lane_idx);
 *      fork
 *        ->this.fe_lane_intf[lane_idx].mon_start;
 *        $display("Triggering monitor for lane %0d", lane_idx);
 *      join
 *    endtask*/

    // ----------------------------------------------------------------------
    // Data Collection Methods
    // ----------------------------------------------------------------------
    task automatic collect_data_in(input int lane_idx, input int run_cycle);
      fork
        /*this.fe_lane_intf[lane_idx].config_monitor(wait_cycle, mon_cycle);*/
        /*data_in_q_t data_in_even_q_tmp;
         *data_in_q_t data_in_odd_q_tmp;
         *data_in_even_q_tmp = data_in_even_q[lane_idx];
         *data_in_odd_q_tmp  = data_in_odd_q[lane_idx];*/
`ifdef DEBUG
        $display("[fe_mon] Starting data_in collect for lane %0d (time %0t)", lane_idx, $time);
`endif
        // give cycle delay
        @(negedge this.fe_lane_mon_intf[lane_idx].clk_in);

        repeat (run_cycle) begin
          @(negedge this.fe_lane_mon_intf[lane_idx].clk_in);
          data_in_even_q[lane_idx].push_back(this.fe_lane_mon_intf[lane_idx].data_in);
`ifdef DEBUG
          $display("[fe_mon] Pushed data %0b to lane %0d data_in even queue (time %0t)",
                   this.fe_lane_mon_intf[lane_idx].data_in, lane_idx, $time);
`endif
          @(negedge this.fe_lane_mon_intf[lane_idx].clk_in);
          data_in_odd_q[lane_idx].push_back(this.fe_lane_mon_intf[lane_idx].data_in);
`ifdef DEBUG
          $display("[fe_mon] Pushed data %0b to lane %0d data_in odd queue (time %0t)",
                   this.fe_lane_mon_intf[lane_idx].data_in, lane_idx, $time);
`endif
        end
      join_none
    endtask

    function automatic print_data_in_q(int lane_idx);
      /*logic [ADC_WIDTH-1:0] data_in_des[DES_OUT_WIDTH];*/
      logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_tmp;
      logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_in_des;

      $display("---------------------------------------------------");
      $display("Finished collecting data_in for lane %0d", lane_idx);
      for (int i = 0; i < data_in_even_q[lane_idx].size(); i++) begin
        data_tmp = data_in_even_q[lane_idx][i];
        get_des_data_in(data_tmp, 0, data_in_des[0]);
        get_des_data_in(data_tmp, 1, data_in_des[1]);
        $display("[fe_mon] Des0 Even Queue[%0d] (des0): %0b", i, data_in_des[0]);
        $display("[fe_mon] Des1 Even queue[%0d] (des1): %0b", i, data_in_des[1]);
        $display("");
      end
      for (int i = 0; i < data_in_odd_q[lane_idx].size(); i++) begin
        data_tmp = data_in_odd_q[lane_idx][i];
        // this is tricky index but should be correct
        get_des_data_in(data_tmp, 0, data_in_des[2]);
        get_des_data_in(data_tmp, 1, data_in_des[3]);
        $display("[fe_mon] Des0 Odd Queue[%0d] (des2): %0b", i, data_in_des[2]);
        $display("[fe_mon] Des1 Odd Queue[%0d] (des3): %0b", i, data_in_des[3]);
        $display("");
      end
      $display("---------------------------------------------------");
      $display("");
    endfunction


    task automatic wait_data_mon_for_cycles(input int lane_idx, input int wait_cycle);
      fork
`ifdef DEBUG
        $display("[fe_mon] Waiting for %0d cycles for lane %0d data_mon collection (time %0t)",
                 wait_cycle, lane_idx, $time);
`endif
        repeat (wait_cycle) begin
          @(posedge this.fe_lane_mon_intf[lane_idx].clk_mon);
`ifdef DEBUG
          $display("[fe_mon] Waiting for lane %0d data_mon collection (time %0t)", lane_idx, $time);
`endif
        end
      join
    endtask

    task automatic collect_data_mon(input int lane_idx, input int run_cycle);
      fork
        // for some reason, this doesn't work
        /*repeat (wait_cycle) begin
         *  @(posedge this.fe_lane_mon_intf[lane_idx].clk_mon);
         *  @(negedge this.fe_lane_mon_intf[lane_idx].clk_mon);
         *end
         *@(negedge this.fe_lane_mon_intf[lane_idx].clk_mon);*/
`ifdef DEBUG
        $display("[fe_mon] Starting data_mon collect for lane %0d (time %0t)", lane_idx, $time);
`endif

        // give cycle delay
        @(negedge this.fe_lane_mon_intf[lane_idx].clk_mon);

        repeat (run_cycle) begin
          @(negedge this.fe_lane_mon_intf[lane_idx].clk_mon);
          data_mon_q[lane_idx].push_back(this.fe_lane_mon_intf[lane_idx].data_mon);
`ifdef DEBUG
          $display("[fe_mon] Pushed data %0b to lane %0d data_mon queue (time %0t)",
                   this.fe_lane_mon_intf[lane_idx].data_mon, lane_idx, $time);
          $display("[fe_mon] == Corresponding data_mon[0]: %0b",
                   this.fe_lane_mon_intf[lane_idx].data_mon[0]);
          $display("[fe_mon] == Corresponding data_mon[1]: %0b",
                   this.fe_lane_mon_intf[lane_idx].data_mon[1]);
          $display("[fe_mon] == Corresponding data_mon[2]: %0b",
                   this.fe_lane_mon_intf[lane_idx].data_mon[2]);
          $display("[fe_mon] == Corresponding data_mon[3]: %0b",
                   this.fe_lane_mon_intf[lane_idx].data_mon[3]);
          $display("");
`endif
        end
      join_none
    endtask

    function automatic print_data_mon_q(input int lane_idx);
      $display("---------------------------------------------------");
      $display("Finished collecting data_mon for lane %0d", lane_idx);
      foreach (data_mon_q[lane_idx][i]) begin
        $display("[fe_mon] Monitor Queue[%0d] (des0): %0b", i, data_mon_q[lane_idx][i][0]);
        $display("[fe_mon] Monitor Queue[%0d] (des1): %0b", i, data_mon_q[lane_idx][i][1]);
        $display("[fe_mon] Monitor Queue[%0d] (des2): %0b", i, data_mon_q[lane_idx][i][2]);
        $display("[fe_mon] Monitor Queue[%0d] (des3): %0b", i, data_mon_q[lane_idx][i][3]);
        $display("");
      end
      $display("---------------------------------------------------");
      $display("");
    endfunction

    // helper method
    function automatic get_des_data_in(input logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in,
                                       input int des_idx, output logic [ADC_WIDTH-1:0] data_in_des);
      // parse data_in into further deserialized form
      for (int i = 0; i < ADC_WIDTH; i++) begin
        data_in_des[i] = data_in[i][des_idx];
      end
    endfunction

    // ----------------------------------------------------------------------
    // Checker Methods
    // ----------------------------------------------------------------------
    task automatic check_config_op_lut(input int lane_idx,
                                       input logic [ADC_WIDTH-1:0] lut_table[2**ADC_WIDTH]);
      fork
        this.lane_lut_table[lane_idx] = lut_table;
      join
    endtask

    task automatic check_data(input int lane_idx, input int run_cycle, output int match);
      // bit instead of logic to avoid x comparison
      logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in_even_from_q;
      logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] data_in_odd_from_q;
      logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_in_des_tmp;
      logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_mon_expected;
      logic [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] data_mon_from_q;
      int match = 0;

      // error out if run_cycle is bigger than the queue size
      if (run_cycle > data_mon_q[lane_idx].size()) begin
        $display("[fe_mon] Error: run_cycle %0d is bigger than the queue size %0d", run_cycle,
                 data_mon_q[lane_idx].size());
        $exit;
      end

      for (int i = 0; i < run_cycle; i++) begin
        // functional model: re-assemble data_in from des2 deserialized data
        // to des4 deserialized form
        data_in_even_from_q = data_in_even_q[lane_idx].pop_front();
        data_in_odd_from_q  = data_in_odd_q[lane_idx].pop_front();
        get_des_data_in(data_in_even_from_q, 0, data_in_des_tmp[0]);
        get_des_data_in(data_in_even_from_q, 1, data_in_des_tmp[1]);
        get_des_data_in(data_in_odd_from_q, 0, data_in_des_tmp[2]);
        get_des_data_in(data_in_odd_from_q, 1, data_in_des_tmp[3]);

        // functional model: 4-way shared LUT
        for (int j = 0; j < DES_OUT_WIDTH; j++) begin
          data_mon_expected[j] = this.lane_lut_table[lane_idx][data_in_des_tmp[j]];
        end

`ifdef DEBUG
        $display("[fe_mon] Checking data_in for lane %0d (time %0t)", lane_idx, $time);
        $display("[fe_mon] data_in_even_from_q: %0b", data_in_even_from_q);
        $display("[fe_mon] data_in_odd_from_q: %0b", data_in_odd_from_q);
        $display("[fe_mon] data_in_des_tmp[0]: %0b", data_in_des_tmp[0]);
        $display("[fe_mon] data_in_des_tmp[1]: %0b", data_in_des_tmp[1]);
        $display("[fe_mon] data_in_des_tmp[2]: %0b", data_in_des_tmp[2]);
        $display("[fe_mon] data_in_des_tmp[3]: %0b", data_in_des_tmp[3]);
`endif

        // compare data_mon_expected with data_mon_q
        data_mon_from_q = data_mon_q[lane_idx].pop_front();
        if (data_mon_expected == data_mon_from_q) begin
          match++;
        end
        else if (data_mon_expected === 24'bx && data_mon_from_q === 24'bx) begin
          match++;
        end
        else begin
          $display("[fe_mon] Error: data_mon_expected[%0d] %0b != data_mon_from_q[%0d] %0b. This happened at %d-th index", i,
                   data_mon_expected, i, data_mon_from_q, match);
        end
      end
    endtask

  endclass


endpackage



`default_nettype wire

