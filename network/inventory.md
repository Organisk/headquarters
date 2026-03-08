# network inventory

<what_is_this>

discovered network topology for the Organisk server park.
scanned 2026-03-08 via tailscale subnet routes.

</what_is_this>

## connectivity

| method | from | to | status |
|--------|------|----|--------|
| tailscale | workstation (100.64.0.25) | all subnets | requires `--accept-routes` |
| LAN | workstation (10.10.4.5) | 10.10.4.0/24 only | direct |
| cloudflare tunnel | ssh.skogix.se | workstation | active |

## subnet routing

| subnet | hosts | routed by | tailscale node |
|--------|-------|-----------|----------------|
| `10.10.0.0/24` | 16 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.1.0/24` | 27 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.2.0/24` | 34 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.4.0/24` | 2 | direct LAN | n/a |
| `10.10.20.0/24` | 15 | saheq-hal-pfs | 100.64.0.8 |
| `10.10.22.0/24` | 1 | bron-pfs | 100.64.0.3 |
| `10.10.99.0/24` | 2 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `192.168.68.0/24` | ? | saheq-hal-pfs | 100.64.0.8 (not scanned) |

## hosts — 10.10.0.0/24 (infra)

| IP | SSH banner | OS hint | notes |
|----|-----------|---------|-------|
| 10.10.0.1 | OpenSSH_9.7 | unknown | gateway |
| 10.10.0.2 | OpenSSH_10.0p2 Debian-7 | debian | |
| 10.10.0.3 | OpenSSH_10.0p2 Debian-7 | debian | |
| 10.10.0.8 | OpenSSH_8.9p1 Ubuntu-3ubuntu0.13 | ubuntu 22.04 | |
| 10.10.0.9 | OpenSSH_10.0p2 Debian-7 | debian | |
| 10.10.0.19 | OpenSSH_10.0p2 Debian-7 | debian | |
| 10.10.0.21 | OpenSSH_9.2p1 Debian-2+deb12u7 | debian 12 | |
| 10.10.0.22 | OpenSSH_10.0p2 Debian-7 | debian | |
| **10.10.0.25** | **OpenSSH (Arch)** | **arch linux** | **soft-serve — claude HQ target** |
| 10.10.0.27 | OpenSSH_9.2p1 Debian-2+deb12u7 | debian 12 | |
| 10.10.0.51 | (no SSH) | | |
| 10.10.0.57 | dropbear_2022.83 | embedded | |
| 10.10.0.58 | dropbear_2024.86 | embedded | |
| 10.10.0.69 | (no SSH) | | |
| 10.10.0.136 | (no SSH) | | |
| 10.10.0.196 | OpenSSH_10.2 | bleeding edge | |

### soft-serve detail (10.10.0.25)

| property | value |
|----------|-------|
| os | Arch Linux |
| cpu | 2x QEMU vCPU |
| ram | 1.9GB (344MB used) |
| disk | 9GB (83% used, 1.6GB free) |
| users | root, aldervall (1000), skogix (1001), git (git-shell) |
| services | soft-serve.service (:23231-3), sshd (:22) |
| tailscale | not installed |
| containers | none |

## hosts — 10.10.1.0/24 (27 hosts)

.1 .2 .3 .4 .5 .7 .8 .9 .10 .12 .14 .15 .17 .19 .20 .21 .22 .24 .26 .32 .50 .53 .57 .64 .72 .116 .126 .131 .146 .221 .230

## hosts — 10.10.2.0/24 (34 hosts)

.1 .2 .7 .8 .9 .10 .20 .31 .32 .33 .34 .36 .40 .41 .42 .44 .49 .50 .54 .68 .69 .71 .76 .77 .80 .101 .117 .124 .142 .155 .170 .184 .192 .220

## hosts — 10.10.20.0/24 (15 hosts)

.1 .2 .11 .12 .13 .14 .15 .20 .21 .25 .50 .52 .54 .64 .100

## hosts — 10.10.22.0/24 (1 host)

.1 (gateway only)

## hosts — 10.10.99.0/24 (2 hosts)

.1 .3

## hosts — 10.10.4.0/24 (workstation)

| IP | name | role |
|----|------|------|
| 10.10.4.5 | skogix-workstation | this machine |
| 10.10.4.9 | | gateway/router (MAC 7c:f1:7e:b1:e8:b2) |

## tailscale overlay

### routers and exit nodes

| tailscale IP | name | routes advertised |
|---|---|---|
| 100.64.0.10 | LFG-ROUTE-INTERNAL | 10.10.0/1/2/99.0/24 |
| 100.64.0.8 | saheq-hal-pfs | 10.10.20.0/24, 192.168.68.0/24 |
| 100.64.0.3 | bron-pfs | 10.10.22.0/24 |
| 100.64.0.12 | LFG-ROUTE-MALTA | 0.0.0.0/0, ::/0 (exit node) |
| 100.64.0.27 | pfsense-rg | (no subnet routes) |

### other online nodes

| tailscale IP | name | owner | OS |
|---|---|---|---|
| 100.64.0.25 | skogix-workstation-cvmtijrz | emil | linux |
| 100.64.0.13 | headplane-agent | router | linux |
| 100.64.0.24 | quiz-server | worker | linux |

### offline (notable)

| tailscale IP | name | owner | last seen |
|---|---|---|---|
| 100.64.0.7 | dellvall | niklas | 2d ago |
| 100.64.0.15 | cachyamd | niklas | 9d ago |
| 100.64.0.23 | win-su9qf55mgts | niklas | 7d ago |
| 100.64.0.26 | brg-skogix-pfs | tagged | 26d ago |

## observations

- **LFG-ROUTE-INTERNAL** is the main gateway — routes 4 subnets including soft-serve's
- **10.10.0.0/24** is mostly debian boxes (6x Debian, 1x Ubuntu, 1x Arch, 2x embedded/dropbear, 3x no SSH)
- **10.10.22.0/24** and **10.10.99.0/24** are nearly empty
- **soft-serve has no tailscale** — reachable only via LFG-ROUTE-INTERNAL subnet routing
- **pfsense-rg** is online but advertises no subnet routes
- **headscale** (self-hosted) manages the overlay — headplane-agent is the control plane
