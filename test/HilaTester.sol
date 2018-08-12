pragma solidity ^0.4.21;

import "../HILA.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract HILATester is HILA {

    address acc1 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;

    constructor() public {}

    function resetTest() private {

        //reset balances
        burn(owner, balanceOf(owner));
        burn(acc1, balanceOf(acc1));

        //reset stakes
        stakeStartTime = 0;
        stakeEndTime = 0;

        stakes[owner].updated = 0;
        stakes[acc1].updated = 0;

        //set balance 1000 to owner
        issue(owner, 1000);
    }

    function testStake() public onlyOwner {

        resetTest();    

        require(stakedAmount(owner)==0, uint2str(stakedAmount(owner)));
        require(stakedAmount(owner)==0, "0.owner stake != 0");
        require(stakedAmount(acc1)==0, "0.acc1 stake != 0");

        transfer(acc1, 500);
        stake();
        require(stakedAmount(owner)==500, "1.owner stake != 500");
        require(stakedAmount(acc1)==500, "1.acc1 stake != 500");

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "2.owner stake != 400"); //400
        require(stakedAmount(acc1)==500, "2.acc1 stake != 500"); //600

        allowed[acc1][owner] = 300;
        transferFrom(acc1, owner, 300);
        require(stakedAmount(owner)==400, "3.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "3.acc1 stake != 300"); //300

        unstake();
        require(stakeEnded(), "stake should have been ended");
        require(stakedAmount(owner)==400, "4.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "4.acc1 stake != 300"); //300

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "5.owner stake != 400"); //600
        require(stakedAmount(acc1)==300, "5.acc1 stake != 300"); //400

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