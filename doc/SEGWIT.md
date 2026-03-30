# SegWit Activation on Zetacoin

## Summary

SegWit (BIP141/143/147) was deployed on Zetacoin via BIP9 versionbits signaling
in the v0.13 release. It reached ACTIVE status, but the mining pool software
(`nodeStratum`) produced ~13,000 blocks with malformed witness commitments before
correcting the issue. This document describes the problem, the chain scan
findings, and the chosen enforcement height for the v0.14.0 modernization.

## BIP9 Deployment Parameters

| Parameter                        | Value          |
|----------------------------------|----------------|
| Bit                              | 1              |
| Start time                       | 1535760000 (Sep 1, 2018) |
| Timeout                          | 1598918400 (Sep 1, 2020) |
| Miner confirmation window        | 20,160 blocks  |
| Activation threshold             | 19,160 (95%)   |
| LOCKED_IN at retarget boundary   | ~9,462,080     |
| ACTIVE at retarget boundary      | ~9,482,240     |

The `getblockchaininfo` RPC on the old v0.13 reference node confirms:
```json
"bip9_softforks": {
  "segwit": {
    "status": "active",
    "startTime": 1535760000,
    "timeout": 1598918400
  }
}
```

## The Problem

After SegWit activation at height ~9,482,240, the `nodeStratum` mining pool
included a **witness commitment OP_RETURN** output in the coinbase transaction
(the standard `6a24aa21a9ed...` pattern), but did **not** include the required
**witness nonce** — a 32-byte stack item in the coinbase's witness data
(BIP141 §4).

Bitcoin Core's `CheckWitnessMalleation()` function (called from both
`IsBlockMutated()` and `ContextualCheckBlock()`) detects the commitment, then
checks for the nonce. When the nonce is missing, validation fails with:

```
bad-witness-nonce-size: invalid witness reserved value size
```

This prevented the new v30.2-based Zetacoin Core from syncing past the SegWit
activation height.

### Affected blocks

| Range              | Heights               | Count   | Description |
|--------------------|-----------------------|---------|-------------|
| Broken (nodeStratum) | 9,482,240 – 9,495,358 | ~13,118 | Commitment OP_RETURN present, witness nonce MISSING |
| Other miners       | interspersed          | varies  | No commitment, no witness data (pass validation) |
| Fixed (nodeStratum) | 9,495,361+            | ongoing | Commitment OP_RETURN present, witness nonce PRESENT |

**Key observations:**
- `size == strippedsize` for all broken blocks (zero witness overhead)
- `size - strippedsize == 36` for fixed blocks (2-byte marker/flag + 1-byte
  stack count + 1-byte item length + 32-byte nonce)
- No blocks in the entire chain contain actual SegWit transactions (all
  transactions are legacy format)
- The transition from broken to fixed occurred cleanly — zero regressions found
  in a sample of 9,132 blocks from height 9,495,361 to 18,626,801

### Last broken block

**Height 9,495,358** — nodeStratum block with witness commitment but no witness
nonce (size=246, strippedsize=246).

### First properly committed block

**Height 9,495,361** — nodeStratum block with both witness commitment and proper
32-byte witness nonce (size=282, strippedsize=246, difference=36).

## Root Cause

The `nodeStratum` pool software generated blocks using Bitcoin Core's
`getblocktemplate` RPC, which includes the witness commitment OP_RETURN in the
coinbase outputs when SegWit is active. However, the pool's block assembly code
did not include the witness nonce in the coinbase's witness field.

Bitcoin Core includes a function `UpdateUncommittedBlockStructures()` that injects
a default all-zeros 32-byte nonce when a block has a commitment but no witness
data. In both the old v0.13 and new v30.2 code, this function is **only** called
from:

1. The `submitblock` RPC handler (for locally submitted blocks)
2. `GenerateCoinbaseCommitment()` (for block template generation)
3. The `bitcoin-chainstate` tool (v30.2 only)

It is **not** called during normal peer-to-peer block synchronization. The old
v0.13 reference node likely accepted these blocks through the `submitblock` path
(as the mining node), where `UpdateUncommittedBlockStructures()` fixed up the
missing nonce before validation.

## Fix: SegwitHeight = 9,495,359

Rather than modifying Bitcoin Core's consensus validation logic, we set the
height-based SegWit enforcement to begin **after** all broken blocks:

```cpp
consensus.SegwitHeight = 9495359;
```

This means:
- Heights < 9,495,359: No SegWit rule enforcement. Broken blocks with
  malformed commitments pass validation. Blocks without commitments also pass.
- Heights ≥ 9,495,359: Full SegWit rule enforcement. All nodeStratum blocks
  from this height onward have proper witness commitments with nonces.
  Other miners' blocks have no commitment and pass validation normally.

### Safety analysis

This is safe because:

1. **No SegWit transactions exist** in the skipped range (9,482,240–9,495,358).
   All transactions are legacy format (`size == strippedsize` for every block).
2. **The broken blocks only affect the coinbase** — the witness commitment
   OP_RETURN is a coinbase-only construct. Regular transaction validation is
   unaffected.
3. **No consensus divergence** — the old v0.13 network accepted these blocks,
   and they are part of the canonical chain with the most cumulative work.
4. **SegWit enforcement resumes** at a height where all commitment-bearing
   blocks have proper witness data.

## Chain Scan Methodology

The scan was performed using the old v0.13 reference node's RPC interface.
Scripts are preserved in `contrib/segwit-scan/`.

1. **Transition scan** (`scan-witness.sh`): Sampled blocks from activation
   height through the chain, identifying the broken→fixed transition zone
   around height 9,495,358–9,495,361.

2. **Regression scan** (`scan-broken.sh`): Sampled 9,132 blocks at 1,000-block
   intervals from height 9,495,361 to 18,626,801. Found **zero** broken blocks
   after the transition.

3. **Dense transition scan**: Every block from 9,495,300 to 9,495,520 was
   checked individually to pinpoint the exact last broken (9,495,358) and first
   fixed (9,495,361) blocks.

## Related Files

- `src/kernel/chainparams.cpp` — `consensus.SegwitHeight` setting
- `src/validation.cpp` — `CheckWitnessMalleation()`, `UpdateUncommittedBlockStructures()`
- `contrib/segwit-scan/` — chain scan scripts and results
- GitHub issue: #4
