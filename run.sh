#!/usr/bin/env bash
# run.sh — bootstrap and provision claude-home
# clone repo on server, then: ./run.sh
set -euo pipefail

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

cd "$(dirname "$0")"

# install minimum deps
if ! command -v ansible-playbook &>/dev/null; then
  log "Installing ansible..."
  sudo pacman -S --needed --noconfirm python-uv git
  uv tool install ansible-core
  export PATH="$HOME/.local/bin:$PATH"
fi

# ensure ansible collections
log "Installing ansible collections..."
ansible-galaxy collection install community.general -p ./tmp/collections

# run playbook locally
log "Running claude-home playbook..."
ansible-playbook playbooks/claude-home.yml --connection=local --inventory localhost, "$@"
