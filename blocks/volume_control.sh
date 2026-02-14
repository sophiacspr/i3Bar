#!/bin/bash
SINK='@DEFAULT_AUDIO_SINK@'

# dependency check: wpctl
if ! command -v wpctl >/dev/null; then
    exit 0
fi

# handle execute volume up, down or muting (passed as an argument)
case "$1" in
    up)   wpctl set-volume "$SINK" 5%+ ;;
    down) wpctl set-volume "$SINK" 5%- ;;
    mute) wpctl set-mute "$SINK" toggle ;;
esac

# force immediate bar update
pkill -RTMIN+10 i3blocks