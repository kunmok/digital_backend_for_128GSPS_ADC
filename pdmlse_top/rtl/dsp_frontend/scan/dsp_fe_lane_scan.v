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

module dsp_fe_lane_scan(
        //---------------------------------------------------------------------------
        //    Scan Chain I/O
        //---------------------------------------------------------------------------
        SClkP,
        SClkN,
        SReset,
        SEnable,
        SUpdate,
        SIn,
        SOut,
        //---------------------------------------------------------------------------

        //---------------------------------------------------------------------------
        //    Configuration I/O
        //---------------------------------------------------------------------------
        ScanBitsRd,
        ScanBitsWr
        //---------------------------------------------------------------------------
    );

    //-----------------------------------------------------------------------------------
    //    Chain Parameters
    //-----------------------------------------------------------------------------------
    parameter TwoPhase =                            1;
    parameter ConfigLatch =                         1;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Configuration Constants
    //-----------------------------------------------------------------------------------
    localparam ChainLength =                    `FeLaneScanChainLength;
    localparam RstGlueWidth =                   1;
    localparam RstLutWidth =                    1;
    localparam EnGlueWidth =                    1;
    localparam EnLutWidth =                     1;
    localparam CfgLutModeLoadWidth =            1;
    localparam CfgLutModeSeedWidth =            1;
    localparam CfgLutModeMissionWidth =         1;
    localparam CfgLutTableWidth =               384;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Scan Chain I/O
    //-----------------------------------------------------------------------------------
    input wire                           SClkP;
    input wire                           SClkN;
    input wire                           SReset;
    input wire                           SEnable;
    input wire                           SUpdate;
    input wire                           SIn;
    output wire                          SOut;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Configuration I/O
    //-----------------------------------------------------------------------------------
    input wire   [ChainLength-1:0]       ScanBitsRd;
    output wire  [ChainLength-1:0]       ScanBitsWr;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Signals
    //-----------------------------------------------------------------------------------
    wire                                 RstGlueToRstLut;
    wire                                 RstLutToEnGlue;
    wire                                 EnGlueToEnLut;
    wire                                 EnLutToCfgLutModeLoad;
    wire                                 CfgLutModeLoadToCfgLutModeSeed;
    wire                                 CfgLutModeSeedToCfgLutModeMission;
    wire                                 CfgLutModeMissionToCfgLutTable;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Scan Segment Instantiations
    //-----------------------------------------------------------------------------------
    WriteSegment             #      (   .PWidth         (RstGlueWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstGlueSeg                  (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneRstGlue]),
                                        .SIn            (SIn),
                                        .SOut           (RstGlueToRstLut));

    WriteSegment             #      (   .PWidth         (RstLutWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstLutSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneRstLut]),
                                        .SIn            (RstGlueToRstLut),
                                        .SOut           (RstLutToEnGlue));

    WriteSegment             #      (   .PWidth         (EnGlueWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnGlueSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneEnGlue]),
                                        .SIn            (RstLutToEnGlue),
                                        .SOut           (EnGlueToEnLut));

    WriteSegment             #      (   .PWidth         (EnLutWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnLutSeg                    (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneEnLut]),
                                        .SIn            (EnGlueToEnLut),
                                        .SOut           (EnLutToCfgLutModeLoad));

    WriteSegment             #      (   .PWidth         (CfgLutModeLoadWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgLutModeLoadSeg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneCfgLutModeLoad]),
                                        .SIn            (EnLutToCfgLutModeLoad),
                                        .SOut           (CfgLutModeLoadToCfgLutModeSeed));

    WriteSegment             #      (   .PWidth         (CfgLutModeSeedWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgLutModeSeedSeg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneCfgLutModeSeed]),
                                        .SIn            (CfgLutModeLoadToCfgLutModeSeed),
                                        .SOut           (CfgLutModeSeedToCfgLutModeMission));

    WriteSegment             #      (   .PWidth         (CfgLutModeMissionWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgLutModeMissionSeg        (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneCfgLutModeMission]),
                                        .SIn            (CfgLutModeSeedToCfgLutModeMission),
                                        .SOut           (CfgLutModeMissionToCfgLutTable));

    WriteSegment             #      (   .PWidth         (CfgLutTableWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgLutTableSeg              (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneCfgLutTable]),
                                        .SIn            (CfgLutModeMissionToCfgLutTable),
                                        .SOut           (SOut));

    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    For Testing
    //-----------------------------------------------------------------------------------
`ifdef NCVLOG
`endif
    //-----------------------------------------------------------------------------------
endmodule
