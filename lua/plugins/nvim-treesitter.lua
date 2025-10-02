return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "javascript", "go", "typescript", "python" },
      highlight = { enable = true },
      indent = { 
        enable = true,
        -- Disable Treesitter indentation for Go because it interferes with 
        -- Vim's built-in comment block indentation (/* */) behavior
        disable = { "go" }
      },
    })
  end,
}

