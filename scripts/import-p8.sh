#!/bin/sh
set -eu

path=$(omarchy-file-select --title "OmaApple MusicKit key" --extensions p8) || exit $?
if [ -z "$path" ] || [ ! -f "$path" ]; then
  exit 1
fi

# Print the PEM so the caller can store it; never copy it into the plugin tree.
cat -- "$path"
