# Zetacoin Chain Gaps and `maxtipage`

## Background

Zetacoin is a low-activity chain with very few active miners. As a result,
there are extended periods where no blocks are mined. The longest observed
single-block gap is **551 days** (approximately 1.5 years).

## Observed Gaps

Block-by-block analysis of the live chain at block 18,624,358 (March 2026)
revealed the following largest single-block gaps:

| Last Block | Next Block | Duration | Calendar Period |
|---|---|---|---|
| 18616513 | 18616542 | **551 days** | Jan 5, 2023 → Jul 9, 2024 |
| 18623456 | 18623457 | **298 days** | Apr 5, 2025 → Jan 28, 2026 |
| 18623193 | 18623194 | **91 days** | Sep 26 → Dec 26, 2024 |
| 18623210 | 18623211 | **79 days** | Dec 27, 2024 → Mar 16, 2025 |
| 18616508 | 18616509 | **72 days** | Jan 4 → Mar 18, 2023 |
| 18616480 | 18616481 | **19 days** | Dec 6 → Dec 25, 2022 |

As of March 2026, new blocks are being mined approximately every **5–7 days**.

Note: During the 551-day gap (Jan 2023 → Jul 2024), 29 blocks were still
mined at irregular intervals, but with individual gaps of days to weeks
between them. The chain was not completely dead but was operating at a tiny
fraction of its target 30-second block rate.

## ZetacoinE (EWMCI) Fork

An unaffiliated group (EWMCI, LLC) created a separate cryptocurrency called
"ZetacoinE" or "Zetacoin New Edition" in late 2021. This is a **completely
different chain** with:

- Scrypt algorithm (not SHA-256d)
- Hybrid PoW + PoS consensus
- New genesis block
- Different address format (`9...` prefix)
- GPL-3.0 license (original is MIT)

The ZetacoinE chain has no connection to the original Zetacoin chain. Blocks
on one chain do not exist on the other. The original SHA-256d chain is what
this software connects to.

Repository: https://github.com/WikiMin3R/ZetacoinE

## Impact on `maxtipage`

The `maxtipage` setting controls when a node considers itself to have completed
initial block download (IBD). If the chain tip is older than `maxtipage`, the
node remains in IBD mode.

**In IBD mode, the node:**
- Will not relay unconfirmed transactions
- Will not respond to `getblocktemplate` (prevents mining)
- Provides limited peer services
- Reports `initialblockdownload: true` in `getblockchaininfo`

**Important:** `maxtipage` does NOT affect syncing. A syncing node will
download and validate all blocks regardless of timestamp gaps. The setting
only affects behavior *after* the node has reached the chain tip.

### Default value

Bitcoin Core's default `maxtipage` is 24 hours. This is unsuitable for
Zetacoin because:

1. Blocks currently arrive every 5–7 days
2. Historical gaps of months to over a year have occurred
3. A fully synced node with the 24h default would permanently stay in IBD
   mode and refuse to function as a full node

**Zetacoin Core sets `maxtipage` to 30 days** (720 hours) by default. This
accommodates the typical multi-day gaps while still detecting nodes that are
genuinely out of sync.

### Override

Operators can override the default with the `-maxtipage` command line option
or config file setting:

```
# In zetacoin.conf — set to 90 days (in seconds)
maxtipage=7776000
```

If you observe that your node reports `initialblockdownload: true` despite
being fully synced, increase this value.

## Chain Health

The design target for Zetacoin is 30-second blocks (2 blocks per minute).
The current ~5-7 day gap between blocks indicates the chain is operating at
roughly 1/15,000th of its target block rate. This is a consequence of the
chain being largely abandoned since 2022, with only occasional mining activity.

The 1 ZET perpetual tail emission ensures the chain can always be resumed
by any miner — there is no point at which mining rewards drop to zero.
