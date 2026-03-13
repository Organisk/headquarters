# network inventory

<what_is_this>

discovered network topology for the Organisk server park.
scanned 2026-03-08 via tailscale subnet routes.
updated 2026-03-13 from claude-home (10.10.0.25) on-network scan.

</what_is_this>

## connectivity

| method | from | to | status |
|--------|------|----|--------|
| tailscale | workstation (100.64.0.25) | all subnets | requires `--accept-routes` |
| LAN | workstation (10.10.4.5) | 10.10.4.0/24 only | direct |
| LAN | claude-home (10.10.0.25) | 10.10.0/1/2/99.0/24 | direct (no tailscale needed) |
| cloudflare tunnel | ssh.skogix.se | workstation | active |
| cloudflare tunnel | cloudflared on claude-home | ? | active (service running) |

## subnet routing

| subnet | hosts | routed by | tailscale node |
|--------|-------|-----------|----------------|
| `10.10.0.0/24` | 16 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.1.0/24` | 33 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.2.0/24` | 29 (6 down) | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `10.10.4.0/24` | 2 | direct LAN | n/a |
| `10.10.20.0/24` | 15 | saheq-hal-pfs | 100.64.0.8 |
| `10.10.22.0/24` | 1 | bron-pfs | 100.64.0.3 |
| `10.10.99.0/24` | 2 | LFG-ROUTE-INTERNAL | 100.64.0.10 |
| `192.168.68.0/24` | ? | saheq-hal-pfs | 100.64.0.8 (not scanned) |

## hosts — 10.10.0.0/24 (infra)

| IP | SSH banner | OS hint | services | notes |
|----|-----------|---------|----------|-------|
| 10.10.0.1 | OpenSSH_9.7 | FreeBSD/pfSense | :443 pfSense WebGUI | gateway/firewall |
| 10.10.0.2 | OpenSSH_10.0p2 Debian-7 | debian | :8006 Proxmox VE (pve01) | hypervisor |
| 10.10.0.3 | OpenSSH_10.0p2 Debian-7 | debian | :8006 Proxmox VE (pve02) | hypervisor |
| 10.10.0.8 | OpenSSH_8.9p1 Ubuntu-3ubuntu0.13 | ubuntu 22.04 | SSH only | |
| 10.10.0.9 | OpenSSH_10.0p2 Debian-7 | debian | :8080 Tomcat/Java | |
| 10.10.0.19 | OpenSSH_10.0p2 Debian-7 | debian | :8006 Proxmox Mail Gateway | mail gateway |
| 10.10.0.21 | OpenSSH_9.2p1 Debian-2+deb12u7 | debian 12 | :3000 Reactive Resume | resume.aldervall.se |
| 10.10.0.22 | OpenSSH_10.0p2 Debian-7 | debian | SSH only | |
| **10.10.0.25** | **OpenSSH (Arch)** | **arch linux** | **:22 SSH, :8080 node, cloudflared, tailscaled** | **claude-home** |
| 10.10.0.27 | OpenSSH_9.2p1 Debian-2+deb12u7 | debian 12 | :5000 Frigate NVR | NVR/camera system |
| 10.10.0.51 | (no SSH, refused) | | | physical device (b0:4a:39) |
| 10.10.0.57 | dropbear_2022.83 | embedded | SSH only | physical device (78:8a:20) |
| 10.10.0.58 | dropbear_2024.86 | embedded | SSH only | physical device (d0:21:f9) |
| 10.10.0.69 | (no SSH) | | | offline 2026-03-13 |
| 10.10.0.136 | (no SSH) | | | offline 2026-03-13 |
| 10.10.0.196 | OpenSSH_10.2 | bleeding edge | | intermittent (d4:54:8b) |

### claude-home detail (10.10.0.25)

| property | value |
|----------|-------|
| hostname | claude-home |
| os | Arch Linux (kernel 6.19.6-arch1-1) |
| cpu | 4x QEMU vCPU |
| ram | 5.6GB (894MB used, 4.8GB available) |
| disk | 29GB (9.3GB used, 18GB free, 35%) |
| users | skogix (1000) |
| services | sshd (:22), cloudflared, tailscaled, node (:8080) |
| tailscale | installed and running |
| containers | none |
| reachable subnets | 10.10.0/1/2/99.0/24 (direct), 10.10.20.0/24 (unreachable) |

## hosts — 10.10.1.0/24 (mixed infra / IoT)

33 live hosts. 2 new (.181, .188) vs previous scan.

| IP | SSH banner | OS hint | services | notes |
|----|-----------|---------|----------|-------|
| 10.10.1.1 | — | FreeBSD/pfSense | :80 pfSense WebGUI | **pfSense** gateway |
| 10.10.1.2 | — | Debian/Proxmox | :8006 Proxmox VE | **pve01** hypervisor |
| 10.10.1.3 | OpenSSH_10.2 | Linux | :443, :3000, :5000 | **Traefik** reverse proxy + log dashboard v2.0.0 |
| 10.10.1.4 | — | Debian/Proxmox | :8006 Proxmox VE | **graph** hypervisor |
| 10.10.1.5 | — | Debian/Proxmox | :8006 Proxmox VE | **pve3** hypervisor |
| 10.10.1.7 | dropbear_2024.86 | embedded | :22 | NAS/embedded (Synology/QNAP?) |
| 10.10.1.8 | dropbear_2024.86 | embedded | :22 | NAS/embedded (Synology/QNAP?) |
| 10.10.1.9 | dropbear_2024.86 | embedded | :22, :8080 | NAS/embedded + web |
| 10.10.1.10 | OpenSSH_9.2p1 Debian | Debian 12 | :22 | VM, SSH only |
| 10.10.1.12 | — | TrueNAS | :80 (302), :443 nginx | **TrueNAS** (iXsystems cert) |
| 10.10.1.14 | — | embedded | :80 (login.asp) | **Hikvision** IP camera |
| 10.10.1.15 | — | embedded | :80, :443, :8080 | **HP Color LaserJet MFP M281fdw** |
| 10.10.1.17 | — | embedded | :80, :443 | **Reolink** NVR/camera |
| 10.10.1.19 | — | media device | :554 RTSP, :7000 AirPlay, :8080 | **Apple TV** or smart TV |
| 10.10.1.20 | dropbear_2022.83 | embedded | :22 | NAS/embedded (older) |
| 10.10.1.21 | dropbear_2022.83 | embedded | :22 | NAS/embedded (older) |
| 10.10.1.22 | — | RouterOS | :80 RouterOS WebFig | **MikroTik** router (v6.49.13) |
| 10.10.1.24 | OpenSSH_9.2p1 Debian | Debian 12 | :22 | VM, SSH only |
| 10.10.1.26 | — | embedded | :80 Fronius WebUI | **Fronius** solar inverter |
| 10.10.1.32 | OpenSSH_10.2 | Linux | :3000 JellyStat, :8080 qBittorrent | **media server** |
| 10.10.1.50 | — | IoT | :8443 | **IKEA Dirigera** smart home hub |
| 10.10.1.53 | — | IoT | :8443 | **IKEA Dirigera** smart home hub |
| 10.10.1.57 | — | unknown | :53 DNS, :554 RTSP | DNS server + camera/NVR |
| 10.10.1.64 | OpenSSH_9.2p1 Debian | Debian 12 | :22 | VM, SSH only |
| 10.10.1.72 | — | unknown | ping only | IoT/phone |
| 10.10.1.116 | — | Sonos | :5000 AirTunes, :7000 AirPlay | **Sonos** speaker (AirPlay 2) |
| 10.10.1.126 | — | unknown | ping only | IoT/phone |
| 10.10.1.131 | — | Sonos | :5000 AirTunes, :7000 AirPlay | **Sonos** speaker (AirPlay 2) |
| 10.10.1.146 | — | Android TV | :8443, :8008 | **Chromecast "Telia TV"** (ethernet, cast 3.72) |
| 10.10.1.181 | — | unknown | ping only | **NEW** — IoT/phone |
| 10.10.1.188 | — | unknown | ping only | **NEW** — IoT/phone |
| 10.10.1.221 | — | Sonos | :5000 AirTunes, :7000 AirPlay | **Sonos** speaker (AirPlay 2) |
| 10.10.1.230 | — | unknown | ping only | IoT/phone |

## hosts — 10.10.2.0/24 (smart home / media)

29 live, 6 down from previous scan (.54, .77, .80, .101, .124, .155). 1 new (.188).

| IP | OS hint | services | notes |
|----|---------|----------|-------|
| 10.10.2.1 | FreeBSD/pfSense | :80 (301), :443 | **pfSense** gateway |
| 10.10.2.2 | Debian 12 | :8006 Proxmox VE | **pvebron** (pvebron.va.aldervall.se) |
| 10.10.2.7 | embedded | dropbear_2024.86 | NAS/embedded |
| 10.10.2.8 | embedded | dropbear_2024.86 | NAS/embedded |
| 10.10.2.9 | embedded | dropbear_2024.86 | NAS/embedded |
| 10.10.2.10 | embedded | dropbear_2022.83 | NAS/embedded (older) |
| 10.10.2.20 | Linux | :5000 nginx (403) | server, nginx blocking direct |
| 10.10.2.31 | embedded | :80/:443 | **Reolink** NVR/camera |
| 10.10.2.32 | Android TV | :8443 | **Chromecast** "Vardagsrum tv" |
| 10.10.2.33 | Sonos | :1400 | **Sonos One** "Altan" |
| 10.10.2.34 | Sonos | :1400 | **Sonos Play:1** "Matheo" |
| 10.10.2.36 | Sonos | :1400 | **Sonos Play:1** "Terrass ute" |
| 10.10.2.40 | IoT | ping only | smart plug/bulb |
| 10.10.2.41 | IoT | ping only | smart plug/bulb |
| 10.10.2.42 | IoT | ping only | smart plug/bulb |
| 10.10.2.44 | embedded | :80 (Nucleus) | **Nucleus** media server |
| 10.10.2.49 | IoT | ping only | smart plug/bulb |
| 10.10.2.50 | IoT | ping only | smart plug/bulb |
| 10.10.2.68 | IoT | ping only | smart plug/bulb |
| 10.10.2.69 | embedded | :80 dropbear | **Telldus** home automation gateway |
| 10.10.2.71 | Sonos | :1400 | **Sonos Play:1** "Sovrum" |
| 10.10.2.76 | Sonos | :1400 | **Sonos Playbar** "Vardagsrum" |
| 10.10.2.117 | Chromecast 4K | :8443, :8008 | **Chromecast Ultra** "Bio" (WiFi: Bron) |
| 10.10.2.142 | Android TV | :8443, :8008 | **Chromecast** "Matheos sovrum" |
| 10.10.2.170 | embedded | :80 | **Xerox WorkCentre 6605DN** printer |
| 10.10.2.184 | IoT | ping only | smart plug/bulb |
| 10.10.2.188 | IoT | ping only | **NEW** — smart plug/bulb |
| 10.10.2.192 | Android TV | :8443, :8008 | **Chromecast** "Tv i Vardagsrum" |
| 10.10.2.220 | Google Cast | :8443, :8008 | **Chromecast** "Koket" (WiFi: Bron) |

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

- **LFG-ROUTE-INTERNAL** is the main gateway — routes 4 subnets including claude-home's
- **10.10.0.0/24** is mostly debian boxes (6x Debian, 1x Ubuntu, 1x Arch, 2x embedded/dropbear, 3x no SSH)
- **10.10.1.0/24** is mixed infra + smart home: 3 Proxmox nodes, TrueNAS, Traefik proxy, MikroTik, Fronius solar, 2x IKEA Dirigera hubs, 3x Sonos, Hikvision + Reolink cameras, media server
- **10.10.2.0/24** is smart home / media: Sonos speakers, Chromecasts, Reolink camera, Telldus automation, Xerox printer, lots of IoT
- **10.10.22.0/24** and **10.10.99.0/24** are nearly empty
- **Proxmox cluster spans subnets**: pve01 (.0.2 and .1.2), pve02 (.0.3), graph (.1.4), pve3 (.1.5), pvebron (.2.2)
- **claude-home now has tailscale** — running as of 2026-03-13
- **claude-home has cloudflared** — tunnel active
- **pfsense-rg** is online but advertises no subnet routes
- **headscale** (self-hosted) manages the overlay — headplane-agent is the control plane

### infrastructure map (10.10.0.0/24)

```
pfSense (.1) ─── gateway/firewall
├── pve01 (.2) ─── Proxmox hypervisor
├── pve02 (.3) ─── Proxmox hypervisor
├── VMs:
│   ├── .8  ─── Ubuntu 22.04
│   ├── .9  ─── Debian (Tomcat/Java :8080)
│   ├── .19 ─── Proxmox Mail Gateway (:8006)
│   ├── .21 ─── Debian 12 (Reactive Resume :3000)
│   ├── .22 ─── Debian
│   ├── .25 ─── claude-home (Arch Linux) ← we are here
│   └── .27 ─── Debian 12 (Frigate NVR :5000)
├── physical:
│   ├── .51 ─── unknown (no SSH)
│   ├── .57 ─── embedded (dropbear)
│   └── .58 ─── embedded (dropbear)
└── offline: .69, .136, .196 (intermittent)
```
