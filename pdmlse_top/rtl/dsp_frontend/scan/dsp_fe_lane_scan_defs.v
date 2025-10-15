//-------------------------------------------------------------------------------------------
// This file was auto generated with the command:
// gen-scan-chain.pl ./cfg/dsp_fe_lane_scan.cfg ./dsp_fe_lane_scan.v ./dsp_fe_lane_scan_defs.v FeLane
// Config file contents:
//                          Field Name       Dir     Width      Mult
//-------------------------------------------------------------------------------------------
//                             RstGlue         W         1         1
//                              RstLut         W         1         1
//                              EnGlue         W         1         1
//                               EnLut         W         1         1
//                      CfgLutModeLoad         W         1         1
//                      CfgLutModeSeed         W         1         1
//                   CfgLutModeMission         W         1         1
//                         CfgLutTable         W       384         1
//
// Scan Chain Module Name = dsp_fe_lane_scan
// Scanchain Length = 391
//-------------------------------------------------------------------------------------------

`timescale 1ns/1ps

//-------------------------------------------------------------------------------------------
//    Scan Chain Length
//-------------------------------------------------------------------------------------------
`define FeLaneScanChainLength        391
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Scan Chain Length Per Field
//-------------------------------------------------------------------------------------------
`define FeLaneRstGlue_ScanChainLength                                1
`define FeLaneRstLut_ScanChainLength                                 1
`define FeLaneEnGlue_ScanChainLength                                 1
`define FeLaneEnLut_ScanChainLength                                  1
`define FeLaneCfgLutModeLoad_ScanChainLength                         1
`define FeLaneCfgLutModeSeed_ScanChainLength                         1
`define FeLaneCfgLutModeMission_ScanChainLength                      1
`define FeLaneCfgLutTable_ScanChainLength                          384

//-------------------------------------------------------------------------------------------
//    Full Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define FeLaneRstGlue                             0:0     
`define FeLaneRstLut                              1:1     
`define FeLaneEnGlue                              2:2     
`define FeLaneEnLut                               3:3     
`define FeLaneCfgLutModeLoad                      4:4     
`define FeLaneCfgLutModeSeed                      5:5     
`define FeLaneCfgLutModeMission                   6:6     
`define FeLaneCfgLutTable                       390:7     
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Indexed Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define FeLaneRstGlue_idx(n)                 (n * 1      +      0)+:     1 //      0:0     
`define FeLaneRstLut_idx(n)                  (n * 1      +      1)+:     1 //      1:1     
`define FeLaneEnGlue_idx(n)                  (n * 1      +      2)+:     1 //      2:2     
`define FeLaneEnLut_idx(n)                   (n * 1      +      3)+:     1 //      3:3     
`define FeLaneCfgLutModeLoad_idx(n)          (n * 1      +      4)+:     1 //      4:4     
`define FeLaneCfgLutModeSeed_idx(n)          (n * 1      +      5)+:     1 //      5:5     
`define FeLaneCfgLutModeMission_idx(n)       (n * 1      +      6)+:     1 //      6:6     
`define FeLaneCfgLutTable_idx(n)             (n * 384    +      7)+:   384 //    390:7     
//-------------------------------------------------------------------------------------------
