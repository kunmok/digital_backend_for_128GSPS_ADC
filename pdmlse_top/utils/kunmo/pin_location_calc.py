"""
    outputs CSV file containing TDC's pin names and their coordinates. 
"""


import numpy as np
import pandas as pd 

# adc_bottom_loc = 1007.64        # y-axis
adc_bottom_loc = 957.24
x_axis = 746.0685

data_order = np.array([0, 8, 12, 4, 13, 5, 9, 1, 15, 7, 11, 3, 14, 6, 10, 2]) 

dist_clk_passage = 4.86
dist_pin00 = 0.9 
dist_pin55 = 1.26 

data0_pin5to0 = np.array([2.97, 3.42, 4.32, 4.77, 5.94, 6.39, 7.47, 8.01, 9.36, 9.81, 10.8, 11.25, 12.42, 12.87])
data0_pin5to0_diff = np.diff(data0_pin5to0)
data0_pin0to5_diff = np.flip(data0_pin5to0_diff) 
data0_pin5to0_diff = np.insert(data0_pin5to0_diff, 0, 0)
data0_pin0to5_diff = np.insert(data0_pin0to5_diff, 0, 0)

pinloc_arr = np.zeros(len(data_order)*(12 + 2))        # 12 for 6*2 bits (via deserialization) and 2 bits for RSTB and CLK
pinname_arr = ['']*(len(data_order)*(12 + 2))
pinloc_prev = 2.97 + adc_bottom_loc

for dx in range(0, len(data_order)):
    d_order = data_order[dx]
    if dx > 0: 
        if np.mod(dx, 4) == 2: 
            # crosses CLK passage
            pinloc_prev = dist_clk_passage 
        elif np.mod(dx, 2) == 1: 
            # <0> to <0> 
            pinloc_prev = dist_pin00 
        elif np.mod(dx, 2) == 0: 
            # <5> to <5> 
            pinloc_prev = dist_pin55

    interleave_cnt = dx*14
    pin_cnt = 0 

    if np.mod(dx, 2) == 1:
        pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin0to5_diff[pin_cnt] + pinloc_prev
        pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin0to5_diff[pin_cnt + 1]
        # print(f"odat_deser{d_order}<{0}>, \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
        # print(f"odat_deser{d_order+16}<{0}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
        pinname_arr[interleave_cnt + pin_cnt]       = 'odat_deser'+str(d_order)+'<0>'
        pinname_arr[interleave_cnt + pin_cnt + 1]   = 'odat_deser'+str(d_order+16)+'<0>'
        pin_cnt += 2
        for bx in range(1, 6):
            pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin0to5_diff[pin_cnt]
            pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin0to5_diff[pin_cnt + 1]
            # print(f"odat_deser{d_order}<{bx}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
            # print(f"odat_deser{d_order+16}<{bx}>, \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
            pinname_arr[interleave_cnt + pin_cnt]       = 'odat_deser'+str(d_order)+'<'+str(bx)+'>'
            pinname_arr[interleave_cnt + pin_cnt + 1]   = 'odat_deser'+str(d_order+16)+'<'+str(bx)+'>'
            pin_cnt += 2

            if bx == 2: 
                pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin0to5_diff[pin_cnt]
                pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin0to5_diff[pin_cnt + 1]
                # print(f"oclk_deser<{d_order}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
                # print(f"orstb_deser<{d_order}>,   \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
                pinname_arr[interleave_cnt + pin_cnt]       = 'oclk_deser<'+str(d_order)+'>'
                pinname_arr[interleave_cnt + pin_cnt + 1]   = 'orstb_deser<'+str(d_order)+'>'
                pin_cnt += 2
    else: 
        pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin5to0_diff[pin_cnt] + pinloc_prev
        pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin5to0_diff[pin_cnt + 1]
        # print(f"odat_deser{d_order+16}<{5}>, \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
        # print(f"odat_deser{d_order}<{5}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
        pinname_arr[interleave_cnt + pin_cnt]     = 'odat_deser'+str(d_order+16)+'<5>'
        pinname_arr[interleave_cnt + pin_cnt + 1] = 'odat_deser'+str(d_order)+'<5>'
        pin_cnt += 2 
        for bx in range(4, -1, -1):
            pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin5to0_diff[pin_cnt]
            pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin5to0_diff[pin_cnt + 1]
            # print(f"odat_deser{d_order+16}<{bx}>, \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
            # print(f"odat_deser{d_order}<{bx}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
            pinname_arr[interleave_cnt + pin_cnt]     = 'odat_deser'+str(d_order+16)+'<'+str(bx)+'>'
            pinname_arr[interleave_cnt + pin_cnt + 1] = 'odat_deser'+str(d_order)+'<'+str(bx)+'>'
            pin_cnt += 2 

            if bx == 3:
                pinloc_arr[interleave_cnt + pin_cnt] = pinloc_arr[interleave_cnt + pin_cnt - 1] + data0_pin5to0_diff[pin_cnt]
                pinloc_arr[interleave_cnt + pin_cnt + 1] = pinloc_arr[interleave_cnt + pin_cnt] + data0_pin5to0_diff[pin_cnt + 1]
                # print(f"orstb_deser<{d_order}>,   \t pin location = {pinloc_arr[interleave_cnt + pin_cnt]:.4f} um")
                # print(f"oclk_deser<{d_order}>,    \t pin location = {pinloc_arr[interleave_cnt + pin_cnt + 1]:.4f} um")
                pinname_arr[interleave_cnt + pin_cnt]     = 'orstb_deser<'+str(d_order)+'>'
                pinname_arr[interleave_cnt + pin_cnt + 1] = 'oclk_deser<'+str(d_order)+'>'
                pin_cnt += 2
pinloc_arr = np.round(pinloc_arr, decimals=6)

# creating a dataframe 
df = pd.DataFrame({
    'Pin Name': pinname_arr,
    'Pin Location (X)': x_axis,
    'Pin Location (Y)': pinloc_arr
})

# Saving the DataFrame to a CSV file
filename = 'tdc_pin_data.csv'
# df.to_csv(filename, index=False)

# print(f"DataFrame saved to {filename}.csv")
