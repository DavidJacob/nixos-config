return {
  {
    "andythigpen/nvim-coverage",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("coverage").setup({
        auto_reload = true,
        lang = {
          go = {
            coverage_file = vim.fn.getcwd() .. "/coverage.out",
          },
        },
      })
    end,
    keys = {
      {
        "<leader>tc",
        "<cmd>Coverage<cr>",
        desc = "Coverage: load & show",
      },
      {
        "<leader>tx",
        "<cmd>CoverageToggle<cr>",
        desc = "Coverage: toggle signs",
      },
      {
        "<leader>tC",
        "<cmd>CoverageSummary<cr>",
        desc = "Coverage: summary",
      },
    },
  },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = {
            "-v",
            "-race",
            "-count=1",
            "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
          },
        },
      },
    },
  },
}
