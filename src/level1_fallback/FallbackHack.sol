// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 将原始合约定义成 interface，方便自己写的合约调用
interface Fallback {
    // 原始合约中的public变量, 作为interface引入时，有一个对应方法可以调用
    // mapping(address => uint256) public contributions;
    function contributions(address user) external view returns (uint256);

    // 原始合约中的public变量, 作为interface引入时，有一个对应方法可以调用
    // address public owner;
    function owner() external view returns (address);

    // 因为interface没有内部逻辑，所以不存在内部调用，原始合约中public必须改成external
    function contribute() external payable;

    // 因为interface没有内部逻辑，所以不存在内部调用，原始合约中public必须改成external
    function getContribution() external view returns (uint256);

    // 因为interface没有内部逻辑，所以不存在内部调用，原始合约中public必须改成external
    function withdraw() external;

    // 这个必须要加，不然remix中不允许我们点击Transact
    receive() external payable;
}
