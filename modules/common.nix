# modules/common.nix: everything the three laptops share.
# Machine-specific settings (disks, graphics, hardware quirks) live in hosts/<name>/.
{ config, pkgs, ... }:

{
  # ---------- Boot, encryption, hibernation ----------
  # Every laptop: LUKS-encrypted disk with LVM inside (root + swap), one
  # password at boot. The layout itself is in modules/disk-layout.nix (disko).
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;   # keep the 1 GB boot partition from filling up
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;   # newest kernel: best for recent laptops

  # Closing the lid suspends; after 1 hour asleep the laptop hibernates
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  # ---------- Networking ----------
  # The hostname comes from flake.nix (the configuration's name)
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
  # Swap Esc and Caps Lock
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "us";
    options = "caps:swapescape";
  };

  # ---------- Nix itself ----------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---------- Caldigit Dock ----------
  # Shared so any of the laptops can use the desk setup
  services.hardware.bolt.enable = true;   # approves Thunderbolt devices

  # Never prefer the CalDigit dock's audio: built-in speakers and mic stay default.
  # The dock's devices are still listed if you pick them by hand.
  services.pipewire.wireplumber.extraConfig."51-caldigit-audio" = {
    "monitor.alsa.rules" = [{
      matches = [
        { "node.name" = "~alsa_output.usb-CalDigit.*"; }
        { "node.name" = "~alsa_input.usb-CalDigit.*"; }
      ];
      actions.update-props = {
        "priority.session" = 100;
        "priority.driver" = 100;
      };
    }];
  };

  # ---------- User ----------
  # zsh is configured in home/zsh.nix (Home Manager). These lines only
  # register it as a login shell and make it the default.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;   # Home Manager's .zshrc already runs compinit
  };
  users.defaultUserShell = pkgs.zsh;
  environment.pathsToLink = [
    "/share/zsh"                # completions for system packages
    "/share/wayland-sessions"   # lets the login screen find the Hyprland session
  ];
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "wheel" "networkmanager" "video" "i2c" ];
  };

  # ---------- Graphics ----------
  # Drivers for the specific GPU are added per host
  hardware.graphics.enable = true;

  # ---------- Laptop power ----------
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;                         # firmware updates: fwupdmgr update

  # ---------- Login ----------
  # Noctalia's graphical login screen (runs on greetd). Pick "Hyprland" as the
  # session the first time; it remembers your choice.
  services.displayManager.noctalia-greeter = {
    enable = true;
    # Lets Noctalia copy your wallpaper, colours and monitor layout to the
    # login screen (Noctalia settings → Sync) without asking for a password.
    passwordlessSyncUsers = [ "david" ];
  };

  # ---------- Sound and Bluetooth ----------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ---------- USB ----------
  services.udisks2.enable = true;   # lets your user mount USB drives without sudo

  # ---------- File manager: Thunar ----------
  # These are system (NixOS) options, not Home Manager ones: Thunar's helpers
  # (gvfs, tumbler, xfconf) run as D-Bus services that the system has to set up.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin   # right-click → extract / compress
      thunar-volman           # handles USB drives and phones
    ];
  };
  services.gvfs.enable = true;      # trash, and access to phones and network shares
  services.tumbler.enable = true;   # image and video thumbnails
  programs.xfconf.enable = true;    # lets Thunar save its settings

  # ---------- External Monitors ----------
  hardware.i2c.enable = true;   # DDC/DI: control brightness of external monitors

  # ---------- Desktop: Hyprland ----------
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];   # file open/save dialogs
  environment.sessionVariables.NIXOS_OZONE_WL = "1";   # Electron apps run natively on Wayland

  # ---------- GPG ----------
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    settings = {
      default-cache-ttl = 28800;   # forget after 8 hour without signing
      max-cache-ttl = 28800;   # always ask after 8 hours
    };
  };

  # ---------- Keyring ----------
  # Keyring for apps that store passwords and keys (Element, Chrome, etc.)
  services.gnome.gnome-keyring.enable = true;
  # Unlock it automatically with your login password
  security.pam.services.greetd.enableGnomeKeyring = true;

  # ---------- Apps ----------
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;   # lets LazyVim's Mason-downloaded tools run

  environment.systemPackages = with pkgs; [
    # Terminal, rescue editor, basics (Neovim's tools live in home/neovim.nix)
    ghostty
    neovim
    git unzip wget curl

    # Hyprland desktop pieces
    hypridle               # idle -> lock -> suspend
    hyprpolkitagent        # password prompts for admin actions
    grim slurp wl-clipboard  # screenshots and clipboard
    brightnessctl          # screen brightness keys
    pavucontrol            # sound settings
    ddcutil                # control external monitors
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
}
