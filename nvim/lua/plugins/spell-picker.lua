return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fw",
      function()
        -- We explictly set `vim.o.spellfile` in `config/options.lua`
        local path = vim.o.spellfile
        if path == "" or path == nil then
          vim.notify("No spellfile set", vim.log.levels.WARN)
          return
        end
        -- spellfile can be a comma-separated list; take the first
        path = vim.split(path, ",")[1]

        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok then
          vim.notify("Could not read spellfile: " .. path, vim.log.levels.ERROR)
          return
        end

        local items = {}
        for i, word in ipairs(lines) do
          if word ~= "" then
            table.insert(items, { idx = i, text = word, word = word })
          end
        end

        Snacks.picker({
          title = "Dictionary",
          items = items,
          layout = { preset = "select" },
          format = function(item)
            return { { item.text } }
          end,
          confirm = function(picker, item)
            picker:close()
            if item then
              vim.fn.setreg('"', item.word)
              vim.notify("Yanked: " .. item.word)
            end
          end,
        })
      end,
      desc = "Find word in dictionary",
    },
  },
}
