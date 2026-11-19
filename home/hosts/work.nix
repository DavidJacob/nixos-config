# home/hosts/work.nix: David's home on the Famedly work laptop
{ pkgs, ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    # The work email lives in ~/.config/git/work-identity (not in this repo)
    includes = [ { path = "~/.config/git/work-identity"; } ];
    signing.key = "A7BBC8836C99A3BC";   # Famedly YubiKey
  };

  home = {
    # Let GnuPG reach the YubiKey through pcscd, so gpg and ykman can share it
    file.".gnupg/scdaemon.conf".text = ''
      disable-ccid
      pcsc-shared
    '';

    # Element (Matrix), work only. Pre-built Element plus a small wrapper that
    # adds the keyring flag (no source build)
    packages = [
      (pkgs.symlinkJoin {
        name = "element-desktop";
        paths = [ pkgs.element-desktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/element-desktop --add-flags "--password-store=gnome-libsecret"
        '';
      })
    ];

    # The Home Manager release this machine was first set up with. Never change it.
    stateVersion = "26.11";
  };
}
