//-------------------------------------------------------------------------------------------
// This file was auto generated with the command:
// gen-scan-chain.pl ./cfg/dsp_be_scan.cfg ./dsp_be_scan.v ./dsp_be_scan_defs.v Be
// Config file contents:
//                          Field Name       Dir     Width      Mult
//-------------------------------------------------------------------------------------------
//                          CfgEqInInv         W         1         1
//                              RstAlu         W         1        64
//                               EnAlu         W         1        64
//                            CfgEqHm1         W         8        64
//                            CfgEqHp1         W         8        64
//                             CfgEqHx         W         8        64
//                             RstFilt         W         1        64
//                              EnFilt         W         1        64
//                          CfgEqP1aEn         W         1         1
//                          CfgEqP1bEn         W         1         1
//                           CfgEqP2En         W         1         1
//                          CfgEqP3oEn         W         1         1
//                          CfgEqP3aEn         W         1         1
//                          CfgEqP3bEn         W         1         1
//                          CfgEqP4pEn         W         1         1
//                          CfgEqP4mEn         W         1         1
//                              RstDec         W         1        64
//                               EnDec         W         1        64
//                         CfgEqOutInv         W         1         1
//                      CfgEqOutEndian         W         1         1
//                             RstBert         W         1         1
//                             CfgPgen         W        36        16
//                           CfgSnapEn         W         1        16
//                          CfgModeBer         W         1        16
//                       CfgBerCountEn         W         1        16
//                    CfgBerShutoffSel         W         4         1
//                         CfgBerInInv         W         1         1
//                   PrbsSeedGoodPrbs7         R         1        16
//                        SnapOutPrbs7         R        32        16
//                     BerShutoffPrbs7         R         1         1
//                       BerCountPrbs7         R        41        16
//                       BitCountPrbs7         R        41         1
//                  PrbsSeedGoodPrbs15         R         1        16
//                       SnapOutPrbs15         R        32        16
//                    BerShutoffPrbs15         R         1         1
//                      BerCountPrbs15         R        41        16
//                      BitCountPrbs15         R        41         1
//                  PrbsSeedGoodPrbs31         R         1        16
//                       SnapOutPrbs31         R        32        16
//                    BerShutoffPrbs31         R         1         1
//                      BerCountPrbs31         R        41        16
//                      BitCountPrbs31         R        41         1
//
// Scan Chain Module Name = dsp_be_scan
// Scanchain Length = 6239
//-------------------------------------------------------------------------------------------

`timescale 1ns/1ps

module dsp_be_scan(
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
    localparam ChainLength =                    `BeScanChainLength;
    localparam CfgEqInInvWidth =                1;
    localparam RstAluWidth =                    64;
    localparam EnAluWidth =                     64;
    localparam CfgEqHm1Width =                  512;
    localparam CfgEqHp1Width =                  512;
    localparam CfgEqHxWidth =                   512;
    localparam RstFiltWidth =                   64;
    localparam EnFiltWidth =                    64;
    localparam CfgEqP1aEnWidth =                1;
    localparam CfgEqP1bEnWidth =                1;
    localparam CfgEqP2EnWidth =                 1;
    localparam CfgEqP3oEnWidth =                1;
    localparam CfgEqP3aEnWidth =                1;
    localparam CfgEqP3bEnWidth =                1;
    localparam CfgEqP4pEnWidth =                1;
    localparam CfgEqP4mEnWidth =                1;
    localparam RstDecWidth =                    64;
    localparam EnDecWidth =                     64;
    localparam CfgEqOutInvWidth =               1;
    localparam CfgEqOutEndianWidth =            1;
    localparam RstBertWidth =                   1;
    localparam CfgPgenWidth =                   576;
    localparam CfgSnapEnWidth =                 16;
    localparam CfgModeBerWidth =                16;
    localparam CfgBerCountEnWidth =             16;
    localparam CfgBerShutoffSelWidth =          4;
    localparam CfgBerInInvWidth =               1;
    localparam PrbsSeedGoodPrbs7Width =         16;
    localparam SnapOutPrbs7Width =              512;
    localparam BerShutoffPrbs7Width =           1;
    localparam BerCountPrbs7Width =             656;
    localparam BitCountPrbs7Width =             41;
    localparam PrbsSeedGoodPrbs15Width =        16;
    localparam SnapOutPrbs15Width =             512;
    localparam BerShutoffPrbs15Width =          1;
    localparam BerCountPrbs15Width =            656;
    localparam BitCountPrbs15Width =            41;
    localparam PrbsSeedGoodPrbs31Width =        16;
    localparam SnapOutPrbs31Width =             512;
    localparam BerShutoffPrbs31Width =          1;
    localparam BerCountPrbs31Width =            656;
    localparam BitCountPrbs31Width =            41;
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
    wire                                 CfgEqInInvToRstAlu;
    wire                                 RstAluToEnAlu;
    wire                                 EnAluToCfgEqHm1;
    wire                                 CfgEqHm1ToCfgEqHp1;
    wire                                 CfgEqHp1ToCfgEqHx;
    wire                                 CfgEqHxToRstFilt;
    wire                                 RstFiltToEnFilt;
    wire                                 EnFiltToCfgEqP1aEn;
    wire                                 CfgEqP1aEnToCfgEqP1bEn;
    wire                                 CfgEqP1bEnToCfgEqP2En;
    wire                                 CfgEqP2EnToCfgEqP3oEn;
    wire                                 CfgEqP3oEnToCfgEqP3aEn;
    wire                                 CfgEqP3aEnToCfgEqP3bEn;
    wire                                 CfgEqP3bEnToCfgEqP4pEn;
    wire                                 CfgEqP4pEnToCfgEqP4mEn;
    wire                                 CfgEqP4mEnToRstDec;
    wire                                 RstDecToEnDec;
    wire                                 EnDecToCfgEqOutInv;
    wire                                 CfgEqOutInvToCfgEqOutEndian;
    wire                                 CfgEqOutEndianToRstBert;
    wire                                 RstBertToCfgPgen;
    wire                                 CfgPgenToCfgSnapEn;
    wire                                 CfgSnapEnToCfgModeBer;
    wire                                 CfgModeBerToCfgBerCountEn;
    wire                                 CfgBerCountEnToCfgBerShutoffSel;
    wire                                 CfgBerShutoffSelToCfgBerInInv;
    wire                                 CfgBerInInvToPrbsSeedGoodPrbs7;
    wire                                 PrbsSeedGoodPrbs7ToSnapOutPrbs7;
    wire                                 SnapOutPrbs7ToBerShutoffPrbs7;
    wire                                 BerShutoffPrbs7ToBerCountPrbs7;
    wire                                 BerCountPrbs7ToBitCountPrbs7;
    wire                                 BitCountPrbs7ToPrbsSeedGoodPrbs15;
    wire                                 PrbsSeedGoodPrbs15ToSnapOutPrbs15;
    wire                                 SnapOutPrbs15ToBerShutoffPrbs15;
    wire                                 BerShutoffPrbs15ToBerCountPrbs15;
    wire                                 BerCountPrbs15ToBitCountPrbs15;
    wire                                 BitCountPrbs15ToPrbsSeedGoodPrbs31;
    wire                                 PrbsSeedGoodPrbs31ToSnapOutPrbs31;
    wire                                 SnapOutPrbs31ToBerShutoffPrbs31;
    wire                                 BerShutoffPrbs31ToBerCountPrbs31;
    wire                                 BerCountPrbs31ToBitCountPrbs31;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    Scan Segment Instantiations
    //-----------------------------------------------------------------------------------
    WriteSegment             #      (   .PWidth         (CfgEqInInvWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqInInvSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqInInv]),
                                        .SIn            (SIn),
                                        .SOut           (CfgEqInInvToRstAlu));

    WriteSegment             #      (   .PWidth         (RstAluWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstAluSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeRstAlu]),
                                        .SIn            (CfgEqInInvToRstAlu),
                                        .SOut           (RstAluToEnAlu));

    WriteSegment             #      (   .PWidth         (EnAluWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnAluSeg                    (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeEnAlu]),
                                        .SIn            (RstAluToEnAlu),
                                        .SOut           (EnAluToCfgEqHm1));

    WriteSegment             #      (   .PWidth         (CfgEqHm1Width),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqHm1Seg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqHm1]),
                                        .SIn            (EnAluToCfgEqHm1),
                                        .SOut           (CfgEqHm1ToCfgEqHp1));

    WriteSegment             #      (   .PWidth         (CfgEqHp1Width),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqHp1Seg                 (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqHp1]),
                                        .SIn            (CfgEqHm1ToCfgEqHp1),
                                        .SOut           (CfgEqHp1ToCfgEqHx));

    WriteSegment             #      (   .PWidth         (CfgEqHxWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqHxSeg                  (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqHx]),
                                        .SIn            (CfgEqHp1ToCfgEqHx),
                                        .SOut           (CfgEqHxToRstFilt));

    WriteSegment             #      (   .PWidth         (RstFiltWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstFiltSeg                  (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeRstFilt]),
                                        .SIn            (CfgEqHxToRstFilt),
                                        .SOut           (RstFiltToEnFilt));

    WriteSegment             #      (   .PWidth         (EnFiltWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnFiltSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeEnFilt]),
                                        .SIn            (RstFiltToEnFilt),
                                        .SOut           (EnFiltToCfgEqP1aEn));

    WriteSegment             #      (   .PWidth         (CfgEqP1aEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP1aEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP1aEn]),
                                        .SIn            (EnFiltToCfgEqP1aEn),
                                        .SOut           (CfgEqP1aEnToCfgEqP1bEn));

    WriteSegment             #      (   .PWidth         (CfgEqP1bEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP1bEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP1bEn]),
                                        .SIn            (CfgEqP1aEnToCfgEqP1bEn),
                                        .SOut           (CfgEqP1bEnToCfgEqP2En));

    WriteSegment             #      (   .PWidth         (CfgEqP2EnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP2EnSeg                (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP2En]),
                                        .SIn            (CfgEqP1bEnToCfgEqP2En),
                                        .SOut           (CfgEqP2EnToCfgEqP3oEn));

    WriteSegment             #      (   .PWidth         (CfgEqP3oEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP3oEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP3oEn]),
                                        .SIn            (CfgEqP2EnToCfgEqP3oEn),
                                        .SOut           (CfgEqP3oEnToCfgEqP3aEn));

    WriteSegment             #      (   .PWidth         (CfgEqP3aEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP3aEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP3aEn]),
                                        .SIn            (CfgEqP3oEnToCfgEqP3aEn),
                                        .SOut           (CfgEqP3aEnToCfgEqP3bEn));

    WriteSegment             #      (   .PWidth         (CfgEqP3bEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP3bEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP3bEn]),
                                        .SIn            (CfgEqP3aEnToCfgEqP3bEn),
                                        .SOut           (CfgEqP3bEnToCfgEqP4pEn));

    WriteSegment             #      (   .PWidth         (CfgEqP4pEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP4pEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP4pEn]),
                                        .SIn            (CfgEqP3bEnToCfgEqP4pEn),
                                        .SOut           (CfgEqP4pEnToCfgEqP4mEn));

    WriteSegment             #      (   .PWidth         (CfgEqP4mEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqP4mEnSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqP4mEn]),
                                        .SIn            (CfgEqP4pEnToCfgEqP4mEn),
                                        .SOut           (CfgEqP4mEnToRstDec));

    WriteSegment             #      (   .PWidth         (RstDecWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstDecSeg                   (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeRstDec]),
                                        .SIn            (CfgEqP4mEnToRstDec),
                                        .SOut           (RstDecToEnDec));

    WriteSegment             #      (   .PWidth         (EnDecWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        EnDecSeg                    (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeEnDec]),
                                        .SIn            (RstDecToEnDec),
                                        .SOut           (EnDecToCfgEqOutInv));

    WriteSegment             #      (   .PWidth         (CfgEqOutInvWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqOutInvSeg              (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqOutInv]),
                                        .SIn            (EnDecToCfgEqOutInv),
                                        .SOut           (CfgEqOutInvToCfgEqOutEndian));

    WriteSegment             #      (   .PWidth         (CfgEqOutEndianWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgEqOutEndianSeg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgEqOutEndian]),
                                        .SIn            (CfgEqOutInvToCfgEqOutEndian),
                                        .SOut           (CfgEqOutEndianToRstBert));

    WriteSegment             #      (   .PWidth         (RstBertWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        RstBertSeg                  (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeRstBert]),
                                        .SIn            (CfgEqOutEndianToRstBert),
                                        .SOut           (RstBertToCfgPgen));

    WriteSegment             #      (   .PWidth         (CfgPgenWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgPgenSeg                  (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgPgen]),
                                        .SIn            (RstBertToCfgPgen),
                                        .SOut           (CfgPgenToCfgSnapEn));

    WriteSegment             #      (   .PWidth         (CfgSnapEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgSnapEnSeg                (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgSnapEn]),
                                        .SIn            (CfgPgenToCfgSnapEn),
                                        .SOut           (CfgSnapEnToCfgModeBer));

    WriteSegment             #      (   .PWidth         (CfgModeBerWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgModeBerSeg               (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgModeBer]),
                                        .SIn            (CfgSnapEnToCfgModeBer),
                                        .SOut           (CfgModeBerToCfgBerCountEn));

    WriteSegment             #      (   .PWidth         (CfgBerCountEnWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgBerCountEnSeg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgBerCountEn]),
                                        .SIn            (CfgModeBerToCfgBerCountEn),
                                        .SOut           (CfgBerCountEnToCfgBerShutoffSel));

    WriteSegment             #      (   .PWidth         (CfgBerShutoffSelWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgBerShutoffSelSeg         (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgBerShutoffSel]),
                                        .SIn            (CfgBerCountEnToCfgBerShutoffSel),
                                        .SOut           (CfgBerShutoffSelToCfgBerInInv));

    WriteSegment             #      (   .PWidth         (CfgBerInInvWidth),
                                        .TwoPhase       (TwoPhase),
                                        .ConfigLatch    (ConfigLatch))
        CfgBerInInvSeg              (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SReset         (SReset),
                                        .SEnable        (SEnable),
                                        .SUpdate        (SUpdate),
                                        .CfgOut         (ScanBitsWr[`BeCfgBerInInv]),
                                        .SIn            (CfgBerShutoffSelToCfgBerInInv),
                                        .SOut           (CfgBerInInvToPrbsSeedGoodPrbs7));

    ReadSegment             #       (   .PWidth         (PrbsSeedGoodPrbs7Width),
                                        .TwoPhase       (TwoPhase))
        PrbsSeedGoodPrbs7Seg        (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BePrbsSeedGoodPrbs7]),
                                        .SIn            (CfgBerInInvToPrbsSeedGoodPrbs7),
                                        .SOut           (PrbsSeedGoodPrbs7ToSnapOutPrbs7));

    ReadSegment             #       (   .PWidth         (SnapOutPrbs7Width),
                                        .TwoPhase       (TwoPhase))
        SnapOutPrbs7Seg             (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeSnapOutPrbs7]),
                                        .SIn            (PrbsSeedGoodPrbs7ToSnapOutPrbs7),
                                        .SOut           (SnapOutPrbs7ToBerShutoffPrbs7));

    ReadSegment             #       (   .PWidth         (BerShutoffPrbs7Width),
                                        .TwoPhase       (TwoPhase))
        BerShutoffPrbs7Seg          (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerShutoffPrbs7]),
                                        .SIn            (SnapOutPrbs7ToBerShutoffPrbs7),
                                        .SOut           (BerShutoffPrbs7ToBerCountPrbs7));

    ReadSegment             #       (   .PWidth         (BerCountPrbs7Width),
                                        .TwoPhase       (TwoPhase))
        BerCountPrbs7Seg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerCountPrbs7]),
                                        .SIn            (BerShutoffPrbs7ToBerCountPrbs7),
                                        .SOut           (BerCountPrbs7ToBitCountPrbs7));

    ReadSegment             #       (   .PWidth         (BitCountPrbs7Width),
                                        .TwoPhase       (TwoPhase))
        BitCountPrbs7Seg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBitCountPrbs7]),
                                        .SIn            (BerCountPrbs7ToBitCountPrbs7),
                                        .SOut           (BitCountPrbs7ToPrbsSeedGoodPrbs15));

    ReadSegment             #       (   .PWidth         (PrbsSeedGoodPrbs15Width),
                                        .TwoPhase       (TwoPhase))
        PrbsSeedGoodPrbs15Seg       (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BePrbsSeedGoodPrbs15]),
                                        .SIn            (BitCountPrbs7ToPrbsSeedGoodPrbs15),
                                        .SOut           (PrbsSeedGoodPrbs15ToSnapOutPrbs15));

    ReadSegment             #       (   .PWidth         (SnapOutPrbs15Width),
                                        .TwoPhase       (TwoPhase))
        SnapOutPrbs15Seg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeSnapOutPrbs15]),
                                        .SIn            (PrbsSeedGoodPrbs15ToSnapOutPrbs15),
                                        .SOut           (SnapOutPrbs15ToBerShutoffPrbs15));

    ReadSegment             #       (   .PWidth         (BerShutoffPrbs15Width),
                                        .TwoPhase       (TwoPhase))
        BerShutoffPrbs15Seg         (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerShutoffPrbs15]),
                                        .SIn            (SnapOutPrbs15ToBerShutoffPrbs15),
                                        .SOut           (BerShutoffPrbs15ToBerCountPrbs15));

    ReadSegment             #       (   .PWidth         (BerCountPrbs15Width),
                                        .TwoPhase       (TwoPhase))
        BerCountPrbs15Seg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerCountPrbs15]),
                                        .SIn            (BerShutoffPrbs15ToBerCountPrbs15),
                                        .SOut           (BerCountPrbs15ToBitCountPrbs15));

    ReadSegment             #       (   .PWidth         (BitCountPrbs15Width),
                                        .TwoPhase       (TwoPhase))
        BitCountPrbs15Seg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBitCountPrbs15]),
                                        .SIn            (BerCountPrbs15ToBitCountPrbs15),
                                        .SOut           (BitCountPrbs15ToPrbsSeedGoodPrbs31));

    ReadSegment             #       (   .PWidth         (PrbsSeedGoodPrbs31Width),
                                        .TwoPhase       (TwoPhase))
        PrbsSeedGoodPrbs31Seg       (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BePrbsSeedGoodPrbs31]),
                                        .SIn            (BitCountPrbs15ToPrbsSeedGoodPrbs31),
                                        .SOut           (PrbsSeedGoodPrbs31ToSnapOutPrbs31));

    ReadSegment             #       (   .PWidth         (SnapOutPrbs31Width),
                                        .TwoPhase       (TwoPhase))
        SnapOutPrbs31Seg            (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeSnapOutPrbs31]),
                                        .SIn            (PrbsSeedGoodPrbs31ToSnapOutPrbs31),
                                        .SOut           (SnapOutPrbs31ToBerShutoffPrbs31));

    ReadSegment             #       (   .PWidth         (BerShutoffPrbs31Width),
                                        .TwoPhase       (TwoPhase))
        BerShutoffPrbs31Seg         (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerShutoffPrbs31]),
                                        .SIn            (SnapOutPrbs31ToBerShutoffPrbs31),
                                        .SOut           (BerShutoffPrbs31ToBerCountPrbs31));

    ReadSegment             #       (   .PWidth         (BerCountPrbs31Width),
                                        .TwoPhase       (TwoPhase))
        BerCountPrbs31Seg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBerCountPrbs31]),
                                        .SIn            (BerShutoffPrbs31ToBerCountPrbs31),
                                        .SOut           (BerCountPrbs31ToBitCountPrbs31));

    ReadSegment             #       (   .PWidth         (BitCountPrbs31Width),
                                        .TwoPhase       (TwoPhase))
        BitCountPrbs31Seg           (   .SClkP          (SClkP),
                                        .SClkN          (SClkN),
                                        .SEnable        (SEnable),
                                        .CfgIn          (ScanBitsRd[`BeBitCountPrbs31]),
                                        .SIn            (BerCountPrbs31ToBitCountPrbs31),
                                        .SOut           (SOut));

    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //    For Testing
    //-----------------------------------------------------------------------------------
`ifdef NCVLOG
`endif
    //-----------------------------------------------------------------------------------
endmodule
