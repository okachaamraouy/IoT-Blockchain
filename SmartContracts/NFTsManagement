// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import OpenZeppelin's ERC721 and Ownable contracts
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/access/Ownable.sol";

contract WaterPermitNFT is ERC721, Ownable {
    uint256 public nextPermitId;
    uint256 public nextLandId;

    struct PermitDetails {
        uint256 maxWaterAllocation;
        string location;
        uint256 expirationDate;
    }

    struct LandOwnershipDetails {
        address owner;
        uint256 landId;
    }

    struct Certification {
        string certificationType;
        bool isValid;
    }

    mapping(uint256 => PermitDetails) public permitDetails;
    mapping(uint256 => LandOwnershipDetails) public landOwnership;
    mapping(uint256 => Certification) public certifications;

    event PermitIssued(
        uint256 indexed permitId,
        address indexed farmer,
        uint256 maxWaterAllocation,
        string location,
        uint256 expirationDate
    );

    event WaterRightsUpdated(uint256 indexed tokenId, uint256 newLimit, uint256 newExpirationDate);
    event CertificationNFTIssued(address indexed farmer, uint256 tokenId, string certificationType);
    event NFTRevoked(uint256 tokenId);
    event OwnershipTransferred(uint256 tokenId, address from, address to);

    constructor() ERC721("WaterPermitNFT", "2IaaS") {}

    function issuePermit(
        address farmer,
        uint256 maxWaterAllocation,
        string memory location,
        uint256 expirationDate
    ) external onlyOwner {
        require(farmer != address(0), "Invalid farmer address");
        require(expirationDate > block.timestamp, "Expiration must be in the future");

        uint256 permitId = nextPermitId;
        nextPermitId++;

        _safeMint(farmer, permitId);
        permitDetails[permitId] = PermitDetails({
            maxWaterAllocation: maxWaterAllocation,
            location: location,
            expirationDate: expirationDate
        });

        emit PermitIssued(permitId, farmer, maxWaterAllocation, location, expirationDate);
    }

    function LandOwnership(address farmer, uint256 landId) external onlyOwner {
        require(farmer != address(0), "Invalid farmer address");

        landOwnership[landId] = LandOwnershipDetails({
            owner: farmer,
            landId: landId
        });
    }

    function UpdateWaterRights(uint256 tokenId, uint256 newLimit, uint256 newExpirationDate) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        require(newExpirationDate > block.timestamp, "Expiration must be in the future");

        permitDetails[tokenId].maxWaterAllocation = newLimit;
        permitDetails[tokenId].expirationDate = newExpirationDate;

        emit WaterRightsUpdated(tokenId, newLimit, newExpirationDate);
    }

    function issueCertificationNFT(address farmer, string memory certificationType) external onlyOwner {
        uint256 tokenId = nextPermitId;
        nextPermitId++;

        _safeMint(farmer, tokenId);
        certifications[tokenId] = Certification({
            certificationType: certificationType,
            isValid: true
        });

        emit CertificationNFTIssued(farmer, tokenId, certificationType);
    }

    function setApproval(address operator, bool approvedStatus) external {
        _setApprovalForAll(msg.sender, operator, approvedStatus);
    }

    function TransferOwnership(address from, address to, uint256 tokenId) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == from, "Incorrect token owner");

        _transfer(from, to, tokenId);
        emit OwnershipTransferred(tokenId, from, to);
    }

    function revokeNFT(uint256 tokenId) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");

        _burn(tokenId);
        certifications[tokenId].isValid = false;
        
        emit NFTRevoked(tokenId);
    }

    function verifyOwnership(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return ownerOf(tokenId);
    }

    function getPermitDetails(uint256 permitId)
        external
        view
        returns (
            uint256 maxWaterAllocation,
            string memory location,
            uint256 expirationDate
        )
    {
        require(_exists(permitId), "Permit does not exist");

        PermitDetails memory details = permitDetails[permitId];
        return (details.maxWaterAllocation, details.location, details.expirationDate);
    }
}
