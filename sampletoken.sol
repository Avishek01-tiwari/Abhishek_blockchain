// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SampleToken is ERC20 {
constructor(uint256 initialSupply) ERC20("SampleToken", "STK") {
_mint(msg.sender, initialSupply);
}
}
