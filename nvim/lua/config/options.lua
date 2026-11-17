-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Explicitly set the spellfile to enable `plugins/spell-picker.lua` to work more easily.
-- This is the default value but without the explicit setting is it derived and does not set `vim.opt.spellfile`
vim.opt.spellfile = vim.fn.stdpath("data") .. "/site/spell/en.utf-8.add"
