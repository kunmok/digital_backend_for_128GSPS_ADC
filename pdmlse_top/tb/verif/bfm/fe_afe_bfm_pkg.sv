//==============================================================================
// Author: Sunjin Choi
// Description: Encapsulates DSP-FE interface and checker
// Signals:
// Note: 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`default_nettype none
// verilog_format: on

package fe_afe_bfm_pkg;
  import tb_cfg_pkg::*;

  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int ADC_WIDTH = `ADC_WIDTH;
  localparam int DES_OUT_WIDTH = `DES_OUT_WIDTH;
  localparam time CLK_TO_DATA_DELAY[LANE_WIDTH] = `CLK_TO_DATA_DELAY_ARRAY;
  localparam time CLK_TO_RST_DELAY[LANE_WIDTH] = `CLK_TO_RST_DELAY_ARRAY;

  class fe_afe_bfm;

    virtual fe_lane_if.master fe_lane_intf[LANE_WIDTH];

    function new(virtual fe_lane_if.master fe_lane_intf[LANE_WIDTH]);
      this.fe_lane_intf = fe_lane_intf;
    endfunction

    /*    task automatic forward_lane_reset(input int lane_idx);
 *      this.afe_intf[lane_idx].rstb <= 1'b0;
 *      repeat (2) begin
 *        @(posedge this.afe_intf[lane_idx].clk);
 *      end
 *      #(CLK_TO_RST_DELAY[lane_idx]);
 *      this.afe_intf[lane_idx].rstb <= 1'b1;
 *      @(posedge this.afe_intf[lane_idx].clk);
 *    endtask
 *
 *    task automatic forward_reset();
 *      int ref_lane = 0;
 *      for (int i = 0; i < LANE_WIDTH; i++) begin
 *        this.afe_intf[i].rstb <= 1'b0;
 *      end
 *      // lousy -- reference is 0-th lane
 *      repeat (2) begin
 *        @(posedge this.afe_intf[ref_lane].clk);
 *      end
 *      #(CLK_TO_RST_DELAY[ref_lane]);
 *      for (int i = 0; i < LANE_WIDTH; i++) begin
 *        this.afe_intf[i].rstb <= 1'b1;
 *      end
 *      @(posedge this.afe_intf[ref_lane].clk);
 *    endtask*/

    task automatic forward_reset(input int lane_idx);
      fork
        /*this.fe_lane_intf[lane_idx].toggle_reset(this.fe_lane_intf[lane_idx].reset_start,
         *                                             CLK_TO_RST_DELAY[lane_idx]);*/
        this.fe_lane_intf[lane_idx].toggle_reset(CLK_TO_RST_DELAY[lane_idx]);
        $display("[fe_afe_bfm] Resetting lane %0d (time %0t)", lane_idx, $time);
      join_none
    endtask

    task automatic trigger_reset(input int lane_idx);
      fork
        ->this.fe_lane_intf[lane_idx].reset_start;
        $display("[fe_afe_bfm] Triggering reset for lane %0d (time %0t)", lane_idx, $time);
      join
    endtask

    task automatic config_test_patt(input int lane_idx,
                                    input test_pattern_e patt_des[DES_OUT_WIDTH]);
      this.fe_lane_intf[lane_idx].config_test_patt_des(patt_des);
    endtask

    task automatic seed_test_patt(input int lane_idx,
                                  input bit [DES_OUT_WIDTH-1:0][ADC_WIDTH-1:0] seed_des);
      this.fe_lane_intf[lane_idx].seed_test_patt_des(seed_des);
    endtask

    task automatic forward_data_for_cycles(input int lane_idx, input int run_cycle);
      fork
        /*this.fe_lane_intf[lane_idx].send_data(this.fe_lane_intf[lane_idx].data_start,
         *                                          run_cycle, CLK_TO_DATA_DELAY[lane_idx]);*/
        this.fe_lane_intf[lane_idx].send_data(run_cycle, CLK_TO_DATA_DELAY[lane_idx]);
        $display("[fe_afe_bfm] Sending data for lane %0d (time %0t)", lane_idx, $time);
      join_none
    endtask

    task automatic trigger_data(input int lane_idx);
      fork
        ->this.fe_lane_intf[lane_idx].data_start;
        $display("[fe_afe_bfm] Triggering data for lane %0d (time %0t)", lane_idx, $time);
        /*repeat (cycle) begin
         *  @(posedge this.fe_lane_intf[lane_idx].clk);
         *end
         *->this.fe_lane_intf[lane_idx].data_end;*/
      join
    endtask

    /*    task automatic forward_data(input int lane_idx);
 *      fork
 *        this.fe_lane_intf[lane_idx].send_data(this.fe_lane_intf[lane_idx].data_start,
 *                                                  this.fe_lane_intf[lane_idx].data_end,
 *                                                  CLK_TO_DATA_DELAY[lane_idx]);
 *        $display("Sending data for lane %0d", lane_idx);
 *      join_none
 *    endtask
 *
 *    task automatic trigger_data_for_cycles(input int lane_idx, input int cycle);
 *      fork
 *        ->this.fe_lane_intf[lane_idx].data_start;
 *        $display("Triggering data for lane %0d", lane_idx);
 *        repeat (cycle) begin
 *          @(posedge this.fe_lane_intf[lane_idx].clk);
 *        end
 *        ->this.fe_lane_intf[lane_idx].data_end;
 *      join
 *    endtask*/

  endclass : fe_afe_bfm

endpackage : fe_afe_bfm_pkg


`default_nettype wire



