#!/bin/sh
# Scan for "broken" blocks: have witness commitment (aa21a9ed) but NO witness data (size == strippedsize)
# This is a fast scan that only reports broken blocks.
CLI="doas jexec zetacoin-ref /usr/local/bin/zetacoin-cli -conf=/usr/local/etc/zetacoin.conf -datadir=/var/db/zetacoin"

START=${1:-9495361}
END=${2:-18626801}
STEP=${3:-1000}
BROKEN=0
CHECKED=0

echo "Scanning for broken blocks (commitment + no witness) from $START to $END (step=$STEP)"

h=$START
while [ $h -le $END ]; do
    HASH=$($CLI getblockhash $h 2>/dev/null)
    [ -z "$HASH" ] && { h=$((h + STEP)); continue; }

    INFO=$($CLI getblock "$HASH" true 2>/dev/null)
    SIZE=$(echo "$INFO" | grep '"size"' | head -1 | sed 's/[^0-9]//g')
    STRIPPED=$(echo "$INFO" | grep '"strippedsize"' | sed 's/[^0-9]//g')

    # Only check for commitment if size == strippedsize (no witness data)
    if [ "$SIZE" = "$STRIPPED" ]; then
        RAW=$($CLI getblock "$HASH" false 2>/dev/null)
        if echo "$RAW" | grep -q "aa21a9ed"; then
            echo "BROKEN at height $h: size=$SIZE, has commitment but no witness data"
            BROKEN=$((BROKEN + 1))
        fi
    fi

    CHECKED=$((CHECKED + 1))
    if [ $((CHECKED % 100)) -eq 0 ]; then
        echo "  ... checked $CHECKED blocks (at height $h)"
    fi
    h=$((h + STEP))
done

echo "Done. Checked $CHECKED blocks, found $BROKEN broken blocks."
