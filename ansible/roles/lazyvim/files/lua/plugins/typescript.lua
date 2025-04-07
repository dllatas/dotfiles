if true then
  return {}
end

--return {
--  "pmizio/typescript-tools.nvim",
--  dependencies = {
--    "nvim-lua/plenary.nvim",
--    "neovim/nvim-lspconfig",
--  },
--  opts = {},
--}

-- add typescript to treesitter
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
      end
    end,
  },

  -- correctly setup lspconfig
  {
    "pmizio/typescript-tools.nvim",
    opts = {
      settings = {
        expose_as_code_action = "all",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "literals",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = false,
          includeCompletionsForModuleExports = true,
          importModuleSpecifierEnding = "minimal",
          quotePreference = "single",
        },
        tsserver_format_preferences = {
          semicolons = "remove",
          insertSpaceBeforeFunctionParenthesis = true,
        },
        complete_function_calls = true,
      },
      keys = {
        {
          "gD",
          function()
            local params = vim.lsp.util.make_position_params()
            LazyVim.lsp.execute({
              command = "typescript.goToSourceDefinition",
              arguments = { params.textDocument.uri, params.position },
              open = true,
            })
          end,
          desc = "Goto Source Definition",
        },
        {
          "gR",
          function()
            LazyVim.lsp.execute({
              command = "typescript.findAllFileReferences",
              arguments = { vim.uri_from_bufnr(0) },
              open = true,
            })
          end,
          desc = "File References",
        },
        {
          "<leader>co",
          LazyVim.lsp.action["source.organizeImports"],
          desc = "Organize Imports",
        },
        {
          "<leader>cM",
          LazyVim.lsp.action["source.addMissingImports.ts"],
          desc = "Add missing imports",
        },
        {
          "<leader>cu",
          LazyVim.lsp.action["source.removeUnused.ts"],
          desc = "Remove unused imports",
        },
        {
          "<leader>cD",
          LazyVim.lsp.action["source.fixAll.ts"],
          desc = "Fix all diagnostics",
        },
        {
          "<leader>cV",
          function()
            LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
          end,
          desc = "Select TS workspace version",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "neovim/nvim-lspconfig",
        opts = {
          -- make sure mason installs the server
          servers = {
            tsserver = {
              enabled = false,
            },
            denols = {},
          },
        },
      },
    },
    event = "VeryLazy",
  },
}
