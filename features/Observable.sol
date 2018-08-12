pragma solidity ^0.4.21;


import "../token/ITokenEventListener.sol";
import "../features/Ownable.sol";


/**
 * @title ObservableToken
  * @dev All transfers can be monitored by token event listener
 */
contract Observable is Ownable {

    ITokenEventListener public eventListener;                                   //Listen events

    /**
     * @dev ManagedToken constructor
     * @param _listener Token listener(address can be 0x0)
     */
    constructor(address _listener) public {
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

    function hasListener() internal view returns(bool) {
        
        return eventListener != address(0);
    }
    
    /*

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
    
    */




}
