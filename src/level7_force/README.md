# level7 force

## 1. 问题
请你向一个叫做`Force` 的合约转入eth。这个合约没有定义过payable的fallback函数，所以不能向正常情况一样给他转入eth。

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
1. 我们虽然可以在remix中编译一个带fallback函数的同名合约，并且通过调用remix的transact功能强行向这个合约地址转入eth，但是发起式remix都会提示我们说这个调用会失败，实际也是失败的：[0x1ee7710bd3416e6d7f2e3cbffa86f9aa0c63acede4911c63ac41f9843016c0b6](https://sepolia.etherscan.io/tx/0x1ee7710bd3416e6d7f2e3cbffa86f9aa0c63acede4911c63ac41f9843016c0b6)

2. 我们只能使用`selfdestruct`来实现, 这个操作码支持我们强行销毁我们的合约并把合约中剩余的资产转出到指定地址:

```solidity
contract ForceDeposit {
    function deposit(address _f) external payable {
        selfdestruct(payable(_f));
    }
}
```

3. 我们在remix中编译部署:[0xa3f89f6dfd5f64b3416886ef910ccb866f6f71eeda57904dda3097033f2ab2a0](https://sepolia.etherscan.io/tx/0xa3f89f6dfd5f64b3416886ef910ccb866f6f71eeda57904dda3097033f2ab2a0)
4. 调用deposit(注意需要输入转入的eth)：[0x5a986c173f0ac85c753163d28d39959c623ecfe9beb4d1cbb9a83e833663cf94](https://sepolia.etherscan.io/tx/0x5a986c173f0ac85c753163d28d39959c623ecfe9beb4d1cbb9a83e833663cf94)

## 3. 补充说明: selfdestruct在cancun-deneb升级时执行效果变更（EIP-6780)

https://consensys.io/blog/ethereum-dencun-upgrade-explained-part-1

1. 注意：cancun是执行层升级的代号，dencun是共识层升级的代号
2. eip-6780对selfdestruct的改动：如果是在合约部署的Constructor里面就执行了selfdestruct，那么还是删除合约源码。但是如果是在后续交易里执行了selfdestruct，则不删除账户、code，只转走eth。
3. 主要是为了后续verkle升级做兼容准备。每次删除数据时，这个路径上所有信息都要变更，导致增加负担