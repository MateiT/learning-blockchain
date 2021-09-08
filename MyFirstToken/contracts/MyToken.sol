// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "./IERC20.sol";

contract NiceToken is IERC20 {
    string name;
    string symbol;
    uint256 totalAmount;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        totalAmount = 100000000000000000000; //100
        balances[msg.sender] = totalAmount;
    }

    function totalSupply() external view override returns (uint256) {
        return totalAmount;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(amount <= balances[sender]);
        balances[sender] -= amount;
        balances[recipient] += amount;

        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        return _approve(msg.sender, spender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal returns (bool) {
        require(balances[owner] >= amount);
        allowances[owner][spender] = amount;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount);

        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }
}

}
