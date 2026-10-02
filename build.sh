#!/usr/bin/env bash
# Build the Barman image. Usage: ./build.sh [extra docker build args]
set -euo pipefail

cd "$(dirname "$0")"
docker build -t barman-macos "$@" .