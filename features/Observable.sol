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

    function resetListener() public onlyOwner {

        delete eventListener;
    }

    function hasListener() internal view returns(bool) {
        
        return eventListener != address(0);
    }


}
