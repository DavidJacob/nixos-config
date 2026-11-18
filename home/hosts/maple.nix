# home/hosts/maple.nix: David's home on maple (personal)
{ ... }:

{
  imports = [ ../common.nix ];

  programs.git = {
    settings.user.email = "davidmjacob86@gmail.com";
    signing.key = "7AF135FF74247E22";   # maple's own GPG key
  };

  # The Home Manager release this machine was first set up with. Never change it.
  home.stateVersion = "26.05";
}
