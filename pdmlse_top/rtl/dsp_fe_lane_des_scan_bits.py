# -------------------------------------------------------------------------------------------
# This file was auto generated with the command:
# scan-to-python.pl scan_defines/dsp_fe_lane_des_scan.cfg ../dsp_fe_lane_des_scan_bits.py
# Config file contents:
#                          Field Name       Dir     Width      Mult
# -------------------------------------------------------------------------------------------
#                                  En         W         1         1
#                            EnRetime         W         1         1
#                           RstRetime         W         1         1
#
# Scan Chain Module Name = dsp_fe_lane_des_scan
# Scanchain Length = 3
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
#    Class dsp_fe_lane_des_scan
# -------------------------------------------------------------------------------------------
class dsp_fe_lane_des_scan:

    # -----------------------------------------------------------------------------------
    #    Constructor
    # -----------------------------------------------------------------------------------
    def __init__(self, 
        En                                   = '0' * 1     , 
        EnRetime                             = '0' * 1     , 
        RstRetime                            = '0' * 1     , 
        filler                               = '0' * 0     ):

        self.filler                               = filler
        self.En                                   = En
        self.EnRetime                             = EnRetime
        self.RstRetime                            = RstRetime
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get scan chain length
    # -----------------------------------------------------------------------------------
    @staticmethod
    def length(): 
        return 3

    @staticmethod
    def length_static(): 
        return 3

    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct bits from class
    # -----------------------------------------------------------------------------------
    def to_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.RstRetime,
            self.EnRetime,
            self.En,
        ]])
        
        # Output check
        if len(bits) != self.length():
            raise ValueError("Error, expecting 3 bits, got " + str(len(bits)) + "!")
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Update class from bits
    # -----------------------------------------------------------------------------------
    def from_bits(self, bits): 
        
        # Check length of bits
        if len(bits) != 3:
            raise ValueError("Error, expecting 3 bits, got " + str(len(bits)) + "!")
        
        self.RstRetime                            = bits[     0:1     ]
        self.EnRetime                             = bits[     1:2     ]
        self.En                                   = bits[     2:3     ]
        self.filler                               = '0' * 0
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Construct class from bits
    # -----------------------------------------------------------------------------------
    @classmethod
    def create_from_bits(cls, bits): 
        
        # Check length of bits
        if len(bits) != 3:
            raise ValueError("Error, expecting 3 bits, got " + str(len(bits)) + "!")
        
        # Create class
        return cls( 
            RstRetime                            = bits[     0:1     ], 
            EnRetime                             = bits[     1:2     ], 
            En                                   = bits[     2:3     ], 
            filler                               = '0' * 0)
            
    # -----------------------------------------------------------------------------------
    
    # -----------------------------------------------------------------------------------
    #    Get write bits from class
    # -----------------------------------------------------------------------------------
    def get_write_bits(self): 
        
        bits = ''.join([bit_val for bit_val in [
            self.RstRetime,
            self.EnRetime,
            self.En,
        ]])
        
        # Return output
        return bits
        
    # -----------------------------------------------------------------------------------
    
# -------------------------------------------------------------------------------------------
