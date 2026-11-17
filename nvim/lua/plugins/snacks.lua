return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        projects = {

          -- Hardcoded projects which will always appear in the project list
          -- (/etc/nixos holds your NixOS, zsh, Hyprland and Neovim config)
          projects = { "/etc/nixos" },

          -- Scan only the ~/code directory for project root patterns
          dev = { "~/code" },

          -- Add `go.mod` to the list of project root patterns
          -- TODO: this seems to be adding `go.mod` twice in patterns, figure out why
          -- config = function(opts)
          --   vim.list_extend(opts.patterns, { "go.mod" })
          -- end,

          -- On selecting a project, restore the session and open Snacks Explorer
          confirm = function(picker, item)
            picker:close()
            if not item then
              return
            end
            vim.schedule(function()
              pcall(function()
                require("persistence").save()
              end)
              vim.cmd("silent! %bwipeout!")
              Snacks.picker.actions.load_session(picker, item)
              vim.schedule(function()
                Snacks.explorer.open()
              end)
            end)
          end,
        },
      },
    },
  },
}
