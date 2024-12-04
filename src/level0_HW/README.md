# level0 Hello Ethernaut

这个关卡主要是熟悉ethernaut网页端如何通过开发者工具的控制台和合约交互，在交互的过程中发现要解决的问题并解决

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
# 发现输出的时下面这个奇怪的前端内容
> i {negative: 0, words: Array(2), length: 1, red: null}
```
  - 我们调用`await contract.infoNum().then(v => v.toString())`将其转换成美观的输出:
```bash
'42'
```

5. 所以我们继续拼接，下面该调用info42了 `await contract.info42()`:
```bash
'theMethodName is the name of the next method.'
```

6. 按照指示继续调用`await contract.theMethodName()`：
```bash
'The method name is method7123949.'
```

7. 继续调用`await contract.method7123949()` :
```bash
'If you know the password, submit it to authenticate().'
```

8. 这个时候我们还不知道password是啥，尝试先调用authenticate看看 `await contract.authenticate()` :
```bash
# 直接报错了，必须得填一个参数
3.b8177702.chunk.js:3 Uncaught Error: Invalid number of parameters for "authenticate". Got 0 expected 1!
```
- 随便换一个参数填 `await contract.authenticate('1')`, 发现直接唤起metamask发起交易了。先关闭metamask，别浪费一笔交易的手续费。

9. 随便尝试一下，`await contract.passwd()`调用，发现真有这个函数，返回值如下：
```bash
'ethernaut0'
```
- ethernaut的浏览器控制台支持直接输入`contract`, 他会展示合约的ABI，我们苦役看到他的所有函数列表

10. 重新 `await contract.authenticate('ethernaut0')`, 会唤起metamask执行

- 在metamask上面等着交易执行完，然后点击ethernaut王衣的submit instance，会重新触发一次metamask审批交易，交易在链上执行完成后，控制台提示我们通过！