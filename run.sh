#!/usr/bin/env bash
# Run the Barman image as container "barmanhost". With no arguments, opens a shell; otherwise runs the given command.
# Usage: ./run.sh [command...]   e.g. ./run.sh barman --version
set -euo pipefail

docker run -it --rm --name barmanhost --hostname barmanhost barman-macos "$@"