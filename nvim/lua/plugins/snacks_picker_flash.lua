return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      actions = {
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  local source = picker.opts.source ~= "explorer" and picker.opts.source or nil
                  local snacks_explorer = require("snacks").picker.get({ source = "explorer" })[1]
                  local snacks_picker = source and require("snacks").picker.get({ source = source })[1]
                  local picker_win = snacks_picker and snacks_picker.layout.wins["list"].win
                  if snacks_explorer and snacks_picker then
                    return win ~= picker_win
                  end
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
    },
  },
}
