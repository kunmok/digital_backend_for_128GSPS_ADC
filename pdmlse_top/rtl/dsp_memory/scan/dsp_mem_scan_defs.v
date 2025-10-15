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

//-------------------------------------------------------------------------------------------
//    Scan Chain Length
//-------------------------------------------------------------------------------------------
`define MemScanChainLength           96
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Scan Chain Length Per Field
//-------------------------------------------------------------------------------------------
`define MemRetimeRst_ScanChainLength                                 1
`define MemBankWRst_ScanChainLength                                  8
`define MemBankRRst_ScanChainLength                                  8
`define MemFsRst_ScanChainLength                                     1
`define MemRetimeEn_ScanChainLength                                  1
`define MemBankEn_ScanChainLength                                    8
`define MemFsEn_ScanChainLength                                      1
`define MemCfgModeRUpdate_ScanChainLength                            1
`define MemCfgModeWShift_ScanChainLength                             1
`define MemCfgModeRShift_ScanChainLength                             1
`define MemCfgFsModeLoad_ScanChainLength                             1
`define MemCfgFsSyncWord_ScanChainLength                            64

//-------------------------------------------------------------------------------------------
//    Full Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define MemRetimeRst                              0:0     
`define MemBankWRst                               8:1     
`define MemBankRRst                              16:9     
`define MemFsRst                                 17:17    
`define MemRetimeEn                              18:18    
`define MemBankEn                                26:19    
`define MemFsEn                                  27:27    
`define MemCfgModeRUpdate                        28:28    
`define MemCfgModeWShift                         29:29    
`define MemCfgModeRShift                         30:30    
`define MemCfgFsModeLoad                         31:31    
`define MemCfgFsSyncWord                         95:32    
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//    Indexed Bit Vector Defs
//-------------------------------------------------------------------------------------------
`define MemRetimeRst_idx(n)                  (n * 1      +      0)+:     1 //      0:0     
`define MemBankWRst_idx(n)                   (n * 8      +      1)+:     8 //      8:1     
`define MemBankRRst_idx(n)                   (n * 8      +      9)+:     8 //     16:9     
`define MemFsRst_idx(n)                      (n * 1      +     17)+:     1 //     17:17    
`define MemRetimeEn_idx(n)                   (n * 1      +     18)+:     1 //     18:18    
`define MemBankEn_idx(n)                     (n * 8      +     19)+:     8 //     26:19    
`define MemFsEn_idx(n)                       (n * 1      +     27)+:     1 //     27:27    
`define MemCfgModeRUpdate_idx(n)             (n * 1      +     28)+:     1 //     28:28    
`define MemCfgModeWShift_idx(n)              (n * 1      +     29)+:     1 //     29:29    
`define MemCfgModeRShift_idx(n)              (n * 1      +     30)+:     1 //     30:30    
`define MemCfgFsModeLoad_idx(n)              (n * 1      +     31)+:     1 //     31:31    
`define MemCfgFsSyncWord_idx(n)              (n * 64     +     32)+:    64 //     95:32    
//-------------------------------------------------------------------------------------------
