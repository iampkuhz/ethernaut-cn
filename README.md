# ethernaut-cn

| level |标题| 考察点 |
| --- |---|--- |
|level0|[HelloEthernaut](src/level0_HW/README.md)|了解如何用浏览器控制台在 ethernaut 中交互|
|level1|[Fallback](src/level1_fallback/README.md)|了解 fallback/receive 函数, 提供 ethernaut 命令行和 remix 两种解决方法|
|level2|[Fallout](src/level2_fallout/README.md)|了解 constructor 构造函数|
|level3|[Coinflip](src/level3_coinflip/README.md)|了解合约的可预测性，调用前模拟调用结果|
|level4|[Telephone](src/level4_telephone/README.md)|了解 `tx.origin` 和 `msg.sender` 差别|
|level5|[Token](src/level5_token/README.md)|老版本 solidity 中 uint 溢出漏洞|
|level6|[Delegation](src/level6_delegation/README.md)|学习如何使用 `delegatecall`|
|level7|[Force](src/level7_force/README.md)|了解 `selfdestruct` 用法|
|level8|[Vault](src/level8_vault/README.md)|理解 solidity 中不存在真正 private 的变量，掌握读取 storage 内容的方法|
|level9|[King](src/level9_king/README.md)|了解 `receive` 函数的触发和执行特点|
|level10|[Reentrancy](src/level10_reentrancy/README.md)|了解重入漏洞和对应防护方式|
|level11|[Elevator](src/level11_elevator/README.md)|合约函数如何实现同样入参在不同的调用点返回不同的值|
|level12|[Privacy](src/level12_privacy/README.md)|合约 storage 存储规则入门|
|level13|[GatekeeperOne](src/level13_gatekeeper_one/README.md)|变量转换逻辑和跨合约调用的gas限制|
|level14|[GatekeeperTwo](src/level14_gatekeeper_two/README.md)|contructor 函数中调用外部合约的特殊逻辑|
|level15|[NaughtCoin](src/level15_naughtcoin/README.md)|`ERC-20` 常见接口的使用方式|
|level16|[Preservation](src/level16_preservation/README.md)|`delegatecall` 的使用方法，多次调用达到攻击目标|
|level17|[Recovery](src/level17_recovery/README.md)|`CREATE` 操作码创建合约时的合约地址生成规则|
|level18|[MagicNumber](src/level18_magicnumber/README.md)|合约编译生成的字节码规范，字节码与操作码的关系，字节码执行逻辑|
|level19|[AlienCodex](src/level19_allencodex/README.md)|合约 storage 中 array 的存储位置计算|
|level20|[Denial](src/level20_denial/README.md)|`receive` 函数循环调用风险|
|level21|[Shop](src/level21_shop/README.md)|`view` 函数特性|
|level22|[Dex](src/level22_dex/README.md)|`DEX` 中 price 算法的重要性|
|level23|[DexTwo](src/level23_dex_two/README.md)|`DEX` 中的必要校验|
|level24|[PuzzleWallet](src/level24_puzzle_wallet/README.md)|`delegatecall` 不改变 `storage`, `msg.sender`, `msg.value` 等信息|



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
forge install OpenZeppelin/openzeppelin-contracts 
```
