// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force { /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
    /~____  =ø= /
    (______)__m_m)
                   */ }

contract ForceDeposit {
    function deposit(address _f) external payable {
        selfdestruct(payable(_f));
    }
}
