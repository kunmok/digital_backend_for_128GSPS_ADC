
from dataclasses import Field, dataclass, field
from enum import Enum, auto
import re
from typing import Optional

"""
ana_pin_name given as: (ts: 0-15, adc_idx: 0-5)
- data pin: odat_deser{ts}<adc_idx>
- rst pin: orstb_deser<{ts}>
- clk pin: oclk_deser<{ts}>
dig_pin_name as:
- data pin: i_ana_dat_lad_fe[{lane}][{adc}][{des}] 
-- at ("lane"+"des"*16)-th timestep where lane is 0-15, des is 0-1
-- == ts = lane + des * 16, in other words, des = ts // 16, lane = ts % 16
- clk pin: i_clk_ref_bdl[ts]
- rst pin: i_rstb_ref_bdl[ts]
"""

class FePinType(Enum):
    data = auto()
    rst = auto()
    clk = auto()

# ana_pin_regex = r"o(dat|rstb|clk)_deser(\d+)<(\d+)>"
ana_pin_regex = r"o(dat|rstb|clk)_deser(?:<(\d+)>|(\d+)<(\d+)>)"

def parse_type_ana_pin_name(ana_pin_name: str) -> FePinType:
    match = re.match(ana_pin_regex, ana_pin_name)
    if match:
        pin_type = match.group(1)
        if pin_type == "dat":
            return FePinType.data
        elif pin_type == "rstb":
            return FePinType.rst
        elif pin_type == "clk":
            return FePinType.clk
        else:
            raise ValueError(f"Unknown pin type in ana_pin_name: {ana_pin_name}")
    raise ValueError(f"Invalid ana_pin_name: {ana_pin_name}")

def parse_ts_ana_pin_name(ana_pin_name: str) -> int:
    pin_type = parse_type_ana_pin_name(ana_pin_name)
    match = re.match(ana_pin_regex, ana_pin_name)
    if match:
        if pin_type == FePinType.data and match.group(3) is not None:
            return int(match.group(3))
        elif (pin_type == FePinType.rst or pin_type == FePinType.clk) and match.group(2) is not None:
            return int(match.group(2))
    raise ValueError(f"Invalid ana_pin_name: {ana_pin_name}")

def parse_adc_idx_ana_pin_name(ana_pin_name: str) -> Optional[int]:
    pin_type = parse_type_ana_pin_name(ana_pin_name)
    match = re.match(ana_pin_regex, ana_pin_name)
    if match and pin_type == FePinType.data and match.group(4) is not None:
        return int(match.group(4))
    elif pin_type == FePinType.clk or pin_type == FePinType.rst:
        return None
    raise ValueError(f"Invalid or missing adc_idx in ana_pin_name: {ana_pin_name}")


def dig_name_formatter(ts: int, adc_idx: int, pin_type: FePinType) -> str:
    if pin_type == FePinType.data:
        lane = ts % 16
        des = ts // 16
        return f"i_ana_dat_lad_fe[{lane}][{adc_idx}][{des}]"
    elif pin_type == FePinType.rst:
        return f"i_rstb_ref_bdl[{ts}]"
    elif pin_type == FePinType.clk:
        return f"i_clk_ref_bdl[{ts}]"
    else:
        raise ValueError(f"Unknown pin type: {pin_type}")


@dataclass
class DspAnaPin:
    ana_pin_name: str
    yloc: float
    yoffset: float
    ts: int = field(init=False)
    adc_idx: Optional[int] = field(init=False)
    pin_type: FePinType = field(init=False)

    def __post_init__(self):
        self.pin_type = parse_type_ana_pin_name(self.ana_pin_name)
        self.ts = parse_ts_ana_pin_name(self.ana_pin_name)
        self.adc_idx = parse_adc_idx_ana_pin_name(self.ana_pin_name)

    def __str__(self):
        return f"{self.ana_pin_name}"

    def __repr__(self):
        return f"{self.ana_pin_name}"

    def pprint(self):
        print(f"ana_pin_name: {self.ana_pin_name}")
        print(f"yloc: {self.yloc}")
        print(f"yoffset: {self.yoffset}")
        print(f"timestep: {self.ts}")
        print(f"adc_idx: {self.adc_idx}")
        print(f"pin_type: {self.pin_type}")


@dataclass
class DspFePin:
    dig_pin_name: str
    lane: int
    des: int
    adc_idx: int
    yloc: float
    yoffset: float
    ana_pin: Optional[DspAnaPin] = None
    yloc_rel: float = field(init=False)

    def __post_init__(self):
        self.yloc_rel = self.yloc - self.yoffset

    @classmethod
    def from_ana_pin(cls, ana_pin: DspAnaPin):
        lane = ana_pin.ts % 16
        des = ana_pin.ts // 16
        adc_idx = ana_pin.adc_idx
        yloc = ana_pin.yloc
        yoffset = ana_pin.yoffset
        dig_pin_name = dig_name_formatter(ana_pin.ts, ana_pin.adc_idx, ana_pin.pin_type)
        return cls(dig_pin_name, lane, des, adc_idx, yloc, yoffset, ana_pin)
    

class DspFePinArray:
    def __init__(self, fe_pins: list[DspFePin]):
        self.fe_pins = fe_pins

    @classmethod
    def from_pin_arr(cls, pinname_arr, pinloc_arr, yoffset: float):
        # interface with kunmo's code
        fe_pins = []
        for ana_pin_name, yloc in zip(pinname_arr, pinloc_arr):
            ana_pin = DspAnaPin(ana_pin_name, yloc, yoffset)
            fe_pins.append(DspFePin.from_ana_pin(ana_pin))
        return cls(fe_pins)


def tcl_edit_pin(pin_name: str, yloc: float) -> str:
    hinst_name = "dsp_fe"
    layer = "m4"
    side = "left"
    assign = f"0.0 {yloc:.2f}"

    cmd = f"edit_pin"
    cmd += f" -fixed_pin"
    cmd += f" -pin {pin_name}"
    cmd += f" -hinst {hinst_name}"
    cmd += f" -layer {{ {layer} }}"
    cmd += f" -side {side}"
    cmd += f" -assign {{ {assign} }}"
    cmd += f" -fix_overlap 0"

    return cmd

def write_tcl_pinloc(dsp_fe_pin_arr: DspFePinArray):
    header = "set_db assign_pins_edit_in_batch true"

    for fe_pin in dsp_fe_pin_arr.fe_pins:
        print(tcl_edit_pin(fe_pin.dig_pin_name, fe_pin.yloc_rel))

    tail = "set_db assign_pins_edit_in_batch false"


# if __name__ == "__main__":
#     from utils.kunmo.pin_location_calc import adc_bottom_loc, pinloc_arr, pinname_arr
#
#     # adc_to_fe_offset = - 200
#     adc_to_fe_offset = - 165.96
#
#     pin_offset = adc_bottom_loc + adc_to_fe_offset
#
#     dsp_fe_pin_arr = DspFePinArray.from_pin_arr(pinname_arr, pinloc_arr, pin_offset)
#
#     write_tcl_pinloc(dsp_fe_pin_arr)

