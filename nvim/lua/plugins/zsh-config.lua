return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fz",
      function()
        Snacks.picker.files({
          cwd = "/etc/nixos",
          hidden = true,
        })
      end,
      desc = "Find NixOS config file",
    },
    {
      "<leader>sz",
      function()
        Snacks.picker.grep({
          cwd = "/etc/nixos",
          hidden = true,
        })
      end,
      desc = "Search NixOS config",
    },
  },
}
