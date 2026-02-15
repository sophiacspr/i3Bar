#!/usr/bin/env bash

TARGET_DIR="$HOME/.config/i3blocks-unified"
I3_CONFIG="$HOME/.config/i3/config"
BACKUP_DIR="$HOME/.config/i3blocks-unified-backups"

MARKER_START="# >>> i3blocks-unified START >>>"
MARKER_END="# <<< i3blocks-unified END <<<"

echo "[1/4] Checking installation..."

if [ ! -d "$TARGET_DIR" ]; then
  echo "Warning: $TARGET_DIR not found. Nothing to remove."
fi

if [ ! -f "$I3_CONFIG" ]; then
  echo "Error: i3 config not found at $I3_CONFIG"
  exit 1
fi

echo "[2/4] Restoring i3 config..."

# restore original i3 config if backup exists
if [ -d "$BACKUP_DIR" ]; then
  LATEST_BACKUP=$(ls -td "$BACKUP_DIR"/i3-config.bak 2>/dev/null | head -n1)
  if [ -f "$LATEST_BACKUP" ]; then
    cp "$LATEST_BACKUP" "$I3_CONFIG"
    echo "Restored original i3 config from backup: $LATEST_BACKUP"
  else
    echo "No backup of i3 config found in $BACKUP_DIR. Original config not restored."
  fi
else
  echo "No backup directory found at $BACKUP_DIR. Original config not restored."
fi

echo "[3/4] Removing installed files..."

if [ -d "$TARGET_DIR" ]; then
  rm -rf "$TARGET_DIR"
  echo "Removed $TARGET_DIR"
fi

echo "[4/4] Reloading i3..."

if command -v i3-msg >/dev/null 2>&1; then
  i3-msg reload >/dev/null || true
  i3-msg restart >/dev/null || true
  echo "i3 reloaded."
else
  echo "Warning: i3-msg not found. Please reload i3 manually."
fi

echo "Uninstall complete."
echo "Note: Dependencies were not removed."
echo "Backups remain in ~/.config/i3blocks-unified-backups/"
