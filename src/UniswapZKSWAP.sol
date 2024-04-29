// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ZKSwap.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract ERC20ZKSwap is ZKSwap {
    using SafeERC20 for IERC20;
    IERC20 public token;

    constructor(
        IVerifier _verifier,
        IHasher _hasher,
        uint256 _denomination,
        uint32 _merkleTreeHeight,
        IERC20 _token
    ) ZKSwap(_verifier, _hasher, _denomination, _merkleTreeHeight) {
        token = _token;
    }

    function _processDeposit() internal override {
        require(
            msg.value == 0,
            "ETH value is supposed to be 0 for ERC20 instance"
        );
        token.safeTransferFrom(msg.sender, address(this), 0);
    }

    function _processWithdraw(
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) internal override {
        require(
            msg.value == _refund,
            "Incorrect refund amount received by the contract"
        );

        token.safeTransfer(_recipient, 0);
        if (_fee > 0) {
            token.safeTransfer(_relayer, _fee);
        }

        if (_refund > 0) {
            (bool success, ) = _recipient.call{value: _refund}("");
            if (!success) {
                // let's return _refund back to the relayer
                _relayer.transfer(_refund);
            }
        }
    }
}
