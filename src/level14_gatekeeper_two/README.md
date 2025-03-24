
# level 14: Gatekeeper Two

## 1. 问题

要求你成功调用 `GatekeeperTwo` 合约的 `enter` 函数，函数成功执行不抛异常。也就是可以通过函数内的所有校验。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
```


## 2. 解法

函数有3个 `modifier`, 我们只要分别通过这个校验即可

### 2.1. `gateOne`

1. `gateOne` 只校验 `msg.sender != tx.origin`, 我们只要通过一个中间合约来调用 `GatekeeperOne` 合约即可通过这个校验


### 2.2. `gateTwo` 

2. `gateTwo` 要求 `extcodesize(caller())` 值为 0. 这个看似要求调用方不是合约地址。但是实际上在合约部署时，合约的 `constructor` 函数内调用其他合约时，因为当前合约没有部署完成，所以 `extcodesize(**)` 会返回 `0`。

> [!NOTE]
> 1. 如果单纯想判断调用方是否是EOA，使用 `tx.origin == msg.sender` 来判断更准确
> 2. 真实情况，绝大部分合约的接口都需要支持合约调用，这个校验不可能部署到所有接口，适用场景有限


### 2.3. `gateThree`

3. 异或操作 `^` 满足 `如果 A^B=C，那么 A^C=A^(A^B)=(A^A)^B=0^B=B`。所以满足 `uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max` 的 `_gateeKey` 可以通过计算得到 `uint64(_gateKey) = uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ type(uint64).max`。这个值，我们通过合约自动算好填入。


4. 最终我们的hack合约如下：

```solidity
contract HackGatekeeperTwo {
    constructor(address _gk2) {
        GatekeeperTwo two = GatekeeperTwo(_gk2);
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(this)))) ^ type(uint64).max);
        two.enter(key);
    }
}
```

> [!TIP]
> 这里我们提供一个测试文件 [Level14.t.sol](../../test/level14/Level14.t.sol)
> 可以在提交之前进行本地调试，调试成功再在测试链上执行

5. 通过remix部署到sepolia上，交易地址 [0xeabf3add56d3e545c1e6469b3af6dd8657f15b20782c964401e8a58f1f1dd08d](https://sepolia.etherscan.io/tx/0xeabf3add56d3e545c1e6469b3af6dd8657f15b20782c964401e8a58f1f1dd08d)

6. 点击 `submit instance`， 提交通过！


| [⬅️ level13 GatekeeperOne](../level13_gatekeeper_one/README.md) | [level15 NaughtCoin ➡️](../level15_naughtcoin/README.md) |
|:------------------------------|--------------------------:|
