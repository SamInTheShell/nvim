return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "goolord/alpha-nvim",
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
      filesystem_watchers = {
        enable = true,
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

    -- Re-open Alpha when only NvimTree is left instead of closing
    -- Add a flag to prevent recursive trap during quit sequence
    local quitting = false
    local saved_tree_width = 60 -- Default width, will be updated when user resizes
    
    -- Track nvim-tree width when there are multiple windows
    vim.api.nvim_create_autocmd("WinResized", {
      callback = function()
        if #vim.api.nvim_list_wins() > 1 then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if require("nvim-tree.utils").is_nvim_tree_buf(vim.api.nvim_win_get_buf(win)) then
              saved_tree_width = vim.api.nvim_win_get_width(win)
              break
            end
          end
        end
      end
    })

    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if quitting then return end
        -- Save tree width when we have multiple windows
        if #vim.api.nvim_list_wins() > 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
          saved_tree_width = vim.api.nvim_win_get_width(vim.api.nvim_get_current_win())
        end
        
        -- Only trigger if we have exactly 1 window and it's nvim-tree
        if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
          -- Defer the split to avoid the closing window error
          vim.schedule(function()
            if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
              local tree_win = vim.api.nvim_get_current_win()
              vim.cmd("vsplit")
              vim.cmd("enew")
              require("alpha").start(true)
              -- Restore nvim-tree width to saved width
              vim.api.nvim_win_set_width(tree_win, saved_tree_width)
            end
          end)
        end
      end
    })
    
    -- Override alpha quit to close nvim-tree first
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha", 
      callback = function(args)
        vim.keymap.set("n", "q", function()
          print("CUSTOM QUIT OVERRIDE TRIGGERED")
        end, { buffer = args.buf, silent = true })
      end,
    })
  end,
}

