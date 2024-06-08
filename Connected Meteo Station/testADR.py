from lib.pyvantagepro2 import VantagePro2
from typing import Union
from serial import Serial
from binascii import hexlify
from time import sleep

# Constants
PORT = '/dev/ttyAMA0'
BAUDRATE = 115200
TIMEOUT = 2
EOL = '\r\n'
serial=Serial(port=PORT,baudrate=BAUDRATE,timeout=TIMEOUT)
def main():
    while True:
        device = VantagePro2.from_url('serial:/dev/ttyUSB_Meteo_Station:19200:8N1')
        
        
        data = device.get_current_data()
        time = data['Datetime']
        print(time)

        print(data['TempIn'])
        print(data['TempOut'])
        print(data['HumIn'])
        print(data['HumOut'])
        print(data['BarTrend'])
        print(data['WindSpeed'])
        print(data['WindDir'])
        print(data['RainDay'])
        print(data['SolarRad'])
        print(data['UV'])
        print(data['RainRate'])
        print(data['SunRise'])
        print(data['SunSet'])
        print(data['Barometer'])
        print(data['ETDay'])
        sendDR(str(5))
        sleep(50)
        send(str(time)+'a'+str(data['TempIn'])
                  +'b')
        sleep(30)
        
def send(data: Union[bytes, str], port: int = 1) -> None:
    if type(data) is not bytes:
        data = (bytes)(data, 'utf-8')
            
    data = hexlify(data).decode('ascii')
    send_command(f'send=lora:{port}:{data}')
    
def sendDR(data: Union[bytes, str]) -> None:
    if type(data) is not bytes:
        data = (bytes)(data, 'utf-8')
            
    data = hexlify(data).decode('ascii')
    send_command(f'set_config=lora:dr:{data}')
            
def send_string(string):
    serial.write((bytes)(string, 'utf-8'))

def send_command(command):
    send_string('at+{0}\r\n'.format(command))
                                                                                                                                                                                                                                                                                                                                           
if __name__ == '__main__':
    main()

