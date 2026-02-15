#!/bin/bash

# find the file with the battery name in it
ENV_FILE="$HOME/.config/i3blocks-unified/i3blocks.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# check if battery name is there
if [ -z "$BATTERY_NAME" ]; then
    echo "Battery: N/A"
    exit 0
fi

BAT="/sys/class/power_supply/$BATTERY_NAME"

# check if battery directory exists
if [ ! -d "$BAT" ]; then
    echo "Battery: N/A"
    exit 0
fi

# optional power profile support
# find current profile
if command -v powerprofilesctl >/dev/null 2>&1; then
    profile="$(powerprofilesctl get 2>/dev/null || echo unknown)"
else
    profile="default"
fi

if command -v powerprofilesctl >/dev/null 2>&1; then

    profile_info="$(powerprofilesctl list 2>/dev/null || echo "")"

    profile_header_lines="$(
        echo "$profile_info" |
        grep -E '^[[:space:]]*[*]?[[:space:]]*[a-z0-9-]+:'
    )" # match lines with profile names

    profile_names="$(
        echo "$profile_header_lines" |
        sed -E 's/^[[:space:]]*\*?[[:space:]]*//'
    )" # remove leading whitespace, optional *, and more 

    # convert newline list into a bash array
    mapfile -t profiles < <(
        echo "$profile_names" |
        sed -E 's/:$//'
    )
fi

# extract profile names from the output
if [ "$BLOCK_BUTTON" = "1" ] && [ "${#profiles[@]}" -gt 0 ]; then
    next=""

    # find the next profile in the list
    for i in "${!profiles[@]}"; do
        if [ "${profiles[i]}" = "$profile" ]; then
            next="${profiles[(i+1) % ${#profiles[@]}]}" # use modulo to wrap around to the first profile again
            break
        fi
    done

    # fallback, e.g. if current profile is not found
    if [ -z "$next" ]; then
        next="${profiles[0]}"
    fi

    # apply next profile
    powerprofilesctl set "$next" >/dev/null 2>&1 || true

    # update current profile
    profile="$(powerprofilesctl get 2>/dev/null || echo unknown)"
fi

capacity=$(cat "$BAT/capacity" 2>/dev/null || echo "")
status=$(cat "$BAT/status" 2>/dev/null || echo "")

# validate numeric capacity
if ! [[ "$capacity" =~ ^[0-9]+$ ]]; then
    echo "Battery: ?"
    exit 0
fi

# update status 
if [ "$status" = "Charging" ]; then
    echo "${capacity}%🔌 (${profile})"
else
    if [ "$capacity" -lt 20 ]; then
        echo "${capacity}%🪫 (${profile})"
    else
        echo "${capacity}%🔋 (${profile})"
    fi
fi