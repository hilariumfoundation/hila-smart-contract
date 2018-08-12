pragma solidity ^0.4.21;


import "./ERC20Token.sol";
import "./ITokenEventListener.sol";
import "../features/Ownable.sol";
import "../features/LimitedSupply.sol";

/**
 * @title ManagedToken
 * @dev ERC20 compatible token with issue and destroy facilities
 * @dev All transfers can be monitored by token event listener
 */
contract ManagedToken_old is ERC20Token, Ownable, LimitedSupply {

    bool public issuanceFinished = false;                                       //Finished issuance

    ITokenEventListener public eventListener;                                   //Listen events

    //event AllowTransfersChanged(bool _newState);                                //Event:
    event Issue(address indexed _to, uint256 _value);                           //Event: Issue
    event Burn(address indexed _from, uint256 _value);                       //Event:
    event IssuanceFinished();                                                   //Event: Finished issuance

    //Modifier: Allow continue to issue
    modifier canIssue() {
        require(!issuanceFinished, "issuing was finished. can't issue anymore.");
        _;
    }

    /**
     * @dev ManagedToken constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owner of contract(address can be 0x0)
     */
    constructor(address _listener, address _owner) public Ownable(_owner) {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        }
    }

    /**
     * @dev Set/remove token event listener
     * @param _listener Listener address (Contract must implement ITokenEventListener interface)
     */
    function setListener(address _listener) public onlyOwner {
        if(_listener != address(0)) {
            eventListener = ITokenEventListener(_listener);
        } else {
            delete eventListener;
        }
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        bool success = super.transfer(_to, _value);
        if(hasListener() && success) {
            eventListener.onTokenTransfer(msg.sender, _to, _value);
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        bool success = super.transferFrom(_from, _to, _value);

        //If has Listenser and transfer success
        if(hasListener() && success) {
            //Call event listener
            eventListener.onTokenTransfer(_from, _to, _value);
        }
        return success;
    }

    function hasListener() internal view returns(bool) {
        
        return eventListener != address(0);
    }

    /**
     * @dev Issue tokens to specified wallet
     * @param _to Wallet address
     * @param _value Amount of tokens
     */
    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        require(withinMaxLimit(totalSupply, _value), "exceeds maximum supply");
        totalSupply = safeAdd(totalSupply, _value);
        balances[_to] = safeAdd(balances[_to], _value);
        //Call event
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    /**
     * @dev Burn tokens on specified address (Called byallowance owner or token holder)
     * @dev Fund contract address must be in the list of owners to burn token during refund
     * @param _from Wallet address
     * @param _value Amount of tokens to destroy
     */
    function burn(address _from, uint256 _value) external onlyOwner {
        require(balances[_from] >= _value);

        totalSupply = safeSub(totalSupply, _value);
        balances[_from] = safeSub(balances[_from], _value);

        emit Transfer(_from, address(0), _value);
        //Call event
        emit Burn(_from, _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From OpenZeppelin StandardToken.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From OpenZeppelin StandardToken.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Finish token issuance
     * @return True if success
     */
    function finishIssuance() public onlyOwner returns (bool) {
        issuanceFinished = true;
        //Call event
        emit IssuanceFinished();
        return true;
    }
}
