return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fz",
      function()
        Snacks.picker.files({
          cwd = vim.fn.expand("~/nixos-config"),
          hidden = true,
        })
      end,
      desc = "Find NixOS config file",
    },
    {
      "<leader>sz",
      function()
        Snacks.picker.grep({
          cwd = vim.fn.expand("~/nixos-config"),
          hidden = true,
        })
      end,
      desc = "Search NixOS config",
    },
  },
}
