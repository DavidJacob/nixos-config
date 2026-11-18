# home/hosts/work.nix: David's home on the Famedly work laptop
{ ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    # The work email lives in ~/.config/git/work-identity (not in this repo)
    # Once the machine is setup run the following command to add it:
    # git config --file ~/.config/git/work-identity user.email "you@famedly.com"
    includes = [ { path = "~/.config/git/work-identity"; } ];
    # TODO: after install, create a GPG key for this machine with your work
    # email, add it to GitHub, and put its ID here. Famedly requires signed
    # commits, so committing fails until the key exists.
    #   gpg --list-secret-keys --keyid-format=long
    # signing.key = "XXXXXXXXXXXXXXXX";
  };

  # The Home Manager release this machine was first set up with. Never change it.
  home.stateVersion = "26.11";
}
