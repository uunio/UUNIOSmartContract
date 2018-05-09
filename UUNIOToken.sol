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


contract QRC20 {

    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    

    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        
        owner = msg.sender;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract BasicToken is QRC20 {
    

    using Math for uint256;
    
    uint256 totalSupply_;    
    mapping(address => uint256) balances_;

    function totalSupply() public view returns (uint256) {
        
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));
        require(_value <= balances_[msg.sender]);

        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances_[_owner];
    }
}


contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value <= balances_[msg.sender]);
        address burner = msg.sender;
        balances_[burner] = balances_[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
    }
}


contract StandardToken is QRC20, BasicToken {


    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns const (bool) {

        require(_to != address(0));
        require(_value <= balances_[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        
        return allowed[_owner][_spender];
    }
}


contract UUNIO is StandardToken, BurnableToken, Ownable {

    
    using Math for uint;

    string constant public symbol  = "UUNIO";
    string constant public name    = "UUNIO";
    uint8 constant public decimals = 8;

    uint256 constant INITIAL_SUPPLY   = 900000000e8;



    // MAINNET
    address team      = 0x9c619ff74015becc48d429755aa54435ba367e23;
    address advisors  = 0xb4fca416727c92f5dbfc1d3c248f9a50b9f811fe;
    address reserve   = 0x8e2c648f493323623c2a55010953ae2b98ec7675;
    address system    = 0x91c2ccf957c32a3f37125240942e97c1bd2ac394;
    address angel     = 0x3f957fc80cdf9ad2a9d78c3afd13a75099a167b3;
    address partners  = 0x8f3e215c76b312fd28fbaaf16fe98d6e9357b8ab;
    address preSale   = 0x39401cd3f45c682bbb75ea4d3add4e268b19d0fc;
    address crowdSale = 0xb06dd470c23979f8331e790d47866130001e7492;
    address benefit   = 0x0ff19b60b84040019ea6b46e6314367484f66f8f;
    
    // TESTNET
    // address team        = 0x08cF66b63c2995c7Cc611f58c3Df1305a1E46ba7;
    // address advisors    = 0xCf456ED49752F0376aFd6d8Ed2CC6e959E57C086;
    // address reserve     = 0x9F1046F1e85640256E2303AC807F895C5c0b862b;
    // address system      = 0xC97eFe0481964b344Df74e8Fa09b194010736A62;
    // address angel       = 0xd03631463a266A749C666E6066D835bDAD307FB8;
    // address partners    = 0xd03631463a266A749C666E6066D835bDAD307FB8;
    // address preSale     = 0xd03631463a266A749C666E6066D835bDAD307FB8;
    // address crowdSale   = 0xd03631463a266A749C666E6066D835bDAD307FB8;
    // address beneficiary = 0x08cF66b63c2995c7Cc611f58c3Df1305a1E46ba7;

    // 10%
    uint constant teamTokens      = 90000000e8;
    // 10%    
    uint constant advisorsTokens  = 90000000e8;
    // 30%    
    uint constant reserveTokens   = 270000000e8;
    // 15.14%
    uint constant systemTokens    = 130000000e8;
    // 5.556684%
    uint constant angelTokens     = 50010156e8;
    // 2.360022%
    uint constant partnersTokens  = 21240198e8;
    // 15.275652%
    uint constant preSaleTokens   = 137480868e8;
    // 11.667642%
    uint constant crowdSaleTokens = 105008778e8;

    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        preFixed(team, teamTokens);
        preFixed(advisors, advisorsTokens);
        preFixed(reserve, reserveTokens);
        preFixed(system, systemTokens);
        preFixed(angel, angelTokens);
        preFixed(partners, partnersTokens);
        preFixed(preSale, preSaleTokens);
        preFixed(crowdSale, crowdSaleTokens);
    }

    function preFixed(address _address, uint _amount) internal returns (bool) {
        balances_[_address] = _amount;
        emit Transfer(address(0x0), _address, _amount);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        return super.transferFrom(_from, _to, _value);
    }

    function () public payable {
        require(msg.value >= 1e8);
        benefit.transfer(msg.value);
    }
}