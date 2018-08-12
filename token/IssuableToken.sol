pragma solidity ^0.4.21;


import "../features/Ownable.sol";
import "../features/SupplyLimited.sol";
import "../token/ERC20Token.sol";

/**
 * @title Issuable
 */
contract IssuableToken is Ownable, SupplyLimited, ERC20Token {

    bool public issuingAllowed = true;                                       
    event Issue(address indexed _to, uint256 _value);                        

    event CanIssue();                                                   
    event CannotIssue();                                                 

    constructor() public {}

    //Modifier: Allow continue to issue
    modifier canIssue() {
        require(issuingAllowed, "token issuing is not allowed!");
        _;
    }

    /**
     * @dev Issue tokens to specified wallet
     * @param _to Wallet address
     * @param _value Amount of tokens
     */
    function issue(address _to, uint256 _value) public onlyOwner canIssue {
        require(withinMaxLimit(totalSupply, _value), "exceeds maximum supply");
        totalSupply = safeAdd(totalSupply, _value);
        balances[_to] = safeAdd(balances[_to], _value);
        //Call event
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    function blockIssuing() public onlyOwner {
        require(issuingAllowed, "issuing is already blocked!");
        issuingAllowed = false;
        emit CannotIssue();
    }

    function allowIssuing() public onlyOwner {
        require(!issuingAllowed, "issuing is already allowed!");
        issuingAllowed = true;
        emit CanIssue();
    }

    function setMaxSupply(uint256 newMax) public onlyOwner {
        maxSupply = newMax;
        emit MaxSupplyChanged(maxSupply);
    }

}
