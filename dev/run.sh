#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

podman pod rm -f pod_dev 2>/dev/null || true
podman network rm dev_default 2>/dev/null || true
podman rm -f soft-serve 2>/dev/null || true

docker compose build
docker compose up -d
docker exec soft-serve bash -c "git clone https://github.com/Organisk/headquarters.git /tmp/headquarters && cd /tmp/headquarters && ./bootstrap.sh"
