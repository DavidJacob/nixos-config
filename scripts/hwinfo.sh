#!/usr/bin/env bash
# scripts/hwinfo.sh: prints what nixos-config needs to know about a new laptop.
# Run from the NixOS installer: bash hwinfo.sh

echo "== Model";  cat /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name /sys/class/dmi/id/product_version
echo "== CPU";    lscpu | grep "Model name"
echo "== RAM";    free -h | grep Mem
echo "== Disks";  lsblk -d -o NAME,SIZE,MODEL
echo "== UEFI";   ls -d /sys/firmware/efi >/dev/null 2>&1 && echo yes || echo NO
echo "== Screen"; for d in /sys/class/drm/card*-eDP-*; do echo "${d##*/}: $(head -1 "$d/modes")"; done
echo "== Screen size (cm w h)"; od -An -tu1 -j21 -N2 /sys/class/drm/card*-eDP-*/edid
