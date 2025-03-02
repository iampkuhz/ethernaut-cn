# level 13: Gatekeeper One

## 1. 问题

要求你成功调用 `GatekeeperOne` 合约的 `enter` 函数，函数成功执行，可以通过函数内的所有校验。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
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

1. `gateOne` 只校验 `msg.sender != tx.origin`, 我们只要通过一个中间合约来调用 `GatekeeperOne` 合约即可通过这个校验

3. 我们先看 `gateThree`, 他需要入参 `_gateKey` 满足几个类型转换结果。我们用chisel做一下测试：

```solidity
// 测试一下截取情况
bytes8 _gateKey=hex"0102030405060708";
// 看下几个require语句中左边的目标值
uint32 left = uint32(uint64(_gateKey))
// 看下第一个require右边的值
uint16 right1 = uint16(uint64(_gateKey))
// 看下第二个require右边的值
uint64 right2 = uint64(_gateKey)
// 随便找一个随机的地址，看下第三个require右边的值
uint16 right3 = uint16(uint160(address(bytes20(hex"D5691358Aa1b5eBB8af26Ad0Aba3CBD74b31690a"))))
```

![](../../resources/img/level13_gatekeeperone/cut.png)

通过观察上面的结果我们发现:

* left和right1只在 `0506` 所在的2个字节处理不一样，如果想要第一个require满足，我们只要将 `_gateKey` 的这2个字节设置为0
* left和right2在 `05060708`这四个字节处理是一样的，所以如果想要第二个require满足，也就是想要left不等于right，那么 `_gateKey` 的前4个字节不能都为0
* right3会把原始地址的最后2个字节保留，所以如果第三个require要满足，如果想要left和right3相等，那么 `_gateKey` 的最后2个字节要和 `tx.orign`, 也就是我们的EOA地址一致

3. 我们使用的EOA地址结尾为 `fB2c`, 所以我们设置的 `_gateKey` 为 `0x010203040000fb2c`

3. 我们最后看`gateTwo`。 他要求 `gasleft() % 8191 == 0`。一方面我们可以通过 `GatekeeperOne.call{gas: XXX}(abi.encodeWithSignature("enter(bytes8)", YYYY))` 来设置 `enter` 函数的总 gas。

4. 因为函数的入参传递等操作也可能消耗gas，所以我们很难直接估算出一个精确的gas。针对这个问题，我们先将合约部署，通过 `foundry` 提供的 `cast` 命令测试出这个精确的gas。脚本如下：

```bash
export ETH_RPC_URL="https://sepolia.infura.io/v3/YOUR_INFURA_KEY"

echo "Testing myCall with different gas limits..."

for i in {5000..5100}
do
  # 执行 cast call 并捕获返回值
  RESULT=$(cast call 0xb5858B8EDE0030e46C0Ac1aaAedea8Fb71EF423C "myCall(bytes8,uint256)" 0x010203040000fb2c $i --gas-limit $i --rpc-url $ETH_RPC_URL 2>&1)

  # 检查是否失败（错误信息通常会包含 "reverted" 或 "error"）
  if echo "$RESULT" | grep -qiE "error|revert"; then
    echo "❌ Gas: $i -> Failed"
  else
    echo "✅ Gas: $i -> Success!"
    echo "   ↳ Response: $RESULT"  # 打印成功返回值
  fi
done
```



## 3. 补充说明

### 3.1. `forge test` 和 `forge script` 都无法找到满足条件的 gas 值

TODO
4. 执行forge test，真实调用rpc

```bash
# 需要将这个url换成自己的url
forge test -vv --match-contract TestGatekeeperOneGasLeft --rpc-url $SEPOLIA_RPC_URL
```