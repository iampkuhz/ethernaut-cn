// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/level14_gatekeeper_two/GatekeeperTwo.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Level14Test is Test {
    address A = address(0x1234);
    address B = address(0x8212);

    GatekeeperTwo gk2;
    HackGatekeeperTwo hack;

    function setUp() public {
        vm.deal(A, 0.1 ether);
        vm.deal(B, 0.2 ether);

        vm.startPrank(A);
        gk2 = new GatekeeperTwo();
        vm.stopPrank();
    }

    function testHack() public {
        console.log("old entrant: %s", gk2.entrant());
        assertNotEq(gk2.entrant(), B, "origin same");
        vm.startPrank(B, B);
        hack = new HackGatekeeperTwo(address(gk2));
        vm.stopPrank();
        assertEq(gk2.entrant(), B);
        console.log("new entrant: %s", gk2.entrant());
    }
}
