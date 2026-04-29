-- Basic indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true 
vim.opt.smarttab = true

vim.opt.scrolloff = 8

-- Search incrementally, highlight
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Show line numbers relatively
vim.opt.number = true
vim.opt.relativenumber = true

-- Replace all by-default
vim.opt.gdefault = true

-- Show unprintable
vim.opt.list = true
vim.opt.listchars = {tab = '⁞ ', eol = '¬', trail = '·'}

-- Autocompletion
vim.opt.wildmode = 'longest,list'
vim.opt.wildmenu = true

-- Also work under ru
vim.opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

vim.opt.colorcolumn = "120"

vim.opt.mouse = ""

-- vim.lsp.set_log_level('off')
vim.lsp.log.set_level('off')

--vim.api.nvim_set_keymap('n', 'n', 'nzz', { noremap = true, silent = true })

-- Extra options 
vim.opt.splitright = true
-- vim.opt.autoread = true
-- vim.opt.autowrite = false
-- vim.opt.completeopt = 'menuone,noinsert,noselect'

-- Install lazy.nvim as plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local on_lsp_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic = require('nvim-navic')
    navic.attach(client, bufnr)
  end
end

vim.o.statusline = "%<%f:%l, %c%V %h%w%m%r %{%v:lua.require'nvim-navic'.get_location()%}%=%-14.(%) %P"

-- Install plugins using lazy
require('lazy').setup({
  -- { 'tpope/vim-commentary', },
  -- { 'tpope/vim-fugitive', },
  -- { 'sheerun/vim-polyglot',
  -- 	init = function()
    -- 		-- vim-polyglot confusingly registers *.comp both for perl and for glsl
    -- 		vim.api.nvim_set_var('polyglot_disabled', {'perl'})
    -- 	end,
    -- },
  {
    'morhetz/gruvbox',
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      vim.g.gruvbox_italic = 1
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    -- config = function()
      --   -- load the colorscheme here
      --   vim.cmd([[colorscheme tokyonight]])
      -- end,
  },
  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "c", "cpp", "go", "lua", "rust", "glsl" },
        highlight = { enable = true, }
      }
    end
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Setup language servers.
      local lspconfig = vim.lsp.config('clangd', {
        cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
        init_options = {
          fallbackFlags = {'-std=c++23'},
        },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
        on_attach = on_lsp_attach,
      })
      vim.lsp.enable('clangd')

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' }, -- For vsnip users.
          -- { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
          { name = 'buffer' },
          { name = 'nvim_lsp_signature_help' },
        })
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      -- Set up lspconfig.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- TODO Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
      -- require('lspconfig')['clangd'].setup {
        vim.lsp.config('clangd', {
          capabilities = capabilities
        })
    end,
  },
  {
    'stevearc/aerial.nvim',
    dependencies = { 'neovim/nvim-lspconfig', },
    config = function()
      require('aerial').setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
          vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
        end
      })
      -- You probably also want to set a keymap to toggle aerial
      vim.keymap.set('n', '<F8>', '<cmd>AerialToggle!<CR>')
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
})

vim.filetype.add({
  extension = {
    vp = 'glsl',
    fp = 'glsl',
    gp = 'glsl',
    vs = 'glsl',
    fs = 'glsl',
    gs = 'glsl',
    tcs = 'glsl',
    tes = 'glsl',
    cs = 'glsl',
    vert = 'glsl',
    frag = 'glsl',
    geom = 'glsl',
    tess = 'glsl',
    shd = 'glsl',
    gls = 'glsl',
    glsl = 'glsl',
    rgen = 'glsl',
    comp = 'glsl',
    rchit = 'glsl',
    rahit = 'glsl',
    rmiss = 'glsl',
  }
})



