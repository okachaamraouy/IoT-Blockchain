// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IPFShash {

    // Struct to store IPFS hash along with timestamp, block number, and transaction hash
    struct IPFSData {
        string hash;          // IPFS hash stored as a string
        uint256 timestamp;    // Timestamp of when the data was registered
        uint256 blockNumber;  // Block number when the data was registered
        bytes32 txHash;       // Transaction hash for the registration
    }

    // Events for IPFS hash registration
    event WeatherDataRegistered(string ipfsHash, uint256 timestamp, uint256 blockNumber, bytes32 txHash, bytes32 generatedKey);
    event WirelessAndActuatorDataRegistered(string ipfsHash, uint256 timestamp, uint256 blockNumber, bytes32 txHash, bytes32 generatedKey);
    event DroneDataRegistered(string ipfsHash, uint256 timestamp, uint256 blockNumber, bytes32 txHash, bytes32 generatedKey);
    event SatelliteDataRegistered(string ipfsHash, uint256 timestamp, uint256 blockNumber, bytes32 txHash, bytes32 generatedKey);

    // Mapping to store IPFS data using a combination of timestamp and txHash as the key
    mapping(bytes32 => IPFSData) public weatherDataIPFS;
    mapping(bytes32 => IPFSData) public wirelessAndActuatorDataIPFS;
    mapping(bytes32 => IPFSData) public droneDataIPFS;
    mapping(bytes32 => IPFSData) public satelliteDataIPFS;

    // Function to generate a key from timestamp and txHash
    function generateKey(uint256 _timestamp, bytes32 _txHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_timestamp, _txHash));
    }

    // Modifier to check only authorized company (for simplicity, assume all addresses are authorized in this example)
    modifier onlyOwner() {
        _;
    }

    // Function to register IPFS hash for weather data and return the generated key
    function registerWeatherData(string memory ipfsHash) public onlyOwner returns (bytes32) {
        uint256 currentTimestamp = block.timestamp;
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, currentTimestamp, block.number));
        bytes32 key = generateKey(currentTimestamp, txHash);

        weatherDataIPFS[key] = IPFSData(ipfsHash, currentTimestamp, block.number, txHash);

        // Emit the event with the generated key
        emit WeatherDataRegistered(ipfsHash, currentTimestamp, block.number, txHash, key);

        return key;  // Return the generated key
    }

    // Function to register IPFS hash for wireless and actuator data and return the generated key
    function registerWirelessAndActuatorData(string memory ipfsHash) public onlyOwner returns (bytes32) {
        uint256 currentTimestamp = block.timestamp;
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, currentTimestamp, block.number));
        bytes32 key = generateKey(currentTimestamp, txHash);

        wirelessAndActuatorDataIPFS[key] = IPFSData(ipfsHash, currentTimestamp, block.number, txHash);

        // Emit the event with the generated key
        emit WirelessAndActuatorDataRegistered(ipfsHash, currentTimestamp, block.number, txHash, key);

        return key;  // Return the generated key
    }

    // Function to register IPFS hash for drone data and return the generated key
    function registerDroneData(string memory ipfsHash) public onlyOwner returns (bytes32) {
        uint256 currentTimestamp = block.timestamp;
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, currentTimestamp, block.number));
        bytes32 key = generateKey(currentTimestamp, txHash);

        droneDataIPFS[key] = IPFSData(ipfsHash, currentTimestamp, block.number, txHash);

        // Emit the event with the generated key
        emit DroneDataRegistered(ipfsHash, currentTimestamp, block.number, txHash, key);

        return key;  // Return the generated key
    }

    // Function to register IPFS hash for satellite data and return the generated key
    function registerSatelliteData(string memory ipfsHash) public onlyOwner returns (bytes32) {
        uint256 currentTimestamp = block.timestamp;
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, currentTimestamp, block.number));
        bytes32 key = generateKey(currentTimestamp, txHash);

        satelliteDataIPFS[key] = IPFSData(ipfsHash, currentTimestamp, block.number, txHash);

        // Emit the event with the generated key
        emit SatelliteDataRegistered(ipfsHash, currentTimestamp, block.number, txHash, key);

        return key;  // Return the generated key
    }
}
