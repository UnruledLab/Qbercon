pragma solidity ^0.4.19;
import "./StandardToken.sol";
import "./Ownable.sol";

/**
 * @title QBXToken
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract QBXToken is StandardToken, Ownable {

  string public constant name = "QBX";
  string public constant symbol = "QBX";
  uint8 public constant decimals = 18;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  address public saleAgent = address(0);

  modifier canMint() {
    require(mintingFinished);
    _;
  }

  function setSaleAgent(address newSaleAgnet) public {
    require(msg.sender == saleAgent || msg.sender == owner);
    saleAgent = newSaleAgnet;
  }
  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint public returns (bool) {
    require(msg.sender == saleAgent || msg.sender == owner);
    totalSupply = totalSupply.sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() canMint public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner));
    mintingFinished = true;
    MintFinished();
    return true;
  }

  event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(msg.sender == saleAgent || msg.sender == owner);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

  function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(msg.sender == saleAgent || msg.sender == owner);
        // Check if the targeted balance is enough
        require(balances[_from] <= _value);
        // Check allowance
        require(_value <= allowed[_from][msg.sender]);
        // Subtract from the targeted balance
        balances[_from] = balances[_from].sub(_value);
         // Subtract from the sender's allowance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].add(_value);
        // Update totalSupply
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
    }
}