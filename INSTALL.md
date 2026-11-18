# Installing NixOS on the MacBook or the work ThinkPad

disko partitions and encrypts the disk from `modules/disk-layout.nix`, and
`nixos-install` builds the machine straight from this flake. Replace `HOST`
below with `macbook` or `work`.

**This wipes the whole disk**, including macOS on the MacBook (macOS can be
reinstalled later with Internet Recovery, Option + Cmd + R at startup).

## Before you start

- **MacBook:** hold Option (⌥) while it starts and pick "EFI Boot". Have a USB
  keyboard handy in case the built-in one doesn't work in the installer.
- **ThinkPad:** in the BIOS (F1 at startup), turn Secure Boot off. Press F12
  at startup to pick the USB stick.
- Boot the NixOS minimal ISO.

## 1. Get online and check the hardware

```sh
nmcli device wifi connect "Network name" --ask
lsblk                         # the internal disk, normally nvme0n1
free -h                       # RAM: the swap size should be at least this
lscpu | grep "Model name"     # work: Intel or AMD?
```

## 2. Get the repo and fill in the TODOs

```sh
nix-shell -p git
git clone https://github.com/DavidJacob/nixos-config /tmp/nixos-config
cd /tmp/nixos-config
nano hosts/HOST/default.nix
```

- Set `my.disk.swapSize` to the RAM size (e.g. `"16G"`).
- If the disk isn't `nvme0n1`, add `my.disk.device = "/dev/<name>";`.
- **work:** keep the Intel line or switch to the AMD lines, as the file explains.

## 3. Partition, encrypt and mount

Asks for the disk password twice. This is the password you'll type at every boot.

```sh
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake /tmp/nixos-config#HOST
```

## 4. Generate the hardware file

`--no-filesystems` because disko already describes the disks. Flakes only see
files git knows about, hence the `git add`.

```sh
sudo nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > hosts/HOST/hardware-configuration.nix
git add hosts/HOST/hardware-configuration.nix
```

## 5. Install

Asks for a root password at the end.

```sh
sudo nixos-install --flake /tmp/nixos-config#HOST
sudo nixos-enter --root /mnt -c 'passwd david'
```

Copy the repo into David's home, then reboot:

```sh
sudo cp -r /tmp/nixos-config /mnt/home/david/nixos-config
sudo nixos-enter --root /mnt -c 'chown -R david:users /home/david/nixos-config'
reboot
```

At the login screen pick **Hyprland** the first time.

## 6. After the first boot

```sh
cd ~/nixos-config
gh auth login                 # HTTPS, log in with a browser
```

Create this machine's GPG key (same steps as on maple), add it to GitHub
(`gh gpg-key add`), and put its ID in `home/hosts/HOST.nix`:

```sh
gpg --list-secret-keys --keyid-format=long
```

**work** only:

- Put your Famedly email in `home/hosts/work.nix`. Famedly requires signed
  commits, so committing fails until the GPG key is set up.
- Add the Fleet enrollment secret (from Famedly's Notion hardware page). It is
  encrypted with this machine's key and never goes into the repo:

  ```sh
  echo '<enroll-key>' | sudo systemd-creds encrypt - /etc/credstore.encrypted/fleet-enroll-key
  sudo systemctl restart orbit
  ```

Then check the screen settings with `hyprctl monitors` and adjust
`hypr/hosts/HOST.lua` if the scale or position looks wrong.

Finally rebuild, and commit the new hardware file:

```sh
rebuild
git add -A
git commit -m "Install HOST"
git push
```
