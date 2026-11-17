return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,
    },
  },
  keys = {
    { "<leader>b>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
    { "<leader>b<", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
  },
}
