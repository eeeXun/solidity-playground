// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct DiplomaData {
    address assignor;
    string name;
    uint256 year;
    string img;
    bool revoke;
}

contract Diploma {
    // receiver address => degree => department => data
    mapping(address => mapping(string => mapping(string => DiplomaData))) assignment;

    // https://github.com/web3/web3.js/issues/535
    event Award(address indexed receiver, string degree, string department);
    event Revoke(address indexed receiver, string degree, string department);

    // Award without image
    function award(
        address to,
        string memory name,
        string memory degree,
        string memory department,
        uint256 year
    ) public {
        assignment[to][degree][department] = DiplomaData({
            assignor: msg.sender,
            name: name,
            year: year,
            img: "",
            revoke: false
        });
        emit Award(to, degree, department);
    }

    // Award with image
    function award(
        address to,
        string memory name,
        string memory degree,
        string memory department,
        string memory img,
        uint256 year
    ) public {
        assignment[to][degree][department] = DiplomaData({
            assignor: msg.sender,
            name: name,
            year: year,
            img: img,
            revoke: false
        });
        emit Award(to, degree, department);
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
        assignment[to][degree][department].revoke = true;
        emit Revoke(to, degree, department);
    }
}
