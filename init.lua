-- Interface
vim.cmd("syntax enable")
vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.number = true
vim.opt.cursorline = true

-- Tabs e indentação
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.g.mapleader = " "

-- Busca
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Performance
vim.opt.lazyredraw = true

-- Templates
local templates = vim.api.nvim_create_augroup("templates", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
    group = templates,
    pattern = "*.c",
    callback = function()
        if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
            vim.cmd("0r ~/.config/nvim/templates/skeleton.c")
        end
    end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
    group = templates,
    pattern = "*.cpp",
    callback = function()
        if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
            vim.cmd("0r ~/.config/nvim/templates/skeleton.cpp")
        end
    end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
    group = templates,
    pattern = "*.java",
    callback = function()
        if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
            vim.cmd("0r ~/.config/nvim/templates/skeleton.java")
        end
    end,
})

-- Lazy.nvim : gerenciador de plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end

vim.opt.rtp:prepend(lazypath)

-- PLUGINS
require("lazy").setup({
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp", "java", "lua" },
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },

    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    
   {
    "hrsh7th/nvim-cmp", --autocomplete
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
        local cmp = require("cmp")

        vim.keymap.set({ "i", "s" }, "<C-j>", function() --ctrl j avança bloco do snippet
            if vim.snippet and vim.snippet.active({ direction = 1 }) then
                vim.snippet.jump(1)
            end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<C-k>", function() --ctrl k volta bloco do snippet
            if vim.snippet and vim.snippet.active({ direction = -1 }) then
                vim.snippet.jump(-1)
            end
        end, { silent = true })

        cmp.setup({
            snippet = {
                expand = function(args)
                    vim.snippet.expand(args.body)
                end,
            },

            mapping = cmp.mapping.preset.insert({
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { "i" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { "i" }),

                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = true })
                    else
                        fallback()
                    end
                end, { "i" }),

                ["<C-e>"] = cmp.mapping.abort(),
            }),

            sources = {
                { name = "nvim_lsp" },
            },
            })
        end,
    }, 

    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()                     
            vim.lsp.config("clangd", {
                capabilities = capabilities,
                cmd = { "clangd" },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_markers = { ".clangd", "compile_commands.json", ".git" },
            })
            vim.lsp.enable("clangd")
        end,
    },
    
    {
    "nvim-telescope/telescope.nvim", --busca de arquivos/textos
    dependencies = {
        "nvim-lua/plenary.nvim",
        },
    },
    
     {
    "akinsho/bufferline.nvim", --abas de buffers
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("bufferline").setup({})
        end,
    },   

    {
    "nvim-neo-tree/neo-tree.nvim", --árvore de arquivos
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
        end,
    },

    {--seletor de temas
    "zaldih/themery.nvim",
    config = function()
        require("themery").setup({
            themes = {
                "koda-dark",
                "koda-light",
                "koda-glade",
                "koda-moss",
                "tokyonight",
                "tokyonight-night",
                "tokyonight-storm",
                "tokyonight-day",
            },
        })
    end
        },
           
    {
    "goolord/alpha-nvim", --interface
    dependencies = {
		{
    "nvim-tree/nvim-web-devicons",
    config = function()
	require("nvim-web-devicons").set_icon({
        -- precisa ter JetBrainsMono Nerd Font instalado
    	[".c"] = { icon = [[]], color = "#519aba", name = "C" },
    	[".cpp"] = { icon = [[]], color = "#519aba", name = "Cpp" },
    	[".java"] = { icon = [[]], color = "#cc3e44", name = "Java" },
    	[".lua"] = { icon = [[]], color = "#51a0cf", name = "Lua" },

	})
        end,
     },
    
	},
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

       -- dashboard.section.header.val = {
   -- [[                                                                     ]],
  --  [[       ███████████           █████      ██                     ]],
  --  [[      ███████████             █████                             ]],
  --  [[      ████████████████ ███████████ ███   ███████     ]],
   -- [[     ████████████████ ████████████ █████ ██████████████   ]],
   -- [[    █████████████████████████████ █████ █████ ████ █████   ]],
 --   [[  ██████████████████████████████████ █████ █████ ████ █████  ]],
 --   [[ ██████  ███ █████████████████ ████ █████ █████ ████ ██████ ]],
  --  [[ ██████   ██  ███████████████   ██ █████████████████ ]],
  --  [[ ██████   ██  ███████████████   ██ █████████████████ ]],
  --  }

    dashboard.section.header.val = {
    [[                                                                       ]],
	[[                                                                     ]],
	[[       ████ ██████           █████      ██                     ]],
	[[      ███████████             █████                             ]],
	[[      █████████ ███████████████████ ███   ███████████   ]],
	[[     █████████  ███    █████████████ █████ ██████████████   ]],
	[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
	[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
	[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
	[[                                                                       ]],
    }

        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
            dashboard.button("g", "󰱼  Find Word", ":Telescope live_grep<CR>"),
            dashboard.button("n", "  New File", ":ene<CR>"),
            dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
        }

        alpha.setup(dashboard.config)
    end,
    },

--THEMES
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
    },

    { "oskarnurm/koda.nvim" },

})

local builtin = require("telescope.builtin") --atalhos telescope

vim.keymap.set("n", "<leader>ff", builtin.find_files, {}) --buscar arquivos
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {}) --buscar texto dentro dos arquivos
vim.keymap.set("n", "<leader>fb", builtin.buffers, {}) --listar buffers abertos
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {}) --help

vim.keymap.set("n", "<leader>tt", ":Themery<CR>") --trocar de tema