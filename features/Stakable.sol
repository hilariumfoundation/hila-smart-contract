pragma solidity ^0.4.21;

import "./Ownable.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Stakable is Ownable {
    
    struct StakeInfo {
        uint updated;
        uint256 amount;        
    }

    uint public stakeStartTime;
    uint public stakeEndTime;

    mapping(address=>StakeInfo) stakes;

    event Staked();
    event Unstaked();

    event StakeUpdated(address account, uint256 staked);

    function updateStake(address account, uint256 balance) internal {

        if (!staking()) return;

        StakeInfo storage stake = stakes[account];

        if ( stake.updated == 0 || balance < stake.amount ) {
            stake.updated = now;
            stake.amount = balance;
        }
    }

    function stake() public onlyOwner {
        require(!staking(), "already being staked!");
        require(!stakeEnded(), "stake finished!");
        stakeStartTime = now;
    }

    //function confirmStake() public onlyOwner {}

    function unstake() public onlyOwner {
        require(staking(), "not staking!");
        stakeEndTime = now;
    }

    function stakeHasnotStarted() internal view returns (bool) {
        return stakeStartTime == 0;
    }

    function staking() public view returns (bool) {
        return stakeStartTime != 0 && stakeEndTime == 0;
    }

    function stakeEnded() public view returns (bool) {
        return stakeEndTime != 0;
    }

}
