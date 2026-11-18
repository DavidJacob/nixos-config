# home/zsh.nix: David's shell, managed by Home Manager
{ config, ... }:

let
  repo = config.my.repo;   # ~/nixos-config, set in home/common.nix
in
{
  programs.zsh = {
    enable = true;

    # Suggests the rest of a command from your history in grey; press → to accept
    autosuggestion.enable = true;
    # Colours commands as you type: red means "command not found"
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      share = true;          # history is shared live between open terminals
      ignoreAllDups = true;  # no duplicate entries in history
      ignoreSpace = true;    # commands starting with a space aren't saved
    };

    # Up/Down search history for what you've already typed
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[A" "^[OA" ];
      searchDownKey = [ "^[[B" "^[OB" ];
    };

    setOptions = [
      "AUTO_CD"                # type a folder name to cd into it
      "INTERACTIVE_COMMENTS"   # allow # comments on the command line
    ];

    shellAliases = {
      # NixOS: builds the configuration named after this machine's hostname.
      # --sudo builds as you and only switches as root, so git doesn't
      # complain about the repo's owner.
      rebuild = "nixos-rebuild switch --flake ${repo} --sudo";
      update  = "nix flake update --flake ${repo} && nixos-rebuild switch --flake ${repo} --sudo";
      clean   = "sudo nix-collect-garbage --delete-older-than 14d";

      # Everyday (ls, ll and lt come from programs.eza below)
      la   = "eza -la";
      tree = "eza --tree";
      v  = "nvim";
      lg = "lazygit";
      gs = "git status";
    };

    initContent = ''
      # Emacs-style line editing (Ctrl+A start, Ctrl+E end, Ctrl+W delete word)
      bindkey -e

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
  programs.fzf.enable = true;

  # `z proj` jumps to the most-used folder matching "proj"
  programs.zoxide.enable = true;

  # Loads a project's dev shell automatically when you cd into it (needs a .envrc)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Nicer ls: also sets up the ls, ll, lt and lla aliases
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  # cat with syntax highlighting (run it as `bat`)
  programs.bat.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
