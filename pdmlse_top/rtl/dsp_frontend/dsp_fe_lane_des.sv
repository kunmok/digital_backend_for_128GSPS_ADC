//==============================================================================
// Author: Sunjin Choi
// Description: 
// Signals:
// Note: DES-2-to-4 refactored out from the lane block for better placement
// guide during syn/par
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_fe_lane_des #(
    parameter int ADC_WIDTH = 6,
    parameter int DES_IN_WIDTH = 2,
    parameter int DES_OUT_WIDTH = 4
) (
    // high speed clk and rst
    input var logic i_rst_ref,
    input var logic i_clk_ref,

    input var logic i_clk,

    // des in and out
    /*input var  logic [ DES_IN_WIDTH-1:0][ADC_WIDTH-1:0] i_ana_dat_fe,*/
    input var logic [ADC_WIDTH-1:0][DES_IN_WIDTH-1:0] i_ana_dat_ad_des_fe,
    output var logic [DES_OUT_WIDTH-1:0] o_dat_ad_des_fe[ADC_WIDTH],

    // embedded scan i/o
    scan_if.recv i_scan,
    scan_if.send o_scan

);

  // ----------------------------------------------------------------------
  // Signals
  // ----------------------------------------------------------------------
  logic en_des;
  logic en_retime;
  logic rst_retime;

  logic rst_sync_retime;

  logic [DES_OUT_WIDTH-1:0] dat_ad_des[ADC_WIDTH];
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // DES
  // ----------------------------------------------------------------------
  generate
    for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_des_2_4
      des_2_to_4 des (
          .i_rst(i_rst_ref),
          .i_clk_ref(i_clk_ref),
          .i_en(en_des),  // TODO(check): individual or group ctrl?
          .i_dat(i_ana_dat_ad_des_fe[i]),
          .o_clk(),
          .o_clk_div_2(),
          .o_dat(dat_ad_des[i])
      );
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Reset Sync
  // ----------------------------------------------------------------------
  reset_sync #(
      .ActiveLow(0),
      .SyncRegWidth(2)
  ) reset_sync_retime (
      .i_rst(rst_retime),  // scan-controlled reset
      .i_clk(i_clk),
      .o_rst(rst_sync_retime)
  );
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Retimer
  // ----------------------------------------------------------------------
  generate
    for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_retime
      always_ff @(posedge i_clk or posedge rst_sync_retime) begin
        if (rst_sync_retime) begin
          o_dat_ad_des_fe[i] <= '0;
        end
        else if (en_retime) begin
          o_dat_ad_des_fe[i] <= dat_ad_des[i];
        end
      end
    end
  endgenerate
  // ----------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // Scan
  // ----------------------------------------------------------------------
  // TODO: instantiate scan
  // scan[]: en_des

  logic sclkp;
  logic sclkn;
  logic senable;
  logic supdate;
  logic sreset;
  logic sin;
  logic sout;
  logic [`FeLaneDesScanChainLength-1:0] scan_bits_wr;

  // TODO: verify post-syn/par netlist
  assign {sclkp, sclkn, senable, supdate, sreset} = i_scan.sctrl;
  assign sin = i_scan.sdata;
  assign o_scan.sdata = sout;
  assign o_scan.sctrl = i_scan.sctrl;

  dsp_fe_lane_des_scan fe_lane_des_scan (
      .SClkP(sclkp),
      .SClkN(sclkn),
      .SReset(sreset),
      .SEnable(senable),
      .SUpdate(supdate),
      .SIn(sin),
      .SOut(sout),
      .ScanBitsRd(),
      .ScanBitsWr(scan_bits_wr)
  );

  assign en_des = scan_bits_wr[`FeLaneDesEn];
  assign en_retime = scan_bits_wr[`FeLaneDesEnRetime];
  assign rst_retime = scan_bits_wr[`FeLaneDesRstRetime];
  // ----------------------------------------------------------------------

endmodule

`default_nettype wire

