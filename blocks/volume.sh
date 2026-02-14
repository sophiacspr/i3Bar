#!/bin/bash

BASE="$HOME/.config/i3blocks-unified/blocks"
CONTROL="$BASE/volume_control.sh"
STATUS="$BASE/volume_status.sh"

# handle mouse clicks on the (mute) and scrolling (up/down) (pass the matching argument to the control script)
case "${BLOCK_BUTTON:-}" in
    1) "$CONTROL" mute ;;
    4) "$CONTROL" up ;;
    5) "$CONTROL" down ;;
esac

"$STATUS"
exit 0
