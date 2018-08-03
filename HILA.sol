pragma solidity ^0.4.21;

import "./token/ManagedToken.sol";

/**
 * HILA Token Contract
 * @title HILA
 */
contract HILA is ManagedToken {
    uint256 public minDeposit;                                                  //Min of value to deposit
    uint256 public coinPrice;                                                   //Parse ether to token: 1 ether = (coinPrice*(1 ether)) Token
    bool public isPause = false;                                                //Pause issue token when deposit
    bool public isLimitTime = false;                                            //Limit time to deposit to buy token
    uint256 public depositStartDate;                                            //Start date of deposit to buy token
    uint256 public depositEndDate;                                              //End date of deposit to buy token

    event WithdrawMoney(address _address, uint256 _value);
    event DepositEvent(address _address, uint256 _value, uint256 _token);

    /**
     * @dev HILA constructor
     * @param _coinPrice Price of coin(price should be greater 0)
     */
    constructor(uint256 _coinPrice, uint256 _depositStartDate, uint256 _depositEndDate) public ManagedToken(msg.sender, msg.sender) {
        name = "HILA";
        symbol = "HILA";
        decimals = 18;
        totalSupply = 1100000000 ether;                                          //The maximum number of tokens is unchanged and totals will decrease after issue
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
          require(now >= depositStartDate && now <= depositEndDate);
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
        require(!isPause, "Deposit to issue token is paused.");
        _;
    }

    /**
    * Deposit to buy token
    */
    function() payable public  {
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

    function paused(bool pause) external onlyOwner {
        isPause = pause;
    }

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
        require(_address != address(0));
        require(_value <= address(this).balance);
        _address.transfer(_value);
        emit WithdrawMoney(_address, _value);
    }
}