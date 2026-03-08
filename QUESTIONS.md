# headquarters — open questions

questions that need answers before proceeding with each phase.

## phase 1: bootstrap

### Q1: ansible — local or remote?
run ansible from this machine (skogix workstation) targeting soft-serve, or install ansible on soft-serve itself?
- we will git clone git@github.com:SkogAI/bootstrap.git and run it. this will give us a ansible-base to then do the rest from.

- **local** = cleaner, soft-serve stays lean, standard ansible pattern
- **remote** = self-contained, but adds ~200MB+ to an already tight disk

### Q2: disk space
9GB total, 1.6GB free (83% used). this is limiting.

- expand the disk/volume?
- clean up existing data first?
- keep it lean and work within constraints?

what's using the space currently?
- hardware is something you ask for how much you need and we get

### Q3: existing services
what services are running on soft-serve? (soft-serve git server? other things?)
need to know what to monitor and what not to break.
- currently not in scope. but probably 20 servers and associated services. dont focus on this for now.

### Q4: claude user auth
how should the `claude` user authenticate?
- not in focus for now. but github both have your ssh keys and a ssh-agent will run

- SSH key pair (generated fresh, or use existing?)
- sudo access from skogix → claude?
- should claude have passwordless sudo for specific commands?
- should claude be able to SSH back to other machines?

### Q5: notification channels
which are already set up vs need building?
- everything is "set up" bot nothing is integrated/specially made for this setup 

- [ ] whatsapp — bot exists? number? gptme-whatsapp?
- [ ] slack — workspace? bot token?
- [ ] git issues — which repos? github app or PAT?
- [ ] other channels? (telegram, email, pushover?)

## phase 2: provisioning

### Q6: claude CLI installation
the claude CLI exists under skogix's account. for the claude user:
- will be a part of the bootstrap/ansible setup install

- install independently under `/home/claude/`?
- symlink from skogix's install?
- install via npm globally?

### Q7: what tools does claude need?
beyond the basics (git, ssh, claude cli), what should be available?
- everything that is needed and essentially will be a mirror of my own workstation

- node/npm? (for claude-memory, plugins)
- uv/uvx? (for gptme tools)
- docker/podman? (for container management)
- other language runtimes?

### Q8: API keys and secrets
how should secrets be managed on soft-serve?
- not in scope currently but ssh-agent

- `.env` files?
- systemd credential store?
- pass/gopass?
- just environment variables in claude's profile?

## phase 3: guardian

### Q9: monitoring scope
what should the guardian watch?
- literally hundreds of millions worth of tokens to explain......

- [ ] disk space (critical given 1.6GB free)
- [ ] memory usage
- [ ] systemd service health
- [ ] network connectivity
- [ ] specific application health
- [ ] git repo status (dirty worktrees, stale branches)
- [ ] security (failed SSH attempts, package updates)
- [ ] other?

### Q10: alert thresholds and escalation
when to alert vs when to auto-fix?
- really?....

- disk > 90%: alert or auto-clean?
- service down: restart automatically or alert first?
- what's critical enough to wake someone up?

### Q11: orchestration model
how should external triggers work?
- ...

- whatsapp message → claude runs a command → responds?
- slack bot → webhook → systemd service?
- github issue created → ansible playbook runs?
- what's the trust model? who can trigger what?
