# home/cheatsheet.nix: shortcut cheatsheet, toggled with Super+/
# Lists every Hyprland bind that has a description of the form
# "Category: what it does" (see the KEYBINDINGS section of hyprland.lua),
# so it stays in sync with your config automatically.
{ pkgs, ... }:

let
  # Shows the table in a pager: arrows/j/k scroll, q closes the window
  view = pkgs.writeShellApplication {
    name = "hypr-cheatsheet-view";
    runtimeInputs = [ pkgs.jq pkgs.less ];
    text = ''
      {
        printf '\n  \e[1mKeyboard shortcuts\e[0m\n'
        hyprctl binds -j | jq -r -f ${./cheatsheet.jq}
        printf '\n'
      } | less -R --prompt="  q to close, arrows to scroll"
    '';
  };

  # Super+/: opens the cheatsheet window, or closes it if it's already open
  toggle = pkgs.writeShellApplication {
    name = "hypr-cheatsheet-toggle";
    runtimeInputs = [ pkgs.procps pkgs.util-linux ];
    text = ''
      if pkill -f hypr-cheatsheet-view; then
        exit 0
      fi
      # Its own ghostty process, so the window gets its own class for the window rule
      setsid -f ghostty --class=nixos.cheatsheet --gtk-single-instance=false \
        --title=Shortcuts -e ${view}/bin/hypr-cheatsheet-view >/dev/null 2>&1
    '';
  };
in
{
  home.packages = [ view toggle ];
}
