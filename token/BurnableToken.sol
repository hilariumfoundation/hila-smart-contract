pragma solidity ^0.4.21;


import "../features/Ownable.sol";
import "../features/SupplyLimited.sol";
import "../token/ERC20Token.sol";

/**
 * @title Issuable
 */
contract BurnableToken is Ownable, ERC20Token {

    bool public burningAllowed = true;                                       
    event Burn(address indexed _to, uint256 _value);                         

    event CanBurn();                                                   
    event CannotBurn();      

    constructor() public {}

    //Modifier: Allow continue to issue
    modifier canBurn() {
        require(burningAllowed, "token burning is not allowed!");
        _;
    }

    /**
     * @dev Burn tokens on specified address (Called byallowance owner or token holder)
     * @dev Fund contract address must be in the list of owners to burn token during refund
     * @param _from Wallet address
     * @param _value Amount of tokens to destroy
     */
    function burn(address _from, uint256 _value) public onlyOwner canBurn {
        require(balances[_from] >= _value, "balance is smaller than the burning amount!");

        totalSupply = safeSub(totalSupply, _value);
        balances[_from] = safeSub(balances[_from], _value);

        emit Transfer(_from, address(0), _value);
        //Call event
        emit Burn(_from, _value);
    }

    function blockburning() public onlyOwner {
        require(burningAllowed, "burning is already blocked!");
        burningAllowed = false;
        emit CannotBurn();
    }

    function allowburning() public onlyOwner {
        require(!burningAllowed, "burning is already allowed!");
        burningAllowed = true;
        emit CanBurn();
    }

}
