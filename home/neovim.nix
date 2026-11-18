# home/neovim.nix: Neovim for LazyVim
#
# The LazyVim config itself stays in Lua, in the nvim/ folder of this repo.
# ~/.config/nvim is a writable link to it, so lazy.nvim can update
# lazy-lock.json and LazyVim can save extras, and those changes land in git.
#
# This file provides what LazyVim and Mason need from the system. Tools in
# extraPackages are visible only to Neovim, not to your normal shell.
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # Your LazyVim config is the whole of ~/.config/nvim, so Home Manager must
    # not write its own init.lua there.
    sideloadInitLua = true;

    # LazyVim doesn't use Neovim's Ruby, Python or Node plugin hosts
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;

    extraPackages = with pkgs; [
      # --- What lazy.nvim, Treesitter and Mason need to work ---
      # Treesitter compiles its syntax parsers
      gcc gnumake tree-sitter
      git curl unzip gnutar gzip     # lazy.nvim and Mason download and unpack with these
      nodejs                         # Mason installs the TypeScript, Svelte, Tailwind,
                                     # Bash, Prettier and Markdown tools through npm
      go                             # Mason installs gopls, goimports, gofumpt, delve etc.
                                     # with `go install`; also needed to run Go code
      wl-clipboard                   # "+ register: copy and paste to the system clipboard

      # --- Language servers that work better from Nix than from Mason ---
      # (nvim/lua/plugins/nixos.lua tells LazyVim not to install these with Mason)
      lua-language-server            # Mason's build needs extra system libraries
      marksman                       # Mason's build needs .NET's ICU libraries
      nil nixfmt statix              # Nix: language server, formatter, linter

      # --- Plugins' helpers ---
      imagemagick ghostscript        # snacks.image: show images and PDFs in the editor
      trash-cli                      # explorer: deleted files go to trash
      file                           # codecompanion: detects file types
    ];
  };

  # The LazyVim config lives in the repo; ~/.config/nvim links to it (writable)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/nvim";

  # Used from the shell as well as inside Neovim
  home.packages = with pkgs; [
    ripgrep fd lazygit   # search and git tools, used by LazyVim's pickers and <leader>gg
    claude-code          # `claude`, used by your codecompanion plugin
    claude-agent-acp     # lets codecompanion talk to Claude Code
  ];
}
