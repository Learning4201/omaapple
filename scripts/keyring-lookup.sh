#!/bin/sh
set -eu

kind=${1:-}
if [ -z "$kind" ]; then
  echo "keyring-lookup.sh: kind is required" >&2
  exit 2
fi

secret-tool lookup service omaapple kind "$kind"
