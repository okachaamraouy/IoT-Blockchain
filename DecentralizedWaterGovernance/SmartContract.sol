// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DecentralizedWaterGovernance {
    
    // State variables
    address public owner;
    uint public totalWaterResources; // Total available water resources (in liters)
    uint public waterAllocationPerFarmer; // Water allocation per farmer
    uint public proposalCount = 0; // Counter for proposals
    uint public rewardTokens; // Reward tokens for water-saving farmers
    
    // Farmer and stakeholder details
    struct Farmer {
        uint waterConsumed; // Water consumed by the farmer
        uint rewardBalance; // Reward tokens for efficient water usage
        bool isRegistered; // Check if the farmer is registered
    }

    struct Proposal {
        string description; // Description of the proposal
        uint waterAmount; // Amount of water requested
        address farmerAddress; // Address of the farmer requesting water
        uint voteCount; // Number of votes received
        bool executed; // Whether the proposal has been executed
    }

    // Mappings to store farmers and proposals
    mapping(address => Farmer) public farmers;
    mapping(uint => Proposal) public proposals;
    
    // Voting details
    mapping(uint => mapping(address => bool)) public hasVoted; // Track who has voted on what proposal
    address[] public stakeholders; // List of stakeholders eligible to vote (farmers and organizations)
    
    // Events
    event ProposalCreated(uint indexed proposalId, string description, address indexed farmer);
    event Voted(uint indexed proposalId, address indexed voter);
    event ProposalExecuted(uint indexed proposalId, address indexed farmer);
    event WaterSaved(address indexed farmer, uint rewardTokens);
    
    // Modifier to allow only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can execute this function");
        _;
    }
    
    // Modifier to allow only registered farmers
    modifier onlyRegisteredFarmer() {
        require(farmers[msg.sender].isRegistered, "Only registered farmers can call this function");
        _;
    }
    
    // Constructor to initialize the contract with initial water resources and allocation amount
    constructor(uint _totalWaterResources, uint _waterAllocationPerFarmer, uint _rewardTokens) {
        owner = msg.sender;
        totalWaterResources = _totalWaterResources;
        waterAllocationPerFarmer = _waterAllocationPerFarmer;
        rewardTokens = _rewardTokens;
    }
    
    // Register a farmer in the system
    function registerFarmer(address farmerAddress) public onlyOwner {
        farmers[farmerAddress] = Farmer(0, 0, true);
    }
    
    // Add a stakeholder (voter) to the system
    function addStakeholder(address stakeholder) public onlyOwner {
        stakeholders.push(stakeholder);
    }
    
    // Create a proposal to request additional water
    function createProposal(string memory description, uint waterAmount) public onlyRegisteredFarmer {
        require(waterAmount <= totalWaterResources, "Requested water exceeds available resources");
        
        proposals[proposalCount] = Proposal({
            description: description,
            waterAmount: waterAmount,
            farmerAddress: msg.sender,
            voteCount: 0,
            executed: false
        });
        
        emit ProposalCreated(proposalCount, description, msg.sender);
        proposalCount++;
    }
    
    // Stakeholders vote on the proposal
    function voteOnProposal(uint proposalId) public {
        require(!hasVoted[proposalId][msg.sender], "You have already voted on this proposal");
        require(farmers[msg.sender].isRegistered || isStakeholder(msg.sender), "Only stakeholders can vote");

        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "This proposal has already been executed");
        
        proposal.voteCount++;
        hasVoted[proposalId][msg.sender] = true;
        
        emit Voted(proposalId, msg.sender);
    }
    
    // Execute a proposal if majority of votes are achieved
    function executeProposal(uint proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.voteCount >= (stakeholders.length / 2), "Proposal does not have enough votes");
        require(totalWaterResources >= proposal.waterAmount, "Not enough water resources available");
        
        // Allocate water to the farmer
        farmers[proposal.farmerAddress].waterConsumed += proposal.waterAmount;
        totalWaterResources -= proposal.waterAmount;
        proposal.executed = true;
        
        emit ProposalExecuted(proposalId, proposal.farmerAddress);
    }
    
    // Reward farmers who conserve water
    function rewardForWaterConservation(address farmerAddress, uint savedWater) public onlyOwner {
        require(farmers[farmerAddress].isRegistered, "Farmer is not registered");
        
        uint reward = savedWater * rewardTokens;
        farmers[farmerAddress].rewardBalance += reward;
        
        emit WaterSaved(farmerAddress, reward);
    }
    
    // View water consumption and reward balance of a farmer
    function viewFarmerDetails(address farmerAddress) public view returns (uint waterConsumed, uint rewardBalance) {
        Farmer memory farmer = farmers[farmerAddress];
        return (farmer.waterConsumed, farmer.rewardBalance);
    }
    
    // Utility function to check if an address is a stakeholder
    function isStakeholder(address addr) internal view returns (bool) {
        for (uint i = 0; i < stakeholders.length; i++) {
            if (stakeholders[i] == addr) {
                return true;
            }
        }
        return false;
    }
    
    // Function to change the water allocation per farmer
    function changeWaterAllocation(uint newAllocation) public onlyOwner {
        waterAllocationPerFarmer = newAllocation;
    }
    
    // Function to add more water resources to the system
    function addWaterResources(uint amount) public onlyOwner {
        totalWaterResources += amount;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
