-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jk", "<Esc>")

-- Focus on the snacks explorer for the currently active buffer
vim.keymap.set("n", "<leader>o", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer and not explorer:is_focused() then
    -- it's open somewhere else — jump to it instead of toggling closed
    explorer:focus()
  else
    Snacks.explorer.open()
  end
end, { desc = "Focus explorer" })
