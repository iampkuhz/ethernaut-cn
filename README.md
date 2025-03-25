# ethernaut-cn

| level |标题| 考察点 |
| --- |---|--- |
|level0|[HelloEthernaut](src/level0_HW/README.md)|了解如何用浏览器控制台在ethernaut中交互|
|level1|[Fallback](src/level1_fallback/README.md)|了解fallback/receive函数, 提供ethernaut命令行和remix两种解决方法|
|level2|[Fallout](src/level2_fallout/README.md)|了解constructor构造函数|
|level3|[Coinflip](src/level3_coinflip/README.md)|了解合约的可预测性，调用前模拟调用结果|
|level4|[Telephone](src/level4_telephone/README.md)|了解tx.origin和tx.sender差别|
|level5|[Token](src/level5_token/README.md)|老版本solidity中uint溢出漏洞|
|level6|[Delegation](src/level6_delegation/README.md)|学习如何使用delegatecall|
|level7|[Force](src/level7_force/README.md)|了解`selfdestruct`用法|
|level8|[Vault](src/level8_vault/README.md)|理解solidity中不存在真正private的变量，掌握读取storage内容的方法|
|level9|[King](src/level9_king/README.md)|了解receive函数的触发和执行特点|
|level10|[Reentrancy](src/level10_reentrancy/README.md)|了解重入漏洞和对应防护方式|
|level11|[Elevator](src/level11_elevator/README.md)|合约函数如何实现同样入参在不同的调用点返回不同的值|
|level12|[Privacy](src/level12_privacy/README.md)|合约storage存储规则入门|
|level13|[GatekeeperOne](src/level13_gatekeeper_one/README.md)|变量转换逻辑和跨合约调用的gas限制|
|level14|[GatekeeperTwo](src/level14_gatekeeper_two/README.md)|contructor函数中调用外部合约的特殊逻辑|
|level15|[NaughtCoin](src/level15_naughtcoin/README.md)|`ERC-20`常见接口的使用方式|
|level16|[Preservation](src/level16_preservation/README.md)|`delegatecall`的使用方法，多次调用达到攻击目标|



## 环境配置
1. 有些涉及调试过程和测试代码，我使用的 `vscode + foundry` 开发测试。为了对 `foundry` 的工程有更好的适配，建议 `vscode` 做如下配置

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

2. 安装foundry 依赖：

```
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```
