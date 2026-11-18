# home/hosts/work.nix: David's home on the Famedly work laptop
{ ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    # TODO: your Famedly email address
    settings.user.email = "TODO@famedly.com";
    # TODO: after install, create a GPG key for this machine with your work
    # email, add it to GitHub, and put its ID here. Famedly requires signed
    # commits, so committing fails until the key exists.
    #   gpg --list-secret-keys --keyid-format=long
    # signing.key = "XXXXXXXXXXXXXXXX";
  };

  # The Home Manager release this machine was first set up with. Never change it.
  home.stateVersion = "26.11";
}
