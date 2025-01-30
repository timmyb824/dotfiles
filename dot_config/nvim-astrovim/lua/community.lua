-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.dracula-nvim" },
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.completion.copilot-lua" },
  { import = "astrocommunity.completion.codeium-nvim" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
}
