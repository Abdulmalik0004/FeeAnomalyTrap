// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "contracts/interfaces/ITrap.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
}

contract FeeAnomalyTrap is ITrap {

    address public constant TOKEN =
        0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;

    uint256 public constant FEE_THRESHOLD = 10 ether;

    struct CollectOutput {
        uint256 feeAmount;
    }

    constructor() {}

    function collect() external view override returns (bytes memory) {
        uint256 fees = IERC20(TOKEN).totalSupply();
        return abi.encode(CollectOutput({ feeAmount: fees }));
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {

        if (data.length < 2) {
            return (false, bytes(""));
        }

        // data[0] = current block
        // data[1] = previous block
        CollectOutput memory curr =
            abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev =
            abi.decode(data[1], (CollectOutput));

        // check if there is an increase first
        if (curr.feeAmount > prev.feeAmount) {

            uint256 delta = curr.feeAmount - prev.feeAmount;

            // trigger if increase is above threshold
            if (delta > FEE_THRESHOLD) {
                return (true, abi.encode(delta));
            }
        }

        return (false, bytes(""));
    }
}
