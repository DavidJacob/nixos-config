# modules/zsh.nix: shell setup for all machines
{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # Suggests the rest of a command from your history in grey; press → to accept
    autosuggestions.enable = true;
    # Colours commands as you type: red means "command not found"
    syntaxHighlighting.enable = true;

    histSize = 50000;
    setOptions = [
      "SHARE_HISTORY"          # history is shared live between open terminals
      "HIST_IGNORE_ALL_DUPS"   # no duplicate entries in history
      "HIST_IGNORE_SPACE"      # commands starting with a space aren't saved
      "HIST_FCNTL_LOCK"        # safe history writes with several shells open
      "AUTO_CD"                # type a folder name to cd into it
      "INTERACTIVE_COMMENTS"   # allow # comments on the command line
    ];

    shellAliases = {
      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      update  = "nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos";
      clean   = "sudo nix-collect-garbage --delete-older-than 14d";

      # Everyday
      ls = "eza --group-directories-first --icons";
      ll = "eza -l --group-directories-first --icons --git";
      la = "eza -la --group-directories-first --icons --git";
      tree = "eza --tree --icons";
      v  = "nvim";
      lg = "lazygit";
      gs = "git status";
    };

    # mkOrder 2000: runs after the plugins above, as history-substring-search
    # must be loaded after syntax highlighting
    interactiveShellInit = lib.mkOrder 2000 ''
      # Emacs-style line editing (Ctrl+A start, Ctrl+E end, Ctrl+W delete word)
      bindkey -e

      # Up/Down search history for what you've already typed
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^[OA' history-substring-search-up
      bindkey '^[OB' history-substring-search-down

      # Ctrl+←/→ jump by word
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      # Completion: case-insensitive, with an arrow-key menu and coloured entries
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    '';
  };

  # Prompt: shows folder, git branch and status, and the language versions in use
  programs.starship.enable = true;

  # Ctrl+R fuzzy history search, Ctrl+T insert a file path, Alt+C jump to a folder
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # `z proj` jumps to the most-used folder matching "proj"
  programs.zoxide.enable = true;

  # Loads a project's dev shell automatically when you cd into it (needs a .envrc)
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    eza   # nicer ls
    bat   # cat with syntax highlighting
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
