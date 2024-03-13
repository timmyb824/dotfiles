return {
    "kdheepak/lazygit.nvim",
    Lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
        "nvim-lua/plenary.nvim",
        },
    config = function()
    require("lazy").setup()
end,
}
