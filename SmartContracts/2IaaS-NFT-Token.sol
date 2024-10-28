// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SmartIrrigationToken as an ERC-20 Token
contract SmartIrrigationToken is ERC20, Ownable {

    // Constructor to set the token name and symbol, and set the initial owner
    constructor() ERC20("Smart Irrigation Token", "2IaaS") Ownable(msg.sender) {
        // Mint initial supply to the contract owner (e.g., government authority)
        _mint(msg.sender, 10e18 * 10 ** decimals()); // Mint 100 trillion tokens initially
    }

    // Function to mint new tokens (e.g., reward for water-efficient irrigation)
    function mintTokens(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens (reduce total supply)
    function burnTokens(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
