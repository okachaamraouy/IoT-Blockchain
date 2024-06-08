from lib.pyvantagepro2 import VantagePro2
from typing import Union
from serial import Serial
from binascii import hexlify
from time import sleep
import datetime

# Constants
PORT = '/dev/serial0'
BAUDRATE = 115200
TIMEOUT = 2
EOL = '\r\n'

### Connect to serial 
serial=Serial(port=PORT,baudrate=BAUDRATE,timeout=TIMEOUT)


def main():
    while True:
        ### connect to VP2 USB port
        device = VantagePro2.from_url('serial:/dev/ttyUSB_Meteo_Station:19200:8N1')
       
        ### GET current data from VP2
        data = device.get_current_data()
       
        time = data['Datetime']
        timewithoutcamma=str(time).split('.')
        replacedate = timewithoutcamma[0].replace("-","/")
        date_format = datetime.datetime.strptime(replacedate,"%Y/%m/%d %H:%M:%S")
                                         
        timestamp = datetime.datetime.timestamp(date_format)
       
        print("Time :",timestamp)
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
       
        ### SEND VP2 data to rak811
        send(str(timestamp)+'a'+str(data['TempIn'])+'b'
                  +str(data['TempOut'])+'c'+str(data['HumIn'])+'d'
                  +str(data['HumOut'])+'e'+str(data['WindSpeed'])+'f'
                  +str(data['WindDir'])+'g' +str(data['RainDay'])+'h'
                  +str(data['SolarRad'])+'i'+str(data['UV'])+'j'
                  +str(data['RainRate']) +'k'+str(data['SunRise'])+'l'
                  +str(data['SunSet'])+'m'+str(data['Barometer'])+'n'))
        sleep(840)
        

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
