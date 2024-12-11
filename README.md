# ethernaut-cn
ethernaut 学习笔记，记录解题思路和中间遇到的问题。

建议先看下我的环境配置。

| level | 概述 |
| --- |--- |
|[HelloEthernaut](src/leve0_HW/README.md)|了解如何用浏览器控制台在ethernaut中交互|
|[level1_fallback](src/level1_fallback/README.md)|了解fallback/receive函数, 提供ethernaut命令行和remix两种解决方法|
|[level2_fallout](src/level2_fallout/README.md)|了解constructor构造函数|
|[level3_coinflip](src/level3_coinflip/README.md)|了解合约的可预测性，调用前模拟调用结果|


## 环境配置
1. 有些涉及调试过程和测试代码，我使用的vscode + foundry开发测试。vscode为了对foundry的工程有更好的适配，建议做如下配置

```json
{
    ...
    "solidity.remappings": [
        "forge-std/=lib/forge-std/src/",
        "@openzeppelin/=lib/openzeppelin-contracts/"
    ],
    "solidity.packageDefaultDependenciesContractsDirectory": "lib",
    "solidity.packageDefaultDependenciesDirectory": "src",
    "[solidity]": {
        "editor.defaultFormatter": "JuanBlanco.solidity"
    },
    "solidity.formatter": "forge"
    ...
}
```
