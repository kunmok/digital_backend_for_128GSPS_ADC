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
`default_nettype none
// verilog_format: on

package fe_scan_bfm_pkg;
  import base_scan_bfm_pkg::*;

  localparam int FeClkspineScanChainLength = `FeClkspineScanChainLength;
  localparam int FeLaneScanChainLength = `FeLaneScanChainLength;
  localparam int FeRodScanChainLength = `FeRodScanChainLength;
  localparam int FeLaneDesScanChainLength = `FeLaneDesScanChainLength;
  localparam int LANE_WIDTH = `LANE_WIDTH;
  /*localparam int FeScanChainLength = FeClkspineScanChainLength \
   *+ FeLaneScanChainLength * LANE_WIDTH \
   *+ FeLaneDesScanChainLength * LANE_WIDTH \
   *+ FeRodScanChainLength;*/

  localparam int FeScanChainLength = FeClkspineScanChainLength + FeLaneScanChainLength * LANE_WIDTH + FeRodScanChainLength + FeLaneDesScanChainLength * LANE_WIDTH;

  /*localparam int FeClkspineScanChainLength = 4;
   *localparam int FeLaneScanChainLength = 4;
   *localparam int FeRodScanChainLength = 4;
   *localparam int LANE_WIDTH = 1;*/

  // TODO: move to dsp_fe.svh
  // Physical-to-logical lane mapping (from bottom to top)
  // Since the scan starts at the bottom, it is daisy-chained from the bottom to the top
  // For example, LanePhysicalOrder[1] = 8, which means the 1st lane in the scan chain is the 8th lane in the time order
  localparam int LanePhysicalOrder[LANE_WIDTH] = `LANE_PHYSICAL_ORDER;
  localparam int MAX_LENGTH = 9999;

  typedef logic [FeClkspineScanChainLength-1:0] cs_scan_t;
  typedef logic [FeLaneDesScanChainLength-1:0] lane_des_scan_t;
  typedef logic [FeLaneScanChainLength-1:0] lane_scan_t;
  typedef logic [FeRodScanChainLength-1:0] rod_scan_t;

  // TODO(check): scan daisy-chain from lane_scan to cs_scan to rod_scan
  // lane_scan index in this struct corresponds to the *physical* order
  // i.e., lane_scan is linearly streamed into the scan chain
  typedef struct packed {
    lane_des_scan_t [LANE_WIDTH-1:0] lane_des_scan_grp;
    lane_scan_t [LANE_WIDTH-1:0] lane_scan_grp;
    cs_scan_t cs_scan;
    rod_scan_t rod_scan;
  } fe_scan_t;

  typedef logic [FeScanChainLength-1:0] fe_scan_flat_t;

  class fe_scan_bfm extends base_scan_bfm;

    localparam time ScanCycle = `SCAN_CYCLE;

    fe_scan_t scan_reg;

    function new(virtual scan_if.send scan_intf, virtual scan_clkgen_if.send scan_clkgen_intf,
                 virtual scan_if.recv scan_mon_intf, string name = "fe_scan_chain");
      super.new(scan_intf, scan_clkgen_intf, scan_mon_intf, name);
      scan_reg = '{default: '0};
    endfunction

    task automatic scan_in();
      fe_scan_flat_t flat_scan;
`ifdef DEBUG
      `CHIP_SCAN_CFG_START
`endif
      flat_scan = flatten_fe_scan(scan_reg);
      super.raw_scan_in(flat_scan, FeScanChainLength);
      super.scan_update();
`ifdef DEBUG
      `CHIP_SCAN_CFG_DONE
`endif
    endtask

    task automatic scan_out(fe_scan_flat_t mon_scan_out);
      super.raw_scan_out(mon_scan_out, FeScanChainLength);
    endtask

    function automatic get_scan_length(output int length);
      length = FeScanChainLength;
    endfunction

    function automatic get_lane_logical_order(input int lane_idx, output int idx);
      idx = LanePhysicalOrder[lane_idx];
    endfunction

    function automatic update_lane_scan(input lane_scan_t lane_scan, input int lane_idx);
      int logi_idx;
      get_lane_logical_order(lane_idx, logi_idx);
`ifdef DEBUG_SCAN
      $display("[before update] lane_scan %d: %h", logi_idx, scan_reg.lane_scan_grp[logi_idx]);
`endif
      scan_reg.lane_scan_grp[logi_idx] = lane_scan;
`ifdef DEBUG_SCAN
      $display("[after update] lane_scan %d: %h", logi_idx, scan_reg.lane_scan_grp[logi_idx]);
`endif
    endfunction

    function automatic update_lane_des_scan(input lane_des_scan_t lane_des_scan,
                                            input int lane_idx);
      int logi_idx;
      get_lane_logical_order(LANE_WIDTH - 1 - lane_idx, logi_idx);
`ifdef DEBUG_SCAN
      $display("[before update] lane_des_scan %d: %h", logi_idx,
               scan_reg.lane_des_scan_grp[logi_idx]);
`endif
      scan_reg.lane_des_scan_grp[logi_idx] = lane_des_scan;
`ifdef DEBUG_SCAN
      $display("[after update] lane_des_scan %d: %h", logi_idx,
               scan_reg.lane_des_scan_grp[logi_idx]);
`endif
    endfunction

    function automatic update_rod_scan(input rod_scan_t rod_scan);
`ifdef DEBUG_SCAN
      $display("[before update] rod_scan: %h", scan_reg.rod_scan);
`endif
      scan_reg.rod_scan = rod_scan;
`ifdef DEBUG_SCAN
      $display("[after update] rod_scan: %h", scan_reg.rod_scan);
`endif
    endfunction

    function automatic update_cs_scan(input cs_scan_t cs_scan);
`ifdef DEBUG_SCAN
      $display("[before update] cs_scan: %h", scan_reg.cs_scan);
`endif
      scan_reg.cs_scan = cs_scan;
`ifdef DEBUG_SCAN
      $display("[after update] cs_scan: %h", scan_reg.cs_scan);
`endif
    endfunction

    function automatic update_scan(lane_scan_t [LANE_WIDTH-1:0] lane_scan_grp,
                                   lane_des_scan_t [LANE_WIDTH-1:0] lane_des_scan_grp,
                                   cs_scan_t cs_scan, rod_scan_t rod_scan);
      for (int i = 0; i < LANE_WIDTH; i++) begin
        update_lane_scan(lane_scan_grp[i], i);
        update_lane_des_scan(lane_des_scan_grp[i], i);
      end
      update_cs_scan(cs_scan);
      update_rod_scan(rod_scan);
`ifdef DEBUG
      `TB_SCAN_CFG_DONE
`endif
    endfunction

    // Function to flatten fe_scan_t
    function automatic fe_scan_flat_t flatten_fe_scan(fe_scan_t scan);
      fe_scan_flat_t flat_scan;
      // order of connection, in reverse (MSB scans in first)
      flat_scan = {scan.rod_scan, scan.lane_scan_grp, scan.cs_scan, scan.lane_des_scan_grp};
`ifdef DEBUG_SCAN
      $display("scan: %p", scan);
`endif
      return flat_scan;
    endfunction

    // Function to unflatten fe_scan_flat_t
    /*    function automatic fe_scan_t unflatten_fe_scan(fe_scan_flat_t flat_scan);
 *      fe_scan_t scan;
 *      int offset = 0;
 *
 *      // Extract cs_scan
 *      scan.cs_scan = flat_scan[FeClkspineScanChainLength-1:0];
 *      offset += FeClkspineScanChainLength;
 *
 *      // Extract lane_scan
 *      for (int i = 0; i < LANE_WIDTH; i++) begin
 *        scan.lane_scan[i] = flat_scan[offset+:FeLaneScanChainLength];
 *        offset += FeLaneScanChainLength;
 *      end
 *
 *      // Extract rod_scan
 *      scan.rod_scan = flat_scan[offset+:FeRodScanChainLength];
 *
 *      return scan;
 *    endfunction*/

  endclass

endpackage  // test_scan_pkg


`default_nettype wire



