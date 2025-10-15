

import fe_scan_bfm_pkg::*;
import fe_afe_bfm_pkg::*;
import fe_mon_pkg::*;

class fe_smoke_test extends fe_test_pkg::fe_base_test;

  int scan_length;
  int scan_idx;
  fe_scan_flat_t scan_in_random;
  fe_scan_flat_t scan_out_monitor;

  // Constructor
  function new(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm, fe_mon mon);
    super.new(scan_bfm, afe_bfm, mon);
  endfunction

  // here you implement wait and everything
  task run();
    setup();

    /*reset();*/
    $display("run smoke test");

    this.scan_bfm.get_scan_length(scan_length);
    $display("length: %d", scan_length);

    for (int i = 0; i < scan_length; i++) begin
      scan_in_random[i] = $urandom_range(0, 1);
    end

    // start scan clk
    this.scan_bfm.start_scan_clk();

    this.scan_bfm.issue_sreset();

    // scan-in using raw scan-in
    this.scan_bfm.raw_scan_in(scan_in_random, scan_length);

    // scan-out using raw scan-out
    this.scan_bfm.raw_scan_out(scan_out_monitor, scan_length);

    /*// stop scan clk
     *this.scan_bfm.stop_scan_clk();*/

    // check if both matches
    if (scan_in_random == scan_out_monitor) begin
      $display("==== SCAN IN AND SCAN OUT MATCH ====");
      $display("==== SCAN TEST PASSED ====");
      this.success = 1'b1;
    end
    else begin
      $display("==== SCAN IN AND SCAN OUT DO NOT MATCH ====");
      $display("==== SCAN TEST FAILED ====");
      this.failure = 1'b0;
    end

    cleanup();
  endtask

  /*static function fe_smoke_test factory(fe_scan_bfm scan_bfm, fe_afe_bfm afe_bfm);
   *  fe_smoke_test fe_test = new(scan_bfm, afe_bfm);
   *  return fe_test;
   *endfunction*/

  `CREATE_TEST_FACTORY(fe_smoke_test)

endclass

