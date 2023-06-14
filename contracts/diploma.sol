// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct DiplomaData {
    address assignor;
    string name;
    uint256 year;
    string img;
    bool valid;
    bool reject;
    bool revoke;
}

contract Diploma {
    // receiver address => degree => department => data
    mapping(address => mapping(string => mapping(string => DiplomaData))) assignment;

    // https://github.com/web3/web3.js/issues/535
    event Award(
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
    event Revoke(
        address indexed from,
        address indexed to,
        string degree,
        string department
    );

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
    ) public {
        require(
            !assignment[msg.sender][degree][department].valid,
            "Diploma already exist!"
        );
        assignment[msg.sender][degree][department] = DiplomaData({
            assignor: to,
            name: name,
            year: year,
            img: img,
            valid: false,
            reject: false,
            revoke: false
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
            assignment[addr][degree][department].assignor == msg.sender,
            "You can't confirm this diploma!"
        );
        assignment[addr][degree][department].valid = true;
        emit Award(msg.sender, addr, degree, department);
    }

    // Reject the request
    function reject(
        address addr,
        string memory degree,
        string memory department
    ) public {
        require(
            assignment[addr][degree][department].assignor == msg.sender,
            "You can't reject this diploma!"
        );
        assignment[addr][degree][department].reject = true;
    }

    // Award diploma
    function award(
        address to,
        string memory name,
        string memory degree,
        string memory department,
        string memory img,
        uint256 year
    ) public {
        require(
            !assignment[to][degree][department].valid,
            "Diploma already exist!"
        );
        assignment[to][degree][department] = DiplomaData({
            assignor: msg.sender,
            name: name,
            year: year,
            img: img,
            valid: true,
            reject: false,
            revoke: false
        });
        emit Award(msg.sender, to, degree, department);
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
        assignment[to][degree][department].revoke = true;
        emit Revoke(msg.sender, to, degree, department);
    }
}
