#!/bin/sh
set -eu

kind=${1:-}
label=${2:-OmaApple}
if [ -z "$kind" ]; then
  echo "keyring-store.sh: kind is required" >&2
  exit 2
fi

secret-tool store --label="$label" service omaapple kind "$kind"
