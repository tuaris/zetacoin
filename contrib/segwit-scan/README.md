# SegWit Chain Scan Tools

Scripts used to scan the Zetacoin blockchain for witness commitment patterns
via the old v0.13 reference node RPC. These were used to diagnose the SegWit
activation issue documented in `doc/SEGWIT.md`.

## Scripts

### scan-witness.sh

Scans a range of blocks and reports: height, size, strippedsize, whether a
witness commitment (aa21a9ed magic) is present, whether the block has witness
data (size > strippedsize), and the mining pool identifier.

```
./scan-witness.sh <start_height> <end_height> [step]
```

### scan-broken.sh

Scans for "broken" blocks: blocks that have a witness commitment OP_RETURN
but NO witness data (size == strippedsize). Only reports broken blocks.

```
./scan-broken.sh <start_height> <end_height> [step]
```

## Prerequisites

- The old v0.13 reference node must be running in jail `zetacoin-ref`
- RPC access via `zetacoin-cli` with config at `/usr/local/etc/zetacoin.conf`

## Results

See `scan-broken-results.txt` for the full scan output confirming zero broken
blocks exist after height 9,495,358.
