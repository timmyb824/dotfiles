return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      --auto_restore_enabled = true,
      --auto_save_enabled = false,
      --auto_session_enable_last_session = false,
      --auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
      --auto_session_enabled = true,
      --auto_save_interval = 30000,
      --auto_restore_last_session = true,
      --auto_session_suppress_dirs = { "desktop", "downloads", "public", "templates", "videos", "pictures", "music" },
      session_lens = {
        buftypes_to_ignore = {}, -- list of buffer types what should not be deleted from current session
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
      vim.keymap.set("n", "<leader>ls", require("auto-session.session-lens").search_session, {
        noremap = true,
      }),
    })
  end,
}
