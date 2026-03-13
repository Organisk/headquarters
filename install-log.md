# claude-home install log

step-by-step record of installing arch linux on soft-serve (10.10.0.25).
date: 2026-03-13.

## environment

| property | value |
|----------|-------|
| host | soft-serve / 10.10.0.25 |
| hypervisor | QEMU/KVM (i440FX + PIIX) |
| cpu | QEMU Virtual CPU |
| ram | 5.6 GiB |
| disk | /dev/sda 30G (QEMU SCSI) |
| boot mode | BIOS/Legacy (no EFI) |
| live ISO | Arch Linux 2025-11-01 |
| live ISO kernel | 6.17.6-arch1-1 |
| live ISO python | 3.13.7 |

## step 1: connect to the live ISO

the server was already booted from the arch ISO with sshd running.

```
ping -c 2 10.10.0.25
```

SSH failed initially — host key had changed from a previous install. fixed by removing the old key:

```
ssh-keygen -R 10.10.0.25
```

this also failed because line 4 in `~/.ssh/known_hosts` was malformed (a cloudflare CA key missing its `@cert-authority *` prefix). fixed the line, then `ssh-keygen -R` succeeded.

reconnected with:

```
ssh -o StrictHostKeyChecking=accept-new root@10.10.0.25
```

## step 2: try archinstall (failed)

### attempt 1: install archinstall

```
pacman -Sy archinstall --noconfirm
```

failed with:

```
error: python-textual: signature from "Robin Candau <antiz@archlinux.org>" is unknown trust
```

the live ISO's pacman keyring was stale.

### attempt 2: refresh keyring

```
pacman-key --init
pacman-key --populate archlinux
```

same error. the keyring package itself needed updating.

### attempt 3: update keyring package first

```
pacman -Sy archlinux-keyring --noconfirm
pacman -S archinstall --noconfirm
```

this worked. archinstall 3.0.15-2 installed.

### attempt 4: run archinstall

```
archinstall --version
```

failed with:

```
ModuleNotFoundError: No module named 'archinstall'
```

**root cause:** the live ISO ships python 3.13, but the updated archinstall package installed its modules under `/usr/lib/python3.14/site-packages/` (the repo has moved to python 3.14). the shebang `/usr/bin/python` points to 3.13, which can't find the 3.14 site-packages.

### attempt 5: PYTHONPATH workaround

```
PYTHONPATH=/usr/lib/python3.14/site-packages python3.13 /usr/bin/archinstall --help
```

this worked — archinstall runs.

### attempt 6: run archinstall with config

created `/tmp/archinstall-config.json`:

```json
{
    "additional-repositories": [],
    "audio_config": null,
    "bootloader": "Grub",
    "hostname": "claude-home",
    "kernels": ["linux"],
    "locale_config": {
        "kb_layout": "us",
        "sys_enc": "UTF-8",
        "sys_lang": "en_US"
    },
    "mirror_config": {
        "mirror_regions": {
            "Worldwide": ["https://geo.mirror.pkgbuild.com/$repo/os/$arch"]
        }
    },
    "network_config": {
        "type": "nm"
    },
    "no_pkg_lookups": false,
    "ntp": true,
    "packages": ["openssh", "git", "vim", "tmux", "htop", "curl", "wget"],
    "parallel downloads": 5,
    "profile_config": {
        "profile": {
            "main": "Server"
        }
    },
    "swap": true,
    "timezone": "Europe/Stockholm",
    "version": "2.8.0"
}
```

created `/tmp/archinstall-creds.json`:

```json
{
    "!root-password": "password1",
    "!users": [
        {
            "username": "skogix",
            "!password": "password1",
            "sudo": true
        }
    ]
}
```

```
PYTHONPATH=/usr/lib/python3.14/site-packages python3.13 /usr/bin/archinstall \
  --config /tmp/archinstall-config.json \
  --creds /tmp/archinstall-creds.json \
  --dry-run
```

failed — archinstall 3.x tries to open a curses TUI even in dry-run mode:

```
_curses.error: setupterm: could not find terminal
```

with `--silent` flag and `TERM=xterm` it ran but produced no output — missing disk layout config that archinstall 3.x requires through TUI selection.

### decision: manual pacstrap

archinstall 3.x is too tightly coupled to its TUI for disk configuration. switched to manual install.

### attempt 7: full system upgrade to get python 3.14

```
pacman -Syu --noconfirm
```

failed as expected:

```
error: Partition / too full: 211902 blocks needed, 49777 blocks free
```

the live ISO airootfs ramdisk only has 256MB, the upgrade needed 814MB.

## step 3: manual install (succeeded)

### 3.1: partition layout

partitions already existed from a previous attempt. reused the layout:

```
NAME   SIZE TYPE FSTYPE
sda     30G disk
├─sda1   1G part vfat    → /boot
└─sda2  29G part ext4    → /
```

partition table: MBR (msdos), matching BIOS/Legacy boot mode.

### 3.2: format

```
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 -F /dev/sda2
```

### 3.3: mount

```
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

### 3.4: pacstrap

```
pacstrap -K /mnt base linux linux-firmware grub networkmanager openssh git vim tmux htop curl wget sudo
```

packages installed:
- **base** — minimal arch base
- **linux** — kernel 6.19.6-arch1-1
- **linux-firmware** — firmware blobs
- **grub** — bootloader
- **networkmanager** — network management
- **openssh** — SSH server
- **git, vim, tmux, htop, curl, wget, sudo** — essential tools

### 3.5: generate fstab

```
genfstab -U /mnt >> /mnt/etc/fstab
```

result:

```
UUID=ac46d9da-be84-4312-aa07-7f768549880f  /      ext4  rw,relatime  0 1
UUID=78C5-6D04                              /boot  vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro  0 2
```

### 3.6: chroot and configure

```
arch-chroot /mnt
```

#### timezone

```
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc
```

#### locale

```
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

#### console keymap

```
echo KEYMAP=us > /etc/vconsole.conf
```

(this was missing on the first mkinitcpio run, causing an error — added it and re-ran)

#### hostname

```
echo claude-home > /etc/hostname
```

#### root password

```
echo root:password1 | chpasswd
```

#### user: skogix

```
useradd -m -G wheel -s /bin/bash skogix
echo skogix:password1 | chpasswd
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
```

#### enable services

```
systemctl enable NetworkManager
systemctl enable sshd
```

#### SSH keys

installed the local ed25519 public key for both root and skogix:

```
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFoUpUb/CaUNSMW3jAEmjBK0OUe3r+NgdKwxyl63NB4" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

mkdir -p /home/skogix/.ssh && chmod 700 /home/skogix/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFoUpUb/CaUNSMW3jAEmjBK0OUe3r+NgdKwxyl63NB4" >> /home/skogix/.ssh/authorized_keys
chmod 600 /home/skogix/.ssh/authorized_keys
chown -R skogix:skogix /home/skogix/.ssh
```

#### initramfs

```
mkinitcpio -P
```

first run errored on missing `/etc/vconsole.conf` (see above). second run clean.

#### bootloader

```
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

both succeeded.

## result

| property | value |
|----------|-------|
| hostname | claude-home |
| kernel | 6.19.6-arch1-1 |
| boot | GRUB, BIOS/Legacy, MBR |
| root partition | /dev/sda2, 29G ext4 |
| boot partition | /dev/sda1, 1G vfat |
| timezone | Europe/Stockholm |
| locale | en_US.UTF-8 |
| root password | password1 |
| user | skogix (wheel, passwordless sudo, password1) |
| SSH | sshd enabled, key auth for root + skogix |
| network | NetworkManager enabled |
| packages | base + linux + grub + networkmanager + openssh + git + vim + tmux + htop + curl + wget + sudo |

## next steps

- reboot into installed system (remove ISO from VM boot order)
- verify SSH access via key auth
- change passwords from defaults
- run bootstrap playbook for full provisioning
- create claude user
