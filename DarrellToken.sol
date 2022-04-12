// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract DarrelToken is ERC20 {
  constructor() ERC20('Darrel Token', 'DRT') {
    _mint(msg.sender, 1000000 * 10 ** 18);
  }
}
