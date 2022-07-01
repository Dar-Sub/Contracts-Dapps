// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Donation {

    address owner;
    uint256 totalDonations;

    struct Donation {
        address donor;
        uint amount;
    }

    Donation donation;
    Donation[] donations;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        donation = Donation(
            msg.sender,
            msg.value
        );

        donations.push(donation);
        totalDonations += msg.value;
    }

    function getDonations() external view returns(Donation[] memory) {
        return donations;
    }

    function getTotalDonations() external view returns(uint) {
        return totalDonations;
    }
}
