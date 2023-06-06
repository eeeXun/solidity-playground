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
    // receiver address => degree => data
    mapping(address => mapping(string => DiplomaData)) assignment;

    event Award(address receiver, string degree);
    event Revoke(address receiver, string degree);

    // Award without image
    function award(
        address to,
        string memory name,
        string memory degree,
        uint256 year
    ) public {
        assignment[to][degree] = DiplomaData({
            assignor: msg.sender,
            name: name,
            year: year,
            img: "",
            revoke: false
        });
        emit Award(to, degree);
    }

    // Award with image
    function award(
        address to,
        string memory name,
        string memory degree,
        string memory img,
        uint256 year
    ) public {
        assignment[to][degree] = DiplomaData({
            assignor: msg.sender,
            name: name,
            year: year,
            img: img,
            revoke: false
        });
        emit Award(to, degree);
    }

    // Revoke diploma
    function revoke(address to, string memory degree) public {
        require(
            assignment[to][degree].assignor == msg.sender,
            "You can't revoke the diploma!"
        );
        assignment[to][degree].revoke = true;
        emit Revoke(to, degree);
    }
}
