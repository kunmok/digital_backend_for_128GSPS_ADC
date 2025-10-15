//==============================================================================
// Author: Sunjin Choi
// Description: Glue logic btw DES and LUT including retimer and packing/unpacking
// Signals:
// Note: 
// Variable naming conventions:
//    signals => snake_case
//    Parameters (aliasing signal values) => SNAKE_CASE with all caps
//    Parameters (not aliasing signal values) => CamelCase
//==============================================================================

// verilog_format: off
`timescale 1ns/1ps
`default_nettype none
// verilog_format: on

module dsp_fe_lane_glue #(
    parameter int ADC_WIDTH = 6,
    parameter int DES_OUT_WIDTH = 4
) (
    // clk from digital clockspine
    input var logic i_rst,
    input var logic i_clk,
    input var logic i_en,

    input var logic [DES_OUT_WIDTH-1:0] i_dat_ad_lane[ADC_WIDTH],
    output var logic [ADC_WIDTH-1:0] o_dat_da_lane[DES_OUT_WIDTH]
);

  // Retimer (simple flip-flops)
  logic [DES_OUT_WIDTH-1:0] dat_ad_lane_d1[ADC_WIDTH];

  generate
    for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_retimer
      always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
          dat_ad_lane_d1[i] <= '0;
        end
        else begin
          if (i_en) begin
            dat_ad_lane_d1[i] <= i_dat_ad_lane[i];
          end
        end
      end
    end
  endgenerate

  // Glue logic between dat_d1 and o_dat_da_lane
  // dat_ad_lane_d1 -> o_dat_da_lane pack/unpack
  // using streaming operator, e.g., if ADC_WIDTH=4 and DES_OUT_WIDTH=2:
  // dat_ad_lane_d1[0] = 2'b01;
  // dat_ad_lane_d1[1] = 2'b10;
  // dat_ad_lane_d1[2] = 2'b11;
  // dat_ad_lane_d1[3] = 2'b00;
  // o_dat_da_lane[0] = 4'b0110;
  // o_dat_da_lane[1] = 4'b1100;
  // {>>{dat_d1}} unpacks into 01 10 11 00 ([0] [1] [2] [3])
  // >> streams from left to right; o_dat[0] = 0110, o_dat[1] = 1100
  /*always_comb begin
   *  {>>{o_dat_da_lane}} = {>>{dat_ad_lane_d1}};
   *end*/

  // above is wrong, this is correct
  generate
    for (genvar i = 0; i < ADC_WIDTH; i++) begin : g_repack_a
      for (genvar j = 0; j < DES_OUT_WIDTH; j++) begin : g_repack_d
        always_comb begin
          o_dat_da_lane[j][i] = dat_ad_lane_d1[i][j];
        end
      end
    end
  endgenerate

endmodule

`default_nettype wire

