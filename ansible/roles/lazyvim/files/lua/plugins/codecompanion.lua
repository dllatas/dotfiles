return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
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
    strategies = {
      chat = {
        adapter = "ollama",
      },
    },
    opts = {
      log_level = "DEBUG",
    },
  },
}
