# FeeAnomalyTrap (Drosera Proof-of-Concept)

## Overview
This trap monitors sudden changes in the token's total supply to identify anomalies that exceed a specified threshold. It is a proof-of-concept demonstrating the essential Drosera trap pattern using deterministic logic.

---

## What It Does
* Monitors the token's total supply changes between consecutive blocks.
* Triggers if the increase between the current block and previous block exceeds a defined threshold of 10 ether (10e18).
* Demonstrates the Drosera trap + responder pattern with a deterministic delta calculation.

---

## Key Files
* `src/FeeAnomalyTrap.sol` - The core trap contract containing the monitoring logic.
* `src/SimpleResponder.sol` - The external responder contract that receives triggers.
* `drosera.toml` - The deployment and configuration file.

---

## Detection Logic

The trap's core monitoring logic is in the deterministic `shouldRespond()` function:

```solidity
function shouldRespond(
    bytes[] calldata data
) external pure override returns (bool, bytes memory) {

    if (data.length < 2) {
        return (false, bytes(""));
    }

    // data[0] = current block
    // data[1] = previous block
    CollectOutput memory curr = abi.decode(data[0], (CollectOutput));
    CollectOutput memory prev = abi.decode(data[1], (CollectOutput));

    // Check if there is an increase
    if (curr.feeAmount > prev.feeAmount) {
        uint256 delta = curr.feeAmount - prev.feeAmount;

        // Trigger if increase is above threshold
        if (delta > FEE_THRESHOLD) {
            return (true, abi.encode(delta));
        }
    }

    return (false, bytes(""));
}
🧪 Implementation Details and Key Concepts
Monitoring Target: Watching changes in token total supply at address 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1.
Deterministic Logic: Operators execute the logic off-chain to achieve consensus before triggering.
Thresholds: Uses a fixed 10 ether delta threshold to determine if the trap should trigger.
Response Mechanism: On trigger, the trap calls the external SimpleResponder contract, passing the detected delta.
Test It
To verify the trap logic using Foundry, run:
Copy code
Bash
forge test --match-contract FeeAnomalyTrap
