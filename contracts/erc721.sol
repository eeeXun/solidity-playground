// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    // token ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Mapping from tokenId to price
    mapping(uint256 => uint256) prices;

    // Fee of minting a token
    uint256 private mintFee;

    constructor() ERC721("MyNFT", "MFT") {
        mintFee = 10_000 wei;
    }

    function destory() public onlyOwner {
        selfdestruct(payable(super.owner()));
    }

    modifier tokenExist(uint256 tokenId) {
        require(tokenId < _tokenIds.current(), "No such token!");
        _;
    }

    // If you're not the owner, you need pay at least 10,000 wei to mint a token
    // When you mint a token, you need to set tokenURI and the price of the token
    function mint(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        require(
            msg.sender == super.owner() || msg.value >= mintFee,
            "Not enough mint fee! At least 10000 wei!"
        );
        uint256 newItemId = _tokenIds.current();
        super._mint(msg.sender, newItemId);
        super._setTokenURI(newItemId, tokenURI);
        prices[newItemId] = price;

        _tokenIds.increment();
        return newItemId;
    }

    // Get the price of given tokenId
    function tokenPrice(uint256 tokenId)
        public
        view
        tokenExist(tokenId)
        returns (uint256)
    {
        return prices[tokenId];
    }

    // Buy the NFT with ether higher than or equal to the NFT price
    // If you buy the token with higher price, the price would update
    function buyToken(uint256 tokenId) public payable tokenExist(tokenId) {
        require(
            msg.value >= prices[tokenId],
            "Not enough ether to buy the NFT!"
        );
        // Update the price
        if (msg.value >= prices[tokenId]) {
            prices[tokenId] = msg.value;
        }
        payable(super.ownerOf(tokenId)).transfer(msg.value);
        super._transfer(super.ownerOf(tokenId), msg.sender, tokenId);
    }
}
