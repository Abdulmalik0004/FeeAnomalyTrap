# FeeAnomalyTrap (Drosera Proof-of-Concept)

## Overview
FeeAnomalyTrap is a Drosera trap that monitors sudden increases in a token's total supply (fee amount) between consecutive blocks.  
If the increase exceeds a predefined threshold, the trap triggers a responder contract.

This project demonstrates the Drosera trap + responder architecture using deterministic off-chain execution logic.

---

## What It Does

- Monitors changes in token fee amount between consecutive blocks.
- Compares current block data with previous block data.
- Calculates the delta (difference).
- Triggers if the increase exceeds a fixed threshold (10 ether).
- Calls an external responder contract when triggered.

---

## Architecture

Trap → Evaluates deterministic delta logic  
Responder → Receives trigger calls when anomaly detected  
Operators → Execute deterministic logic off-chain before consensus  

---

## Key Files

- `src/FeeAnomalyTrap.sol` — Core trap contract containing monitoring logic.
- `src/SimpleResponder.sol` — External responder contract that receives triggers.
- `drosera.toml` — Deployment and configuration file.

---

## Detection Logic

The trap’s deterministic monitoring logic is implemented in `shouldRespond()`:

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
