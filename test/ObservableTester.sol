pragma solidity ^0.4.21;

import "../token/ITokenEventListener.sol";
import "../math/SafeMath.sol";


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract ObservableTester is ITokenEventListener, SafeMath {

    uint256 public sum;

    event TokenEvent(address from, address to, uint256 value);

    constructor() public {}

    function onTokenTransfer(address _from, address _to, uint256 _value) external {

        sum = safeAdd(sum, _value);
        emit TokenEvent(_from, _to, _value);
    }

}