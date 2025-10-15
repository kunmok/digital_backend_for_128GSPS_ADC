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

package mem_scan_bfm_pkg;
  import base_scan_bfm_pkg::*;

  localparam int MemScanChainLength = `MemScanChainLength;
  localparam int LANE_WIDTH = `LANE_WIDTH;
  localparam int MAX_LENGTH = 9999;

  typedef logic [MemScanChainLength-1:0] mem_scan_t;

  class mem_scan_bfm extends base_scan_bfm;

    localparam time ScanCycle = `SCAN_CYCLE;

    mem_scan_t scan_reg;

    function new(virtual scan_if.send scan_intf, virtual scan_clkgen_if.send scan_clkgen_intf,
                 virtual scan_if.recv scan_mon_intf, string name = "mem_scan_chain");
      super.new(scan_intf, scan_clkgen_intf, scan_mon_intf, name);
      scan_reg = '{default: '0};
    endfunction

    task automatic scan_in();
`ifdef DEBUG
      `CHIP_SCAN_CFG_START
`endif
      super.raw_scan_in(scan_reg, MemScanChainLength);
      super.scan_update();
`ifdef DEBUG
      `CHIP_SCAN_CFG_DONE
`endif
    endtask

    task automatic scan_out(mem_scan_t mon_scan_out);
      super.raw_scan_out(mon_scan_out, MemScanChainLength);
    endtask

    function automatic get_scan_length(output int length);
      length = MemScanChainLength;
    endfunction

    function automatic update_scan(mem_scan_t mem_scan);
      // TODO: this is a redundant step, but for uniformity of style across
      // different scan_bfm classes, we will keep this for now
      scan_reg = mem_scan;
`ifdef DEBUG
      `TB_SCAN_CFG_DONE
`endif
    endfunction

  endclass

endpackage  // test_scan_pkg


`default_nettype wire



