pragma solidity ^0.4.21;

import "../HILA.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract HILATester is HILA {

    address acc1 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    address acc2 = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;

    uint256 public debugNum;
    uint256 public debugString;

    event Debug(string text, uint256 number);

    constructor() public {}

    function resetTest() private {

        //reset balances
        burn(owner, balanceOf(owner));
        burn(acc1, balanceOf(acc1));

        //reset stakes
        stakedTime = 0;
        unstakedTime = 0;

        stakes[owner].updated = 0;
        stakes[acc1].updated = 0;

        //set balance 1000 to owner
        issue(owner, 1000);
    }

    function testStake() public onlyOwner {

        resetTest();    

        require(balanceOf(owner)==1000, "0.init. balance of owner != 1000");
        require(balanceOf(acc1)==0, "0.init. balance of acc1 != 0");
        require(balanceOf(acc1)==0, "0.init. balance of acc2 != 0");

        debugNum = stakedAmount(owner);
        require(stakedAmount(owner)==0, "0.owner stake != 0");
        require(stakedAmount(acc1)==0, "0.acc1 stake != 0");
        require(stakedAmount(acc2)==0, "0.acc2 stake != 0");

        transfer(acc1, 500);
        stake();
        confirmStake();
        require(stakedAmount(owner)==500, "1.owner stake != 500");
        require(stakedAmount(acc1)==500, "1.acc1 stake != 500");
        require(stakedAmount(acc2)==0, "1.acc2 stake != 0");

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "2.owner stake != 400"); //400
        require(stakedAmount(acc1)==500, "2.acc1 stake != 500"); //600
        require(stakedAmount(acc2)==0, "2.acc2 stake != 0");

        allowed[acc1][owner] = 300;
        transferFrom(acc1, owner, 300);
        require(stakedAmount(owner)==400, "3.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "3.acc1 stake != 300"); //300
        require(stakedAmount(acc2)==0, "3.acc2 stake != 0");

        unstake();
        confirmUnstake();
        require(unstaked(), "stake should have been ended");
        require(stakedAmount(owner)==400, "4.owner stake != 400"); //700
        require(stakedAmount(acc1)==300, "4.acc1 stake != 300"); //300
        require(stakedAmount(acc2)==0, "4.acc2 stake != 0");

        transfer(acc1, 100);
        require(stakedAmount(owner)==400, "5.owner stake != 400"); //600
        require(stakedAmount(acc1)==300, "5.acc1 stake != 300"); //400

        allowed[acc1][owner] = 200;
        transferFrom(acc1, owner, 200);
        require(stakedAmount(owner)==400, "4.owner stake != 400"); //800
        require(stakedAmount(acc1)==300, "4.acc1 stake != 300"); //200
        require(stakedAmount(acc2)==0, "4.acc2 stake != 0");

        transfer(acc2, 300);
        require(stakedAmount(owner)==400, "7.owner stake != 400"); //500
        require(stakedAmount(acc1)==300, "7.acc1 stake != 300"); //200
        require(stakedAmount(acc2)==0, "7.acc1 stake != 0"); //300

        //debugNum = stakedAmount(acc1);
        //require(stakedAmount(acc1)==500, uint2str(stakedAmount(acc1)));
    }

    function testDebugNum() external {
        debugNum = 100;
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