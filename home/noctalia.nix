# home/noctalia.nix: Noctalia desktop shell
# Provides the bar, app launcher, notifications, volume/brightness popups,
# wallpaper and colour themes. Started from hyprland.lua.
{ pkgs, ... }:

let
  # Official NixOS wallpapers from nixpkgs, gathered into one folder.
  # Add or remove names from the list; see pkgs.nixos-artwork.wallpapers for all.
  wallpapers = pkgs.symlinkJoin {
    name = "nixos-wallpapers";
    paths = with pkgs.nixos-artwork.wallpapers; [
      catppuccin-mocha
      catppuccin-macchiato
      nineish-dark-gray
      nineish-catppuccin-mocha
      binary-black
      moonscape
      waterfall
      simple-dark-gray
    ];
  };
in
{
  programs.noctalia = {
    enable = true;

    # Defaults, written to ~/.config/noctalia/config.toml.
    # Changes made in Noctalia's settings window are stored separately and
    # override these, so you can experiment there and copy keepers in here.
    settings = {
      bar.main = {
        position = "top";

        # Left side of the bar: Noctalia's defaults plus "now playing" (media)
        # right after the workspaces. It used to be on the right, but there it
        # got squashed against the clock on the laptop screen.
        start = [ "launcher" "wallpaper" "workspaces" "media" ];

        # Right side of the bar: Noctalia's defaults (minus media, now on the
        # left) plus caffeine (keep awake)
        end = [
          "tray" "notifications" "clipboard" "network" "bluetooth"
          "caffeine" "volume" "brightness" "battery" "control-center" "session"
        ];

        # Laptop screen only: use its full width and the shorter clock
        monitor.laptop = {
          match = "eDP-1";
          margin_ends = 20;
          center = [ "clock-short" ];
        };
      };

      # Wallpapers to choose from in Noctalia's wallpaper picker
      wallpaper.directory = "${wallpapers}/share/backgrounds/nixos";

      # hyprlock and hypridle handle locking. With Noctalia's lock screen on as
      # well, both would react to the same lock signal and fight over the screen.
      lockscreen.enabled = false;

      # Enable DDC/DI for controlling external monitors
      brightness.enable_ddcutil = true;

      # Clock in the middle of the bar: "Tue, November 17 | 15:41"
      widget.clock = {
        format = "{:%a, %B %-d | %H:%M}";
        tooltip_format = "{:%A, %-d %B %Y, week %V}";   # on hover: "Tuesday, 17 November 2026, week 47"
      };

      # Hide the media widget when nothing is playing (no more "Nothing playing")
      widget.media.hide_when_no_media = true;

      # A shorter clock for the laptop screen: "Tue 17 Nov | 15:41"
      widget.clock-short = {
        type = "clock";
        format = "{:%a %-d %b | %H:%M}";
        tooltip_format = "{:%A, %-d %B %Y, week %V}";
      };
    };
  };
}
