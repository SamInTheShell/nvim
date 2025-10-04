return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- optionally enable 24-bit colour
    vim.opt.termguicolors = true

    -- empty setup using defaults
    require("nvim-tree").setup()

    -- OR setup with some options
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 60,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })

    -- Auto-open NvimTree only when no file is provided
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Only open tree if no arguments were passed (no files specified)
        if vim.fn.argc() == 0 then
          require("nvim-tree.api").tree.open()
          vim.cmd("wincmd l")  -- Focus right window (editor)
        end
      end,
    })

    vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")

    -- Auto-close Neovim when only NvimTree is left
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
          vim.cmd "quit"
        end
      end
    })
  end,
}

