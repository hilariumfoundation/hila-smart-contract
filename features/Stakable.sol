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

    uint public stakedTime;
    uint public unstakedTime;

    bool public stakeRequested;
    bool public unstakeRequested;

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
            emit StakeUpdated(account, balance);
        }
    }

    // stake start functions

    function stake() public onlyOwner {
        require(!staking(), "already staked!");
        require(!unstaked(), "already unstaked!");
        stakeRequested = true;
    }

    function confirmStake() public onlyOwner {
        require(stakeRequested, "stake was not requested!");
        stakedTime = now;
        emit Staked();
    }

    function cancelStake() public onlyOwner {
        require(stakeRequested, "stake was not requested!");
        stakeRequested = false;
    }

    // unstake functions
    function unstake() public onlyOwner {
        require(staking(), "not staking!");
        unstakeRequested = true;        
    }

    function confirmUnstake() public onlyOwner {
        require(unstakeRequested, "stake was not requested!");
        unstakedTime = now;
        emit Unstaked();
    }

    function cancelUnstake() public onlyOwner {
        require(unstakeRequested, "stake was not requested!");
        unstakeRequested = false;
    }

    // state check functions

    function stakeHasnotStarted() internal view returns (bool) {
        return stakedTime == 0;
    }

    function staking() public view returns (bool) {
        return stakedTime != 0 && unstakedTime == 0;
    }

    function unstaked() public view returns (bool) {
        return unstakedTime != 0;
    }

    function lastStakeUpdateTime(address account) public view returns (uint) {

        return stakes[account].updated;
    }
}
