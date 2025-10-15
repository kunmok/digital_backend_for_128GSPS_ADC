//-------------------------------------------------------------------------------------------
// This file was auto generated with the command:
// gen-scan-chain.pl ./cfg/dsp_fe_lane_des_scan.cfg ./dsp_fe_lane_des_scan.v ./dsp_fe_lane_des_scan_defs.v FeLaneDes
// Config file contents:
//                          Field Name       Dir     Width      Mult
//-------------------------------------------------------------------------------------------
//                                  En         W         1         1
//                            EnRetime         W         1         1
//                           RstRetime         W         1         1
//
// Scan Chain Module Name = dsp_fe_lane_des_scan
// Scanchain Length = 3
//-------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module dsp_fe_lane_des_scan(
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
    localparam ChainLength =                    `FeLaneDesScanChainLength;
    localparam EnWidth =                        1;
    localparam EnRetimeWidth =                  1;
    localparam RstRetimeWidth =                 1;
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
    wire                                 EnToEnRetime;
    wire                                 EnRetimeToRstRetime;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Scan Segment Instantiations
    //-----------------------------------------------------------------------------------
    WriteSegment             #      (   .PWidth         (EnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnSeg                       (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneDesEn]),
                                        .SIn            (SIn),
                                        .SOut           (EnToEnRetime));

    WriteSegment             #      (   .PWidth         (EnRetimeWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnRetimeSeg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneDesEnRetime]),
                                        .SIn            (EnToEnRetime),
                                        .SOut           (EnRetimeToRstRetime));

    WriteSegment             #      (   .PWidth         (RstRetimeWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstRetimeSeg                (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`FeLaneDesRstRetime]),
                                        .SIn            (EnRetimeToRstRetime),
                                        .SOut           (SOut));

    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    For Testing
    //-----------------------------------------------------------------------------------
`ifdef NCVLOG
`endif
    //-----------------------------------------------------------------------------------
endmodule
