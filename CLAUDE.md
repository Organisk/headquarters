# headquarters — claude's home base on soft-serve

<what_is_this>

provisioning and guardian infrastructure for claude's dedicated environment on the `soft-serve` Arch Linux VM (10.10.0.25). coordinates bootstrap, ansible provisioning, container management, monitoring, and orchestration.

</what_is_this>

<target>

| property | value |
|----------|-------|
| host | `claude-home` / `10.10.0.25` |
| os | Arch Linux (rolling) |
| hypervisor | QEMU/KVM (on pve01/pve02) |
| ram | 5.6 GiB |
| disk | 29G root (18GB free) |
| kernel | 6.19.6-arch1-1 |
| boot | BIOS/Legacy, GRUB, MBR |
| services | sshd, cloudflared, tailscaled |
| install log | install-log.md |

</target>

<quickstart>

```bash
# provision claude-home (run on the server itself)
./run.sh

# or with tailscale authkey
HEADSCALE_AUTHKEY=<key> ./run.sh

# run specific role only
ansible-playbook playbooks/claude-home.yml --connection=local --inventory localhost, --tags packages
```

</quickstart>

<structure>

```
roles/
├── packages/   — pacman package installation
├── network/    — tailscale + network config
└── claude/     — claude user environment
playbooks/
└── claude-home.yml  — main playbook (packages → network → claude)
vars/
└── claude-home.yml  — variables for provisioning
network/
├── inventory.md     — full host inventory for Organisk server park
├── topology.html    — interactive network topology explorer
└── CLAUDE.md
```

**playbook roles** (in order):
1. **packages** — pacman package installation
2. **network** — tailscale enrollment, network configuration
3. **claude** — claude user environment setup

</structure>

<goals>

## phase 0: base install (done 2026-03-13)
- arch linux installed via manual pacstrap (archinstall had python 3.13/3.14 mismatch)
- hostname `claude-home`, root + skogix user, sshd + NetworkManager enabled
- SSH key auth configured, passwordless sudo for wheel
- tailscale + cloudflared running

## phase 1: bootstrap (in progress)
- provisioning via `./run.sh` — ansible playbook with packages/network/claude roles
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
- [x] ~~generate headscale service key for soft-serve tailscale enrollment~~ (done 2026-03-13)
- [x] ~~install tailscale on soft-serve~~ (done — tailscaled running)
- [x] ~~add tailscale/network ansible role~~ (done — `network` role in playbook)
- [ ] approve subnet routes in headscale for workstation (currently not being pushed)
- [ ] create claude user and environment
- [ ] set up guardian health checks and monitoring

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
| network inventory & topology | network/CLAUDE.md |
| ansible roles | roles/ |
| playbooks | playbooks/claude-home.yml |
| variables | vars/claude-home.yml |
| network topology (visual) | network/topology.html |

</routing>

<conventions>

follows @.skogai/knowledge/patterns/style/CLAUDE.md conventions.
commits: `{type}(headquarters): {description}`

</conventions>
