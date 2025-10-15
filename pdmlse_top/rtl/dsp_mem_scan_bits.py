# -------------------------------------------------------------------------------------------
# This file was auto generated with the command:
# scan-to-python.pl scan_defines/dsp_mem_scan.cfg ../dsp_mem_scan_bits.py
# Config file contents:
#                          Field Name       Dir     Width      Mult
# -------------------------------------------------------------------------------------------
#                           RetimeRst         W         1         1
#                            BankWRst         W         8         1
#                            BankRRst         W         8         1
#                               FsRst         W         1         1
#                            RetimeEn         W         1         1
#                              BankEn         W         8         1
#                                FsEn         W         1         1
#                      CfgModeRUpdate         W         1         1
#                       CfgModeWShift         W         1         1
#                       CfgModeRShift         W         1         1
#                       CfgFsModeLoad         W         1         1
#                       CfgFsSyncWord         W        64         1
#
# Scan Chain Module Name = dsp_mem_scan
# Scanchain Length = 96
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
#    Class dsp_mem_scan
# -------------------------------------------------------------------------------------------
class dsp_mem_scan:

    # -----------------------------------------------------------------------------------
    #    Constructor
    # -----------------------------------------------------------------------------------
    def __init__(self, 
        RetimeRst                            = '0' * 1     , 
        BankWRst                             = '0' * 8     , 
        BankRRst                             = '0' * 8     , 
        FsRst                                = '0' * 1     , 
        RetimeEn                             = '0' * 1     , 
        BankEn                               = '0' * 8     , 
        FsEn                                 = '0' * 1     , 
        CfgModeRUpdate                       = '0' * 1     , 
        CfgModeWShift                        = '0' * 1     , 
        CfgModeRShift                        = '0' * 1     , 
        CfgFsModeLoad                        = '0' * 1     , 
        CfgFsSyncWord                        = '0' * 64    , 
        filler                               = '0' * 0     ):

        self.filler                               = filler
        self.RetimeRst                            = RetimeRst
        self.BankWRst                             = BankWRst
        self.BankRRst                             = BankRRst
        self.FsRst                                = FsRst
        self.RetimeEn                             = RetimeEn
        self.BankEn                               = BankEn
        self.FsEn                                 = FsEn
        self.CfgModeRUpdate                       = CfgModeRUpdate
        self.CfgModeWShift                        = CfgModeWShift
        self.CfgModeRShift                        = CfgModeRShift
        self.CfgFsModeLoad                        = CfgFsModeLoad
        self.CfgFsSyncWord                        = CfgFsSyncWord
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get scan chain length
    # -----------------------------------------------------------------------------------
    @staticmethod
    def length(): 
        return 96

    @staticmethod
    def length_static(): 
        return 96

    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct bits from class
    # -----------------------------------------------------------------------------------
    def to_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.CfgFsSyncWord,
            self.CfgFsModeLoad,
            self.CfgModeRShift,
            self.CfgModeWShift,
            self.CfgModeRUpdate,
            self.FsEn,
            self.BankEn,
            self.RetimeEn,
            self.FsRst,
            self.BankRRst,
            self.BankWRst,
            self.RetimeRst,
        ]])
        
        # Output check
        if len(bits) != self.length():
            raise ValueError("Error, expecting 96 bits, got " + str(len(bits)) + "!")
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Update class from bits
    # -----------------------------------------------------------------------------------
    def from_bits(self, bits): 
        
        # Check length of bits
        if len(bits) != 96:
            raise ValueError("Error, expecting 96 bits, got " + str(len(bits)) + "!")
        
        self.CfgFsSyncWord                        = bits[     0:64    ]
        self.CfgFsModeLoad                        = bits[    64:65    ]
        self.CfgModeRShift                        = bits[    65:66    ]
        self.CfgModeWShift                        = bits[    66:67    ]
        self.CfgModeRUpdate                       = bits[    67:68    ]
        self.FsEn                                 = bits[    68:69    ]
        self.BankEn                               = bits[    69:77    ]
        self.RetimeEn                             = bits[    77:78    ]
        self.FsRst                                = bits[    78:79    ]
        self.BankRRst                             = bits[    79:87    ]
        self.BankWRst                             = bits[    87:95    ]
        self.RetimeRst                            = bits[    95:96    ]
        self.filler                               = '0' * 0
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct class from bits
    # -----------------------------------------------------------------------------------
    @classmethod
    def create_from_bits(cls, bits): 
        
        # Check length of bits
        if len(bits) != 96:
            raise ValueError("Error, expecting 96 bits, got " + str(len(bits)) + "!")
        
        # Create class
        return cls( 
            CfgFsSyncWord                        = bits[     0:64    ], 
            CfgFsModeLoad                        = bits[    64:65    ], 
            CfgModeRShift                        = bits[    65:66    ], 
            CfgModeWShift                        = bits[    66:67    ], 
            CfgModeRUpdate                       = bits[    67:68    ], 
            FsEn                                 = bits[    68:69    ], 
            BankEn                               = bits[    69:77    ], 
            RetimeEn                             = bits[    77:78    ], 
            FsRst                                = bits[    78:79    ], 
            BankRRst                             = bits[    79:87    ], 
            BankWRst                             = bits[    87:95    ], 
            RetimeRst                            = bits[    95:96    ], 
            filler                               = '0' * 0)
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get write bits from class
    # -----------------------------------------------------------------------------------
    def get_write_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.CfgFsSyncWord,
            self.CfgFsModeLoad,
            self.CfgModeRShift,
            self.CfgModeWShift,
            self.CfgModeRUpdate,
            self.FsEn,
            self.BankEn,
            self.RetimeEn,
            self.FsRst,
            self.BankRRst,
            self.BankWRst,
            self.RetimeRst,
        ]])
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
# -------------------------------------------------------------------------------------------
