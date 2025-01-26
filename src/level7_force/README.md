# level7 Force

## 1. 问题

请向一个名为 `Force` 的合约转入 ETH。由于该合约未定义 `payable` 的 `fallback` 函数，因此无法通过正常方式转入 ETH。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force { /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
    /~____  =ø= /
    (______)__m_m)
                   */ }
```

## 2. 解法

> [!CAUTION]
> 虽然我们可以在 Remix 中编译一个包含 `fallback` 函数的同名合约，并通过 Remix 的 `transact` 功能尝试向该合约地址转入 ETH，但 Remix 会提示该调用失败，实际交易也会失败：[交易链接](https://sepolia.etherscan.io/tx/0x1ee7710bd3416e6d7f2e3cbffa86f9aa0c63acede4911c63ac41f9843016c0b6)。

我们只能使用 `selfdestruct` 来实现。这一操作码允许我们销毁自己的合约，并将合约中的剩余资产强制转入指定地址：

```solidity
contract ForceDeposit {
    function deposit(address _f) external payable {
        selfdestruct(payable(_f));
    }
}
```

1. 在 Remix 中编译并部署合约：[部署交易链接](https://sepolia.etherscan.io/tx/0xa3f89f6dfd5f64b3416886ef910ccb866f6f71eeda57904dda3097033f2ab2a0)。

2. 调用 `deposit` 函数（注意需输入转入的 ETH）：[交易链接](https://sepolia.etherscan.io/tx/0x5a986c173f0ac85c753163d28d39959c623ecfe9beb4d1cbb9a83e833663cf94)。

## 3. 补充说明: selfdestruct在cancun-deneb升级时执行效果变更（EIP-6780)

https://consensys.io/blog/ethereum-dencun-upgrade-explained-part-1

> [!NOTE]
> cancun是执行层升级的代号，dencun是共识层升级的代号

1. EIP-6780 对 `selfdestruct` 的改动：
   - 如果在合约部署的 `constructor` 中执行 `selfdestruct`，则仍会删除合约代码。
   - 如果在后续交易中执行 `selfdestruct`，则不会删除账户和代码，仅转出 ETH。

2. 此改动主要为后续的 Verkle 树升级提供兼容性。每次删除数据时，该路径上的所有信息都需要变更，增加了操作负担。

| [⬅️ level6 delegation](../level6_delegation/README.md) | [level7 vault ➡️](../level8_vault/README.md) |
|:------------------------------|--------------------------:|