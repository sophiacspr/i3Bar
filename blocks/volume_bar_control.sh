#!/bin/bash
set -euo pipefail
exec 2>/dev/null

BASE="$HOME/.config/i3blocks-unified/blocks"
CONTROL="$BASE/volume_control.sh"
STATUS="$BASE/volume_status.sh"

if [ ! -x "$CONTROL" ]; then
    echo "Vol: N/A"
    exit 0
fi

# handle scroll/click if control exists
if [ -x "$CONTROL" ]; then
    case "${BLOCK_BUTTON:-}" in
        1) "$CONTROL" mute || true ;;
        4) "$CONTROL" up   || true ;;
        5) "$CONTROL" down || true ;;
    esac
fi

# update the volume display
exec "$STATUS"
