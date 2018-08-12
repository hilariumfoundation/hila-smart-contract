pragma solidity ^0.4.21;

import "./features/Pausable.sol";
import "./features/Lockable.sol";
import "./features/Observable.sol";

import "./token/IssuableToken.sol";
import "./token/BurnableToken.sol";


/**
 * HILA Token Contract
 * @title HILA
 */
contract HILA_old is Pausable, Lockable, IssuableToken, BurnableToken, Observable {
    uint256 public minDeposit;                                                  //Min of value to deposit
    uint256 public coinPrice;                                                   //Parse ether to token: 1 ether = (coinPrice*(1 ether)) Token

    bool public isLimitTime = false;                                            //Limit time to deposit to buy token
    uint256 public depositStartDate;                                            //Start date of deposit to buy token
    uint256 public depositEndDate;                                              //End date of deposit to buy token

    event WithdrawMoney(address _address, uint256 _value);
    event DepositEvent(address _address, uint256 _value, uint256 _token);

    /**
     * @dev HILA constructor
     * @param _coinPrice Price of coin(price should be greater 0)
     */
    constructor(uint256 _coinPrice, uint256 _depositStartDate, uint256 _depositEndDate) public ObservableToken(msg.sender) {
        name = "HILA";
        symbol = "HILA";
        decimals = 4;
        maxSupply = 200 * (10 ** 8) * (10**decimals);                         //The maximum number of tokens is unchanged and totals will decrease after issue
        minDeposit = 0.01 ether;                                                //Default MIN of deposit is 0.01 ether.
        coinPrice = _coinPrice;                                                 //Price of coin can be changed.
        depositStartDate = _depositStartDate;                                   //Start time to deposit to buy token
        depositEndDate = _depositEndDate;                                       //End time to deposit to buy token
    }

    /**
     * Throws if called when allow check time and time is invalid
     */
    modifier checkTime() {
        if(isLimitTime){
            require(now >= depositStartDate && now <= depositEndDate, "out of deposit time limit!");
        }
        _;
    }

    /**
     * Throws if called when value is less than minDeposit
     */
    modifier checkValue() {
        require(msg.value >= minDeposit, "Deposit is required greater value of minDeposit");
        _;
    }

    /**
     * Throws if called when isPause = true
     */
    modifier canDeposit() {
        require(!paused, "Deposit to issue token is paused.");
        _;
    }

    /**
    * Deposit to buy token
    */
    function()  payable public {
        Deposit();
    }

    /**
     * Function Deposit private
     */
    function Deposit() private canDeposit checkTime checkValue{
        //Calculate number of token to issue
        uint256 value = safeMul(msg.value, coinPrice);
        //Check to have enough token to issue
        require(totalSupply >= value, "Not enough token to issue.");
        //Total of token can continue to issue
        totalSupply = safeSub(totalSupply, value);

        //Add token to Sender
        if(balances[msg.sender] == 0){
            balances[msg.sender] = value;
        }else{
            balances[msg.sender] = safeAdd(balances[msg.sender], value);
        }

        //Event transfer token to Sender
        emit DepositEvent(msg.sender, msg.value, value);
    }

    /**
      Begin: Set params by owner
    */

    function setPriceToken(uint256 _coinPrice) external onlyOwner {
        coinPrice = _coinPrice;
    }

    function setMinDeposit(uint256 _minDeposit) external onlyOwner {
        minDeposit = _minDeposit;
    }

    function setTotalSupply(uint256 _totalSupply) external onlyOwner {
        totalSupply = _totalSupply;
    }

    function setCheckTime(bool _isLimitTime) external onlyOwner {
        isLimitTime = _isLimitTime;
    }

    function setStartTimeDeposit(uint256 startTime) external onlyOwner {
        depositStartDate = startTime;
    }

    function setEndTimeDeposit(uint256 endTime) external onlyOwner {
        depositEndDate = endTime;
    }

    /**
      End: Set params by owner
    */

    /**
     * @dev Transfer money from contract wallet to an address _address
     * Function call only by owner
     * @param _address Wallet address (address is not 0x00)
     * @param _value Amount of money will be withdrawed
     */
    function withdraw(address _address, uint256 _value) external onlyOwner {
        require(_address != address(0), "invalid address!");
        require(_value <= address(this).balance, "balance is not enough to withdraw!");
        _address.transfer(_value);
        emit WithdrawMoney(_address, _value);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused whenNotLocked returns (bool) {

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused  returns (bool) {
        require(!isLocked(_from), "account is locked!" );
        return super.transferFrom(_from, _to, _value);
    }
}