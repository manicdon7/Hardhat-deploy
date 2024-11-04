// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ManicNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    event NFTMinted(address indexed recipient, uint256 indexed tokenId);
    // Declare the NFTMinted event

    constructor() ERC721("ManicNFT", "MNFT") Ownable(address(msg.sender)) { 
        tokenCounter = 1; 
}

    function mintNFT(address recipient) external onlyOwner returns (uint256) {
        require(recipient != address(0), "Cannot mint to the zero address");
        
        uint256 newTokenId = tokenCounter;
        _safeMint(recipient, newTokenId); // Mint the NFT to the recipient
        tokenCounter++; // Increment the token counter for the next NFT
        emit NFTMinted(recipient, newTokenId); // Emit an event for the minting
        return newTokenId; // Return the new token ID
    }
}
