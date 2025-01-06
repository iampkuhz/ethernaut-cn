// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/level9_king/king.sol";

contract Level9LocalTest is Test {
    King mockA;
    UnchangedKing mockB;

    address a = address(0x124);
    address b = address(0x456);
    address c = address(0x789);

    function setUp() public {
        vm.deal(a, 0.001 ether);
        vm.startPrank(a);
        mockA = new King{value: 0.001 ether}();
        console.log("King address:", address(mockA));
        console.log("King king:", mockA._king());
        console.log("King owner:", mockA.owner());
        console.log("King price:", mockA.prize());
        vm.stopPrank();

        vm.startPrank(b);
        mockB = new UnchangedKing(address(mockA));
        vm.stopPrank();

        vm.deal(c, 0.002 ether);
        console.log("mockA balance:", address(mockA).balance);
    }

    function testOvertake() public {
        vm.startPrank(c);
        mockB.overtake{value: 0.001 ether}();
        vm.stopPrank();

        console.log("mockA new king:", mockA._king());
    }
}
