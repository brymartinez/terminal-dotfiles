return {
  {
    "loctvl842/monokai-pro.nvim",
    opts = {
      transparent_background = false,
      terminal_colors = true,
      devicons = true,
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
        type = { italic = true },
        storageclass = { italic = true },
        structure = { italic = true },
        parameter = { italic = true },
        annotation = { italic = true },
        tag_attribute = { italic = true },
      },
      filter = "pro",
      override = function(c)
        return {
          Normal = { bg = "#0a0a0a" },
          SignColumn = { bg = "#0a0a0a" },
          NormalFloat = { bg = "#121212" },
          NeoTreeNormal = { bg = "#0a0a0a" },
          NeoTreeNormalNC = { bg = "#0a0a0a" },
          StatusLine = { bg = "#0a0a0a" },
          LineNr = { bg = "#0a0a0a", fg = "#4a4a4a" },
          CursorLineNr = { bg = "#0a0a0a" },
        }
      end,
    },
    config = function(_, opts)
      require("monokai-pro").setup(opts)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-pro",
    },
  },
}
