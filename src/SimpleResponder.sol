// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleResponder {

    event FeeAnomalyDetected(uint256 delta);

    function respondCallback(uint256 amount) public {
        emit FeeAnomalyDetected(amount);
    }
}
