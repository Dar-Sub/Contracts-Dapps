// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Auction {

    address payable public beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestbid;
    bool ended;

    mapping(address => uint) pendingReturns;

    event highestBidIncrease(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {

        if(block.timestamp > auctionEndTime) revert("The Auction has ended!");
        if(msg.value <= highestbid) revert("Sorry, the bid is not high enough.");
        if(highestbid != 0) {
            pendingReturns[highestBidder] += highestbid;
        }
        highestBidder = msg.sender;
        highestbid = msg.value;

        emit highestBidIncrease(msg.sender, msg.value);

    }


    function withdraw() public payable returns(bool) {

        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender] = 0;
        }

        if(!payable(msg.sender).send(amount)) {
            pendingReturns[msg.sender] = amount;
        }
        return true;

    }


    function auctionEnd() public {

        if(block.timestamp < auctionEndTime) revert("The auction has not ended yet!");
        if(ended) revert("The auction is already over!");
        ended = true;
        emit auctionEnded(highestBidder, highestbid);
        beneficiary.transfer(highestbid);

    }


}
