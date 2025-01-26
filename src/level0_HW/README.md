# level0 Hello Ethernaut

这个关卡主要是熟悉如何通过 Ethernaut 网页端的开发者工具控制台与合约交互，并在交互过程中发现并解决问题。


1. 先在console执行 `await contract.info()` 看下效果：
```bash
'You will find what you need in info1().'
```

2. 再调用`await contract.info1()`:
```bash
'Try info2(), but with "hello" as a parameter.'
```

3. 按照上面的要求，调用`await contract.info2('hello')`:
```bash
'The property infoNum holds the number of the next info method to call.'
```

4. 按照上面的要求，调用`await contract.infoNum()`:
```bash
# 发现输出的是以下奇怪的前端内容
> i {negative: 0, words: Array(2), length: 1, red: null}
```
  - 我们调用`await contract.infoNum().then(v => v.toString())`将其转换成美观的输出:
```bash
'42'
```

5. 因此我们继续拼接，接下来调用 `await contract.info42()`:
```bash
'theMethodName is the name of the next method.'
```

6. 根据提示继续调用 `await contract.theMethodName()`：
```bash
'The method name is method7123949.'
```

7. 继续调用`await contract.method7123949()` :
```bash
'If you know the password, submit it to authenticate().'
```

8. 此时我们还不知道密码（password）是什么，尝试先调用 `authenticate` 查看：`await contract.authenticate()`：

```bash
# 直接报错了，必须得填一个参数
3.b8177702.chunk.js:3 Uncaught Error: Invalid number of parameters for "authenticate". Got 0 expected 1!
```
- 随便换一个参数填 `await contract.authenticate('1')`, 发现直接唤起metamask发起交易了。先关闭metamask，别浪费一笔交易的手续费。

9. 尝试调用 `await contract.passwd()`，发现确实存在该函数，返回值如下：

```bash
'ethernaut0'
```
> [!NOTE]
> ethernaut的浏览器控制台支持直接输入`contract`, 他会展示合约的ABI，我们可以看到他的函数列表

10. 重新 `await contract.authenticate('ethernaut0')`, 会唤起metamask执行

11. 在 MetaMask 上等待交易执行完成后，点击 Ethernaut 网页的 `submit instance` 按钮，这会重新触发一次 MetaMask 的交易审批。交易在链上执行完成后，控制台会提示我们通关成功！
