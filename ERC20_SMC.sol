// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <0.9.0;

// -------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -------------------------------------------------

interface  ERC20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);


    // Get the total token supply
    function totalSupply() external view returns (uint256);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) external view returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) external returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) external returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract ERC20Token is ERC20Interface {
    string public override name = "daochoiBLC";
    string public override symbol = "DACHOI";
    uint8 public override decimals = 18;
    uint public override totalSupply;

    // Owner of this contract
    address public founder;

    // Balances for each account
    mapping(address => uint) public balances;

    // Owner of account approves the transfer of an amount to another account
    // Ex: 0x1111... (owner) allows 0x2222... (the spender) ---- 100 tokens
    // allowed[0x1111][0x2222] == 100; token
    mapping(address => mapping(address => uint)) allowed;

    constructor(uint _totalSupply) {
        totalSupply = _totalSupply;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256 balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokenValue) public override returns (bool success){
        require(balances[msg.sender] >= tokenValue, "Can not transfer due to insufficient balance");

        balances[to] += tokenValue;
        balances[msg.sender] -= tokenValue;

        emit Transfer(msg.sender, to, tokenValue);

        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256 remaining){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokenValue) public override returns (bool success){
        require(balances[msg.sender] >= tokenValue, "Can not approve due to insufficient balance");
        require(tokenValue >0, "Token must greater than 0");

        allowed[msg.sender][spender] = tokenValue;

        emit Approval(msg.sender, spender, tokenValue);

        return true;
    }

    function transferFrom(address from, address to, uint256 tokenValue) public override returns (bool success){
        require(allowed[from][msg.sender] >= tokenValue, "Can not transferFrom due to insufficient balance");
        require(balances[from] >= tokenValue);

        balances[to] += tokenValue;
        balances[from] -= tokenValue;
        allowed[from][msg.sender] -= tokenValue;

        emit Transfer(from, to, tokenValue);

        return true;
    }
}