pragma solidity ^0.4.21;

import "../features/Stakable.sol";
import "../token/ERC20Token.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract StakeTester is ERC20Token, Stakable {

    address acc1 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    address acc2 = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;

    constructor() public {

        owner = msg.sender;
        name = "Stake test token";
        symbol = "TOKEN";
        decimals = 0;
        totalSupply = 1000;

        resetTest();
    }

    function stakedAmount(address account) public view returns(uint256) {

        if (stakeHasnotStarted()) return 0;        
        StakeInfo storage stake = stakes[account];
        return stake.updated == 0 ? balanceOf(account) : stake.amount;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        
        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transfer(_to, _value);
        if(success) {

            if ( staking() ) {
                updateStake(msg.sender, balanceOf(msg.sender) );
                updateStake(_to, prevToBalance );             
            }
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        
        //require(!isLocked(_from), "account is locked!" );

        uint256 prevToBalance = balanceOf(_to);

        bool success = super.transferFrom(_from, _to, _value);

        if(success) {

            if ( staking() ) {
                updateStake(_from, balanceOf(_from) );
                updateStake(_to, prevToBalance );             
            }
        }
        return success;
    }

    function resetTest() private {

        //reset balances
        balances[owner] = totalSupply;
        balances[acc1] = 0;

        //reset stakes
        stakedTime = 0;
        unstakedTime = 0;

        stakes[owner].updated = 0;
        stakes[acc1].updated = 0;
    }

    function test() public onlyOwner {

        resetTest();    

        require(balanceOf(owner)==1000, "0.init. balance of owner != 1000");

        require(stakedAmount(owner)==0, "0.owner stake != 0");
        require(stakedAmount(acc1)==0, "0.acc1 stake != 0");
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        transfer(acc1, 500);
        stake();
        require(stakedAmount(owner)==500, "1.owner stake != 500");
        require(stakedAmount(acc1)==500, "1.acc1 stake != 500");
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "2.owner stake != 400"); //400
        require(stakedAmount(acc1)==500, "2.acc1 stake != 500"); //600
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        allowed[acc1][owner] = 300;
        transferFrom(acc1, owner, 300);
        require(stakedAmount(owner)==400, "3.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "3.acc1 stake != 300"); //300
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        unstake();
        require(unstaked(), "stake should have been ended");
        require(stakedAmount(owner)==400, "4.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "4.acc1 stake != 300"); //300
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "5.owner stake != 400"); //600
        require(stakedAmount(acc1)==300, "5.acc1 stake != 300"); //400

        transfer(acc2, 300);
        require(stakedAmount(owner)==400, "6.owner stake != 400"); //300
        require(stakedAmount(acc2)==0, "6.acc1 stake != 0"); //300


        //require(stakedAmount(acc1)==500, uint2str(stakedAmount(acc1)));
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}