# home/hosts/work.nix: David's home on the Famedly work laptop
{ ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    # The work email lives in ~/.config/git/work-identity (not in this repo)
    # Once the machine is setup run the following command to add it:
    # git config --file ~/.config/git/work-identity user.email "you@famedly.com"
    includes = [ { path = "~/.config/git/work-identity"; } ];
    signing.key = "A7BBC8836C99A3BC";
  };

  # Let GnuPG reach the YubiKey through pcscd, so gpg and ykman can share it
  home.file.".gnupg/scdaemon.conf".text = ''
    disable-ccid
    pcsc-shared
  '';

  # The Home Manager release this machine was first set up with. Never change it.
  home.stateVersion = "26.11";
}
