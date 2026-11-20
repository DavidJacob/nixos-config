# Installing NixOS on a laptop

disko partitions and encrypts the disk from `modules/disk-layout.nix`, and
`nixos-install` builds the machine straight from this flake. Replace `HOST`
below with `maple`, `macbook` or `work`.

**This wipes the whole disk**, including macOS on the MacBook (macOS can be
reinstalled later with Internet Recovery, Option + Cmd + R at startup).

Everything on the installer runs as root (`sudo -i` in step 1). Mixing a repo
cloned as the normal user with `sudo` commands makes git refuse it ("not owned
by current user").

## Before you start

- **Reinstalling an existing machine:** commit and push everything, and back
  up what isn't in the repo, especially that machine's GPG secret key:
  `gpg --export-secret-keys --armor <KEY-ID> > <usb-stick>/HOST-gpg-secret.asc`
- **maple (Acer):** press F12 at the logo to pick the USB stick (enable
  "F12 Boot Menu" in the BIOS, F2, if it does nothing).
- **MacBook:** hold Option (⌥) while it starts and pick "EFI Boot". Have a USB
  keyboard handy in case the built-in one doesn't work in the installer.
- **ThinkPad:** in the BIOS (F1 at startup), turn Secure Boot off. Press F12
  at startup to pick the USB stick.
- Boot the NixOS minimal ISO.

## 1. Become root, get online, check the hardware

```sh
sudo -i
nmcli device wifi connect "Network name" --ask     # add `hidden yes` for a hidden network
nix-shell -p git
git clone https://github.com/DavidJacob/nixos-config /tmp/nixos-config
cd /tmp/nixos-config
bash scripts/hwinfo.sh        # model, CPU, RAM, disk, screen
```

## 2. Check the machine's settings

In `hosts/HOST/default.nix`:

- `my.disk.swapSize` must be at least the RAM size (e.g. `"16G"`).
- If the disk isn't `nvme0n1`, add `my.disk.device = "/dev/<name>";`.

Optional: preview exactly what disko will do, without touching the disk:

```sh
less "$(nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --dry-run --mode destroy,format,mount --flake /tmp/nixos-config#HOST | tail -1)"
```

## 3. Partition, encrypt and mount

disko lists the disk and asks you to type `yes`, then asks for the disk
password twice. This is the password you'll type at every boot.

```sh
nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake /tmp/nixos-config#HOST
lsblk                          # nvme0n1p1 (1G), nvme0n1p2 → cryptroot → vg-swap, vg-root
```

## 4. Generate the hardware file

`--no-filesystems` because disko already describes the disks. Flakes only see
files git knows about, hence the `git add`.

```sh
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > hosts/HOST/hardware-configuration.nix
git add hosts/HOST/hardware-configuration.nix
```

## 5. Install

Asks for a root password at the end. If that fails, run
`nixos-enter --root /mnt -c 'passwd'` afterwards.

```sh
nixos-install --flake /tmp/nixos-config#HOST
nixos-enter --root /mnt -c 'passwd david'
```

Copy the repo into David's home, then reboot:

```sh
cp -r /tmp/nixos-config /mnt/home/david/nixos-config
nixos-enter --root /mnt -c 'chown -R david:users /home/david/nixos-config'
reboot
```

At the login screen pick **Hyprland** the first time.

## 6. After the first boot

```sh
cd ~/nixos-config
gh auth login     # GitHub.com, HTTPS, "No" to "Authenticate Git", browser login
```

Answering anything else makes gh try to write Home Manager's read-only config.

**GPG signing key:**

- Reinstall: `gpg --import <usb-stick>/HOST-gpg-secret.asc`, then
  `gpg --edit-key <KEY-ID>` → `trust`, `5`, `quit`.
- New machine: create a key (or connect a YubiKey), upload it with
  `gpg --armor --export <KEY-ID> | gh gpg-key add -`
  (after `gh auth refresh -s write:gpg_key`), and put its ID in
  `home/hosts/HOST.nix`.

**work** only:

- Work email (kept out of the repo):
  `git config --file ~/.config/git/work-identity user.email "you@famedly.com"`
- Fleet enrollment secret (from Famedly's Notion hardware page). It is
  encrypted with this machine's key and never goes into the repo:

  ```sh
  echo '<enroll-key>' | sudo systemd-creds encrypt - /etc/credstore.encrypted/fleet-enroll-key
  sudo systemctl restart orbit
  ```

Check the screen with `hyprctl monitors` and adjust `hypr/hosts/HOST.lua` if
the scale or position looks wrong. Then rebuild, and commit the new hardware
file:

```sh
rebuild
git add -A
git commit -m "Install HOST"
git push
```

Also: `fwupdmgr refresh && fwupdmgr update` for firmware, and log in to
Claude Code (`claude`) and Chrome.
