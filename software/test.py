import serial
import time
import binascii

sleep_time=0.1

def pixel_set(ser, ix, iy):
    data = bytearray(2)
    data[0] = 0x10
    data[1] = ix << 4 | iy
    # print(binascii.b2a_hex(data))
    ser.write(data)
    ser.flush()

def pixel_clr(ser, ix, iy):
    data = bytearray(2)
    data[0] = 0x20
    data[1] = ix << 4 | iy
    # print(binascii.b2a_hex(data))
    ser.write(data)
    ser.flush()
    
# 4613/10 = 461baud
ser = serial.Serial(
	port='/dev/ftdi5',
	baudrate=461
)

# reset
ser.write(b"\xff\xff")

# clear display
ser.write(b"\x30")

# colour blue
ser.write(b"\x04")

# across the top
iy=0
for ix in range(16):
    pixel_set(ser, ix, iy)
    time.sleep(sleep_time)
    pixel_clr(ser, ix, iy)

# down the left side
for iy in range(1, 8, 1):
    pixel_set(ser, ix, iy)
    time.sleep(sleep_time)
    pixel_clr(ser, ix, iy)
    
# across the bottom
for ix in range(14, -1, -1):
    pixel_set(ser, ix, iy)
    time.sleep(sleep_time)
    pixel_clr(ser, ix, iy)

# up the right side
for iy in range(6, 0, -1):
    pixel_set(ser, ix, iy)
    time.sleep(sleep_time)
    pixel_clr(ser, ix, iy)

# all pixels
for iy in range(8):
    for ix in range(16):
        pixel_set(ser, ix, iy)
        time.sleep(sleep_time)
        pixel_clr(ser, ix, iy)

    
ser.close()
