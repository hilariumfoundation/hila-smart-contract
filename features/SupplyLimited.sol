pragma solidity ^0.4.21;

import "../math/SafeMath.sol";
import "./Ownable.sol";

/**
 * @title LimitedSupply
 * @dev Maximum supply limit 
 */
contract SupplyLimited is SafeMath {
    
    uint256 public maxSupply;

    event MaxSupplyChanged(uint256 max);

    constructor() public {}

    function overMaxLimit(uint256 _totalSupply, uint256 _value) internal view returns (bool) {

        return safeAdd(_totalSupply, _value) > maxSupply;
    }

    function withinMaxLimit(uint256 _totalSupply, uint256 _value) internal view returns (bool) {

        return safeAdd(_totalSupply, _value) <= maxSupply;
    }



}
