# ethernaut-cn
ethernaut 学习笔记，记录解题思路和中间遇到的问题。

建议先看下我的环境配置。

| level | 概述 |
| --- |--- |
|[level1_fallback](level1_fallback/README.md)|利用fallback处理|

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
