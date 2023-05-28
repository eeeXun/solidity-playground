// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {

    constructor() ERC20("MyToken", "MTK") {
        super._mint(super.owner(), 1000 * (10**super.decimals()));
    }

    function destory() public onlyOwner {
        selfdestruct(payable(super.owner()));
    }

    function remaining() public view returns (uint256) {
        return super.balanceOf(super.owner());
    }

    // buy token
    // 1 ether = 10 token
    receive() external payable {
        super._transfer(super.owner(), msg.sender, msg.value * 10);
    }

    // withdraw ether with tokens
    // 1 token = 0.1 ether
    function withdraw(uint256 tokens) public {
        require(
            super.balanceOf(msg.sender) >= tokens,
            "You don't have enough tokens!"
        );
        require(
            address(this).balance >= tokens / 10,
            "Not enough balance of ether!"
        );
        super._transfer(msg.sender, super.owner(), tokens);
        payable(msg.sender).transfer(tokens / 10);
    }
}
