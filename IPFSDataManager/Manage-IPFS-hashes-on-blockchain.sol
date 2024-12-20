// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IPFSDataManager {

    // Struct to represent an entry of data stored on IPFS
    struct DataEntry {
        string ipfsHash;
        string description;
        address owner;
        uint timestamp;
    }

    // Mapping to store IPFS data with a unique identifier
    mapping(uint256 => DataEntry) public dataEntries;

    // Counter for data entries
    uint256 public entryCount = 0;

    // Event to log the data entry creation
    event DataEntryCreated(uint256 entryId, string ipfsHash, address owner);

    // Function to add a new IPFS hash with description
    function addIPFSData(string memory _ipfsHash, string memory _description) public {
        entryCount++;
        dataEntries[entryCount] = DataEntry(_ipfsHash, _description, msg.sender, block.timestamp);

        // Emitting the event
        emit DataEntryCreated(entryCount, _ipfsHash, msg.sender);
    }

    // Function to retrieve an IPFS hash by entry ID
    function getIPFSData(uint256 _entryId) public view returns (string memory, string memory, address, uint) {
        DataEntry memory entry = dataEntries[_entryId];
        return (entry.ipfsHash, entry.description, entry.owner, entry.timestamp);
    }

    // Function to update an existing IPFS hash (only the owner can update)
    function updateIPFSData(uint256 _entryId, string memory _newIpfsHash) public {
        require(dataEntries[_entryId].owner == msg.sender, "Only the owner can update this entry");
        dataEntries[_entryId].ipfsHash = _newIpfsHash;
    }
}
