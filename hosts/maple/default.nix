# hosts/maple: Acer Swift 3 (SF314-59), Intel Iris Xe. Personal laptop.
{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/disk-layout.nix
  ]
  # Created during installation (see INSTALL.md)
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # ---------- Disk ----------
  # At least the RAM size, for hibernation (check with free -h)
  my.disk.swapSize = "16G";

  # ---------- Intel Iris Xe graphics ----------
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];   # hardware video decoding

  # The NixOS release this machine was first installed with. Set it once at
  # install time, then never change it.
  system.stateVersion = "26.11";
}
