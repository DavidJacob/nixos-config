# home/common.nix: David's home folder, the same on every laptop.
# What differs per machine (git email, signing key) is in home/hosts/<name>.nix.
{ config, lib, pkgs, osConfig, ... }:

let
  # Writable links into the repo: edits apply as soon as you save, no rebuild.
  # Use for configs you change often.
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/${path}";
in
{
  imports = [ ./zsh.nix ./noctalia.nix ./cheatsheet.nix ./neovim.nix ];

  # Where this repo is checked out. Used for the writable links (Hyprland,
  # Neovim) and the rebuild aliases.
  options.my.repo = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nixos-config";
    description = "Path of the nixos-config checkout.";
  };

  config = {
    # ---------- Packages ----------
    home.packages = with pkgs; [
      google-chrome
      pomo            # Pomodoro timer in the terminal (github.com/Bahaaio/pomo)
    ];

    # ---------- Git, with commits signed by your GPG key ----------
    # Email and key are set per machine in home/hosts/<name>.nix
    programs.git = {
      enable = true;
      settings = {
        user.name = "David";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
      signing = {
        format = "openpgp";
        signByDefault = true;                 # signs commits and tags
      };
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "https";
    };

    # ---------- Cursor theme ----------
    home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;    # a popular, clean cursor theme
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;                # GTK apps use it too
    };

    # ---------- Hyprland, hypridle, hyprlock ----------
    # ~/.config/hypr becomes a link to the hypr folder in this repo.
    # hyprland.lua loads the screen settings for this machine from hypr/hosts/.
    xdg.configFile."hypr".source = link "hypr";

    # Hyprland's Lua API definitions (hl.*), so Neovim's Lua language server
    # knows them. hypr/.luarc.json points at this folder.
    xdg.dataFile."hyprland-stubs".source = "${osConfig.programs.hyprland.package}/share/hypr/stubs";

    # ---------- USB disk automounter ----------
    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
  };
}
