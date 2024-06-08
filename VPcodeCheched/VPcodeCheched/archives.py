from lib.pyvantagepro2 import VantagePro2
from typing import Union
from serial import Serial
from binascii import hexlify
from time import sleep

# Constants
PORT = '/dev/ttyS0'
BAUDRATE = 115200
TIMEOUT = 2
EOL = '\r\n'
def main():
    while True:
        device = VantagePro2.from_url('serial:/dev/ttyUSB_Meteo_Station:19200:8N1')
        data = device.get_archives(datetime(2022, 5, 10, 6, 0, 0),datetime.now())
        
        data.to_csv()
       


