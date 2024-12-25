// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Delegation {

    // 直接调用pwn函数，实际上Delegation合约会通过delegatecall调用Delegate的pwn来执行
    function pwn() external;

    // 查询owner，方便remix校验结果
    function owner() external view returns (address);
}