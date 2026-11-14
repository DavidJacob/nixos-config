# home/david.nix: everything in David's home folder
{ config, ... }:

let
  # Writable links into the repo: edits apply as soon as you save, no rebuild.
  # Use for configs you change often.
  repo = "/etc/nixos";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  # The Home Manager release this config was first written for. Never change it.
  home.stateVersion = "26.05";

  # ---------- Git, with commits signed by your GPG key ----------
  programs.git = {
    enable = true;
    settings = {
      user.name = "David";
      user.email = "davidmjacob86@gmail.com";       # replace: the email verified on GitHub
      init.defaultBranch = "main";
      pull.rebase = true;
    };
    signing = {
      key = "7AF135FF74247E22";                    # replace: the ID from gpg --list-secret-keys --keyid-format=long
      format = "openpgp";
      signByDefault = true;                 # signs commits and tags
    };
  };

  # ---------- Hyprland, hypridle, hyprlock ----------
  # ~/.config/hypr becomes a link to the hypr folder in this repo
  xdg.configFile."hypr".source = link "hypr";
}
