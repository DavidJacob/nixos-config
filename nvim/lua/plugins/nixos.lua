-- NixOS: language servers provided by Nix (see home/neovim.nix) instead of Mason.
-- Mason's prebuilt binaries for these need system libraries NixOS doesn't have.
-- Everything else is still installed by Mason as usual.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      lua_ls = { mason = false },
      marksman = { mason = false },
      nil_ls = { mason = false },
    },
  },
}
