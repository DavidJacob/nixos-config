{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ---------- Boot, encryption, hibernation ----------
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;   # keep the 1 GB boot partition from filling up
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;   # newest kernel: best for recent Intel laptops

  # Unlock the encrypted partition at boot. Root and swap are LVM volumes
  # inside it, so one password unlocks both. nixos-generate-config does not
  # detect LUKS under LVM, which is why this line is needed here.
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/cryptroot";
    allowDiscards = true;   # lets SSD TRIM pass through the encryption
  };

  # Resume from the encrypted swap volume after hibernation
  boot.resumeDevice = "/dev/disk/by-label/swap";

  # Closing the lid suspends; after 1 hour asleep the laptop hibernates
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  # ---------- Networking ----------
  networking.hostName = "maple";
  networking.networkmanager.enable = true;

  # ---------- Locale: English language, UK formats, US keyboard ----------
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "us";

  # ---------- Nix itself ----------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---------- User ----------
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # ---------- Intel Iris Xe graphics ----------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];   # hardware video decoding
  };

  # ---------- Laptop power ----------
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;                         # firmware updates: fwupdmgr update

  # ---------- Sound and Bluetooth ----------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ---------- Desktop: Hyprland ----------
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];   # file open/save dialogs
  environment.sessionVariables.NIXOS_OZONE_WL = "1";   # Electron apps run natively on Wayland

  # ---------- Apps ----------
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;   # lets LazyVim's Mason-downloaded tools run

  environment.systemPackages = with pkgs; [
    # Terminal and editor
    ghostty
    neovim
    git gh gcc gnumake unzip wget curl ripgrep fd lazygit tree-sitter

    # Hyprland desktop pieces
    waybar                 # status bar
    wofi                   # app launcher
    mako                   # notifications
    hypridle               # idle -> lock -> suspend
    hyprpolkitagent        # password prompts for admin actions
    networkmanagerapplet   # Wi-Fi tray icon
    grim slurp wl-clipboard  # screenshots and clipboard
    brightnessctl          # screen brightness keys
    pavucontrol            # sound settings
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Set this to the value nixos-generate-config wrote in its own
  # configuration.nix, then never change it.
  system.stateVersion = "26.05";
}
