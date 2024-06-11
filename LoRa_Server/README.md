# LoRa-Server
- An open-source LoRaWAN Network Server that can be used to set up private or public LoRaWAN networks.
- The 2IaaS Blockchain-Based IoT platform for intelligent irrigation in agriculture is based on the use of the ChirpStack open-source LoRaWAN Network Server. ChirpStack is open-source software licensed under the MIT License. The MIT License is a permissive free software license originating at the Massachusetts Institute of Technology (MIT). It is a simple and easy-to-understand license that places very few restrictions on reuse, making it one of the most broadly used open-source licenses. ChirpStack provides a web interface for the management of gateways, devices, and tenants, as well as the setup of data integrations with major cloud providers, databases, and services commonly used for handling device data. ChirpStack also provides a gRPC-based API that can be used to integrate or extend ChirpStack.
- Please refer to the ChirpStack website (https://www.chirpstack.io/) for documentation and pre-compiled binaries.
- The main components of the ChirpStack LoRaWAN Network Server that are used for the 2IaaS platform are described in the following:
  1. ChirpStack Gateway Bridge:
     
  Functionality: The ChirpStack Gateway Bridge is a component that sits between the LoRa gateway and the ChirpStack Network Server. It translates the Semtech UDP packet forwarder protocol into MQTT, which is more 
  suitable for integration with modern IoT platforms and allows for easier network management and scalability.
  
  Key Features:
  - Converts UDP packets from gateways to MQTT.
  - Supports various gateway configurations.
  - Allows for easy integration with cloud-based MQTT brokers.
 
  2. ChirpStack Network Server :

  Functionality: The ChirpStack Network Server is responsible for the core LoRaWAN network server functionalities. It handles the LoRaWAN MAC layer, manages data from end devices, and forwards it to the 
  ChirpStack Application Server or other application servers.

  Key Features:
  
  - LoRaWAN MAC layer implementation.
  - Management of device activation (OTAA and ABP).
  - Downlink transmission scheduling.
  - Data de-duplication and frame counter management.
  - Implements LoRaWAN regional parameters.
 
  3. ChirpStack Application Server:
  
  Functionality: The ChirpStack Application Server is responsible for the management of applications, devices, and users. It also handles the integration of device data with external services and applications.
  
  Key Features:
  
  - User, tenant, and device management.
  - Integration with various databases and cloud services.
  - Provides a REST and gRPC API for external integrations.
  - Web interface for monitoring and configuration.
  - Supports multiple organizations and applications.
 
  4. ChirpStack Gateway Configuration Server
  Functionality: This component provides configuration management for LoRa gateways. It allows the automatic configuration and firmware updates for supported gateways, ensuring that they are correctly set up to communicate with the network server.
  
  Key Features:
  
  - Remote configuration of gateways.
  - Firmware update management.
  - Monitoring and diagnostics of gateway status.
 
  5. ChirpStack Geolocation Server
  Functionality: The Geolocation Server is an optional component used for geolocating devices based on the time-difference of arrival (TDoA) and received signal strength indicator (RSSI) measurements. This 
  enables the determination of device positions without GPS.
  
  Key Features:
  
  - TDoA and RSSI-based geolocation.
  - Integrates with the ChirpStack Network Server.
  - Can use multiple gateways for accurate positioning.
 
  6. ChirpStack API
  Functionality: ChirpStack provides both RESTful and gRPC APIs, which are essential for integrating ChirpStack with external systems and applications. These APIs allow for programmatic management of the network 
  and access to device data.
  
  Key Features:
  
  - RESTful API for easy integration with web applications.
  - gRPC API for high-performance, low-latency integrations.
  - Full access to network and application management functionalities.
  - Supports user authentication and authorization.
 
  7. ChirpStack Web Interface
  Functionality: The ChirpStack Web Interface is a user-friendly dashboard for managing all aspects of the LoRa Server deployment. It allows users to configure gateways, manage devices, monitor network activity, 
  and integrate with external services.
  
  Key Features:
  
  - Intuitive interface for network management.
  - Real-time monitoring of device and gateway status.
  - Configuration and management of users, tenants, and devices.
  - Visualization of device data and network metrics.
    
  8. Database Backend
  
  Functionality: ChirpStack utilizes databases such as PostgreSQL for storing network and application server data. This includes device and gateway configurations, user information, and device data. On the other 
  hand, to ensure the integrity of those data, the 2IaaS platform uses Blockchain technology and stores references to it via smart contracts, this approach necessitates both the 2IaaS On-Chain and Off-Chain 
  Adapters to interact with smart contracts securely and efficiently.
  
  Key Features:
  
  - Enable the creation of decentralized applications for intelligent irrigation in agriculture.
  - Secure sharing of data.
  - Decentralized control with unmatched transparency.
  - Scalable and robust data storage.
  - Supports data querying and integration with external applications.
  - Provide a robust infrastructure with no central or one point of failure which can lose the data when some gateways or servers fail.
