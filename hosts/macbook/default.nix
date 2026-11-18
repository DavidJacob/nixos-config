# hosts/macbook: MacBook Pro 13" 2017 with Touch Bar (MacBookPro14,2). Personal laptop.
# Intel Kaby Lake (Iris Plus 650), 2560x1600 screen, Broadcom Wi-Fi.
{ inputs, lib, ... }:

{
  imports = [
    ../../modules/disk-layout.nix

    # nixos-hardware has no 14,2 profile; 14,1 is the same 2017 13" without the
    # Touch Bar, and covers what matters: the SPI keyboard and touchpad (also at
    # the disk password prompt), Kaby Lake graphics, fan control (mbpfan),
    # the FaceTime HD camera, firmware and HiDPI.
    inputs.nixos-hardware.nixosModules.apple-macbook-pro-14-1
  ]
  # Created during installation (see INSTALL.md). Until then the config still
  # evaluates, so it can be checked from another machine.
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # ---------- Disk ----------
  # TODO: set to the Mac's RAM (8G or 16G; check with `free -h` on the installer)
  my.disk.swapSize = "16G";

  # ---------- Known gaps on this model ----------
  # TODO Speakers and headphone jack: the Cirrus Logic CS8409 audio chip needs
  # an out-of-tree driver (github.com/davidjo/snd_hda_macbookpro) that isn't
  # packaged in nixpkgs yet. USB and Bluetooth audio work without it.
  #
  # TODO Touch Bar: check after install whether it shows the Esc/function/media
  # keys. Caps Lock is already swapped to Esc on every machine, so Esc works
  # either way.
  #
  # If the Mac doesn't wake from suspend, see the commented-out
  # disable-nvme-d3cold service in nixos-hardware's apple/macbook-pro/14-1.

  # The NixOS release this machine was first installed with. Set it once at
  # install time (nixos-generate-config prints it), then never change it.
  system.stateVersion = "26.11";
}
