-- setup is follows this guide: https://lsp-zero.netlify.app/v3.x/tutorial.html

vim.wo.number = true
vim.opt.clipboard="unnamed,unnamedplus"

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { "savq/melange-nvim" },
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
  {'numToStr/Comment.nvim'},
  {'lewis6991/gitsigns.nvim'},
  {'github/copilot.vim'},
  {'akinsho/toggleterm.nvim', version = "*", config = true},
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {'ThePrimeagen/harpoon'},
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  }
})

-- colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme 'melange'

-- commentiong with 'gcc'
require('Comment').setup()

-- toggle term
require("toggleterm").setup{
  open_mapping = [[<c- >]],
  direction ='float',
}

-- flash for jumping 
require('flash').setup()


--lsp stuff
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

--- if you want to know more about lsp-zero and mason.nvim
--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

--git stuff
require('gitsigns').setup()

local builtin = require('telescope.builtin')
vim.keymap.set('n', ' ff', builtin.find_files, {})
vim.keymap.set('n', ' fg', builtin.live_grep, {})
vim.keymap.set('n', ' fb', builtin.buffers, {})
vim.keymap.set('n', ' fh', builtin.help_tags, {})

--harpoon
require('harpoon').setup({
	global_settings = {
	    -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
	    save_on_toggle = false,

	    -- saves the harpoon file upon every change. disabling is unrecommended.
	    save_on_change = true,

	    -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
	    enter_on_sendcmd = false,

	    -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
	    tmux_autoclose_windows = false,

	    -- filetypes that you want to prevent from adding to the harpoon list menu.
	    excluded_filetypes = { "harpoon" },

	    -- set marks specific to each git branch inside git repository
	    mark_branch = false,

	    -- enable tabline with harpoon marks
	    tabline = false,
	    tabline_prefix = "   ",
	    tabline_suffix = "   ",
	}
})
require('telescope').load_extension('harpoon')

vim.keymap.set('n', ' ha', require('harpoon.mark').add_file)
vim.keymap.set('n', ' hc', require('harpoon.mark').clear_all)
vim.keymap.set('n', ' hn', require('harpoon.ui').nav_next)
vim.keymap.set('n', ' hp', require('harpoon.ui').nav_prev)
vim.keymap.set('n', ' hh', ':Telescope harpoon marks<CR>')

local function remove_current_file()
    local harpoon_mark = require('harpoon.mark')
    local current_file = vim.fn.expand('%:p')  -- Get the full path of the current file

    harpoon_mark.rm_file(current)  -- Remove the current file from Harpoon
end

vim.keymap.set('n', ' hr', remove_current_file)
