// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../../src/level13_gatekeeper_one/GatekeeperOne.sol";

interface IGatekeeperBridge {
    function myCall(bytes8 _gateKey, uint256 _gas) external view;
}

contract TestGatekeeperOneGasLeftScript is Script {
    function run() external {
        // 手工set地址
        address bridgeAddress = 0x06dEa6B4d353ea9111255116C1eA27112d549f6f;
        IGatekeeperBridge bridge = IGatekeeperBridge(bridgeAddress);
        console.log("GatekeeperBridge address in sepolia: %s", address(bridge));

        bytes8 gateKey = bytes8(hex"010203040000fb2c");
        // bytes8 gateKey = bytes8(hex"0102030400000000");

        address origin = 0x9a65D28F9e195fcbf9599bA0F0552Dc6129DfB2c;
        vm.prank(origin, origin);

        // 注意：out of gas 时不会返回失败原因
        for (uint256 i = 8191 * 5 + 250; i <= 8191 * 5 + 260; i++) {
            try bridge.myCall(gateKey, i) {
                console.log("Success! Target gas set: %s", (i - 8191 * 5));
                break;
            } catch (bytes memory reason) {
                // 失败时继续
                // continue;
                console.log("Failed for gas: %s, reason: %s", (i - 8191 * 5), string(reason));
                continue;
            }
            // if (success) {
            //     console.log("Success! Target gas set: %s", i);
            // } else {
            //     console.log("Failed for gas: %s", i);
            // }
        }
    }
}
