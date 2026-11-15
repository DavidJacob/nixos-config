# home/david.nix: everything in David's home folder
{ config, pkgs, ... }:

let
  # Writable links into the repo: edits apply as soon as you save, no rebuild.
  # Use for configs you change often.
  repo = "/etc/nixos";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  imports = [ ./zsh.nix ./noctalia.nix ];

  # The Home Manager release this config was first written for. Never change it.
  home.stateVersion = "26.05";

  # ---------- Packages ----------
  home.packages = with pkgs; [
    google-chrome
  ];

  # ---------- Git, with commits signed by your GPG key ----------
  programs.git = {
    enable = true;
    settings = {
      user.name = "David";
      user.email = "davidmjacob86@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
    signing = {
      key = "7AF135FF74247E22";
      format = "openpgp";
      signByDefault = true;                 # signs commits and tags
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  # ---------- Hyprland, hypridle, hyprlock ----------
  # ~/.config/hypr becomes a link to the hypr folder in this repo
  xdg.configFile."hypr".source = link "hypr";
}
