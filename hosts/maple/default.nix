# hosts/maple: Acer Swift 3 (SF314-59), Intel Iris Xe. Personal laptop.
# Installed by hand (no disko), so the disk settings are written out here.
{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Unlock the encrypted partition at boot. Root and swap are LVM volumes
  # inside it, so one password unlocks both. nixos-generate-config does not
  # detect LUKS under LVM, which is why this line is needed here.
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/cryptroot";
    allowDiscards = true;   # lets SSD TRIM pass through the encryption
  };

  # Resume from the encrypted swap volume after hibernation
  boot.resumeDevice = "/dev/disk/by-label/swap";

  # ---------- Intel Iris Xe graphics ----------
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];   # hardware video decoding

  # Set this to the value nixos-generate-config wrote in its own
  # configuration.nix, then never change it.
  system.stateVersion = "26.05";
}
