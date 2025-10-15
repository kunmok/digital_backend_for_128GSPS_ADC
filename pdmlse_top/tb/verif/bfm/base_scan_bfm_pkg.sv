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

package base_scan_bfm_pkg;

  class base_scan_bfm;

    localparam time ScanCycle = `SCAN_CYCLE;

    /*parameter int SCAN_LENGTH = 1024;*/
    /*parameter time ScanCycle = 10ns;*/

    virtual scan_if.send scan_intf;

    /*// Scan clock generator controls
     *logic scan_clk_gen_rst;
     *logic scan_clk_gen_en;*/

    virtual scan_clkgen_if.send scan_clkgen_intf;
    virtual scan_if.recv scan_mon_intf;

    function new(virtual scan_if.send scan_intf, virtual scan_clkgen_if.send scan_clkgen_intf,
                 virtual scan_if.recv scan_mon_intf, string name = "scan_chain");
      this.scan_intf = scan_intf;
      this.scan_mon_intf = scan_mon_intf;
      this.scan_clkgen_intf = scan_clkgen_intf;
    endfunction

    // Don't want to make class for the scan type... just drop this
    /*virtual task scan_in(input logic [9999:0] scan_in);
     *endtask*/

    virtual function get_scan_length(output int length);
    endfunction

    // Scan in some number of bits
    /*task automatic raw_scan_in(input logic [9999:0] scan_in_data, input logic [31:0] length);*/
    task automatic raw_scan_in(input logic [9999:0] scan_in_data, input int length);
      integer scan_pos;
      integer i;
      begin
        scan_intf.sctrl.senable = 1'b1;
        // MSB bits are scanned in first
        for (i = 0; i < length; i = i + 1) begin
          scan_pos = length - 1 - i;
          scan_intf.sdata = scan_in_data[scan_pos];
          /*$display("%d", scan_intf.sdata);*/
          #(ScanCycle);
        end
        scan_intf.sctrl.senable = 1'b0;
      end
    endtask

    // Scan out some number of bits
    /*task automatic raw_scan_out(output logic [9999:0] scan_out_data, input logic [31:0] length);*/
    task automatic raw_scan_out(output logic [9999:0] scan_out_data, input int length);
      integer scan_pos;
      integer i;
      begin
        scan_intf.sctrl.senable = 1'b1;
        $display("scan_intf.sctrl.senable: %d", scan_intf.sctrl.senable);
        // MSB bits are scanned out first
        for (i = 0; i < length; i = i + 1) begin
          scan_pos = length - 1 - i;
          // get sout (sout = scan_mon_intf.sdata)
          scan_out_data[scan_pos] = scan_mon_intf.sdata;
          /*$display("%d", scan_intf.sdata);*/
          #(ScanCycle);
        end
        scan_intf.sctrl.senable = 1'b0;
        $display("scan_intf.sctrl.senable: %d", scan_intf.sctrl.senable);
        /*$display("%d", scan_out_data);*/
      end
    endtask

    // Issue a reset to the scan chain
    task issue_sreset;
      begin
        #(ScanCycle);
        scan_intf.sctrl.sreset = 1'b1;
        scan_clkgen_intf.scan_clkgen_rst = 1'b1;
        #(ScanCycle);
        scan_intf.sctrl.sreset = 1'b0;
        scan_clkgen_intf.scan_clkgen_rst = 1'b0;
        #(ScanCycle);
      end
    endtask

    // Start the scan clock
    task start_scan_clk;
      begin
        scan_clkgen_intf.scan_clkgen_en = 1'b1;
        #(ScanCycle);
      end
    endtask

    // Stop the scan clock
    task stop_scan_clk;
      begin
        scan_clkgen_intf.scan_clkgen_en = 1'b0;
        #(ScanCycle);
      end
    endtask

    // Scan update
    task scan_update;
      begin
        scan_intf.sctrl.supdate = 1'b1;
        #(ScanCycle);
        scan_intf.sctrl.supdate = 1'b0;
        #(ScanCycle);
      end
    endtask

    // Scan enable
    task scan_enable;
      begin
        scan_intf.sctrl.senable = 1'b1;
        #(ScanCycle);
        scan_intf.sctrl.senable = 1'b0;
        #(ScanCycle);
      end
    endtask

  endclass
endpackage

`default_nettype wire

