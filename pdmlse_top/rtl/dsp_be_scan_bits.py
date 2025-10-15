# -------------------------------------------------------------------------------------------
# This file was auto generated with the command:
# scan-to-python.pl scan_defines/dsp_be_scan.cfg ../dsp_be_scan_bits.py
# Config file contents:
#                          Field Name       Dir     Width      Mult
# -------------------------------------------------------------------------------------------
#                          CfgEqInInv         W         1         1
#                              RstAlu         W         1        64
#                               EnAlu         W         1        64
#                            CfgEqHm1         W         8        64
#                            CfgEqHp1         W         8        64
#                             CfgEqHx         W         8        64
#                             RstFilt         W         1        64
#                              EnFilt         W         1        64
#                          CfgEqP1aEn         W         1         1
#                          CfgEqP1bEn         W         1         1
#                           CfgEqP2En         W         1         1
#                          CfgEqP3oEn         W         1         1
#                          CfgEqP3aEn         W         1         1
#                          CfgEqP3bEn         W         1         1
#                          CfgEqP4pEn         W         1         1
#                          CfgEqP4mEn         W         1         1
#                              RstDec         W         1        64
#                               EnDec         W         1        64
#                         CfgEqOutInv         W         1         1
#                      CfgEqOutEndian         W         1         1
#                             RstBert         W         1         1
#                             CfgPgen         W        36        16
#                           CfgSnapEn         W         1        16
#                          CfgModeBer         W         1        16
#                       CfgBerCountEn         W         1        16
#                    CfgBerShutoffSel         W         4         1
#                         CfgBerInInv         W         1         1
#                   PrbsSeedGoodPrbs7         R         1        16
#                        SnapOutPrbs7         R        32        16
#                     BerShutoffPrbs7         R         1         1
#                       BerCountPrbs7         R        41        16
#                       BitCountPrbs7         R        41         1
#                  PrbsSeedGoodPrbs15         R         1        16
#                       SnapOutPrbs15         R        32        16
#                    BerShutoffPrbs15         R         1         1
#                      BerCountPrbs15         R        41        16
#                      BitCountPrbs15         R        41         1
#                  PrbsSeedGoodPrbs31         R         1        16
#                       SnapOutPrbs31         R        32        16
#                    BerShutoffPrbs31         R         1         1
#                      BerCountPrbs31         R        41        16
#                      BitCountPrbs31         R        41         1
#
# Scan Chain Module Name = dsp_be_scan
# Scanchain Length = 6239
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
#    Class dsp_be_scan
# -------------------------------------------------------------------------------------------
class dsp_be_scan:

    # -----------------------------------------------------------------------------------
    #    Constructor
    # -----------------------------------------------------------------------------------
    def __init__(self, 
        CfgEqInInv                           = '0' * 1     , 
        RstAlu                               = '0' * 64    , 
        EnAlu                                = '0' * 64    , 
        CfgEqHm1                             = '0' * 512   , 
        CfgEqHp1                             = '0' * 512   , 
        CfgEqHx                              = '0' * 512   , 
        RstFilt                              = '0' * 64    , 
        EnFilt                               = '0' * 64    , 
        CfgEqP1aEn                           = '0' * 1     , 
        CfgEqP1bEn                           = '0' * 1     , 
        CfgEqP2En                            = '0' * 1     , 
        CfgEqP3oEn                           = '0' * 1     , 
        CfgEqP3aEn                           = '0' * 1     , 
        CfgEqP3bEn                           = '0' * 1     , 
        CfgEqP4pEn                           = '0' * 1     , 
        CfgEqP4mEn                           = '0' * 1     , 
        RstDec                               = '0' * 64    , 
        EnDec                                = '0' * 64    , 
        CfgEqOutInv                          = '0' * 1     , 
        CfgEqOutEndian                       = '0' * 1     , 
        RstBert                              = '0' * 1     , 
        CfgPgen                              = '0' * 576   , 
        CfgSnapEn                            = '0' * 16    , 
        CfgModeBer                           = '0' * 16    , 
        CfgBerCountEn                        = '0' * 16    , 
        CfgBerShutoffSel                     = '0' * 4     , 
        CfgBerInInv                          = '0' * 1     , 
        PrbsSeedGoodPrbs7                    = '0' * 16    , 
        SnapOutPrbs7                         = '0' * 512   , 
        BerShutoffPrbs7                      = '0' * 1     , 
        BerCountPrbs7                        = '0' * 656   , 
        BitCountPrbs7                        = '0' * 41    , 
        PrbsSeedGoodPrbs15                   = '0' * 16    , 
        SnapOutPrbs15                        = '0' * 512   , 
        BerShutoffPrbs15                     = '0' * 1     , 
        BerCountPrbs15                       = '0' * 656   , 
        BitCountPrbs15                       = '0' * 41    , 
        PrbsSeedGoodPrbs31                   = '0' * 16    , 
        SnapOutPrbs31                        = '0' * 512   , 
        BerShutoffPrbs31                     = '0' * 1     , 
        BerCountPrbs31                       = '0' * 656   , 
        BitCountPrbs31                       = '0' * 41    , 
        filler                               = '0' * 0     ):

        self.filler                               = filler
        self.CfgEqInInv                           = CfgEqInInv
        self.RstAlu                               = RstAlu
        self.EnAlu                                = EnAlu
        self.CfgEqHm1                             = CfgEqHm1
        self.CfgEqHp1                             = CfgEqHp1
        self.CfgEqHx                              = CfgEqHx
        self.RstFilt                              = RstFilt
        self.EnFilt                               = EnFilt
        self.CfgEqP1aEn                           = CfgEqP1aEn
        self.CfgEqP1bEn                           = CfgEqP1bEn
        self.CfgEqP2En                            = CfgEqP2En
        self.CfgEqP3oEn                           = CfgEqP3oEn
        self.CfgEqP3aEn                           = CfgEqP3aEn
        self.CfgEqP3bEn                           = CfgEqP3bEn
        self.CfgEqP4pEn                           = CfgEqP4pEn
        self.CfgEqP4mEn                           = CfgEqP4mEn
        self.RstDec                               = RstDec
        self.EnDec                                = EnDec
        self.CfgEqOutInv                          = CfgEqOutInv
        self.CfgEqOutEndian                       = CfgEqOutEndian
        self.RstBert                              = RstBert
        self.CfgPgen                              = CfgPgen
        self.CfgSnapEn                            = CfgSnapEn
        self.CfgModeBer                           = CfgModeBer
        self.CfgBerCountEn                        = CfgBerCountEn
        self.CfgBerShutoffSel                     = CfgBerShutoffSel
        self.CfgBerInInv                          = CfgBerInInv
        self.PrbsSeedGoodPrbs7                    = PrbsSeedGoodPrbs7
        self.SnapOutPrbs7                         = SnapOutPrbs7
        self.BerShutoffPrbs7                      = BerShutoffPrbs7
        self.BerCountPrbs7                        = BerCountPrbs7
        self.BitCountPrbs7                        = BitCountPrbs7
        self.PrbsSeedGoodPrbs15                   = PrbsSeedGoodPrbs15
        self.SnapOutPrbs15                        = SnapOutPrbs15
        self.BerShutoffPrbs15                     = BerShutoffPrbs15
        self.BerCountPrbs15                       = BerCountPrbs15
        self.BitCountPrbs15                       = BitCountPrbs15
        self.PrbsSeedGoodPrbs31                   = PrbsSeedGoodPrbs31
        self.SnapOutPrbs31                        = SnapOutPrbs31
        self.BerShutoffPrbs31                     = BerShutoffPrbs31
        self.BerCountPrbs31                       = BerCountPrbs31
        self.BitCountPrbs31                       = BitCountPrbs31
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get scan chain length
    # -----------------------------------------------------------------------------------
    @staticmethod
    def length(): 
        return 6239

    @staticmethod
    def length_static(): 
        return 6239

    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct bits from class
    # -----------------------------------------------------------------------------------
    def to_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.BitCountPrbs31,
            self.BerCountPrbs31,
            self.BerShutoffPrbs31,
            self.SnapOutPrbs31,
            self.PrbsSeedGoodPrbs31,
            self.BitCountPrbs15,
            self.BerCountPrbs15,
            self.BerShutoffPrbs15,
            self.SnapOutPrbs15,
            self.PrbsSeedGoodPrbs15,
            self.BitCountPrbs7,
            self.BerCountPrbs7,
            self.BerShutoffPrbs7,
            self.SnapOutPrbs7,
            self.PrbsSeedGoodPrbs7,
            self.CfgBerInInv,
            self.CfgBerShutoffSel,
            self.CfgBerCountEn,
            self.CfgModeBer,
            self.CfgSnapEn,
            self.CfgPgen,
            self.RstBert,
            self.CfgEqOutEndian,
            self.CfgEqOutInv,
            self.EnDec,
            self.RstDec,
            self.CfgEqP4mEn,
            self.CfgEqP4pEn,
            self.CfgEqP3bEn,
            self.CfgEqP3aEn,
            self.CfgEqP3oEn,
            self.CfgEqP2En,
            self.CfgEqP1bEn,
            self.CfgEqP1aEn,
            self.EnFilt,
            self.RstFilt,
            self.CfgEqHx,
            self.CfgEqHp1,
            self.CfgEqHm1,
            self.EnAlu,
            self.RstAlu,
            self.CfgEqInInv,
        ]])
        
        # Output check
        if len(bits) != self.length():
            raise ValueError("Error, expecting 6239 bits, got " + str(len(bits)) + "!")
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Update class from bits
    # -----------------------------------------------------------------------------------
    def from_bits(self, bits): 
        
        # Check length of bits
        if len(bits) != 6239:
            raise ValueError("Error, expecting 6239 bits, got " + str(len(bits)) + "!")
        
        self.BitCountPrbs31                       = bits[     0:41    ]
        self.BerCountPrbs31                       = bits[    41:697   ]
        self.BerShutoffPrbs31                     = bits[   697:698   ]
        self.SnapOutPrbs31                        = bits[   698:1210  ]
        self.PrbsSeedGoodPrbs31                   = bits[  1210:1226  ]
        self.BitCountPrbs15                       = bits[  1226:1267  ]
        self.BerCountPrbs15                       = bits[  1267:1923  ]
        self.BerShutoffPrbs15                     = bits[  1923:1924  ]
        self.SnapOutPrbs15                        = bits[  1924:2436  ]
        self.PrbsSeedGoodPrbs15                   = bits[  2436:2452  ]
        self.BitCountPrbs7                        = bits[  2452:2493  ]
        self.BerCountPrbs7                        = bits[  2493:3149  ]
        self.BerShutoffPrbs7                      = bits[  3149:3150  ]
        self.SnapOutPrbs7                         = bits[  3150:3662  ]
        self.PrbsSeedGoodPrbs7                    = bits[  3662:3678  ]
        self.CfgBerInInv                          = bits[  3678:3679  ]
        self.CfgBerShutoffSel                     = bits[  3679:3683  ]
        self.CfgBerCountEn                        = bits[  3683:3699  ]
        self.CfgModeBer                           = bits[  3699:3715  ]
        self.CfgSnapEn                            = bits[  3715:3731  ]
        self.CfgPgen                              = bits[  3731:4307  ]
        self.RstBert                              = bits[  4307:4308  ]
        self.CfgEqOutEndian                       = bits[  4308:4309  ]
        self.CfgEqOutInv                          = bits[  4309:4310  ]
        self.EnDec                                = bits[  4310:4374  ]
        self.RstDec                               = bits[  4374:4438  ]
        self.CfgEqP4mEn                           = bits[  4438:4439  ]
        self.CfgEqP4pEn                           = bits[  4439:4440  ]
        self.CfgEqP3bEn                           = bits[  4440:4441  ]
        self.CfgEqP3aEn                           = bits[  4441:4442  ]
        self.CfgEqP3oEn                           = bits[  4442:4443  ]
        self.CfgEqP2En                            = bits[  4443:4444  ]
        self.CfgEqP1bEn                           = bits[  4444:4445  ]
        self.CfgEqP1aEn                           = bits[  4445:4446  ]
        self.EnFilt                               = bits[  4446:4510  ]
        self.RstFilt                              = bits[  4510:4574  ]
        self.CfgEqHx                              = bits[  4574:5086  ]
        self.CfgEqHp1                             = bits[  5086:5598  ]
        self.CfgEqHm1                             = bits[  5598:6110  ]
        self.EnAlu                                = bits[  6110:6174  ]
        self.RstAlu                               = bits[  6174:6238  ]
        self.CfgEqInInv                           = bits[  6238:6239  ]
        self.filler                               = '0' * 0
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct class from bits
    # -----------------------------------------------------------------------------------
    @classmethod
    def create_from_bits(cls, bits): 
        
        # Check length of bits
        if len(bits) != 6239:
            raise ValueError("Error, expecting 6239 bits, got " + str(len(bits)) + "!")
        
        # Create class
        return cls( 
            BitCountPrbs31                       = bits[     0:41    ], 
            BerCountPrbs31                       = bits[    41:697   ], 
            BerShutoffPrbs31                     = bits[   697:698   ], 
            SnapOutPrbs31                        = bits[   698:1210  ], 
            PrbsSeedGoodPrbs31                   = bits[  1210:1226  ], 
            BitCountPrbs15                       = bits[  1226:1267  ], 
            BerCountPrbs15                       = bits[  1267:1923  ], 
            BerShutoffPrbs15                     = bits[  1923:1924  ], 
            SnapOutPrbs15                        = bits[  1924:2436  ], 
            PrbsSeedGoodPrbs15                   = bits[  2436:2452  ], 
            BitCountPrbs7                        = bits[  2452:2493  ], 
            BerCountPrbs7                        = bits[  2493:3149  ], 
            BerShutoffPrbs7                      = bits[  3149:3150  ], 
            SnapOutPrbs7                         = bits[  3150:3662  ], 
            PrbsSeedGoodPrbs7                    = bits[  3662:3678  ], 
            CfgBerInInv                          = bits[  3678:3679  ], 
            CfgBerShutoffSel                     = bits[  3679:3683  ], 
            CfgBerCountEn                        = bits[  3683:3699  ], 
            CfgModeBer                           = bits[  3699:3715  ], 
            CfgSnapEn                            = bits[  3715:3731  ], 
            CfgPgen                              = bits[  3731:4307  ], 
            RstBert                              = bits[  4307:4308  ], 
            CfgEqOutEndian                       = bits[  4308:4309  ], 
            CfgEqOutInv                          = bits[  4309:4310  ], 
            EnDec                                = bits[  4310:4374  ], 
            RstDec                               = bits[  4374:4438  ], 
            CfgEqP4mEn                           = bits[  4438:4439  ], 
            CfgEqP4pEn                           = bits[  4439:4440  ], 
            CfgEqP3bEn                           = bits[  4440:4441  ], 
            CfgEqP3aEn                           = bits[  4441:4442  ], 
            CfgEqP3oEn                           = bits[  4442:4443  ], 
            CfgEqP2En                            = bits[  4443:4444  ], 
            CfgEqP1bEn                           = bits[  4444:4445  ], 
            CfgEqP1aEn                           = bits[  4445:4446  ], 
            EnFilt                               = bits[  4446:4510  ], 
            RstFilt                              = bits[  4510:4574  ], 
            CfgEqHx                              = bits[  4574:5086  ], 
            CfgEqHp1                             = bits[  5086:5598  ], 
            CfgEqHm1                             = bits[  5598:6110  ], 
            EnAlu                                = bits[  6110:6174  ], 
            RstAlu                               = bits[  6174:6238  ], 
            CfgEqInInv                           = bits[  6238:6239  ], 
            filler                               = '0' * 0)
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get write bits from class
    # -----------------------------------------------------------------------------------
    def get_write_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            # self.BitCountPrbs31,
            # self.BerCountPrbs31,
            # self.BerShutoffPrbs31,
            # self.SnapOutPrbs31,
            # self.PrbsSeedGoodPrbs31,
            # self.BitCountPrbs15,
            # self.BerCountPrbs15,
            # self.BerShutoffPrbs15,
            # self.SnapOutPrbs15,
            # self.PrbsSeedGoodPrbs15,
            # self.BitCountPrbs7,
            # self.BerCountPrbs7,
            # self.BerShutoffPrbs7,
            # self.SnapOutPrbs7,
            # self.PrbsSeedGoodPrbs7,
            self.CfgBerInInv,
            self.CfgBerShutoffSel,
            self.CfgBerCountEn,
            self.CfgModeBer,
            self.CfgSnapEn,
            self.CfgPgen,
            self.RstBert,
            self.CfgEqOutEndian,
            self.CfgEqOutInv,
            self.EnDec,
            self.RstDec,
            self.CfgEqP4mEn,
            self.CfgEqP4pEn,
            self.CfgEqP3bEn,
            self.CfgEqP3aEn,
            self.CfgEqP3oEn,
            self.CfgEqP2En,
            self.CfgEqP1bEn,
            self.CfgEqP1aEn,
            self.EnFilt,
            self.RstFilt,
            self.CfgEqHx,
            self.CfgEqHp1,
            self.CfgEqHm1,
            self.EnAlu,
            self.RstAlu,
            self.CfgEqInInv,
        ]])
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
# -------------------------------------------------------------------------------------------
