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

    string public version;
    
    /**
     * @dev HILA constructor
     */
    constructor() public Observable(0x0) {
        owner = msg.sender;
        name = "Hilarium";
        symbol = "HILA";
        decimals = 4;
        maxSupply = 200 * (10 ** 8) * (10**4);
        //maxSupply = 100; // test purpose
        
        version = "2.1";
    }

    function transfer(address _to, uint256 _value) public whenNotPaused whenNotLocked returns (bool) {
        
        address _from = msg.sender;

        uint256 prevFromBalance = balanceOf(_from);
        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transfer(_to, _value);
        
        if(success) {
            transferPostaction(_from, _to, _value, prevFromBalance, prevToBalance);
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        
        require( !isLocked(_from), "account is locked!" );

        uint256 prevFromBalance = balanceOf(_from);
        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transferFrom(_from, _to, _value);

        if(success) {
            transferPostaction(_from, _to, _value, prevFromBalance, prevToBalance);
        }
        return success;
    }

    function transferPostaction(address _from, address _to, uint256 _value, uint256 _prevFromBalance, uint256 _prevToBalance ) private {

        if ( staking() ) {
            updateStake(_from, balanceOf(_from) );
            updateStake(_to, _prevToBalance );             
        }
        else if ( unstaked() ) {
            updateStake(_from, _prevFromBalance );
            updateStake(_to, _prevToBalance );             
        }

        if( hasListener()) {
            eventListener.onTokenTransfer(_from, _to, _value);
        }
    }
    
    function stakedAmount(address account) public view returns(uint256) {

        StakeInfo storage stake = stakes[account];
        return stakeNotStarted()? 0 : stake.updated == 0 ? balanceOf(account) : stake.amount;
    }
}