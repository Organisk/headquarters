#!/usr/bin/env bash
# bootstrap.sh — Bootstrap for fresh Arch Linux
# git clone https://github.com/Organisk/headquarters && cd headquarters && ./bootstrap.sh
set -euo pipefail

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

# Install minimum deps
log "Syncing package database..."
sudo pacman -Sy --noconfirm
log "Installing base packages..."
sudo pacman -S --needed --noconfirm github-cli uv git

# Setup ansible via uv
log "Setting up ansible..."
uv tool install ansible-core
export PATH="$HOME/.local/bin:$PATH"

# Auth gh
log "Authenticating gh..."
ANSIBLE_VAULT_PASSWORD_FILE=./pat.password.example ansible-vault view ./pat.vault.test | gh auth login --with-token
gh auth setup-git
gh auth status

# Install ansible collections and run playbook
log "Running ansible..."
ansible-galaxy collection install -r .requirements.yml
ansible-playbook playbooks/bootstrap.yml
