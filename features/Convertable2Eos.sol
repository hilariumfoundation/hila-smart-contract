pragma solidity ^0.4.21;

import "./Ownable.sol";
import "./Pausable.sol";
import "./Lockable.sol";

contract Convertable2Eos is Ownable, Pausable, Lockable {
    
    mapping (address => string) private eosAccounts;

    // only account owner can set eos account info.
    function setEosAccount(string eosAccount) public whenNotPaused whenNotLocked {
        require( utfStringLength(eosAccount) == 12, "eos account length should be 12 characters!");
        eosAccounts[msg.sender] = eosAccount;
    }

    function getEosAccount(address account) public view returns (string) {

        return eosAccounts[account];
    }

    function myEosAccount() public view returns (string) {

        return eosAccounts[msg.sender];
    }

    function utfStringLength(string str) private pure returns (uint length)
    {
        uint i=0;
        bytes memory string_rep = bytes(str);

        while (i<string_rep.length)
        {
            if (string_rep[i]>>7==0)
                i+=1;
            else if (string_rep[i]>>5==0x6)
                i+=2;
            else if (string_rep[i]>>4==0xE)
                i+=3;
            else if (string_rep[i]>>3==0x1E)
                i+=4;
            else
                //For safety
                i+=1;

            length++;
        }
    }

}
