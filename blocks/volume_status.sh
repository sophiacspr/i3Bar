#!/bin/bash

SINK='@DEFAULT_AUDIO_SINK@'

# dependency check: wpctl
if ! command -v wpctl >/dev/null; then
    echo "--%🔈"
    exit 0
fi

# get the volume information for the default sink, otherwise continue with empty volume
VOL_RAW=$(wpctl get-volume "$SINK" 2>/dev/null || true)

if [ -z "$VOL_RAW" ]; then
    echo "--%🔈"
    exit 0
fi

# detect mute by looking for the "MUTED" keyword in the output, default is not muted
MUTE=no
echo "$VOL_RAW" | grep -q MUTED && MUTE=yes

# extract numeric volume (second field)
VOL_VAL=$(echo "$VOL_RAW" | awk '{print $2}')

# if second field is not a number, exit with no volume
if ! [[ "$VOL_VAL" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "--%🔈"
    exit 0
fi

# convert volume to percentage
VOL=$(awk "BEGIN { printf \"%d\", $VOL_VAL * 100 }")

# padding for better alignment
VOL=$(printf "%3d" "$VOL")

if [ "$MUTE" = yes ]; then
    echo "${VOL}%🔇"
else
    echo "${VOL}%🔊"
fi
