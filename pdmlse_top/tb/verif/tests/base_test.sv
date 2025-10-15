

class base_test;

  /*  base_scan_bfm scan_bfm;
 *
 *  function new(base_scan_bfm scan_bfm);
 *    this.scan_bfm = scan_bfm;
 *  endfunction*/

  virtual task setup();
    $display("Setting up base test...");
  endtask

  virtual task run();
    /*$display("Running base test...");*/
  endtask

  virtual task cleanup();
    $display("Cleaning up base test...");
  endtask

endclass
