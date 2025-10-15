module ScanTop (
input scan_clk,
input scan_en,
input scan_in,
input scan_reset,
output [7:0] dp_fe_hpf_biasn,
output [7:0] dp_fe_hpf_biasp,
output [7:0] dp_ctle_cm_vref,
output [7:0] dp_abuf_cm_vref,
output [1:0] cp_sel,
output [5:0] cp_16G_ctrl_0,
output [5:0] cp_16G_ctrl_1,
output [5:0] cp_16G_ctrl_2,
output [5:0] cp_16G_ctrl_3,
output [5:0] cp_16G_ctrl_4,
output [5:0] cp_16G_ctrl_5,
output [5:0] cp_16G_ctrl_6,
output [5:0] cp_16G_ctrl_7,
output [7:0] cp_16G_ctrln,
output [7:0] cp_16G_ctrlp,
output [7:0] dp_tnh1_casc_bias_0,
output [7:0] dp_tnh1_casc_bias_1,
output [7:0] dp_tnh1_casc_bias_2,
output [7:0] dp_tnh1_casc_bias_3,
output [7:0] dp_tnh1_casc_bias_4,
output [7:0] dp_tnh1_casc_bias_5,
output [7:0] dp_tnh1_casc_bias_6,
output [7:0] dp_tnh1_casc_bias_7,
output [7:0] dp_tnh1_casc_bias_8,
output [7:0] dp_tnh1_casc_bias_9,
output [7:0] dp_tnh1_casc_bias_10,
output [7:0] dp_tnh1_casc_bias_11,
output [7:0] dp_tnh1_casc_bias_12,
output [7:0] dp_tnh1_casc_bias_13,
output [7:0] dp_tnh1_casc_bias_14,
output [7:0] dp_tnh1_casc_bias_15,
output [7:0] dp_tnh2_casc_bias_0,
output [7:0] dp_tnh2_casc_bias_1,
output [7:0] dp_tnh2_casc_bias_2,
output [7:0] dp_tnh2_casc_bias_3,
output [7:0] dp_tnh2_casc_bias_4,
output [7:0] dp_tnh2_casc_bias_5,
output [7:0] dp_tnh2_casc_bias_6,
output [7:0] dp_tnh2_casc_bias_7,
output [7:0] dp_tnh2_casc_bias_8,
output [7:0] dp_tnh2_casc_bias_9,
output [7:0] dp_tnh2_casc_bias_10,
output [7:0] dp_tnh2_casc_bias_11,
output [7:0] dp_tnh2_casc_bias_12,
output [7:0] dp_tnh2_casc_bias_13,
output [7:0] dp_tnh2_casc_bias_14,
output [7:0] dp_tnh2_casc_bias_15,
output [5:0] cp_8G_ctrl_0,
output [5:0] cp_8G_ctrl_1,
output [5:0] cp_8G_ctrl_2,
output [5:0] cp_8G_ctrl_3,
output [5:0] cp_8G_ctrl_4,
output [5:0] cp_8G_ctrl_5,
output [5:0] cp_8G_ctrl_6,
output [5:0] cp_8G_ctrl_7,
output [5:0] cp_8G_ctrl_8,
output [5:0] cp_8G_ctrl_9,
output [5:0] cp_8G_ctrl_10,
output [5:0] cp_8G_ctrl_11,
output [5:0] cp_8G_ctrl_12,
output [5:0] cp_8G_ctrl_13,
output [5:0] cp_8G_ctrl_14,
output [5:0] cp_8G_ctrl_15,
output [1:0] dp_vtc_bias_0,
output [1:0] dp_vtc_bias_1,
output [1:0] dp_vtc_bias_2,
output [1:0] dp_vtc_bias_3,
output [1:0] dp_vtc_bias_4,
output [1:0] dp_vtc_bias_5,
output [1:0] dp_vtc_bias_6,
output [1:0] dp_vtc_bias_7,
output [1:0] dp_vtc_bias_8,
output [1:0] dp_vtc_bias_9,
output [1:0] dp_vtc_bias_10,
output [1:0] dp_vtc_bias_11,
output [1:0] dp_vtc_bias_12,
output [1:0] dp_vtc_bias_13,
output [1:0] dp_vtc_bias_14,
output [1:0] dp_vtc_bias_15,
output [1:0] dp_sf_bias_0,
output [1:0] dp_sf_bias_1,
output [1:0] dp_sf_bias_2,
output [1:0] dp_sf_bias_3,
output [1:0] dp_sf_bias_4,
output [1:0] dp_sf_bias_5,
output [1:0] dp_sf_bias_6,
output [1:0] dp_sf_bias_7,
output [1:0] dp_sf_bias_8,
output [1:0] dp_sf_bias_9,
output [1:0] dp_sf_bias_10,
output [1:0] dp_sf_bias_11,
output [1:0] dp_sf_bias_12,
output [1:0] dp_sf_bias_13,
output [1:0] dp_sf_bias_14,
output [1:0] dp_sf_bias_15,
output [1:0] dp_tnh2_bias_0,
output [1:0] dp_tnh2_bias_1,
output [1:0] dp_tnh2_bias_2,
output [1:0] dp_tnh2_bias_3,
output [1:0] dp_tnh2_bias_4,
output [1:0] dp_tnh2_bias_5,
output [1:0] dp_tnh2_bias_6,
output [1:0] dp_tnh2_bias_7,
output [1:0] dp_tnh2_bias_8,
output [1:0] dp_tnh2_bias_9,
output [1:0] dp_tnh2_bias_10,
output [1:0] dp_tnh2_bias_11,
output [1:0] dp_tnh2_bias_12,
output [1:0] dp_tnh2_bias_13,
output [1:0] dp_tnh2_bias_14,
output [1:0] dp_tnh2_bias_15,
output [7:0] dp_hpf_biasn_0,
output [7:0] dp_hpf_biasn_1,
output [7:0] dp_hpf_biasn_2,
output [7:0] dp_hpf_biasn_3,
output [7:0] dp_hpf_biasn_4,
output [7:0] dp_hpf_biasn_5,
output [7:0] dp_hpf_biasn_6,
output [7:0] dp_hpf_biasn_7,
output [7:0] dp_hpf_biasp_0,
output [7:0] dp_hpf_biasp_1,
output [7:0] dp_hpf_biasp_2,
output [7:0] dp_hpf_biasp_3,
output [7:0] dp_hpf_biasp_4,
output [7:0] dp_hpf_biasp_5,
output [7:0] dp_hpf_biasp_6,
output [7:0] dp_hpf_biasp_7,
output dp_en_div_4to1,
output dp_ringosc_en,
output [8:0] dp_amux,
output [15:0] dp_sel_clk_inv,
output [1:0] dp_tnh1_bias_0,
output [1:0] dp_tnh1_bias_1,
output [1:0] dp_tnh1_bias_2,
output [1:0] dp_tnh1_bias_3,
output [1:0] dp_tnh1_bias_4,
output [1:0] dp_tnh1_bias_5,
output [1:0] dp_tnh1_bias_6,
output [1:0] dp_tnh1_bias_7,
output [1:0] dp_tnh1_bias_8,
output [1:0] dp_tnh1_bias_9,
output [1:0] dp_tnh1_bias_10,
output [1:0] dp_tnh1_bias_11,
output [1:0] dp_tnh1_bias_12,
output [1:0] dp_tnh1_bias_13,
output [1:0] dp_tnh1_bias_14,
output [1:0] dp_tnh1_bias_15,
output scan_out
);
wire [127:0] scan_00;
wire [127:0] scan_01;
wire [127:0] scan_02;
wire [127:0] scan_03;
wire [127:0] scan_04;
wire [127:0] scan_05;
wire [127:0] scan_06;
wire [127:0] scan_07;
wire [127:0] scan_08;
wire [127:0] scan_09;
wire [127:0] scan_10;
reg take_scanout_data;
wire [139:0] scan_in_data_reg;
reg [139:0] scan_out_mux_output;
wire [10:0] scan_en_sub;
wire [11:0] addr;
assign scan_out = scan_in_data_reg[139];

                parameter ADDR0 = 12'b100101100;
                //parameter for digital chain # 00
                assign dp_fe_hpf_biasn = scan_00[31:24];
assign dp_fe_hpf_biasp = scan_00[23:16];
assign dp_ctle_cm_vref = scan_00[15:8];
assign dp_abuf_cm_vref = scan_00[7:0];

                Scan_reset #(.WIDTH(128)) scan_00_module (
                  .reset(scan_reset),
                  .out(scan_00),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[0]),
                  .reset_value({96'd0, 8'd175,8'd175,8'd175,8'd163})
                );

                
                parameter ADDR1 = 12'b1100100;
                //parameter for digital chain # 01
                assign cp_sel = scan_01[65:64];
assign cp_16G_ctrl_0 = scan_01[63:58];
assign cp_16G_ctrl_1 = scan_01[57:52];
assign cp_16G_ctrl_2 = scan_01[51:46];
assign cp_16G_ctrl_3 = scan_01[45:40];
assign cp_16G_ctrl_4 = scan_01[39:34];
assign cp_16G_ctrl_5 = scan_01[33:28];
assign cp_16G_ctrl_6 = scan_01[27:22];
assign cp_16G_ctrl_7 = scan_01[21:16];
assign cp_16G_ctrln = scan_01[15:8];
assign cp_16G_ctrlp = scan_01[7:0];

                Scan_reset #(.WIDTH(128)) scan_01_module (
                  .reset(scan_reset),
                  .out(scan_01),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[1]),
                  .reset_value({62'd0, 2'd2,6'd38,6'd36,6'd42,6'd40,6'd32,6'd36,6'd20,6'd18,8'd0,8'd255})
                );

                
                parameter ADDR2 = 12'b111110100;
                //parameter for digital chain # 02
                assign dp_tnh1_casc_bias_0 = scan_02[127:120];
assign dp_tnh1_casc_bias_1 = scan_02[119:112];
assign dp_tnh1_casc_bias_2 = scan_02[111:104];
assign dp_tnh1_casc_bias_3 = scan_02[103:96];
assign dp_tnh1_casc_bias_4 = scan_02[95:88];
assign dp_tnh1_casc_bias_5 = scan_02[87:80];
assign dp_tnh1_casc_bias_6 = scan_02[79:72];
assign dp_tnh1_casc_bias_7 = scan_02[71:64];
assign dp_tnh1_casc_bias_8 = scan_02[63:56];
assign dp_tnh1_casc_bias_9 = scan_02[55:48];
assign dp_tnh1_casc_bias_10 = scan_02[47:40];
assign dp_tnh1_casc_bias_11 = scan_02[39:32];
assign dp_tnh1_casc_bias_12 = scan_02[31:24];
assign dp_tnh1_casc_bias_13 = scan_02[23:16];
assign dp_tnh1_casc_bias_14 = scan_02[15:8];
assign dp_tnh1_casc_bias_15 = scan_02[7:0];

                Scan_reset #(.WIDTH(128)) scan_02_module (
                  .reset(scan_reset),
                  .out(scan_02),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[2]),
                  .reset_value({8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165,8'd165})
                );

                
                parameter ADDR3 = 12'b1100100000;
                //parameter for digital chain # 03
                assign dp_tnh2_casc_bias_0 = scan_03[127:120];
assign dp_tnh2_casc_bias_1 = scan_03[119:112];
assign dp_tnh2_casc_bias_2 = scan_03[111:104];
assign dp_tnh2_casc_bias_3 = scan_03[103:96];
assign dp_tnh2_casc_bias_4 = scan_03[95:88];
assign dp_tnh2_casc_bias_5 = scan_03[87:80];
assign dp_tnh2_casc_bias_6 = scan_03[79:72];
assign dp_tnh2_casc_bias_7 = scan_03[71:64];
assign dp_tnh2_casc_bias_8 = scan_03[63:56];
assign dp_tnh2_casc_bias_9 = scan_03[55:48];
assign dp_tnh2_casc_bias_10 = scan_03[47:40];
assign dp_tnh2_casc_bias_11 = scan_03[39:32];
assign dp_tnh2_casc_bias_12 = scan_03[31:24];
assign dp_tnh2_casc_bias_13 = scan_03[23:16];
assign dp_tnh2_casc_bias_14 = scan_03[15:8];
assign dp_tnh2_casc_bias_15 = scan_03[7:0];

                Scan_reset #(.WIDTH(128)) scan_03_module (
                  .reset(scan_reset),
                  .out(scan_03),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[3]),
                  .reset_value({8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128,8'd128})
                );

                
                parameter ADDR4 = 12'b11001000;
                //parameter for digital chain # 04
                assign cp_8G_ctrl_0 = scan_04[95:90];
assign cp_8G_ctrl_1 = scan_04[89:84];
assign cp_8G_ctrl_2 = scan_04[83:78];
assign cp_8G_ctrl_3 = scan_04[77:72];
assign cp_8G_ctrl_4 = scan_04[71:66];
assign cp_8G_ctrl_5 = scan_04[65:60];
assign cp_8G_ctrl_6 = scan_04[59:54];
assign cp_8G_ctrl_7 = scan_04[53:48];
assign cp_8G_ctrl_8 = scan_04[47:42];
assign cp_8G_ctrl_9 = scan_04[41:36];
assign cp_8G_ctrl_10 = scan_04[35:30];
assign cp_8G_ctrl_11 = scan_04[29:24];
assign cp_8G_ctrl_12 = scan_04[23:18];
assign cp_8G_ctrl_13 = scan_04[17:12];
assign cp_8G_ctrl_14 = scan_04[11:6];
assign cp_8G_ctrl_15 = scan_04[5:0];

                Scan_reset #(.WIDTH(128)) scan_04_module (
                  .reset(scan_reset),
                  .out(scan_04),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[4]),
                  .reset_value({32'd0, 6'd22,6'd24,6'd24,6'd30,6'd24,6'd26,6'd28,6'd28,6'd26,6'd26,6'd26,6'd26,6'd18,6'd26,6'd26,6'd28})
                );

                
                parameter ADDR5 = 12'b1111101000;
                //parameter for digital chain # 05
                assign dp_vtc_bias_0 = scan_05[31:30];
assign dp_vtc_bias_1 = scan_05[29:28];
assign dp_vtc_bias_2 = scan_05[27:26];
assign dp_vtc_bias_3 = scan_05[25:24];
assign dp_vtc_bias_4 = scan_05[23:22];
assign dp_vtc_bias_5 = scan_05[21:20];
assign dp_vtc_bias_6 = scan_05[19:18];
assign dp_vtc_bias_7 = scan_05[17:16];
assign dp_vtc_bias_8 = scan_05[15:14];
assign dp_vtc_bias_9 = scan_05[13:12];
assign dp_vtc_bias_10 = scan_05[11:10];
assign dp_vtc_bias_11 = scan_05[9:8];
assign dp_vtc_bias_12 = scan_05[7:6];
assign dp_vtc_bias_13 = scan_05[5:4];
assign dp_vtc_bias_14 = scan_05[3:2];
assign dp_vtc_bias_15 = scan_05[1:0];

                Scan_reset #(.WIDTH(128)) scan_05_module (
                  .reset(scan_reset),
                  .out(scan_05),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[5]),
                  .reset_value({96'd0, 2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0})
                );

                
                parameter ADDR6 = 12'b1010111100;
                //parameter for digital chain # 06
                assign dp_sf_bias_0 = scan_06[31:30];
assign dp_sf_bias_1 = scan_06[29:28];
assign dp_sf_bias_2 = scan_06[27:26];
assign dp_sf_bias_3 = scan_06[25:24];
assign dp_sf_bias_4 = scan_06[23:22];
assign dp_sf_bias_5 = scan_06[21:20];
assign dp_sf_bias_6 = scan_06[19:18];
assign dp_sf_bias_7 = scan_06[17:16];
assign dp_sf_bias_8 = scan_06[15:14];
assign dp_sf_bias_9 = scan_06[13:12];
assign dp_sf_bias_10 = scan_06[11:10];
assign dp_sf_bias_11 = scan_06[9:8];
assign dp_sf_bias_12 = scan_06[7:6];
assign dp_sf_bias_13 = scan_06[5:4];
assign dp_sf_bias_14 = scan_06[3:2];
assign dp_sf_bias_15 = scan_06[1:0];

                Scan_reset #(.WIDTH(128)) scan_06_module (
                  .reset(scan_reset),
                  .out(scan_06),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[6]),
                  .reset_value({96'd0, 2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0})
                );

                
                parameter ADDR7 = 12'b1110000100;
                //parameter for digital chain # 07
                assign dp_tnh2_bias_0 = scan_07[31:30];
assign dp_tnh2_bias_1 = scan_07[29:28];
assign dp_tnh2_bias_2 = scan_07[27:26];
assign dp_tnh2_bias_3 = scan_07[25:24];
assign dp_tnh2_bias_4 = scan_07[23:22];
assign dp_tnh2_bias_5 = scan_07[21:20];
assign dp_tnh2_bias_6 = scan_07[19:18];
assign dp_tnh2_bias_7 = scan_07[17:16];
assign dp_tnh2_bias_8 = scan_07[15:14];
assign dp_tnh2_bias_9 = scan_07[13:12];
assign dp_tnh2_bias_10 = scan_07[11:10];
assign dp_tnh2_bias_11 = scan_07[9:8];
assign dp_tnh2_bias_12 = scan_07[7:6];
assign dp_tnh2_bias_13 = scan_07[5:4];
assign dp_tnh2_bias_14 = scan_07[3:2];
assign dp_tnh2_bias_15 = scan_07[1:0];

                Scan_reset #(.WIDTH(128)) scan_07_module (
                  .reset(scan_reset),
                  .out(scan_07),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[7]),
                  .reset_value({96'd0, 2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0})
                );

                
                parameter ADDR8 = 12'b110010000;
                //parameter for digital chain # 08
                assign dp_hpf_biasn_0 = scan_08[127:120];
assign dp_hpf_biasn_1 = scan_08[119:112];
assign dp_hpf_biasn_2 = scan_08[111:104];
assign dp_hpf_biasn_3 = scan_08[103:96];
assign dp_hpf_biasn_4 = scan_08[95:88];
assign dp_hpf_biasn_5 = scan_08[87:80];
assign dp_hpf_biasn_6 = scan_08[79:72];
assign dp_hpf_biasn_7 = scan_08[71:64];
assign dp_hpf_biasp_0 = scan_08[63:56];
assign dp_hpf_biasp_1 = scan_08[55:48];
assign dp_hpf_biasp_2 = scan_08[47:40];
assign dp_hpf_biasp_3 = scan_08[39:32];
assign dp_hpf_biasp_4 = scan_08[31:24];
assign dp_hpf_biasp_5 = scan_08[23:16];
assign dp_hpf_biasp_6 = scan_08[15:8];
assign dp_hpf_biasp_7 = scan_08[7:0];

                Scan_reset #(.WIDTH(128)) scan_08_module (
                  .reset(scan_reset),
                  .out(scan_08),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[8]),
                  .reset_value({8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179,8'd179})
                );

                
                parameter ADDR9 = 12'b10001001100;
                //parameter for digital chain # 09
                assign dp_en_div_4to1 = scan_09[26];
assign dp_ringosc_en = scan_09[25];
assign dp_amux = scan_09[24:16];
assign dp_sel_clk_inv = scan_09[15:0];

                Scan_reset #(.WIDTH(128)) scan_09_module (
                  .reset(scan_reset),
                  .out(scan_09),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[9]),
                  .reset_value({101'd0, 1'd0,1'd0,9'd1,16'd0})
                );

                
                parameter ADDR10 = 12'b1001011000;
                //parameter for digital chain # 10
                assign dp_tnh1_bias_0 = scan_10[31:30];
assign dp_tnh1_bias_1 = scan_10[29:28];
assign dp_tnh1_bias_2 = scan_10[27:26];
assign dp_tnh1_bias_3 = scan_10[25:24];
assign dp_tnh1_bias_4 = scan_10[23:22];
assign dp_tnh1_bias_5 = scan_10[21:20];
assign dp_tnh1_bias_6 = scan_10[19:18];
assign dp_tnh1_bias_7 = scan_10[17:16];
assign dp_tnh1_bias_8 = scan_10[15:14];
assign dp_tnh1_bias_9 = scan_10[13:12];
assign dp_tnh1_bias_10 = scan_10[11:10];
assign dp_tnh1_bias_11 = scan_10[9:8];
assign dp_tnh1_bias_12 = scan_10[7:6];
assign dp_tnh1_bias_13 = scan_10[5:4];
assign dp_tnh1_bias_14 = scan_10[3:2];
assign dp_tnh1_bias_15 = scan_10[1:0];

                Scan_reset #(.WIDTH(128)) scan_10_module (
                  .reset(scan_reset),
                  .out(scan_10),
                  .data_in(scan_in_data_reg),
                  .enable(scan_en_sub[10]),
                  .reset_value({96'd0, 2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0,2'd0})
                );

                
    subclk #( .ADDR0(ADDR0),
.ADDR1(ADDR1),
.ADDR2(ADDR2),
.ADDR3(ADDR3),
.ADDR4(ADDR4),
.ADDR5(ADDR5),
.ADDR6(ADDR6),
.ADDR7(ADDR7),
.ADDR8(ADDR8),
.ADDR9(ADDR9),
.ADDR10(ADDR10)
    ) subclk_sub ( .reset(scan_reset),
     .scan_in(scan_in), .scan_en(scan_en), .take_scanout_data(take_scanout_data),
     .scan_clk(scan_clk), .addr_out(addr), .scan_en_sub(scan_en_sub), .scan_out_mux_output(scan_out_mux_output), .scan_in_data_reg(scan_in_data_reg));
    

always @(*) begin
	case(addr)
	default: begin
		scan_out_mux_output = 0;
		take_scanout_data=0;
	end
endcase
end
endmodule
