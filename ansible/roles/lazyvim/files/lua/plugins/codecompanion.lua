return {
  "olimorris/codecompanion.nvim",
  opts = {
    adapters = {
      -- Preserve the older DeepSeek-over-Ollama profile as an optional adapter.
      llama3 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "deepseek-r1",
          schema = {
            model = {
              default = "deepseek-r1:8b",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        })
      end,
    },
    -- Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    strategies = {
      -- Change the adapter as required.
      chat = { adapter = "ollama" },
      inline = { adapter = "ollama" },
    },
    opts = {
      log_level = "DEBUG",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
