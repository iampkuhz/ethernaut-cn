// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/level22_dex/dex.sol";
import "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract SwappableTokenMock is ERC20Mock {
    address private immutable _dex;

    constructor(address dexInstance) ERC20Mock() {
        _dex = dexInstance;
    }

    /// @notice 兼容原题的“奇怪 approve 签名”
    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        _approve(owner, spender, amount);
    }
}

contract Level22Test is Test {
    Dex dex;
    SwappableTokenMock token1;
    SwappableTokenMock token2;
    DexHack dexHack;

    address dexEoa = address(0x12);
    address user = address(0x13);

    function setUp() public {
        vm.deal(address(dex), 0.1 ether);
        vm.deal(user, 0.1 ether);

        vm.startPrank(dexEoa, dexEoa);
        dex = new Dex();
        token1 = new SwappableTokenMock(address(dex));
        token2 = new SwappableTokenMock(address(dex));
        dex.setTokens(address(token1), address(token2));
        vm.stopPrank();

        vm.startPrank(user, user);
        dexHack = new DexHack(address(dex));
        token1.mint(address(dex), 100);
        token1.mint(address(dexHack), 10);
        token2.mint(address(dex), 100);
        token2.mint(address(dexHack), 10);
        vm.stopPrank();
    }

    function testCall() public {
        vm.startPrank(user, user);
        console.log("dexHack token1 balance:", dex.balanceOf(address(token1), address(dexHack)));
        console.log("dexHack token2 balance:", dex.balanceOf(address(token2), address(dexHack)));
        console.log("dex token1 balance:", dex.balanceOf(address(token1), address(dex)));
        console.log("dex token2 balance:", dex.balanceOf(address(token2), address(dex)));

        dexHack.loopCall();
        vm.stopPrank();
    }
}
