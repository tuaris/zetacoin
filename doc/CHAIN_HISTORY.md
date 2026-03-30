# Zetacoin Chain History

This document records significant consensus and soft fork incidents on the
Zetacoin blockchain, reconstructed from the old v0.13 source repository
(github.com/zetacoin/zetacoin) git history. Understanding these incidents is
essential for maintaining consensus compatibility in the modernized codebase.

## Timeline of Releases and Incidents

### v0.11.3.1 — June 17, 2017: Emergency Soft Fork Fix

**Commit:** `05ecbdd2c` — "Fix soft fork mechanism parameters"

The original `IsSuperMajority()` function (Bitcoin's pre-BIP9 soft fork
activation mechanism) used a single window of 8,000 blocks with thresholds
of 750/950. On Zetacoin's low-hashrate network with 30-second block times,
this window was too small — soft fork rules were activating or deactivating
unpredictably as miners cycled through version numbers.

**Fix:** Split into two separate supermajority functions:
- `IsSuperMajority1` — window=8,000 blocks, thresholds 750/950 (for script
  verification flag enforcement: BIP66 DERSIG, BIP65 CLTV)
- `IsSuperMajority2` — window=10,000 blocks, thresholds 7,500/9,500 (for
  block version rejection rules)

This gave the version rejection rules a much larger and more conservative
window to prevent premature rejection of older block versions on a network
where miners might not upgrade simultaneously.

### v0.11.3.2 — September 15, 2017: Version 5 Blocks

**Commits:** `f75bdd27a`, `40f8cb6a3`

- Bumped `CURRENT_VERSION` from 3 to 4 (v0.11.3.3, October 2017)
- Added rejection rule for version < 4 blocks when 95% of the network
  has upgraded to version 5 (using the larger `IsSuperMajority2` window)

This enforced BIP65 (CHECKLOCKTIMEVERIFY) by requiring version 4+ blocks.

### v0.11.3.3 — October 8, 2017: BIP65 Enforcement

**Commits:** `96483409b`, `b84e2101d`, `29204e959`

- Set `CURRENT_VERSION = 4` (enforce BIP65 CHECKLOCKTIMEVERIFY)
- Raised `MIN_PEER_PROTO_VERSION` to 70002 to disconnect old peers

### v0.11.3.4 — January 11, 2018: Version 5 Blocks / Disconnect v3

**Commits:** `f7cf14f9b`, `027a5bd63`, `5ce86b949`

- Bumped `CURRENT_VERSION` to 5 — a Zetacoin-specific block version
  (Bitcoin only went up to version 4 before switching to versionbits)
- Purpose: disconnect peers mining version 3 blocks that don't support
  the 0.11 soft forks (BIP65/66)
- Added checkpoint at recent height

### v0.11.3.5 → v0.12 Merge — January–February 2018

**Commits:** `984f75b53`, `39b53766c`, `96ce092f1`

- Merged upstream Bitcoin 0.11, then 0.12.0
- Brought BIP9 versionbits infrastructure (needed for CSV and later SegWit)
- First BIP9 deployment: CSV (BIP68/112/113)

### March 2018: Soft Fork Height Oscillation (Chain Incident)

This sequence of commits reveals a chain incident where the developer
struggled to transition from `IsSuperMajority` to height-based activation:

1. **Mar 7** (`66bbc8535`): "Set past soft forks at bip 65 fork height"
   - Set `BIP65_HEIGHT = 8405468`
   - Replaced ALL `IsSuperMajority` checks with height-based checks
   - Removed `IsSuperMajority1/2` functions entirely

2. **Mar 9** (`ed40b2b2b`): "Versionbits last block version"
   - Changed `VERSIONBITS_LAST_OLD_BLOCK_VERSION` from 4 to 5
   - Needed because Zetacoin used version 5 blocks (non-standard)

3. **Mar 14** (`be650d2b5`): "**Revert** past soft forks set at bip65 height"
   - **EMERGENCY REVERT** — went BACK to `IsSuperMajority` checks
   - Re-added both `IsSuperMajority1` and `IsSuperMajority2` functions
   - The height `8405468` was apparently wrong, causing chain validation
     failures when nodes tried to sync

This revert strongly suggests that setting `BIP65_HEIGHT = 8405468` caused
nodes to reject blocks that had already been accepted by the network, likely
because the height was set too low (before BIP65 had actually been enforced
by the supermajority mechanism on the live chain).

### April 2018: Second Attempt at Height-Based Activation

After a 3-week gap (likely testing), the developer tried again:

4. **Apr 6** (`e2aa3bf3b`): "Set BIP65/66 height"
   - Set `BIP65_HEIGHT = 8570810` (165,342 blocks higher than the first
     attempt — the correct height where BIP65 was actually enforced)
   - Removed `IsSuperMajority1/2` completely (again)
   - Removed ALL block version rejection rules from `ContextualCheckBlockHeader`
   - Made coinbase height enforcement unconditional (no longer gated on
     supermajority)

5. **Apr 6** (`04d2c618b`): "Block version 2 rule height"
   - Cleaned up remaining block version 2 rule references

6. **Apr 6** (`3e6b9c53e`): "BIP9 deployment dates"
   - Set CSV BIP9 start time to April 7, 2018, timeout October 7, 2019
   - Set TESTDUMMY to same dates

7. **Apr 7** (`6e6358ec3`): "Reject legacy blocks"
   - Added: reject blocks with `nVersion < 4` at heights >= BIP65_HEIGHT

### April 15, 2018: v0.12.1 Merge (PR #16)

All the above changes were merged to master. The chain was now using:
- Height-based BIP65/66 enforcement at height 8,570,810
- BIP9 versionbits for CSV (starting April 7, 2018)
- No more `IsSuperMajority` — fully height-gated

### July 2018: v0.13.2 Merge — SegWit Deployment (PR #19)

**Commits:** `8d5975f59`, `cd1939fb7`, `2f891f4b8`

- Merged upstream Bitcoin 0.13.2 (stock code, no Zetacoin-specific witness
  handling modifications)
- Set SegWit BIP9 deployment: start September 1, 2018, timeout September 1, 2020
- Increased upgrade warning window from 100 to 400 blocks (with threshold 300)
- `VERSIONBITS_LAST_OLD_BLOCK_VERSION = 5` (set in March) was already correct

SegWit activated via BIP9 signaling. See `doc/SEGWIT.md` for the witness
commitment issue that occurred after activation.

### Post-2018: No Further Code Changes

The last Zetacoin-specific code change was `57a012205` (July 31, 2018) —
a client version update. The only subsequent commits were an ElectrumX
integration doc (2020) and its merge (2021). No further consensus changes
were made.

## Key Consensus Parameters (Final v0.13.2 State)

| Parameter | Value | Notes |
|-----------|-------|-------|
| BIP34 (coinbase height) | Not height-gated | Enforced unconditionally |
| BIP65 (CLTV) | Height 8,570,810 | Second attempt; first was 8,405,468 |
| BIP66 (strict DER) | Height 8,570,810 | Tied to BIP65 height |
| CSV (BIP68/112/113) | BIP9 bit 0 | Start Apr 7, 2018; activated ~9,213,120 |
| SegWit (BIP141/143/147) | BIP9 bit 1 | Start Sep 1, 2018; activated ~9,482,240 |
| Taproot | Never deployed | |
| Block version | 5 (pre-versionbits) | Zetacoin-specific; Bitcoin used 4 |
| VERSIONBITS_LAST_OLD_BLOCK_VERSION | 5 | Matches Zetacoin's version 5 blocks |

## Block Version Transitions

Scanned from the old v0.13 reference node:

| Version | Height Range | Notes |
|---------|-------------|-------|
| 1 | 0 (genesis only) | |
| 2 | 1 – ~4,850,000 | BIP34 (coinbase height) |
| 3 | ~4,850,000 – ~7,850,000 | BIP66 (strict DER) signaling |
| 4 | ~7,850,000 – ~8,450,000 | BIP65 (CLTV) signaling |
| 5 | ~8,450,000 – 8,570,810 | Zetacoin-specific (disconnect old peers) |
| 0x20000000+ | 8,570,810+ | Versionbits (BIP9 signaling for CSV, SegWit) |

**Critical note for v0.14.0:** BIP66Height MUST be set to 8,570,810 (not 1).
Version 2 blocks exist through ~4.85M and would be rejected during fresh sync
if BIP66 were enforced from genesis. The previous chainstate reindex test did
not catch this because `-reindex-chainstate` skips `ContextualCheckBlockHeader`.

## Lessons for v0.14.0

1. **BIP65_HEIGHT was wrong on the first attempt** — the developer had to
   revert and try again with a height 165K blocks higher. This underscores
   the importance of scanning the actual chain data before setting activation
   heights (which we did for SegWit — see `doc/SEGWIT.md`).

2. **IsSuperMajority was problematic on low-hashrate chains** — Zetacoin
   needed custom window sizes and thresholds because the standard Bitcoin
   parameters didn't work well with its block rate and miner distribution.

3. **Version 5 blocks are Zetacoin-specific** — our `VERSIONBITS_LAST_OLD_BLOCK_VERSION`
   must remain 5 (not Bitcoin's default of 4).

4. **BIP66Height must match the old code** — version 2 blocks exist through
   ~4.85M, so BIP66 cannot be enforced from genesis. Both BIP65 and BIP66
   are enforced at height 8,570,810.

5. **No SegWit-specific workaround existed** — the witness commitment issue
   (blocks with commitment but no nonce) was handled by Bitcoin Core's built-in
   `UpdateUncommittedBlockStructures()` on the mining node. No emergency fix
   was needed at the time because it worked transparently via the `submitblock`
   path.

6. **Reindex tests are insufficient** — `-reindex-chainstate` skips
   `ContextualCheckBlockHeader`, which validates block versions against
   deployment heights. A fresh peer-to-peer sync must be tested to catch
   parameter errors like incorrect BIP66Height.
