from lib.pyvantagepro2 import VantagePro2
from typing import Union
from serial import Serial
from binascii import hexlify
from time import sleep
from memory_profiler import profile



# Constants
PORT = '/dev/serial0'
BAUDRATE = 115200
TIMEOUT = 2
EOL = '\r\n'

### Connect to serial 
serial=Serial(port=PORT,baudrate=BAUDRATE,timeout=TIMEOUT)

@profile
def my_func():
    
        ### connect to VP2 USB port 
        device = VantagePro2.from_url('serial:/dev/ttyUSB_Meteo_Station:19200:8N1')
        
        ### GET current data from VP2
        data = device.get_current_data()
        
        time = data['Datetime']
        print("Time :",time)

        print("TempIn :", data['TempIn'])
        print("TempOut :",data['TempOut'])
        print("HumIn :",data['HumIn'])
        print("HumOut :",data['HumOut'])
        print("BarTrend :",data['BarTrend'])
        print("WindSpeed :",data['WindSpeed'])
        print("WindDir :",data['WindDir'])
        print("RainDay :",data['RainDay'])
        print("SolarRad :",data['SolarRad'])
        print("UV :",data['UV'])
        print("RainRate :",data['RainRate'])
        print("SunRise :",data['SunRise'])
        print("SunSet :",data['SunSet'])

        print("Barometer :",data['Barometer'])
        print("ETDay :",data['ETDay'])
        
        ###SEND VP2 data to rak811
        send(str(time)+'a'+str(data['TempIn'])
                 +'b'+str(data['TempOut'])+'c'+str(data['HumIn'])
                 +'d'+str(data['HumOut'])+'e'+str(data['BarTrend'])
                 +'f'+str(data['WindSpeed'])+'g'+str(data['WindDir'])
                 +'h'+str(data['RainDay'])+'i'+str(data['SolarRad'])
                 +'j'+str(data['UV'])+'k'+str(data['RainRate'])
                 +'l'+str(data['SunRise'])+'m'+str(data['SunSet'])+'n'+str(data['Barometer'])+'o'+str(data['ETDay'])+'p')
                 
        sleep(900)
        
        
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
    ###SEND Data Rate 5  
    #sendDR(str(5))  console=tty1 root=PARTUUID=f645bebe-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
    #sleep(5)
    my_func()