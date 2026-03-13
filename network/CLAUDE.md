# network/ — network inventory and topology

<what_is_this>

network documentation and tooling for the Organisk server park.
discovered topology, host inventory, subnet mapping, interactive explorer.

</what_is_this>

<quickstart>

```bash
# serve the interactive topology explorer
cd network && python3 -m http.server 8888 --bind 0.0.0.0
# then open http://10.10.0.25:8888/topology.html

# ping sweep a subnet
for i in $(seq 1 254); do ping -c1 -W0.3 10.10.X.$i &>/dev/null && echo "10.10.X.$i UP" & done; wait

# grab SSH banners
timeout 2 bash -c "echo '' | nc -w1 HOST 22"
```

</quickstart>

<access>

from claude-home (10.10.0.25):
- **direct**: 10.10.0/1/2/99.0/24
- **unreachable**: 10.10.20.0/24 (needs tailscale `--accept-routes` or saheq-hal-pfs routing)
- **not scanned**: 192.168.68.0/24

</access>

<routing>

| need | go to |
|------|-------|
| full host inventory | inventory.md |
| interactive topology | topology.html (serve with python http.server) |
| scanning methodology | ping sweep + SSH banner + curl port probe (see quickstart) |

</routing>
