

// Seems like you need this for class tbs to interface with the scan_clk_gen module
interface scan_clkgen_if;

  logic scan_clkgen_rst;
  logic scan_clkgen_en;
  logic sclkp;
  logic sclkn;

  modport recv(input scan_clkgen_rst, scan_clkgen_en, output sclkp, output sclkn);
  modport send(output scan_clkgen_rst, scan_clkgen_en, input sclkp, input sclkn);

endinterface
