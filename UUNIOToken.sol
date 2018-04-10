pragma solidity ^0.4.16;
// pragma solidity ^0.4.13;

library Math {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if(a == 0) { return 0; }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract QRC20Basic {


    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract QRC20 is QRC20Basic {


    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    

    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        
        owner = msg.sender;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract BasicToken is QRC20Basic {
    

    using SafeMath for uint256;
    
    uint256 totalSupply_;    
    mapping(address => uint256) balances;

    function totalSupply() public view returns (uint256) {
        
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }
}


contract BurnableToken is BasicToken {


    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(burner, _value);
    }
}


contract StandardToken is QRC20, BasicToken {


    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


contract UUNIOToken is StandardToken, BurnableToken, Ownable {

    
    using SafeMath for uint;

    string constant public symbol  = "UUNIO";
    string constant public name    = "UNNIOToken";
    uint8 constant public decimals = 8;
    uint256 INITIAL_SUPPLY         = 900000000e8;
    uint constant unlockTime       = 0000000000;

    address company     = 0x00;
    address team        = 0x00;
    address crowdsale   = 0x00;
    address beneficiary = 0x00;

    uint constant companyTokens   = 0e8;
    uint constant teamTokens      = 0e8;
    uint constant crowdsaleTokens = 0e8;


    function UUNIOToken() public {

        totalSupply_ = INITIAL_SUPPLY;

        preSale(company, companyTokens);
        preSale(team, teamTokens);
        preSale(crowdsale, crowdsaleTokens);
    }

    function preSale(address _address, uint _amount) internal returns (bool) {
        balances[_address] = _amount;
        Transfer(address(0x0), _address, _amount);
    }

    function checkPermissions(address _from) internal constant returns (bool) {

        if (_from == team && now < unlockTime) { return false; }
        if (_from == crowdsale || _from == company) { return true; }
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(msg.sender));
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(_from));
        super.transferFrom(_from, _to, _value);
    }

    function () public payable {

        require(msg.value >= 1e8);
        beneficiary.transfer(msg.value);
    }
}