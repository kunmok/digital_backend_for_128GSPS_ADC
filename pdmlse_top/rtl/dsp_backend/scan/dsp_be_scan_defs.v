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

//-------------------------------------------------------------------------------------------
//    Scan Chain Length
//-------------------------------------------------------------------------------------------
`define BeScanChainLength            6239
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Scan Chain Length Per Field
//-------------------------------------------------------------------------------------------
`define BeCfgEqInInv_ScanChainLength                                 1
`define BeRstAlu_ScanChainLength                                     1
`define BeEnAlu_ScanChainLength                                      1
`define BeCfgEqHm1_ScanChainLength                                   8
`define BeCfgEqHp1_ScanChainLength                                   8
`define BeCfgEqHx_ScanChainLength                                    8
`define BeRstFilt_ScanChainLength                                    1
`define BeEnFilt_ScanChainLength                                     1
`define BeCfgEqP1aEn_ScanChainLength                                 1
`define BeCfgEqP1bEn_ScanChainLength                                 1
`define BeCfgEqP2En_ScanChainLength                                  1
`define BeCfgEqP3oEn_ScanChainLength                                 1
`define BeCfgEqP3aEn_ScanChainLength                                 1
`define BeCfgEqP3bEn_ScanChainLength                                 1
`define BeCfgEqP4pEn_ScanChainLength                                 1
`define BeCfgEqP4mEn_ScanChainLength                                 1
`define BeRstDec_ScanChainLength                                     1
`define BeEnDec_ScanChainLength                                      1
`define BeCfgEqOutInv_ScanChainLength                                1
`define BeCfgEqOutEndian_ScanChainLength                             1
`define BeRstBert_ScanChainLength                                    1
`define BeCfgPgen_ScanChainLength                                   36
`define BeCfgSnapEn_ScanChainLength                                  1
`define BeCfgModeBer_ScanChainLength                                 1
`define BeCfgBerCountEn_ScanChainLength                              1
`define BeCfgBerShutoffSel_ScanChainLength                           4
`define BeCfgBerInInv_ScanChainLength                                1
`define BePrbsSeedGoodPrbs7_ScanChainLength                          1
`define BeSnapOutPrbs7_ScanChainLength                              32
`define BeBerShutoffPrbs7_ScanChainLength                            1
`define BeBerCountPrbs7_ScanChainLength                             41
`define BeBitCountPrbs7_ScanChainLength                             41
`define BePrbsSeedGoodPrbs15_ScanChainLength                         1
`define BeSnapOutPrbs15_ScanChainLength                             32
`define BeBerShutoffPrbs15_ScanChainLength                           1
`define BeBerCountPrbs15_ScanChainLength                            41
`define BeBitCountPrbs15_ScanChainLength                            41
`define BePrbsSeedGoodPrbs31_ScanChainLength                         1
`define BeSnapOutPrbs31_ScanChainLength                             32
`define BeBerShutoffPrbs31_ScanChainLength                           1
`define BeBerCountPrbs31_ScanChainLength                            41
`define BeBitCountPrbs31_ScanChainLength                            41

//-------------------------------------------------------------------------------------------
//    Full Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define BeCfgEqInInv                              0:0     
`define BeRstAlu                                 64:1     
`define BeEnAlu                                 128:65    
`define BeCfgEqHm1                              640:129   
`define BeCfgEqHp1                             1152:641   
`define BeCfgEqHx                              1664:1153  
`define BeRstFilt                              1728:1665  
`define BeEnFilt                               1792:1729  
`define BeCfgEqP1aEn                           1793:1793  
`define BeCfgEqP1bEn                           1794:1794  
`define BeCfgEqP2En                            1795:1795  
`define BeCfgEqP3oEn                           1796:1796  
`define BeCfgEqP3aEn                           1797:1797  
`define BeCfgEqP3bEn                           1798:1798  
`define BeCfgEqP4pEn                           1799:1799  
`define BeCfgEqP4mEn                           1800:1800  
`define BeRstDec                               1864:1801  
`define BeEnDec                                1928:1865  
`define BeCfgEqOutInv                          1929:1929  
`define BeCfgEqOutEndian                       1930:1930  
`define BeRstBert                              1931:1931  
`define BeCfgPgen                              2507:1932  
`define BeCfgSnapEn                            2523:2508  
`define BeCfgModeBer                           2539:2524  
`define BeCfgBerCountEn                        2555:2540  
`define BeCfgBerShutoffSel                     2559:2556  
`define BeCfgBerInInv                          2560:2560  
`define BePrbsSeedGoodPrbs7                    2576:2561  
`define BeSnapOutPrbs7                         3088:2577  
`define BeBerShutoffPrbs7                      3089:3089  
`define BeBerCountPrbs7                        3745:3090  
`define BeBitCountPrbs7                        3786:3746  
`define BePrbsSeedGoodPrbs15                   3802:3787  
`define BeSnapOutPrbs15                        4314:3803  
`define BeBerShutoffPrbs15                     4315:4315  
`define BeBerCountPrbs15                       4971:4316  
`define BeBitCountPrbs15                       5012:4972  
`define BePrbsSeedGoodPrbs31                   5028:5013  
`define BeSnapOutPrbs31                        5540:5029  
`define BeBerShutoffPrbs31                     5541:5541  
`define BeBerCountPrbs31                       6197:5542  
`define BeBitCountPrbs31                       6238:6198  
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Indexed Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define BeCfgEqInInv_idx(n)                  (n * 1      +      0)+:     1 //      0:0     
`define BeRstAlu_idx(n)                      (n * 1      +      1)+:     1 //     64:1     
`define BeEnAlu_idx(n)                       (n * 1      +     65)+:     1 //    128:65    
`define BeCfgEqHm1_idx(n)                    (n * 8      +    129)+:     8 //    640:129   
`define BeCfgEqHp1_idx(n)                    (n * 8      +    641)+:     8 //   1152:641   
`define BeCfgEqHx_idx(n)                     (n * 8      +   1153)+:     8 //   1664:1153  
`define BeRstFilt_idx(n)                     (n * 1      +   1665)+:     1 //   1728:1665  
`define BeEnFilt_idx(n)                      (n * 1      +   1729)+:     1 //   1792:1729  
`define BeCfgEqP1aEn_idx(n)                  (n * 1      +   1793)+:     1 //   1793:1793  
`define BeCfgEqP1bEn_idx(n)                  (n * 1      +   1794)+:     1 //   1794:1794  
`define BeCfgEqP2En_idx(n)                   (n * 1      +   1795)+:     1 //   1795:1795  
`define BeCfgEqP3oEn_idx(n)                  (n * 1      +   1796)+:     1 //   1796:1796  
`define BeCfgEqP3aEn_idx(n)                  (n * 1      +   1797)+:     1 //   1797:1797  
`define BeCfgEqP3bEn_idx(n)                  (n * 1      +   1798)+:     1 //   1798:1798  
`define BeCfgEqP4pEn_idx(n)                  (n * 1      +   1799)+:     1 //   1799:1799  
`define BeCfgEqP4mEn_idx(n)                  (n * 1      +   1800)+:     1 //   1800:1800  
`define BeRstDec_idx(n)                      (n * 1      +   1801)+:     1 //   1864:1801  
`define BeEnDec_idx(n)                       (n * 1      +   1865)+:     1 //   1928:1865  
`define BeCfgEqOutInv_idx(n)                 (n * 1      +   1929)+:     1 //   1929:1929  
`define BeCfgEqOutEndian_idx(n)              (n * 1      +   1930)+:     1 //   1930:1930  
`define BeRstBert_idx(n)                     (n * 1      +   1931)+:     1 //   1931:1931  
`define BeCfgPgen_idx(n)                     (n * 36     +   1932)+:    36 //   2507:1932  
`define BeCfgSnapEn_idx(n)                   (n * 1      +   2508)+:     1 //   2523:2508  
`define BeCfgModeBer_idx(n)                  (n * 1      +   2524)+:     1 //   2539:2524  
`define BeCfgBerCountEn_idx(n)               (n * 1      +   2540)+:     1 //   2555:2540  
`define BeCfgBerShutoffSel_idx(n)            (n * 4      +   2556)+:     4 //   2559:2556  
`define BeCfgBerInInv_idx(n)                 (n * 1      +   2560)+:     1 //   2560:2560  
`define BePrbsSeedGoodPrbs7_idx(n)           (n * 1      +   2561)+:     1 //   2576:2561  
`define BeSnapOutPrbs7_idx(n)                (n * 32     +   2577)+:    32 //   3088:2577  
`define BeBerShutoffPrbs7_idx(n)             (n * 1      +   3089)+:     1 //   3089:3089  
`define BeBerCountPrbs7_idx(n)               (n * 41     +   3090)+:    41 //   3745:3090  
`define BeBitCountPrbs7_idx(n)               (n * 41     +   3746)+:    41 //   3786:3746  
`define BePrbsSeedGoodPrbs15_idx(n)          (n * 1      +   3787)+:     1 //   3802:3787  
`define BeSnapOutPrbs15_idx(n)               (n * 32     +   3803)+:    32 //   4314:3803  
`define BeBerShutoffPrbs15_idx(n)            (n * 1      +   4315)+:     1 //   4315:4315  
`define BeBerCountPrbs15_idx(n)              (n * 41     +   4316)+:    41 //   4971:4316  
`define BeBitCountPrbs15_idx(n)              (n * 41     +   4972)+:    41 //   5012:4972  
`define BePrbsSeedGoodPrbs31_idx(n)          (n * 1      +   5013)+:     1 //   5028:5013  
`define BeSnapOutPrbs31_idx(n)               (n * 32     +   5029)+:    32 //   5540:5029  
`define BeBerShutoffPrbs31_idx(n)            (n * 1      +   5541)+:     1 //   5541:5541  
`define BeBerCountPrbs31_idx(n)              (n * 41     +   5542)+:    41 //   6197:5542  
`define BeBitCountPrbs31_idx(n)              (n * 41     +   6198)+:    41 //   6238:6198  
//-------------------------------------------------------------------------------------------
