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
      bar.main.position = "top";

      # Wallpapers to choose from in Noctalia's wallpaper picker
      wallpaper.directory = "${wallpapers}/share/backgrounds/nixos";

      # hyprlock and hypridle handle locking. With Noctalia's lock screen on as
      # well, both would react to the same lock signal and fight over the screen.
      lockscreen.enabled = false;
    };
  };
}
