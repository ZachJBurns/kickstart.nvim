vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Fix deprecation warnings for plugins using vim.tbl_islist in Neovim 0.10+
if vim.islist then
  vim.tbl_islist = vim.islist
end

-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Git keymaps
vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Git Status' })

-- Terminal navigation for smoother switching between windows
vim.keymap.set('t', '<C-w>h', [[<C-\><C-n><C-w>h]])
vim.keymap.set('t', '<C-w>j', [[<C-\><C-n><C-w>j]])
vim.keymap.set('t', '<C-w>k', [[<C-\><C-n><C-w>k]])
vim.keymap.set('t', '<C-w>l', [[<C-\><C-n><C-w>l]])
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

-- [[ Basic Options ]]
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.undofile = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.termguicolors = true

-- [[ Install lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      -- Replacement for neodev (highly recommended for Neovim 0.10+)
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      require('mason').setup()
      
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- This replaces the manual setup and fixes the deprecation warning
      require('mason-lspconfig').setup({
        ensure_installed = { 'gopls', 'lua_ls' },
        handlers = {
          -- The first entry (without a key) is the default handler
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- Next, provide specific overrides for servers
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { 'vim' } },
                  completion = { callSnippet = "Replace" },
                },
              },
            })
          end,
        }
      })

      -- Global diagnostic config
      vim.diagnostic.config({ virtual_text = true })

      -- LSP Keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip', 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local cmp = require 'cmp'
      cmp.setup {
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
        },
        sources = { { name = 'nvim_lsp' }, { name = 'luasnip' } },
      }
    end,
  },

  {
    "nickjvandyke/opencode.nvim",
    dependencies = { { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } } },
    config = function()
      local opencode = require("opencode")
      vim.keymap.set("n", "<leader>oa", function() opencode.ask("@this: ") end)
      vim.keymap.set("n", "<leader>ot", function() opencode.toggle() end)
    end,
  },

  { 'navarasu/onedark.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'onedark' end },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'lua', 'go', 'markdown', 'markdown_inline', 'query' },
        highlight = { enable = true },
      }
    end
  },

  'tpope/vim-fugitive',
  { 'lewis6991/gitsigns.nvim', opts = {} },
  { 'numToStr/Comment.nvim', opts = {} },
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'j-hui/fidget.nvim', opts = {} },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle workspace_diagnostics<cr>', { desc = 'Workspace Diagnostics (Trouble)' })
      vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Document Diagnostics (Trouble)' })
      vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Location List (Trouble)' })
      vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { desc = 'Quickfix List (Trouble)' })
      vim.keymap.set('n', 'gR', '<cmd>TroubleToggle lsp_references<cr>', { desc = 'LSP References (Trouble)' })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = 'Find by String' })
      vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Find Git Files' })
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Search Neovim files' })
    end,
  },

  {
    'stevearc/oil.nvim',
    opts = {},
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
      vim.keymap.set('n', '<leader>pv', '<CMD>Oil<CR>', { desc = 'Project View (Oil)' })
    end,
  },

  { import = 'kickstart.plugins' },
  { import = 'custom.plugins' },
})
