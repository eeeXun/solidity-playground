// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

struct DiplomaData {
    address assignor;
    string name;
    uint256 year;
    string img;
    bool reviewing;
    bool valid;
    bool rejected;
    bool revoked;
}

contract Diploma {
    // receiver address => degree => department => data
    mapping(address => mapping(string => mapping(string => DiplomaData))) assignment;

    AggregatorV3Interface internal dataFeed;

    constructor() {
        // ETH / USD
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    // https://github.com/web3/web3.js/issues/535
    event Grant(
        address indexed from,
        address indexed to,
        string degree,
        string department
    );
    event Request(
        address indexed from,
        address indexed to,
        string degree,
        string department
    );

    // Request Fee is 10 USD
    // 1 ETH = answer/(10**8) (USD)
    // 1 USD = (10**8)/answer (ETH)
    // 10 USD = (10**9)/answer * (10**18) (Wei) = (10**27)/answer (Wei)
    function getFee() public view returns (int256) {
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        return (10**27) / answer;
    }

    function getData(
        address addr,
        string memory degree,
        string memory department
    ) public view returns (DiplomaData memory) {
        return assignment[addr][degree][department];
    }

    // Request diploma
    function request(
        address to,
        string memory name,
        string memory degree,
        string memory department,
        string memory img,
        uint256 year
    ) public payable {
        require(
            !assignment[msg.sender][degree][department].valid,
            "Diploma already exist!"
        );
        require(
            !assignment[msg.sender][degree][department].reviewing &&
                !assignment[msg.sender][degree][department].rejected,
            "Your diploma is under review or rejected! Don't resend it!"
        );
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        require(int256(msg.value) >= (10**27) / answer, "Insufficient Fee!");
        payable(to).transfer(msg.value);
        assignment[msg.sender][degree][department] = DiplomaData({
            assignor: to,
            name: name,
            year: year,
            img: img,
            reviewing: true,
            valid: false,
            rejected: false,
            revoked: false
        });
        emit Request(msg.sender, to, degree, department);
    }

    // Approve the request
    function approve(
        address addr,
        string memory degree,
        string memory department
    ) public {
        require(
            assignment[addr][degree][department].reviewing &&
                assignment[addr][degree][department].assignor == msg.sender,
            "You can't confirm this diploma!"
        );
        assignment[addr][degree][department].valid = true;
        assignment[addr][degree][department].reviewing = false;
        emit Grant(msg.sender, addr, degree, department);
    }

    // Reject the request
    function reject(
        address addr,
        string memory degree,
        string memory department
    ) public {
        require(
            assignment[addr][degree][department].reviewing &&
                assignment[addr][degree][department].assignor == msg.sender,
            "You can't reject this diploma!"
        );
        assignment[addr][degree][department].rejected = true;
        assignment[addr][degree][department].reviewing = false;
    }

    // Revoke diploma
    function revoke(
        address to,
        string memory degree,
        string memory department
    ) public {
        require(
            assignment[to][degree][department].assignor == msg.sender,
            "You can't revoke the diploma!"
        );
        require(
            assignment[to][degree][department].valid,
            "This diploma is not valid! Not need to revoke it!"
        );
        assignment[to][degree][department].revoked = true;
    }

    // Recover diploma
    function recover(
        address to,
        string memory degree,
        string memory department
    ) public {
        require(
            assignment[to][degree][department].assignor == msg.sender,
            "You can't recover the diploma!"
        );
        require(
            assignment[to][degree][department].valid,
            "This diploma is not valid! Not need to recover it!"
        );
        assignment[to][degree][department].revoked = false;
    }
}
