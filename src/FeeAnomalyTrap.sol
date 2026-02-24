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

        uint256 supply;

        try IERC20(TOKEN).totalSupply() returns (uint256 s) {
            supply = s;
        } catch {
            supply = 0;
        }

        return abi.encode(CollectOutput({ feeAmount: supply }));
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {

        if (data.length < 2) {
            return (false, bytes(""));
        }

        CollectOutput memory curr =
            abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev =
            abi.decode(data[1], (CollectOutput));

        uint256 delta;

        if (curr.feeAmount > prev.feeAmount) {
            delta = curr.feeAmount - prev.feeAmount;
        } else {
            delta = prev.feeAmount - curr.feeAmount;
        }

        if (delta > FEE_THRESHOLD) {
            return (true, abi.encode(delta));
        }

        return (false, bytes(""));
    }
}
