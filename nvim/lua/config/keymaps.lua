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

-- Emoji picker: type to search by name, Enter copies the emoji to the system
-- clipboard (paste anywhere with Ctrl+V, or `p` in Neovim).
-- Uses snacks.nvim's icons picker limited to emoji; the emoji list is
-- downloaded once and cached. (<leader>si is LazyVim's picker for all icons,
-- which inserts the icon into the buffer instead.)
vim.keymap.set("n", "<leader>se", function()
  Snacks.picker.icons({
    icon_sources = { "emoji" },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.fn.setreg("+", item.icon)
        Snacks.notify("Copied " .. item.icon .. " " .. item.name, { title = "Emoji" })
      end
    end,
  })
end, { desc = "Emoji (copy)" })
