# -------------------------------------------------------------------------------------------
# This file was auto generated with the command:
# scan-to-python.pl scan_defines/dsp_fe_lane_scan.cfg ../dsp_fe_lane_scan_bits.py
# Config file contents:
#                          Field Name       Dir     Width      Mult
# -------------------------------------------------------------------------------------------
#                             RstGlue         W         1         1
#                              RstLut         W         1         1
#                              EnGlue         W         1         1
#                               EnLut         W         1         1
#                      CfgLutModeLoad         W         1         1
#                      CfgLutModeSeed         W         1         1
#                   CfgLutModeMission         W         1         1
#                         CfgLutTable         W       384         1
#
# Scan Chain Module Name = dsp_fe_lane_scan
# Scanchain Length = 391
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
#    Class dsp_fe_lane_scan
# -------------------------------------------------------------------------------------------
class dsp_fe_lane_scan:

    # -----------------------------------------------------------------------------------
    #    Constructor
    # -----------------------------------------------------------------------------------
    def __init__(self, 
        RstGlue                              = '0' * 1     , 
        RstLut                               = '0' * 1     , 
        EnGlue                               = '0' * 1     , 
        EnLut                                = '0' * 1     , 
        CfgLutModeLoad                       = '0' * 1     , 
        CfgLutModeSeed                       = '0' * 1     , 
        CfgLutModeMission                    = '0' * 1     , 
        CfgLutTable                          = '0' * 384   , 
        filler                               = '0' * 0     ):

        self.filler                               = filler
        self.RstGlue                              = RstGlue
        self.RstLut                               = RstLut
        self.EnGlue                               = EnGlue
        self.EnLut                                = EnLut
        self.CfgLutModeLoad                       = CfgLutModeLoad
        self.CfgLutModeSeed                       = CfgLutModeSeed
        self.CfgLutModeMission                    = CfgLutModeMission
        self.CfgLutTable                          = CfgLutTable
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get scan chain length
    # -----------------------------------------------------------------------------------
    @staticmethod
    def length(): 
        return 391

    @staticmethod
    def length_static(): 
        return 391

    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct bits from class
    # -----------------------------------------------------------------------------------
    def to_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.CfgLutTable,
            self.CfgLutModeMission,
            self.CfgLutModeSeed,
            self.CfgLutModeLoad,
            self.EnLut,
            self.EnGlue,
            self.RstLut,
            self.RstGlue,
        ]])
        
        # Output check
        if len(bits) != self.length():
            raise ValueError("Error, expecting 391 bits, got " + str(len(bits)) + "!")
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Update class from bits
    # -----------------------------------------------------------------------------------
    def from_bits(self, bits): 
        
        # Check length of bits
        if len(bits) != 391:
            raise ValueError("Error, expecting 391 bits, got " + str(len(bits)) + "!")
        
        self.CfgLutTable                          = bits[     0:384   ]
        self.CfgLutModeMission                    = bits[   384:385   ]
        self.CfgLutModeSeed                       = bits[   385:386   ]
        self.CfgLutModeLoad                       = bits[   386:387   ]
        self.EnLut                                = bits[   387:388   ]
        self.EnGlue                               = bits[   388:389   ]
        self.RstLut                               = bits[   389:390   ]
        self.RstGlue                              = bits[   390:391   ]
        self.filler                               = '0' * 0
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct class from bits
    # -----------------------------------------------------------------------------------
    @classmethod
    def create_from_bits(cls, bits): 
        
        # Check length of bits
        if len(bits) != 391:
            raise ValueError("Error, expecting 391 bits, got " + str(len(bits)) + "!")
        
        # Create class
        return cls( 
            CfgLutTable                          = bits[     0:384   ], 
            CfgLutModeMission                    = bits[   384:385   ], 
            CfgLutModeSeed                       = bits[   385:386   ], 
            CfgLutModeLoad                       = bits[   386:387   ], 
            EnLut                                = bits[   387:388   ], 
            EnGlue                               = bits[   388:389   ], 
            RstLut                               = bits[   389:390   ], 
            RstGlue                              = bits[   390:391   ], 
            filler                               = '0' * 0)
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get write bits from class
    # -----------------------------------------------------------------------------------
    def get_write_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.CfgLutTable,
            self.CfgLutModeMission,
            self.CfgLutModeSeed,
            self.CfgLutModeLoad,
            self.EnLut,
            self.EnGlue,
            self.RstLut,
            self.RstGlue,
        ]])
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
# -------------------------------------------------------------------------------------------
