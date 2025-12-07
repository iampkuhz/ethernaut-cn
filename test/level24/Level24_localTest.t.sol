// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/level24_puzzle_wallet/PuzzleWallet.sol";

contract MockPuzzle {
    address public pendingAdminOrOwner;
    uint256 public adminOrMaxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    constructor() {
        // 随便初始化一个地址
        pendingAdminOrOwner = address(bytes20(hex"725595BA16E76ED1F6cC1e1b65A88365cC494824"));
        adminOrMaxBalance = uint256(uint160(bytes20(hex"725595BA16E76ED1F6cC1e1b65A88365cC494824")));
    }

    modifier onlyAdmin() {
        require(msg.sender == address(uint160(adminOrMaxBalance)), "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdminOrOwner = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(
            pendingAdminOrOwner == _expectedAdmin, "Expected new admin by the current admin is not the pending admin"
        );
        adminOrMaxBalance = uint256(uint160(pendingAdminOrOwner));
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        adminOrMaxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == pendingAdminOrOwner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= adminOrMaxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        console.log("execute address:%s", to);
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success, bytes memory ret) = to.call{value: value}(data);
        if (!success) {
            if (ret.length > 0) {
                // bubble up 原始错误
                assembly {
                    revert(add(ret, 32), mload(ret))
                }
            }
            revert("Execution failed to.call");
        }
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        console.log("start multicall");
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            console.log("call %d/%d", i, data.length);
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            console.log("call %d/%d checked", i, data.length);
            (bool success,) = address(this).delegatecall(data[i]);
            console.log("call %d/%d executed", i, data.length);
            require(success, "Error while delegating call");
        }
    }
}

contract Level24Test is Test {
    MockPuzzle puzzle;
    WalletHack hack;

    address user = address(0x12);
    address host = address(0x13);

    function setUp() public {
        vm.deal(host, 0.1 ether);
        vm.deal(user, 0.1 ether);

        vm.startPrank(host, host);
        puzzle = new MockPuzzle();
        vm.stopPrank();

        console.log("puzzle balance :%d (before init)", address(puzzle).balance);
        vm.deal(address(puzzle), 0.01 ether);
        console.log("puzzle balance :%d (after init)", address(puzzle).balance);

        vm.startPrank(user, user);
        hack = new WalletHack(address(puzzle));
        vm.stopPrank();
    }

    function testHack() public {
        vm.startPrank(user, user);
        hack.hack{value: 0.03 ether}();
        vm.stopPrank();
    }
}
