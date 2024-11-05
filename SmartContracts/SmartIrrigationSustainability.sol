// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./2IaaSTokens.sol"; // Import the 2IaaS token contract

contract SmartIrrigationSustainability {

    SmartIrrigationToken public tokenContract;  // ERC-20 token contract instance

    // Enum for the status of an anomaly
    enum AnomalyStatus { Reported, InProgress, Resolved }

    // Enum for the comprehensive list of anomaly types within the smart irrigation system
    enum AnomalyType { 
        SensorFailure,           // Sensor failure (e.g., soil moisture sensor)
        GatewayFailure,          // LoRaWAN or communication hub failure
        ServerFailure,           // Backend server issue
        IoTDeviceFailure,        // Failure of an IoT device (e.g., disconnection)
        ExtremeWeather,          // Extreme weather conditions affecting irrigation, often requiring adjustments in water management strategies or leading to failures in crop production. 
        WaterSupplyFailure,      // Insufficient water supply or water pump failure
        NetworkFailure,          // Network communication failure
        PowerFailure,            // Power failure affecting devices or system
        IrrigationSystemFailure, // Physical failure in the irrigation infrastructure
        DataAnomaly              // Anomalies in the data collected by the system
    }

    // Enums for certification types
    enum CertificationType {
            RegulatedWaterUse, // This certification ensures that the water used for irrigation adheres to legal and environmental regulations. Farmers must comply with local and national water usage laws to receive this certification. It focuses on responsible water allocation and avoiding over-extraction from water sources.
            EfficientWaterManagement, // This certification focuses on the implementation of advanced irrigation technologies and strategies that optimize water usage. The goal is to minimize water waste while maximizing crop yield. It includes smart irrigation techniques, proper scheduling, and efficient water distribution methods.
            SmartSustainableIrrigation // This certification focuses on the use of smart technologies to promote sustainable water management in agriculture. It involves integrating IoT (Internet of Things) devices, wireless sensors and actuators network, blockchain, fog computing, and cloud computing for real-time monitoring, data-driven decision-making, and transparent reporting of water usage. The objective is to ensure the correct implementation of smart irrigation systems and techniques, which can bring tangible long-term benefits to irrigation practices.
    }

    struct IrrigationData {
        uint timestamp;
        string cropType;
        uint netIrrigationRequirement; // Net irrigation in mm/day
        uint grossIrrigationRequirement; // Gross irrigation in mm/day
        uint irrigationDuration; // Duration in minutes
        uint frequency; // Frequency of irrigation events (number of events per day)
        string reason; // For example: "Soil moisture below the minimum threshold, irrigation needed", "Evapotranspiration rate high, additional irrigation required", "Seasonal adjustment for growth stage, increased water required", "High temperature detected, water application needed", "Scheduled irrigation event", "Post-fertilizer application, water required to facilitate nutrient absorption", "Manual irrigation override by operator", "Drought conditions, supplemental irrigation necessary", etc.
        bool irrigationPerformed;
    }

    struct Farmer {
        address farmerAddress;
        string name;
        bool registered;
    }

    struct LandPiece {
        uint id;
        address farmer;
        string location; // Location of the land piece (could be GPS coordinates)
        uint surface; // Surface area in square meters
        CertificationType certType;
        bool certified; // Whether the land has been certified
    }

    struct Anomaly {
        uint timestamp;
        AnomalyType anomalyType; // Type of anomaly
        string description; // Description of the issue
        AnomalyStatus status; // Status of the anomaly (Reported, InProgress, Resolved)
    }

    struct LoRaWANIoTDevice {
        bytes8 devEUI;          // Unique identifier for the device (64-bit)
        bytes8 appEUI;          // Application identifier (64-bit)
        bytes16 nwkSKey;        // Network session key (128-bit)
        bytes16 appSKey;        // Application session key (128-bit)
        uint16 devNonce;        // 2-byte counter to prevent replay attacks (max value 65535)
        uint creationTimestamp; // Creation timestamp
        uint updateTimestamp;   // Last update timestamp
        bool registered;        // Status to indicate if the device is registered
    }

    mapping(address => bool) public authorizedCompanies;
    mapping(address=>bool) public RegisteredCertificationAuthorities;
    mapping(address => bool) public RegulatedWaterUseCertified; // Mapping to track certifications for farms
    mapping(address => bool) public EfficientWaterManagementCertified;
    mapping(address => bool) public SmartSustainableIrrigationCertified;
    mapping(address => Farmer) public farmers;
    mapping(uint => LandPiece) public landPieces;
    mapping(bytes8 => LoRaWANIoTDevice) public LoRaWAN_EndDevices; // Mapping of LoRaWAN end-devices by their DevEUI
    mapping(address => bool) public registeredDevices; // Mapping of installed devices, excluding LoRaWAN end-devices
    mapping(uint => Anomaly) public anomalies; // Store anomalies with a unique ID
    mapping (address => IrrigationData) public irrigationRecords;
    mapping(address => bool) public registeredFarmers; // Mapping to track registered farmers

    address public manager; // associated with the government
    bool public irrigationTriggered = false;
    uint public anomalyCount = 0; // Counter to track anomaly IDs

    // Events
    event FarmerRegistered(address indexed farmer, string name); // Event for Farmers registration
    event FarmerRevoked(address indexed farmerAddress); // Event for Farmers revocation
    event LandRegistered(uint indexed landId, address indexed farmer, string location, uint surface); // Event for land piece registration
    event LandRevoked(uint indexed landId, address indexed farmer); // Event for land piece revocation
    event LandCertified(uint indexed landId, CertificationType certType); // Event for land piece certification
    event LoRaWANDeviceRegistered(bytes8 indexed devEUI,bytes8 appEUI,bytes16 nwkSKey,bytes16 appSKey,uint16 devNonce,uint creationTimestamp,uint updateTimestamp,bool registered); // Event for IoT device registration on the Blockchain
    event LoRaWANDeviceRevoked(bytes16 indexed devEUI); // Event for LoRaWAN IoT End-Devices revocation
    event AnomalyReported(uint indexed anomalyId, AnomalyType anomalyType, string description, AnomalyStatus status); // Event for reporting an anomaly in the system
    event AnomalyStatusUpdated(uint indexed anomalyId, AnomalyStatus status); // Event for updating the status of a reported anomaly
    event IrrigationPerformed(address indexed farmer, uint netIrrigationRequirement, uint grossIrrigationRequirement, uint irrigationDuration, uint frequency); // Event for performing irrigation based on AI-Driven Expert system recommendations
    event IrrigationPlanUpdated(address indexed farmer, uint newNetIrrigationRequirement, uint newGrossIrrigationRequirement, uint newDuration, uint newFrequency); // Event for updating the irrigation plan based on AI-Driven Expert system recommendations
    event IrrigationCompleted(address indexed farmer, uint soilMoistureBefore, uint soilMoistureAfter, uint waterUsed); // Event for confirming that irrigation is completed
    event RegulatedWaterUseCertifiedEvent(address indexed farm); // Event for certifying a farm under the Regulated Water Use certification
    event EfficientWaterManagementCertifiedEvent(address indexed farm); // Event for certifying a farm under the Efficient Water Management certification
    event SmartSustainableIrrigationCertifiedEvent(address indexed farm); // Event for certifying a farm under the Smart Sustainable Irrigation certification 
    event CA_Authorized(address indexed caAddress); // Event for CA (Certificate Authority) authorization
    event CA_Revoked(address indexed caAddress); // Event for CA (Certificate Authority) revocation
    event CompanyAuthorized(address indexed companyAddress); // Event for Company authorization
    event CompanyRevoked(address indexed companyAddress); // Event for Company revocation
    event DeviceInstalledSuccessfully(address Device, bytes32 IPFShash); // Event for the registration of installed devices, excluding LoRaWAN end-devices
    event DeviceRevokedSuccessfully(address indexed Device, bytes32 IPFShash); // Event for the revocation of installed devices, excluding LoRaWAN end-devices
    event RewardIssued(address indexed farmer, uint256 amount);
    event PenaltyIssued(address indexed farmer, uint256 amount);
    event DevNonceIncremented(bytes8 indexed devEUI, uint16 newDevNonce);

    modifier onlyManager() {
        require(msg.sender == manager, "Not an authorized government personnel.");
        _;
    }
    
    constructor(address tokenAddress) {
        manager = msg.sender; // Set the manager
        tokenContract = SmartIrrigationToken(tokenAddress);  // Initialize token contract using its address
    }

    // Reward farmers for efficient water management by minting tokens
    function rewardFarmer(address farmer, uint256 rewardAmount) public onlyManager {
        require(registeredFarmers[farmer], "Farmer is not registered.");
        tokenContract.mintTokens(farmer, rewardAmount);
        emit RewardIssued(farmer, rewardAmount);
    }

    // Penalize farmers for excessive water usage by burning tokens
    function penalizeFarmer(address farmer, uint256 penaltyAmount) public onlyManager {
        require(registeredFarmers[farmer], "Farmer is not registered.");
        require(tokenContract.balanceOf(farmer) >= penaltyAmount, "Insufficient balance for penalty.");
        tokenContract.burnTokens(farmer, penaltyAmount);
        emit PenaltyIssued(farmer, penaltyAmount);
    }

    // Charge tokens for irrigation services (e.g., water consumption)
    function chargeForIrrigation(address farmer, uint256 chargeAmount) public {
        require(registeredFarmers[farmer], "Farmer is not registered.");
        require(tokenContract.balanceOf(farmer) >= chargeAmount, "Insufficient balance.");

        // Burn tokens as payment for irrigation services
        tokenContract.burnTokens(farmer, chargeAmount);
    }

    // Function to check the balance of a farmer
    function checkFarmerBalance(address farmer) public view returns (uint256) {
        return tokenContract.balanceOf(farmer);
    }

    // Modifier to ensure only CA can certify
    modifier onlyCA {
        require(RegisteredCertificationAuthorities[msg.sender], "Only Certificate Authority can certify");
        _;
    }

    modifier onlyAuthorizedCompany() {
        require(authorizedCompanies[msg.sender], "Not an authorized company.");
        _;
    }

    // Function to authorize Certificate Authority (CA)
    function authorizeCA(address _ca) public onlyManager {
        RegisteredCertificationAuthorities[_ca] = true;

        // Emit the event when a CA is authorized
        emit CA_Authorized(_ca);
    }

    // Function to revoke Certificate Authority (CA)
    function Revoke_authorizedCA(address _ca) public onlyManager {
        require(RegisteredCertificationAuthorities[_ca], "CA is not authorized.");

        RegisteredCertificationAuthorities[_ca] = false;

        // Emit the event when a CA is revoked
        emit CA_Revoked(_ca);
    }

    // Function to register authorized companies
    function authorizeCompany(address _company) public onlyManager {
        authorizedCompanies[_company] = true;

        // Emit the event when a company is authorized
        emit CompanyAuthorized(_company);
    }

    // Function to revoke an authorized company
    function Revoke_authorizedCompany(address _company) public onlyManager {
        require(authorizedCompanies[_company], "Company is not authorized.");

        authorizedCompanies[_company] = false;

        // Emit the event when a company is revoked
        emit CompanyRevoked(_company);
    }

    // Function to register a farmer
    function registerFarmer(address _farmerAddress, string memory _name) public onlyManager {
        require(!farmers[_farmerAddress].registered, "Farmer is already registered.");

        farmers[_farmerAddress] = Farmer({
            farmerAddress: _farmerAddress,
            name: _name,
            registered: true
        });
        
        // Ensure the farmer is marked as registered in the registeredFarmers mapping
        registeredFarmers[_farmerAddress] = true;

        emit FarmerRegistered(_farmerAddress, _name);
    }

    // Function to revoke a farmer
    function revokeFarmer(address _farmerAddress) public onlyManager {
        require(farmers[_farmerAddress].registered, "Farmer is not registered.");

        // Update both mappings to ensure the farmer is no longer considered registered
        farmers[_farmerAddress].registered = false;
        registeredFarmers[_farmerAddress] = false;

        emit FarmerRevoked(_farmerAddress); // Emit the event
    }


    // Function to register a land piece
    function registerLand(uint _landId, address _farmerAddress, string memory _location, uint _surface) public onlyManager {
        require(farmers[_farmerAddress].registered, "Farmer is not registered.");

        landPieces[_landId] = LandPiece({
            id: _landId,
            farmer: _farmerAddress,
            location: _location,
            surface: _surface,
            certType: CertificationType.RegulatedWaterUse, // Default certification (can be changed)
            certified: false // Initially not certified
        });

        emit LandRegistered(_landId, _farmerAddress, _location, _surface);
    }

    // Function to certify a land piece
    function certifyLand(uint _landId, CertificationType _certType) public onlyCA {
        require(!landPieces[_landId].certified, "Land already certified.");
        require(landPieces[_landId].id != 0, "Land piece not registered."); // Ensure land is registered
        
        landPieces[_landId].certified = true;
        landPieces[_landId].certType = _certType;

        emit LandCertified(_landId, _certType);
    }

    // Function to get Land details
    function getLandDetails(uint _landId) public view returns (address, string memory, uint, CertificationType, bool) {
        LandPiece storage land = landPieces[_landId];
        return (land.farmer, land.location, land.surface, land.certType, land.certified);
    }

    // Function to revoke certification (by CA)
    function revokeCertification(uint _landId) public onlyCA {
        require(landPieces[_landId].certified, "Land not certified.");
        landPieces[_landId].certified = false; // Revoke certification
    }

    // Function to view certification status
    function viewCertification(uint _landId) public view returns (CertificationType, bool) {
        return (landPieces[_landId].certType, landPieces[_landId].certified);
    }

    // Function to register a LoRaWAN IoT device with DevNonce initialized to 0
    function registerLoRaWANIoTEndDevice(
        bytes8 _devEUI,
        bytes8 _appEUI,
        bytes16 _nwkSKey,
        bytes16 _appSKey
    ) public onlyManager {
        require(!LoRaWAN_EndDevices[_devEUI].registered, "Device is already registered.");

        LoRaWAN_EndDevices[_devEUI] = LoRaWANIoTDevice({
            devEUI: _devEUI,
            appEUI: _appEUI,
            nwkSKey: _nwkSKey,
            appSKey: _appSKey,
            devNonce: 0, // Initialize DevNonce to 0
            creationTimestamp: block.timestamp,
            updateTimestamp: block.timestamp,
            registered: true
        });

        emit LoRaWANDeviceRegistered(
            _devEUI,
            _appEUI,
            _nwkSKey,
            _appSKey,
            0,
            block.timestamp,
            block.timestamp,
            true
        );
    }

    // Function to handle a join request by incrementing DevNonce
    function joinRequest(bytes8 _devEUI) public onlyManager {
        require(LoRaWAN_EndDevices[_devEUI].registered, "Device is not registered.");
        
        LoRaWANIoTDevice storage device = LoRaWAN_EndDevices[_devEUI];

        // Check if DevNonce has reached its max value (2-byte limit of 65535)
        require(device.devNonce < type(uint16).max, "DevNonce overflow: Device needs to reset.");

        // Increment DevNonce for each join request
        device.devNonce += 1;
        device.updateTimestamp = block.timestamp; // Update the timestamp for the last join request

        emit DevNonceIncremented(_devEUI, device.devNonce);
    }    

    // Function to revoke a LoRaWAN IoT device
    function revokeLoRaWANIoTEndDevice(bytes8 _devEUI) public onlyManager {
        require(LoRaWAN_EndDevices[_devEUI].registered, "Device is not registered.");

        // Mark the device as unregistered
        LoRaWAN_EndDevices[_devEUI].registered = false;

        // Emit the DeviceRevoked event
        emit LoRaWANDeviceRevoked(_devEUI);
    }

    // Register installed devices by authorized communities (e.g., IoT Gateways, Servers, and all sensors and actuators that communicate with the Fog Nodes through wireless technologies other than LoRa, etc.)
    function registerInstalledDevice(address Device, bytes32 IPFShash) public onlyAuthorizedCompany{
        require(!registeredDevices[Device], "Device is already registered.");

        // Register the device
        registeredDevices[Device] = true;
        emit DeviceInstalledSuccessfully(Device, IPFShash);
    }

    // Function to revoke an installed device
    function revokeInstalledDevice(address Device, bytes32 IPFShash) public onlyAuthorizedCompany {
        require(registeredDevices[Device], "Device is not registered.");

        // Revoke the device by marking it as unregistered
        registeredDevices[Device] = false;

        // Emit event for successful revocation
        emit DeviceRevokedSuccessfully(Device, IPFShash);
    }

    // Function to call a registered device using its DevEUI (used by AI-Driven Expert system)
    function callDeviceByDevEUI(bytes8 _devEUI) public view onlyManager returns (
        bytes8, bytes8, bytes16, bytes16, uint16, uint, uint, bool
    ) {
        require(LoRaWAN_EndDevices[_devEUI].registered, "Device is not registered.");

        LoRaWANIoTDevice storage device = LoRaWAN_EndDevices[_devEUI];
        
        // Return all device details as per the updated struct
        return (
            device.devEUI,
            device.appEUI,
            device.nwkSKey,
            device.appSKey,
            device.devNonce,
            device.creationTimestamp,
            device.updateTimestamp,
            device.registered
        );
    }

    // Function to report an anomaly
    function reportAnomaly(AnomalyType _anomalyType, string memory _description) public onlyManager {
        anomalyCount++;
        anomalies[anomalyCount] = Anomaly({
            timestamp: block.timestamp,
            anomalyType: _anomalyType,
            description: _description,
            status: AnomalyStatus.Reported
        });

        emit AnomalyReported(anomalyCount, _anomalyType, _description, AnomalyStatus.Reported);
    }

    // Function to update the status of an anomaly
    function updateAnomalyStatus(uint _anomalyId, AnomalyStatus _status) public onlyManager {
        require(anomalies[_anomalyId].timestamp != 0, "Anomaly does not exist.");
        anomalies[_anomalyId].status = _status;

        emit AnomalyStatusUpdated(_anomalyId, _status);
    }

    // Function to trigger irrigation based on AI-Driven Expert system recommendations
    function triggerIrrigation(address _farmer, string memory _cropType, uint _netIrrigationRequirement, uint _grossIrrigationRequirement, uint _duration, uint _frequency, string memory _reason) public onlyManager {
        require(!irrigationTriggered, "Irrigation already triggered");
        
        irrigationRecords[_farmer] = IrrigationData({
            timestamp: block.timestamp,
            cropType: _cropType,
            netIrrigationRequirement: _netIrrigationRequirement,
            grossIrrigationRequirement: _grossIrrigationRequirement,
            irrigationDuration: _duration,
            frequency: _frequency, // Frequency of irrigation events per day
            reason: _reason,
            irrigationPerformed: false
        });
        
        irrigationTriggered = true;
        emit IrrigationPerformed(_farmer, _netIrrigationRequirement, _grossIrrigationRequirement, _duration, _frequency);
    }

    // Function to confirm irrigation completion directly by AI-Driven Expert system (using Python/Node-RED)
    function confirmIrrigationCompletion(address _farmer, uint _soilMoistureBefore, uint _soilMoistureAfter, uint _waterUsed) public onlyManager {
        IrrigationData storage data = irrigationRecords[_farmer];

        // Logic to ensure irrigation was performed based on water usage and soil moisture readings
        if (_soilMoistureAfter > _soilMoistureBefore && _waterUsed > 0) {
            data.irrigationPerformed = true;
            emit IrrigationCompleted(_farmer, _soilMoistureBefore, _soilMoistureAfter, _waterUsed);
        } else {
            anomalyCount++; // Increment anomaly count for a new anomaly ID
            emit AnomalyReported(anomalyCount, AnomalyType.IrrigationSystemFailure, "Soil moisture did not increase as expected.", AnomalyStatus.Reported);
        }
    }

    // Function to reset the irrigation status after completion (requires confirmation)
    function resetIrrigation(address _farmer) public onlyManager {
        IrrigationData storage data = irrigationRecords[_farmer];

        require(data.irrigationPerformed, "Irrigation is not completed yet.");

        data.irrigationPerformed = false; // Reset irrigation status for the next cycle
    }

    // Function to dynamically update irrigation plans based on AI-Driven Expert system recommendations
    function updateIrrigationPlan(address _farmer, uint _newNetIrrigationRequirement, uint _newGrossIrrigationRequirement, uint _newDuration, uint _newFrequency) public onlyManager {
        IrrigationData storage data = irrigationRecords[_farmer];
        data.netIrrigationRequirement = _newNetIrrigationRequirement;
        data.grossIrrigationRequirement = _newGrossIrrigationRequirement;
        data.irrigationDuration = _newDuration;
        data.frequency = _newFrequency; 
        emit IrrigationPlanUpdated(_farmer, _newNetIrrigationRequirement, _newGrossIrrigationRequirement, _newDuration, _newFrequency);
    }

    // Function to get irrigation data for a specific farmer
    function getIrrigationData(address _farmer) public view returns (IrrigationData memory) {
        return irrigationRecords[_farmer];
    }

}
