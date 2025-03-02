// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract GatekeeperBridgeMock {
    function myCall(bytes8 _gateKey, uint256 _gas) public view {}
}

// 这个函数需要调用sepolia执行，而不是本地VM
contract TestGatekeeperOneGasLeft {
    function testGas() public view {
        // 手工set地址
        GatekeeperBridgeMock bridge = GatekeeperBridgeMock(0xb5858B8EDE0030e46C0Ac1aaAedea8Fb71EF423C);
        console.log("GatekeeperBridge address in sepolia: %s", address(bridge));

        for (uint256 i = 8191 * 5 + 50; i <= 8191 * 5 + 800; i++) {
            console.log("gas: %s", i);
            try bridge.myCall(bytes8(hex"010203040000fb2c"), i) {
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
    }
}
