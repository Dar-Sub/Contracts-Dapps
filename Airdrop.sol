Pragma solidity ^0.8.6;

contract airdrop {

uint stakingWallet = 10;

function airdrop() public view returns(uint) {
if(stakingWallet == 10){
   return stakingWallet + 10;
} else {
   return stakingWallet + 1;
}
}
}
