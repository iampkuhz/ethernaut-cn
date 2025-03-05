// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/level13_gatekeeper_one/GatekeeperOne.sol";

contract Level13Test is Test {
    GatekeeperOne one;
    GatekeeperBridge bridge;

    address a = address(0x124);

    function setUp() public {
        vm.deal(a, 10 ether);

        vm.startPrank(a);
        one = new GatekeeperOne();
        bridge = new GatekeeperBridge(address(one));
        vm.stopPrank();
    }

    function testHack() public {
        vm.startPrank(a, a);
        console.log("EOA:%s, bridge address: %s", address(a), address(bridge));
        console.log("gatekeeperone: %s", address(one));

        bridge.myCall();
        vm.stopPrank();
    }
}
