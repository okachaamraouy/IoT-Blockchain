# A Novel Library for Connecting Davis Vantage Pro 2 Weather Stations to the Internet via Single Board Computers with Minimal Resources.
Meteorological stations are extensively used for gathering accurate real-time data, which is vital in smart and precision agriculture. 
This work aims to make Davis Vantage Pro2 (VP2) weather station data accessible in real-time by creating a simple library for Single-Board Computers (SBCs) with operating systems based on Linux, 
regarding minimization of resources such as RAM, CPU, and power computing. This project aims to surpass the capabilities of the WeeWX weather system,
which is infeasible to implement on various types of SBCs with minimal resources. Moreover, WeeWX does not allow developers to configure it as needed manually.
This solution renders the VP2 weather station a flexible end device in the Internet of Things (IoT) networks. The library was developed as a novel weather station real-time data acquisition, to facilitate communication with the VP2 console.
In this work, we will get into steps to implement the solution, including development modeling of the library to visualize and design our system, the practical realization of the proposed system, and a remote web application example to visualize VP2 weather station real-time data.

The weather station is mainly used to measure and forecast weather conditions. However, they can also be used for private measurements, specifically in precision agriculture. In addition,
it is an important thing that helps farms of any size to manage their crop yield more efficiently, also collects meteorological and climatic conditions surrounding the farm to protect crops from frost damage or any other risks associated with adverse weather conditions, and provides data to make irrigation decisions. Nowadays, it is very necessary to set up weather stations in remote areas that will provide data in RT as part of collaborative resources for agricultural interventions and irrigation programs. Davis VP2 is one of the best high-quality
weather stations offering a wide range of options, and sensors that can be mounted separately from each other. It provides more accurate and reliable weather monitoring in the harshest environments, delivering real-time data measurements, and is usually used in most scientific agriculture research. To facilitate the communication with VP2 console, there are free and open-source software programs that interact with various weather stations to produce charts, reports, and web pages, such as WeeWX, Cumulus MX, Wview, Pywws, etc. Among them, we find that WeeWX is the most successful, and widely used around the world because it gives the possibility to connect the VP2 console using a USB port or WiFi without problems. But when running this software on an SBC, many processes are running in the backend, which requires a large RAM memory, and a higher CPU clock speed, which increases energy consumption. In addition, to access weather data via WeeWX we are obligated to access the last record of the WeeWX SQLite database, which is not the appropriate solution for real-time devices within the IoT infrastructure. We can also have data acquisition by WeatherLink software provided by Davis Instruments, which is only available for Windows, and version Mac, and transfer weather data to a Personal Computer (PC). Hence, developing this solution as part of Intelligent-Irrigation-as-a-Service (2IaaS) which recognizes the vast number of irrigation technologies that can be delivered as a remote access service, and the solution
provides extraction of all the data from the VP2 weather station via a simple program running on SBC, with the ability to use it freely in IoT architecture.

# Materials aspect
To build a robust and reliable meteo station for IoT applications, VP2 Integrated Sensor Suite (ISS) was used to collect outside weather data in real-time, this unit includes outside humidity and temperature sensors protected by a passive radiation shield against solar radiation and other sources of radiated and reflected heat, rain gauge smart sensor, anemometer as a single package for wind speed and direction measurements, UV index sensor to measure global solar UV irradiance by measuring the sunburning portion of the UV spectrum, and Solar Radiation sensors to measure solar radiation for evapotranspiration and THSW index. Also, other sensors provided by Davis Instruments can be added easily, and separately from each other, such
as a leaf wetness sensor, soil moisture sensor, and sonic anemometer to measure wind direction and speed with no moving parts using sonic pulses to detect air movement, stainless steel temperature probe with Registered Jack (RJ) connector or two-wire termination, etc. The other unit includes a VP2 console equipped with an indoor temperature and humidity sensor, and a barometric pressure sensor to measure atmospheric pressure. The outside weather data is sent to a VP2 console using a specific cable by Davis Instruments to ensure that weather data is delivered to a console continuously without corruption, which offers the best high accuracy and reliable weather monitoring in RT data updates every 2 seconds. In addition, a third
component is required, such as WeatherLink Serial-Port Data Logger to connect the VP2 console to SBC using serial communication. The built-in library developed allows SBCs to access real-time weather data measurements and send them simultaneously to the cloud and a Network Attached Storage (NAS) server, as shown in the following figure.

![figure1](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/f74c492f-80a5-4e8a-916a-21671bf57f41)

In order to execute the developed library using the embedded operating system based on the Linux with appropriate SBC, without constraints of RAM, and CPU clock speed, We take into consideration controlling the growth of complexity of large embedded systems and facilitating the building of understandable systems.

# Software Modeling aspect

The most part notation of the UML is simple to understand in nature graphical, explaining how elements collaborate together over time to achieve functional goals, and the complex systems can be easily modeled with three core, class diagrams, statecharts, and sequence diagrams to represent the details and validate runtime scenarios, we chose a UML sequence diagram, as our system has two essential use cases, how does the VP2 console wake up?, and how can we get real-time data from the VP2 console?. Besides, to model the objects of our system, display the relation-ships between the objects, and describe what those objects do and the services that they provide, we use class diagram.

# The console waking up sequence diagram

Before sending commands to the console, the wake-up procedure should be performed as shown in the following figure. After, the SBC serial port is opened and ready to communicate by sending and receiving data, the function Wake Up() sends line feed character ”\n”, and listens for line feed and carriage returned response characters ”\n\r”, which confirm the waking up of the console. If there is no response in intervals of 2 seconds then we try again two times, a total of 3 attempts until the console has woken up, if it continues not responding, then signal connection exceptions. After the console wakes up, it stays awake for 2 minutes.


![figure2](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/3aa28afa-713a-4154-b8f9-c53560784ed9)


# Getting the console real-time data sequence diagram

After the console has woken up, we get current data in real-time by sending to the console, that we need to access the LOOP Packet that contains 99 bytes long of real-time data as shown in the following figure, The station console responds first with Acknowledge <ACK> =‘\x06’, then sends one binary data LOOP packet every two seconds. And the console goes to sleep immediately to conserve battery power, just in case we access the LOOP packet. If there is no response, not receiving Acknowledge, we try again two times with intervals of 2 seconds, a total of 3 attempts, until the console responds first with Acknowledge <ACK>. If it continues not responding, then signal connection exceptions. To receive each sensor’s data we verify that there is no error detected using the Cyclic Redundancy Check (CRC-CCITT standard) that the console used, then parse the data to get each field of data with the correct value, using the size and offset from LOOP Data formats.

![figure3](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/7c86c24d-a17e-4d73-bd69-27aba66986e6)

# The library class diagram

The library cantains the VantageProException class to manage exceptions, and VantagePro class which is composed of LoopPacketParser class, and VantageCRC class. As explained below and
shown in the following figure.

![figure4](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/e555db23-ccda-4d58-bc48-ebae0cf3e2f9)

# Experimentation

The installation of professional weather stations becomes necessary in local or remote areas as part of collaborative real-time resources, with the ability to accept new technological revolutions. In this section, we will provide a comprehensive practical overview of our proposed system in application scenarios through the implementation of the example IoT architecture shown in the following figure in order to evaluate its reliability and effectiveness.


![figure5](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/195ff108-e2de-47c9-a26a-71de912d1e8f)

# VP2 Console

VP2 weather station gives updated weather information locally. VP2 console allows access to analyze, monitor, and visualize current data in real-time, calculated indexes, historical data, and graphing. It provides easy access to graphs of the last 24 hours of data, last month, or the previous year. Also, the VP2 console gives the ability to set up 22 alarms in order to alert extreme critical points for some weather conditions. VP2 console is a practical unit with an aesthetic and easy to understand display. Also, equipped with a serial port giving access to real-time weather conditions that we are interested. The figure below shows the experimental result of the VP2 console.


![figure6](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/33e8064b-949a-414d-a359-f8d9b13e2f00)

# Web application example for visualization VP2 weather conditions

To ensure the required reliability and functionality of the developed library as expected from IoT applications with the ability to accept emerging technological revolution, The above application architecture has been created and designed as a responsive web application that supports mobile and web access for real-time weather station data acquisition, coming from VP2 sensors such as humidity, temperature, rain rate, daily rain, UV, radiation, wind direction, wind speed, barometer, dew point, time, sunrise, and sunset. MQTT presents the standard, lightweight and stable real-time publish/subscribe protocol suited for efficiently distributing real-time weather data. MQTT protocol enhances machine-to-machine (M2M) communication, which makes remote IoT devices with limitations ideal connected in real-time with a small code footprint and
minimal network bandwidth, and has been used to publish weather station data to our private cloud with a fixed public IP address, and in the node-red programming tool, the MQTT subscribe listens for RT data and visualizes them with VP2 console time. The figure bellow illustrates the application with RT weather data visualization in gauges, graphs and charts:


![figure7](https://github.com/okachaamraouy/2IaaS_Blockchain-Based-IoT-Platform/assets/75426884/123ea7df-7822-4b56-96cd-855da77f3b07)




