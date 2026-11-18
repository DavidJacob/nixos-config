# modules/disk-layout.nix: the standard laptop disk, described for disko.
# Used by macbook and work. maple was partitioned by hand before this existed,
# so it keeps its own settings in hosts/maple/default.nix.
#
#   /dev/nvme0n1 (my.disk.device)
#   ├─ ESP        1 GiB   FAT32, /boot
#   └─ cryptroot  rest    LUKS2 (one password at boot)
#        └─ LVM volume group "vg"
#             ├─ swap   my.disk.swapSize   used for hibernation (at least the RAM size)
#             └─ root   rest               ext4, /
#
# disko both partitions the disk at install time (see INSTALL.md) and writes the
# matching fileSystems, swapDevices, LUKS and resume settings into the system,
# so hardware-configuration.nix is generated with --no-filesystems.
{ config, lib, inputs, ... }:

let
  cfg = config.my.disk;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.my.disk = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "The whole disk to install on. Check with lsblk before installing.";
    };
    swapSize = lib.mkOption {
      type = lib.types.str;
      example = "16G";
      description = "Size of the swap volume. Hibernation needs at least the amount of RAM.";
    };
  };

  config.disko.devices = {
    disk.main = {
      type = "disk";
      device = cfg.device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          cryptroot = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # No password file: disko asks for the disk password while formatting
              settings.allowDiscards = true;   # SSD TRIM through the encryption
              content = {
                type = "lvm_pv";
                vg = "vg";
              };
            };
          };
        };
      };
    };

    lvm_vg.vg = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = cfg.swapSize;
          content = {
            type = "swap";
            resumeDevice = true;   # sets boot.resumeDevice for hibernation
          };
        };
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
