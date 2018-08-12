pragma solidity ^0.4.21;

import "./features/Pausable.sol";
import "./features/Lockable.sol";
import "./features/Observable.sol";

import "./token/IssuableToken.sol";
import "./token/BurnableToken.sol";


/**
 * HILA Token Contract
 * @title HILA
 */
contract HILA is Pausable, Lockable, IssuableToken, BurnableToken, Observable {

    /**
     * @dev HILA constructor
     */
    constructor() public Observable(0x0) {
        owner = msg.sender;
        name = "HILA";
        symbol = "HILA";
        decimals = 4;
        maxSupply = 200 * (10 ** 8) * (10**4);
        //maxSupply = 100; // test purpose
    }

    function transfer(address _to, uint256 _value) public whenNotPaused whenNotLocked returns (bool) {
        
        bool success = super.transfer(_to, _value);
        if(hasListener() && success) {
            eventListener.onTokenTransfer(msg.sender, _to, _value);
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        
        require(!isLocked(_from), "account is locked!" );

        bool success = super.transferFrom(_from, _to, _value);

        //If has Listenser and transfer success
        if(hasListener() && success) {
            eventListener.onTokenTransfer(_from, _to, _value);
        }
        return success;
    }
    

}