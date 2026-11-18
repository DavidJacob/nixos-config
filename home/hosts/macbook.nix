# home/hosts/macbook.nix: David's home on the MacBook (personal)
{ ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    settings.user.email = "davidmjacob86@gmail.com";
    # TODO: after install, create this machine's own GPG key (same steps as on
    # maple), add it to GitHub, and put its ID here:
    #   gpg --list-secret-keys --keyid-format=long
    # signing.key = "XXXXXXXXXXXXXXXX";
  };

  # The Home Manager release this machine was first set up with. Never change it.
  home.stateVersion = "26.11";
}
