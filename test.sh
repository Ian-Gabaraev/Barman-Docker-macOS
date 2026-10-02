#!/usr/bin/env bash
# Smoke-test the image: checks that Barman, Python, pip and all dependencies are installed.
# Usage: ./test.sh   (builds the image first)
set -euo pipefail

cd "$(dirname "$0")"
./build.sh

# Runs inside the container; every check must succeed.
read -r -d '' CHECKS <<'EOF' || true
set -e
fail=0
check() {
  if "$@" >/dev/null 2>&1; then echo "PASS: $*"; else echo "FAIL: $*"; fail=1; fi
}

for cmd in barman barman-cloud-backup barman-cloud-restore barman-wal-archive \
           python3 pip3 rsync file tar; do
  check command -v "$cmd"
done

check barman --version
check python3 --version
check pip3 --version
check python3 -m venv --help

for mod in psycopg2 argcomplete boto3 dateutil \
           azure.identity azure.storage.blob azure.mgmt.compute \
           google.cloud.storage google.cloud.compute grpc \
           snappy cramjam zstandard lz4; do
  check python3 -c "import $mod"
done

exit $fail
EOF

docker run --rm barman-macos bash -c "$CHECKS"
