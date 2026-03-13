# headquarters — claude's home base on soft-serve

<what_is_this>

provisioning and guardian infrastructure for claude's dedicated environment on the `soft-serve` Arch Linux VM (10.10.0.25). coordinates bootstrap, ansible provisioning, container management, monitoring, and orchestration.

</what_is_this>

<target>

| property | value |
|----------|-------|
| host | `claude-home` (was `soft-serve`) / `10.10.0.25` |
| os | Arch Linux (rolling) |
| hypervisor | QEMU/KVM |
| ram | 5.6 GiB |
| disk | 30G (/dev/sda: 1G boot + 29G root) |
| kernel | 6.19.6-arch1-1 |
| boot | BIOS/Legacy, GRUB, MBR |
| python | 3.14 (repo current, not yet installed — base install only) |
| claude user | **does not exist yet** |
| install log | install-log.md |

</target>

<submodules>

### bootstrap/ — `SkogAI/bootstrap`
one-liner arch linux provisioning. clones from github, runs `bootstrap.sh`.

**flow**: `bootstrap.sh` → `sudo pacman -S github-cli uv git` → `uv tool install ansible-core` → `ansible-vault view pat.vault.test` → `gh auth login` → `ansible-galaxy collection install` → `ansible-playbook playbooks/bootstrap.yml`

**playbook roles** (in order):
1. **users** — wheel group, aur_builder user, yay AUR helper, pacman packages
2. **packages** — full workstation package list (53 pacman + 20 AUR packages)
3. **secrets** — clones SSH keys from github.com/skogai/secrets
4. **bitwarden** — bitwarden integration
5. **dolt** — dolt database + systemd service

**testing**: `pat.vault.test` encrypted with `password1` (via `pat.password.example`) for container/CI use. real `pat.vault` uses production vault password.

**dev/**: Dockerfile, docker-compose.yml, run.sh — bare arch container simulating fresh archinstall VM.

### container/ — `SkogAI/container`
arch linux docker dev container + podman service management (21 service scripts).

</submodules>

<goals>

## phase 0: base install (done 2026-03-13)
- arch linux installed via manual pacstrap (archinstall had python 3.13/3.14 mismatch)
- hostname `claude-home`, root + skogix user, sshd + NetworkManager enabled
- SSH key auth configured, passwordless sudo for wheel
- **status: awaiting reboot into installed system**

## phase 1: bootstrap (next)
- clone `SkogAI/bootstrap`, run `bootstrap.sh` — gh auth + ansible playbook
- previous blocker in container: yay build OOM killed (should work on real hardware with 5.6G RAM)
- extend with claude user role (currently only provisions `skogix`)

## phase 2: ansible provisioning
- claude user environment mirroring skogix workstation
- `.claude/` directory structure, dotfiles, tools
- cron infrastructure, systemd timers

## phase 3: guardian
- health checks, monitoring, `/loop` integration
- notification channels: whatsapp, slack, git issues
- remote orchestration

## todo
- [ ] generate headscale service key for soft-serve tailscale enrollment
- [ ] install tailscale on soft-serve (`pacman -S tailscale`, `tailscale up --login-server=$HEADSCALE_URL --hostname=soft-serve`)
- [ ] add `tailscale` ansible role to bootstrap playbook (after `users`, before `packages`)
- [ ] approve subnet routes in headscale for workstation (currently not being pushed)

</goals>

<decisions>

- **disk/hardware**: expandable on request, not a constraint
- **bootstrap method**: `git clone` bootstrap from github, run `bootstrap.sh`
- **tool parity**: claude's environment mirrors skogix workstation
- **SSH auth**: github ssh keys + ssh-agent
- **testing**: bare arch container simulates fresh archinstall VM
- **vault for testing**: `pat.vault.test` + `pat.password.example` (`password1`)
- **ansible.cfg**: password file paths commented out (not needed with passwordless sudo)

</decisions>

<routing>

| need | go to |
|------|-------|
| install log & decisions | install-log.md |
| network inventory & topology | @network/CLAUDE.md |
| bootstrap repo | bootstrap/ (submodule: SkogAI/bootstrap) |
| container tooling | container/ (submodule: SkogAI/container) |
| ansible roles | bootstrap/roles/ |
| package lists | bootstrap/vars/packages.yml |
| dev/test container | bootstrap/dev/ |

</routing>

<conventions>

follows @.skogai/knowledge/patterns/style/CLAUDE.md conventions.
commits: `{type}(headquarters): {description}`

</conventions>
