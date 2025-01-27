// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/level10_reentrancy/HackReEntrancy.sol";

contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        // 这里修改一下源码，不然无法编译，调试时不需要SafeMath
        balances[_to] = balances[_to] + msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        // console.log("sender: ", msg.sender, ", allLeft:", address(this).balance, ", sender left:", msg.sender.balance);
        console.log(
            "reentrancy: %s gwei, hack: %s gwei",
            (address(this).balance / 1 gwei),
            (address(msg.sender).balance / 1 gwei)
        );
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            console.log("sender balance log: %s, amount: %s", balances[msg.sender], _amount);
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract Level10LocalTest is Test {
    Reentrance mockA;
    HackReentrancy mockB;

    address a = address(0x124);
    address b = address(0x456);
    address c = address(0x789);
    address d = address(0x729);

    function setUp() public {
        vm.deal(a, 0.9 ether);
        vm.deal(b, 0.2 ether);
        vm.deal(c, 0.3 ether);
        vm.deal(d, 0.1 ether);

        // 用A部署合约 Reentrance
        vm.startPrank(a);
        mockA = new Reentrance();
        mockA.donate{value: 0.001 ether}(a);
        vm.stopPrank();

        vm.startPrank(d);
        // mockA.donate{value: 0.07 ether}(d);
        vm.stopPrank();

        // 用B部署合约 Hack
        vm.startPrank(b);
        mockB = new HackReentrancy(payable(address(mockA)));
        vm.stopPrank();
    }

    function testHack() public {
        console.log(
            "1. reentrancy balance: ",
            (address(mockA).balance / 1 gwei),
            ", HackReentrancy balance: ",
            (address(mockB).balance / 1 gwei)
        );
        vm.startPrank(c);
        mockB.hack{value: 110000 gwei}();
        vm.stopPrank();
        console.log(
            "2. c balance: ",
            (address(mockA).balance / 1 gwei),
            ", HackReentrancy balance: ",
            (address(mockB).balance / 1 gwei)
        );
    }
}
