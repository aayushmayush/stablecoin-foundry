// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volatility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


error DecentralizedStableCoin_MustBeMoreThanZero();
error DecentralizedStableCoin_BurnAmountExceedsBalance();
error DecentralizedStableCoin__MustBeMoreThanZero()

contract DecentralizedStableCoin is ERC20Burnable,Ownable{
    constructor(address initialOwner) ERC20("DecentralizedStableCoin","DSC") Ownable(initialOwner){}



    function burn(uint256 _amount) public override onlyOwner{
        uint256 balance=balanceOf(msg.sender);

        if(balance<_amount){
            revert DecentralizedStableCoin_BurnAmountExceedsBalance();
        }
        //will call burn of parent class
        super.burn(_amount); 
    }


    function mint(address _to,uint256 _amount) external onlyOwner returns(bool){
        if(_amount <= 0){
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, amount)
        return true;
    }

    

}