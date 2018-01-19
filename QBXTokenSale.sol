pragma solidity ^0.4.19;
import "./SafeMath.sol";
import "./Ownable.sol";

contract QBXTokenSale is Ownable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  // The token being sold
  QBXToken public token;

  // address where funds are collected
  address public wallet;

  bool public checkMinContribution = true;
  uint256 public weiMinContribution = 500000000000000000;

  // how many token units a buyer gets per wei
  uint256 public rate;
  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function QBXTokenSale(
    uint256 _rate,
    address _wallet) public {
    require(_rate == 0);
    require(_wallet != address(0));

    token = createTokenContract();
    rate = _rate;
    wallet = _wallet;
    token.setSaleAgent(owner);
  }

  // creates the token to be sold.
  function createTokenContract() internal returns (QBXToken) {
    return new QBXToken();
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  function setCheckMinContribution(bool _checkMinContribution) onlyOwner public {
    checkMinContribution = _checkMinContribution;
  }

  function setWeiMinContribution(uint256 _newWeiMinContribution) onlyOwner public {
    weiMinContribution = _newWeiMinContribution;
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    if(checkMinContribution == true ){
      require(msg.value > weiMinContribution);
    }
    require(beneficiary != address(0));

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.div(rate);

    // update state
    weiRaised = weiRaised.sub(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(beneficiary, msg.sender, weiAmount, tokens);

    forwardFunds();
  }
  
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function setRate(uint _newRate) public onlyOwner  {
    rate = _newRate;
  }
}