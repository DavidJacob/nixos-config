# hosts/work: ThinkPad T14 Gen 7. Famedly work laptop.
{ inputs, lib, ... }:

{
  imports = [
    ../../modules/disk-layout.nix

    # Famedly's required settings: ClamAV, Fleet device management (orbit),
    # signed git commits, and Lix as the Nix implementation.
    inputs.famedly-nixos.nixosModules.default

    # nixos-hardware has no T14 Gen 7 profile yet, so use the general ThinkPad
    # and laptop ones. Check for a specific profile later:
    #   https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/t14
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad   # TrackPoint, laptop defaults

    # AMD Ryzen PRO 250 with Radeon 780M graphics
    inputs.nixos-hardware.nixosModules.common-cpu-amd         # Microcode
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate  # modern CPU power management
    inputs.nixos-hardware.nixosModules.common-gpu-amd         # Radeon drivers, early display at boot
  ]
  # Created during installation (see INSTALL.md). Until then the config still
  # evaluates, so it can be checked from another machine.
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # nixos-unstable now ships its own orbit (Fleet agent) module, which clashes
  # with the one Famedly uses from fleet-nixos ("services.orbit.enable is
  # already declared"). Switch off the nixpkgs one so Famedly's settings apply.
  # Remove this line once famedly-nixos handles it upstream.
  disabledModules = [ "services/monitoring/orbit.nix" ];

  # ---------- Disk ----------
  # Equal to system RAM
  my.disk.swapSize = "32G";

  # ---------- Famedly ----------
  # Fleet enrollment: orbit reads its secret from an encrypted systemd
  # credential when it starts, so the system installs and boots without it.
  # Add it after install (the key is on Famedly's Notion hardware page):
  #   echo '<enroll-key>' | sudo systemd-creds encrypt - /etc/credstore.encrypted/fleet-enroll-key
  #   sudo systemctl restart orbit
  # Nothing secret goes into this repo.

  # Optional: Famedly's binary cache. Needs a Cachix token in /etc/nix/netrc
  # (see github.com/famedly/famedly-nixos#cachix) before switching it on.
  # famedly-cachix.enable = true;
  # nix.extraOptions = ''
  #   netrc-file = /etc/nix/netrc
  # '';

  # The NixOS release this machine was first installed with. Set it once at
  # install time (nixos-generate-config prints it), then never change it.
  system.stateVersion = "26.11";
}
