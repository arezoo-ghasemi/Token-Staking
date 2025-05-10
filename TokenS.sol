// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenS is ERC20 {
    constructor() ERC20("TokenS","TKS") {
        _mint(msg.sender, 10_000*1e18);
    }
}