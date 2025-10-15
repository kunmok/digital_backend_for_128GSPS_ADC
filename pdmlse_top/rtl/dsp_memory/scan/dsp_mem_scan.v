//-------------------------------------------------------------------------------------------
// This file was auto generated with the command:
// gen-scan-chain.pl ./cfg/dsp_mem_scan.cfg ./dsp_mem_scan.v ./dsp_mem_scan_defs.v Mem
// Config file contents:
//                          Field Name       Dir     Width      Mult
//-------------------------------------------------------------------------------------------
//                           RetimeRst         W         1         1
//                            BankWRst         W         8         1
//                            BankRRst         W         8         1
//                               FsRst         W         1         1
//                            RetimeEn         W         1         1
//                              BankEn         W         8         1
//                                FsEn         W         1         1
//                      CfgModeRUpdate         W         1         1
//                       CfgModeWShift         W         1         1
//                       CfgModeRShift         W         1         1
//                       CfgFsModeLoad         W         1         1
//                       CfgFsSyncWord         W        64         1
//
// Scan Chain Module Name = dsp_mem_scan
// Scanchain Length = 96
//-------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module dsp_mem_scan(
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
    localparam ChainLength =                    `MemScanChainLength;
    localparam RetimeRstWidth =                 1;
    localparam BankWRstWidth =                  8;
    localparam BankRRstWidth =                  8;
    localparam FsRstWidth =                     1;
    localparam RetimeEnWidth =                  1;
    localparam BankEnWidth =                    8;
    localparam FsEnWidth =                      1;
    localparam CfgModeRUpdateWidth =            1;
    localparam CfgModeWShiftWidth =             1;
    localparam CfgModeRShiftWidth =             1;
    localparam CfgFsModeLoadWidth =             1;
    localparam CfgFsSyncWordWidth =             64;
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
    wire                                 RetimeRstToBankWRst;
    wire                                 BankWRstToBankRRst;
    wire                                 BankRRstToFsRst;
    wire                                 FsRstToRetimeEn;
    wire                                 RetimeEnToBankEn;
    wire                                 BankEnToFsEn;
    wire                                 FsEnToCfgModeRUpdate;
    wire                                 CfgModeRUpdateToCfgModeWShift;
    wire                                 CfgModeWShiftToCfgModeRShift;
    wire                                 CfgModeRShiftToCfgFsModeLoad;
    wire                                 CfgFsModeLoadToCfgFsSyncWord;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Scan Segment Instantiations
    //-----------------------------------------------------------------------------------
    WriteSegment             #      (   .PWidth         (RetimeRstWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RetimeRstSeg                (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemRetimeRst]),
                                        .SIn            (SIn),
                                        .SOut           (RetimeRstToBankWRst));

    WriteSegment             #      (   .PWidth         (BankWRstWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        BankWRstSeg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemBankWRst]),
                                        .SIn            (RetimeRstToBankWRst),
                                        .SOut           (BankWRstToBankRRst));

    WriteSegment             #      (   .PWidth         (BankRRstWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        BankRRstSeg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemBankRRst]),
                                        .SIn            (BankWRstToBankRRst),
                                        .SOut           (BankRRstToFsRst));

    WriteSegment             #      (   .PWidth         (FsRstWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        FsRstSeg                    (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemFsRst]),
                                        .SIn            (BankRRstToFsRst),
                                        .SOut           (FsRstToRetimeEn));

    WriteSegment             #      (   .PWidth         (RetimeEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RetimeEnSeg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemRetimeEn]),
                                        .SIn            (FsRstToRetimeEn),
                                        .SOut           (RetimeEnToBankEn));

    WriteSegment             #      (   .PWidth         (BankEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        BankEnSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemBankEn]),
                                        .SIn            (RetimeEnToBankEn),
                                        .SOut           (BankEnToFsEn));

    WriteSegment             #      (   .PWidth         (FsEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        FsEnSeg                     (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemFsEn]),
                                        .SIn            (BankEnToFsEn),
                                        .SOut           (FsEnToCfgModeRUpdate));

    WriteSegment             #      (   .PWidth         (CfgModeRUpdateWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgModeRUpdateSeg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemCfgModeRUpdate]),
                                        .SIn            (FsEnToCfgModeRUpdate),
                                        .SOut           (CfgModeRUpdateToCfgModeWShift));

    WriteSegment             #      (   .PWidth         (CfgModeWShiftWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgModeWShiftSeg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemCfgModeWShift]),
                                        .SIn            (CfgModeRUpdateToCfgModeWShift),
                                        .SOut           (CfgModeWShiftToCfgModeRShift));

    WriteSegment             #      (   .PWidth         (CfgModeRShiftWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgModeRShiftSeg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemCfgModeRShift]),
                                        .SIn            (CfgModeWShiftToCfgModeRShift),
                                        .SOut           (CfgModeRShiftToCfgFsModeLoad));

    WriteSegment             #      (   .PWidth         (CfgFsModeLoadWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgFsModeLoadSeg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemCfgFsModeLoad]),
                                        .SIn            (CfgModeRShiftToCfgFsModeLoad),
                                        .SOut           (CfgFsModeLoadToCfgFsSyncWord));

    WriteSegment             #      (   .PWidth         (CfgFsSyncWordWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgFsSyncWordSeg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`MemCfgFsSyncWord]),
                                        .SIn            (CfgFsModeLoadToCfgFsSyncWord),
                                        .SOut           (SOut));

    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    For Testing
    //-----------------------------------------------------------------------------------
`ifdef NCVLOG
`endif
    //-----------------------------------------------------------------------------------
endmodule
