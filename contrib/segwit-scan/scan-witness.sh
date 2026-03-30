#!/bin/sh
# Scan Zetacoin blocks for witness commitment pattern (aa21a9ed)
# and check if coinbase has witness data (size > strippedsize)
#
# Usage: ./scan-witness.sh <start_height> <end_height> [step]

CLI="doas jexec zetacoin-ref /usr/local/bin/zetacoin-cli -conf=/usr/local/etc/zetacoin.conf -datadir=/var/db/zetacoin"

START=${1:-9482240}
END=${2:-9482260}
STEP=${3:-1}

echo "Scanning blocks $START to $END (step=$STEP)"
echo "Height | Size | StrippedSize | HasCommitment | CoinbaseSig"
echo "-------|------|-------------|---------------|------------"

h=$START
while [ $h -le $END ]; do
    HASH=$($CLI getblockhash $h 2>/dev/null)
    if [ -z "$HASH" ]; then
        echo "$h | ERROR: no hash"
        h=$((h + STEP))
        continue
    fi

    # Get block info (verbose=true)
    INFO=$($CLI getblock "$HASH" true 2>/dev/null)
    SIZE=$(echo "$INFO" | grep '"size"' | head -1 | sed 's/[^0-9]//g')
    STRIPPED=$(echo "$INFO" | grep '"strippedsize"' | sed 's/[^0-9]//g')

    # Get raw block hex
    RAW=$($CLI getblock "$HASH" false 2>/dev/null)

    # Check for witness commitment magic in raw block
    HAS_COMMIT="no"
    if echo "$RAW" | grep -q "aa21a9ed"; then
        HAS_COMMIT="YES"
    fi

    # Extract coinbase scriptsig hint (pool identifier)
    # The coinbase script is after the 32-byte null prevhash + 4-byte ffffffff + length byte
    # Just grep for common pool identifiers
    POOL=""
    if echo "$RAW" | grep -qi "6e6f64655374726174756d"; then
        POOL="/nodeStratum/"
    elif echo "$RAW" | grep -qi "736c757368"; then
        POOL="/slush/"
    else
        # Try to extract ascii from coinbase
        POOL="(unknown)"
    fi

    WITNESS_DATA="no"
    if [ "$SIZE" != "$STRIPPED" ] && [ -n "$SIZE" ] && [ -n "$STRIPPED" ]; then
        WITNESS_DATA="YES"
    fi

    echo "$h | $SIZE | $STRIPPED | $HAS_COMMIT | witness=$WITNESS_DATA | $POOL"
    h=$((h + STEP))
done
