-- ---if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- -- Customize Mason plugins

-- ---@type LazySpec
-- return {
--   -- use mason-lspconfig to configure LSP installations
--   {
--     "williamboman/mason-lspconfig.nvim",
--     -- overrides `require("mason-lspconfig").setup(...)`
--     opts = {
--       ensure_installed = {
--         "lua_ls",
--         -- add more arguments for adding more language servers
--       },
--     },
--   },
--   -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
--   {
--     "jay-babu/mason-null-ls.nvim",
--     -- overrides `require("mason-null-ls").setup(...)`
--     opts = {
--       ensure_installed = {
--         "stylua",
--         -- add more arguments for adding more null-ls sources
--       },
--       automatic_installation = true,
--     },
--   },
--   {
--     "jay-babu/mason-nvim-dap.nvim",
--     -- overrides `require("mason-nvim-dap").setup(...)`
--     opts = {
--       ensure_installed = {
--         "python",
--         -- add more arguments for adding more debuggers
--       },
--     },
--   },
-- }

-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        "bashls",
        "dockerls",
        "gopls",
        "helm_ls",
        "jedi_language_server",
        "jinja_lsp",
        "jsonls",
        "lua_ls",
        "marksman",
        "pyright",
        "pylyzer",
        "pylsp",
        "ts_ls",
        -- "ruby_lsp", -- TODO: Install error; install manually
        "ruff",
        -- "ruff_lsp", -- TODO: Install error; install manually
        "rust_analyzer",
        "sourcery",
        "terraformls",
        "typos_lsp",
        "yamlls",
      },
    },
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      ensure_installed = {
        "ansible-lint",
        "beautysh",
        "black",
        "codespell",
        "cspell",
        "dotenv-linter",
        "eslint_d",
        "gitlint",
        "gitleaks",
        "goimports",
        "gofumpt",
        "isort",
        "jsonlint",
        "kube-linter",
        "markdownlint",
        "misspell",
        "prettier",
        "pylint",
        "rubyfmt",
        "ruff",
        "shellcheck",
        "shfmt",
        "sql-formatter",
        "stylua",
        "trufflehog",
        "typos",
        "yamllint",
        "yamlfmt",
      },
      automatic_installation = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      ensure_installed = {
        "python",
        "delve",
        "node2",
        "codelldb",
      },
    },
  },
}
