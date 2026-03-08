# headquarters — claude's home base on soft-serve

<what_is_this>

provisioning and guardian infrastructure for claude's dedicated environment on the `soft-serve` Arch Linux VM (10.10.0.25). coordinates bootstrap, ansible provisioning, container management, monitoring, and orchestration.

this is the **coordination layer** — it doesn't reinvent bootstrap or container tooling, it extends them for claude's dedicated setup.

</what_is_this>

<target>

| property | value |
|----------|-------|
| host | `soft-serve` / `10.10.0.25` |
| os | Arch Linux (rolling) |
| kernel | 6.18.2-arch2-1 |
| ram | 2GB (expandable on request) |
| disk | 9GB total, 1.6GB free (expandable on request) |
| python | 3.13 |
| claude cli | exists at `/home/skogix/.local/bin/claude` |
| claude user | **does not exist yet** |
| ansible | not installed (bootstrap installs via `uv tool install ansible-core`) |
| docker/podman | not installed |

</target>

<submodules>

### bootstrap/ — `SkogAI/bootstrap`
one-liner arch linux provisioning. installs base deps (github-cli, uv, git), ansible via uv, decrypts PAT from vault, authenticates gh, runs ansible playbook.

**flow**: `bootstrap.sh` → pacman base deps → `uv tool install ansible-core` → vault-decrypt PAT → `gh auth` → `ansible-playbook playbooks/bootstrap.yml`

**playbook roles** (in order):
1. **users** — user groups, AUR builder user, yay, pacman update, package install
2. **packages** — full workstation package list (claude-code from AUR, tmux, zsh, ripgrep, uv, etc.)
3. **secrets** — secret management
4. **bitwarden** — bitwarden integration
5. **dolt** — dolt database + systemd service

**config**: vault password at `~/.ssh/ansible-vault-password`, become password at `~/.ssh/ansible-become-password`, inventory at `.inventory`, vars in `vars/main.yml` (currently hardcoded to `user_name: skogix`)

### container/ — `SkogAI/container`
arch linux docker dev container. full toolchain matching claude code sandbox.

**includes**: base-devel, python (3.10-3.13 via pyenv), node/npm, go, rust, ruby, php, java, postgresql, redis, playwright, libreoffice headless, xvfb, docker CLI.

**argcfile.sh**: podman-based service management (searxng currently). scripts/ has 21 service definitions (grafana, prometheus, uptime-kuma, traefik, nextcloud, etc.)

**user**: non-root `dev` user with passwordless sudo, zsh shell.

</submodules>

<goals>

## phase 1: bootstrap
- clone `SkogAI/bootstrap` on soft-serve, run `bootstrap.sh`
- extend with claude user role (currently only provisions `skogix`)
- SSH keys via GitHub + ssh-agent

## phase 2: ansible provisioning
- claude user environment mirroring skogix workstation
- `.claude/` directory structure, dotfiles, tools
- claude CLI installed as part of bootstrap ansible
- cron infrastructure, systemd timers

## phase 3: guardian
- health check scripts (disk, memory, services, connectivity)
- cron/systemd timers for periodic checks
- `/loop` integration for continuous monitoring
- notification channels: whatsapp, slack, git issues
- remote orchestration — users trigger actions via external channels

</goals>

<decisions>

- **disk/hardware**: expandable on request, not a constraint
- **bootstrap method**: clone SkogAI/bootstrap and run, gives ansible base
- **tool parity**: claude's environment mirrors skogix workstation
- **SSH auth**: github ssh keys + ssh-agent (details deferred)
- **notifications**: infrastructure exists but nothing integrated for this setup yet
- **monitoring scope**: extensive, details to be defined iteratively
- **other services (~20)**: not in scope for now

</decisions>

<development>

### local test environment
a bare `archlinux:latest` container named `soft-serve` simulates a fresh archinstall VM. bootstrap is mounted read-only at `/bootstrap/`, copied to `~/bootstrap/` at runtime for ansible to write to.

| file | purpose |
|------|---------|
| Dockerfile | bare arch + base-devel + sudo + openssh + skogix user in wheel |
| docker-compose.yml | runs container with bootstrap/ mounted read-only |
| run-bootstrap.sh | copies bootstrap, installs collections, patches ansible.cfg (removes password file refs), runs playbook with users+packages tags |
| test-bootstrap.sh | validates each bootstrap step (container state, base deps, ansible, collections, users role, packages) |

### known issues
- `ansible.cfg` in bootstrap/ hardcodes `~/.ssh/ansible-become-password` and `~/.ssh/ansible-vault-password` — run-bootstrap.sh patches these out for container use
- secrets/bitwarden/dolt roles skipped in container (need gh auth / PAT)

</development>

<routing>

| need | go to |
|------|-------|
| open questions | QUESTIONS.md |
| bootstrap repo | bootstrap/ (submodule: SkogAI/bootstrap) |
| container tooling | container/ (submodule: SkogAI/container) |
| ansible roles | bootstrap/roles/ |
| package lists | bootstrap/vars/packages.yml |
| container services | container/scripts/ (21 service definitions) |
| run bootstrap in container | run-bootstrap.sh |
| verify bootstrap results | test-bootstrap.sh |

</routing>

<conventions>

follows @.skogai/knowledge/patterns/style/CLAUDE.md conventions.
commits: `{type}(headquarters): {description}`

</conventions>
