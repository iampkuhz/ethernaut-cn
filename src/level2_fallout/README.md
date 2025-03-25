# level2 Fallout

## 1. 问题

要求你将目标合约的 `owner` 修改为你自己的地址。

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

这个问题的原因是用户在编写合约时，未正确编写构造函数。
原本计划作为构造函数的 `constructor` 被错误地写成了 `Fal1out`。这可能是因为合约名字在后续修改时未同步更新，或者在初次编写时未发现该问题。

> [!IMPORTANT]
> 需要说明的是，为了防止出现类似问题，从 Solidity `0.4.22` 开始，构造函数必须使用关键字 `constructor(){...}` 声明，不能再通过合约的同名函数来实现构造函数。

1. 在 Ethernaut 中直接调用 `Fal1out`，控制台会唤起 MetaMask [提交交易到 Sepolia](https://sepolia.etherscan.io/tx/0xbc8f6e10e83031627679c22aa5f18effb9af0d47055c9f79d2e90d7b66cbf741)：


```bash
await contract.Fal1out();
```

2. 执行查询，查看 `owner`，确认已经更新为你的地址：

```bash
await contract.owner()
```

3. 点击 `submit instance`， 提交通过！



<br/>
<br/>
| [⬅️ level1 Fallback](../level1_fallback/README.md) | [level3 Coinflip ➡️](../level3_coinflip/README.md) |
| :---------------------------------------------- | -------------------------------------: |