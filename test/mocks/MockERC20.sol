// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name_,string memory symbol_,address account_,uint256 initialSupply_) ERC20(name_,symbol_) {
          _mint(account_,initialSupply_);
    }



    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
