pragma solidity ^0.4.21;

import "./features/Pausable.sol";
import "./features/Lockable.sol";
import "./features/Stakable.sol";
import "./features/Observable.sol";

import "./token/IssuableToken.sol";
import "./token/BurnableToken.sol";


/**
 * HILA Token Contract
 * @title HILA
 */
contract HILA is Pausable, Lockable, IssuableToken, BurnableToken, Stakable, Observable {

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
        
        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transfer(_to, _value);
        if(success) {

            if ( staking() ) {
                updateStake(msg.sender, balanceOf(msg.sender) );
                updateStake(_to, prevToBalance );             
            }

            if (hasListener()) {
                eventListener.onTokenTransfer(msg.sender, _to, _value);
            }

        }

        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        
        require(!isLocked(_from), "account is locked!" );

        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transferFrom(_from, _to, _value);

        if(success) {

            if ( staking() ) {
                updateStake(_from, balanceOf(_from) );
                updateStake(_to, prevToBalance );             
            }

            if( hasListener()) {
                eventListener.onTokenTransfer(_from, _to, _value);
            }
        }
        return success;
    }
    
    function stakedAmount(address account) public view returns(uint256) {

        StakeInfo storage stake = stakes[account];
        return stake.updated == 0 ? balanceOf(account) : stake.amount;
    }
}