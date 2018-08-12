pragma solidity ^0.4.21;

import "./Ownable.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Lockable is Ownable {
    
    mapping (address => bool) private locked;

    event Locked(address account);
    event Unlocked(address account);

    function isLocked(address account) public view returns (bool) {

        return locked[account];
    }

    modifier whenNotLocked() {
        require( !isLocked(msg.sender), "account is locked!" );
        _;
    }

    /**
    * @dev lock transfer of specific account.
    * @param account The address of account to lock.
    */
    function lock(address account) public onlyOwner {
        require( !isLocked(account), "already locked!" );
        locked[account] = true;

        emit Locked(account);
    }

    /**
    * @dev unlock transfer of specific account.
    * @param account The address of account to unlock.
    */
    function unlock(address account) public onlyOwner {
        require( isLocked(account), "already unlocked!" );
        locked[account] = false;

        emit Unlocked(account);
    }

}
