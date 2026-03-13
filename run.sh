#!/usr/bin/env bash
set -euo pipefail

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

cd "$(dirname "$0")"

# ensure ansible deps
log "Checking ansible collections..."
ansible-galaxy collection install community.general --force-with-deps -p ./tmp/collections

# run playbook
log "Running claude-home playbook..."
ansible-playbook playbooks/claude-home.yml "$@"
