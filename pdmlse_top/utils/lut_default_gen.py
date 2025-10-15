

from dataclasses import dataclass
from typing import List
import numpy as np

"""
6b-6b LUT generator for systemverilog
Systemverilog lut of size [2**6][6] 
- Two MSB bits are grey code
- Next two bits are also grey code
- Last two bits are binary code
"""

def grey_2b_decode(grey: int) -> int:
    """
    Decode 2-bit grey code to binary
    """
    if grey >= 4 or grey < 0:
        raise ValueError("Invalid grey code")
    if grey == 0:
        return 0
    if grey == 1:
        return 1
    if grey == 2:
        return 3
    if grey == 3:
        return 2

@dataclass
class Bit2b:
    val: int

    def __post_init__(self):
        if self.val >= 4 or self.val < 0:
            raise ValueError("Invalid 2-bit value")

    @classmethod
    def from_str(cls, binrep: str):
        return cls(int(binrep, 2))

    def decode_grey(self):
        return Bit2b(grey_2b_decode(self.val))

    def to_str(self):
        return np.binary_repr(self.val, width=2)

@dataclass
class Bit6b:
    val: int

    def __post_init__(self):
        if self.val >= 64 or self.val < 0:
            raise ValueError("Invalid 6-bit value")

    def to_str(self):
        return np.binary_repr(self.val, width=6)

    def split(self) -> List[Bit2b]:
        return Bit2b(self.val >> 4), Bit2b((self.val >> 2) & 0b11), Bit2b(self.val & 0b11)

    @classmethod
    def assemble(cls, b54: Bit2b, b32: Bit2b, b10: Bit2b):
        return cls((b54.val << 4) | (b32.val << 2) | b10.val)


def write_sv_array():
    """
    Write out the LUT in systemverilog format
    """
    with open("../rtl/params/dsp_fe.svh", "w") as f:
        f.write("`define LUT_DEFAULT_TABLE \\\n")
        f.write("  { \\\n")
        for i in range(64):
            # idx = 63 - i # Reverse order
            idx = i # TODO(check) don't need to reverse
            b6b = Bit6b(idx)
            b54, b32, b10 = b6b.split()
            b54_gd = b54.decode_grey()
            b32_gd = b32.decode_grey()
            b6b_decoded = Bit6b.assemble(b54_gd, b32_gd, b10)
            if idx == 0: # last
                f.write(f"    6'b{b6b_decoded.to_str()} \\\n")
            else:
                f.write(f"    6'b{b6b_decoded.to_str()}, \\\n")
        f.write("  }")

if __name__ == "__main__":
    write_sv_array()

