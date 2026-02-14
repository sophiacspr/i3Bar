#!/bin/bash

# print the formatted day, date and time
date '+%a %d-%m-%Y %H:%M'

# dependency check: xgd-open command
if ! command -v xdg-open >/dev/null; then
    exit 0
fi

# open google calendar on click from default browser
case "$BLOCK_BUTTON" in
    1) xdg-open "https://calendar.google.com" >/dev/null 2>&1 & ;;
esac

