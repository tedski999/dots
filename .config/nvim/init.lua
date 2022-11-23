pcall(require, "impatient")

-- TODO:
-- better ways to jump between previous files (merge buffer and oldfiles, maybe send oldfiles to buffers and then :b on keybind?)

local packer_bootstrap = false
local packer_installdir = vim.fn.resolve(vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim")
if vim.fn.empty(vim.fn.glob(packer_installdir)) > 0 then
	print " +-------| PLS BE PATIENT |-------+"
	print " | Plugins will now be installed. |"
	print " |  Wait until Packer completes,  |"
	print " |      then restart Neovim.      |"
	print " +--------------------------------+"
	packer_bootstrap = vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", packer_installdir})
	vim.cmd("packadd packer.nvim")
end

require("packer").startup({
	function(use)

		-- Plugin management and optimisation --

		use({"wbthomason/packer.nvim", config = function()
			vim.keymap.set({"n","v"}, "<leader>p", "<cmd>PackerStatus<cr>")
			vim.keymap.set({"n","v"}, "<leader>P", "<cmd>PackerSync<cr>")
		end})

		use({"lewis6991/impatient.nvim"})

		use({"nathom/filetype.nvim"})

		-- Theming and presentation --

		use({"whatyouhide/vim-gotham", config = function()
			vim.cmd([[
				colorscheme gotham
				" Spelling
				highlight SpellBad guibg=NONE guifg=NONE gui=undercurl guisp=Red
				highlight SpellCap guibg=NONE guifg=NONE gui=undercurl guisp=Blue
				highlight SpellRare guibg=NONE guifg=NONE gui=undercurl guisp=Purple
				highlight SpellLocal guibg=NONE guifg=NONE gui=undercurl guisp=Yellow
				" Popup windows
				highlight Pmenu ctermfg=14 ctermbg=8 guifg=#599cab guibg=#111a23
				highlight link NormalFloat Pmenu
				highlight link FloatBorder Pmenu
				" Status line
				highlight StatusLine guibg=#111a23
				highlight link StatusLineNC StatusLine
				" Code errors and warnings
				highlight DiagnosticLineNrError guibg=#51202a guifg=#ff0000 gui=bold
				highlight DiagnosticLineNrWarn guibg=#51412a guifg=#ffa500 gui=bold
				highlight DiagnosticLineNrInfo guibg=#1e535d guifg=#00ffff gui=bold
				highlight DiagnosticLineNrHint guibg=#1e205d guifg=#0000ff gui=bold
				sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
				sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
				sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
				sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
				" Highlight references
				highlight LspReferenceRead gui=bold
				highlight link LspReferenceText LspReferenceRead
				highlight link LspReferenceWrite LspReferenceRead
				" Indent-Blankline
				highlight IndentBlanklineChar guifg=#0a3749 gui=nocombine
				highlight IndentBlanklineContextChar guifg=#195466 gui=nocombine
			]])
		end})

		use({"nvim-lualine/lualine.nvim", config = function()
			require("lualine").setup({
				extensions = {"fugitive"},
				options = {
					icons_enabled = false,
					section_separators = "",
					component_separators = "",
					theme = {
						normal =   {a = {bg = "#195466", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						insert =   {a = {bg = "#009368", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						visual =   {a = {bg = "#cb6635", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						replace =  {a = {bg = "#c23127", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						command =  {a = {bg = "#62477c", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						terminal = {a = {bg = "#111a23", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}},
						inactive = {a = {bg = "#111a23", fg = "#d3ebe9", gui = "bold"}, b = {bg = "#0a3749", fg = "#99d1ce"}, c = {bg = "#111a23", fg = "#599cab"}}
					},
					refresh = {statusline = 100, tabline = 100, winbar = 100}
				},
				sections = {
					lualine_a = {{"mode", fmt = function(mode) return mode:sub(1,1) end}},
					lualine_b = {{"filename", symbols = {modified = " *", readonly = " -"}}},
					lualine_c = {"diff"},
					lualine_x = {{"diagnostics", sections = {"error", "warn"}}},
					lualine_y = {"filetype"},
					lualine_z = {"progress", "location"},
				},
				inactive_sections = {
					lualine_a = {{"mode", fmt = function() return " " end}},
					lualine_b = {},
					lualine_c = {{"filename", symbols = {modified = " *", readonly = " -"}}, "diff"},
					lualine_x = {{"diagnostics", sections = {"error", "warn"}}},
					lualine_y = {},
					lualine_z = {}
				}
			})
		end})

		use({"lukas-reineke/indent-blankline.nvim", config = function()
			require("indent_blankline").setup({
				char = "▏",
				strict_tabs = true,
				show_current_context = true,
				viewport_buffer = 100,
				use_treesitter = true,
				show_trailing_blankline_indent = false,
				use_treesitter_scope = true,
				filetype_exclude = { "haskell" }
			})
		end})

		use({"folke/trouble.nvim", requires = "folke/todo-comments.nvim", config = function()
			-- vim.keymap.set({"n","v"}, "<leader>jd", vim.lsp.buf.definition)
			vim.keymap.set({"n","v"}, "<leader>jd", "<cmd>Trouble lsp_definitions<cr>")
			vim.keymap.set({"n","v"}, "<leader>jt", "<cmd>Trouble lsp_type_definitions<cr>")
			vim.keymap.set({"n","v"}, "<leader>jr", "<cmd>Trouble lsp_references<cr>")
			vim.keymap.set({"n","v"}, "<leader>ji", "<cmd>Trouble lsp_implementations<cr>")
			vim.keymap.set({"n","v"}, "<leader>E", "<cmd>TroubleToggle workspace_diagnostics<cr>")

			require("trouble").setup({
				icons = false,
				use_diagnostic_signs = true,
				action_keys = {
					close = {"<esc>", "q"},
					jump_close = {"<cr>", "<c-space>", "<tab>"},
					open_split = "<c-s>",
					open_vsplit = "<c-v>",
					open_tab = "<c-t>",
					cancel = {},
					refresh = {},
					jump = {},
					toggle_mode = {},
					toggle_preview = {},
					hover = {},
					preview = {}
				}
			})

			vim.keymap.set({"n","v"}, "<leader>t", "<cmd>TodoTrouble<cr>")
			require("todo-comments").setup({
				signs = false,
				highlight = {
					pattern = [[.*<(KEYWORDS)\s*(\(.*\))?\s*:]],
					before = "",
					keyword = "",
					after = ""
				},
				search = {
					command = "rg",
					args = {"--color=never", "--no-heading", "--with-filename", "--line-number", "--column"},
					pattern = [[\b(KEYWORDS)\s*(\(.*\))?\s*:]]
				}
			})
		end})

		use({"ncm2/float-preview.nvim", config = function()
			-- TODO: not great when some completemenu entries are really wide
			vim.g["float_preview#docked"] = 0
		end})

		use({"psliwka/vim-smoothie", config = function()
			vim.g.smoothie_speed_constant_factor = 30
			vim.g.smoothie_speed_linear_factor = 30
			vim.g.smoothie_speed_exponentiation_factor = 0.9
		end})

		use({"norcalli/nvim-colorizer.lua", ft = {"css","scss","javascript","html","lua"}, config = function()
			require("colorizer").setup({"css","scss","javascript","html","lua"})
		end})

		use({"iamcco/markdown-preview.nvim", run = function() vim.fn["mkdp#util#install"]() end, ft = "markdown", config = function()
			vim.g.mkdp_auto_close = 0
		end})

		-- File management --

		use({"tpope/vim-vinegar"})

		use({"lambdalisue/suda.vim", config = function()
			vim.api.nvim_create_user_command("S", "SudaWrite", {})
		end})

		-- Languages and syntax --

		use({"nvim-treesitter/nvim-treesitter", requires = {"nvim-treesitter/nvim-treesitter-textobjects"}, run = ":TSUpdate", config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash", "c", "cmake", --[["comment",]] "cpp", "css", "dockerfile", "fish", "glsl",
					"go", "help", "html", "java", "javascript", "jsdoc", "json", "latex", "lua",
					"make", "python", "rust", "scss", "toml", "typescript", "vim", "vue", "yaml"
				},
				highlight = {
					enable = true,
					disable = function(_, bufnr)
						return vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > 1024 * 100
					end,
				},
				-- indent = {enable = true},
				textobjects = {
					select = {
						enable = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner"
						}
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>]"] = "@parameter.inner"
						},
						swap_previous = {
							["<leader>["] = "@parameter.inner"
						}
					},
					move = {
						enable = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer"
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer"
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer"
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer"
						}
					}
				}
			})
		end})

		use({"neovim/nvim-lspconfig", requires = {"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim"}, config = function()
			vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"
			vim.keymap.set("", "<leader>l", "<cmd>LspInfo<cr>")
			vim.keymap.set("", "<leader>L", "<cmd>Mason<cr>")
			vim.keymap.set({"n","v"}, "<c-k>", vim.lsp.buf.hover)
			vim.keymap.set({"n","v"}, "<leader>k", vim.lsp.buf.code_action)
			vim.keymap.set({"n","v"}, "<leader>e", vim.diagnostic.open_float)
			vim.keymap.set({"n","v"}, "<leader>R", vim.lsp.buf.rename)
			vim.keymap.set("i", "<tab>", function() return vim.fn.pumvisible() == 1 and "<c-n>" or "<tab>" end, {expr = true})
			vim.keymap.set("i", "<s-tab>", function() return vim.fn.pumvisible() == 1 and "<c-p>" or "<s-tab>" end, {expr = true})
			vim.keymap.set("i", "<bs>", function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local char = vim.api.nvim_get_current_line():sub(col-1,col-1)
				if char:match("[A-Za-z0-9._>/]") then vim.schedule(vim.lsp.omnifunc) end
				return "<bs>"
			end, {silent = true, expr = true})
			vim.api.nvim_create_autocmd("InsertCharPre", {callback = function()
				if vim.v.char:match("[A-Za-z0-9._>/]") then vim.schedule(vim.lsp.omnifunc) end
			end})

			for i, kind in ipairs(vim.lsp.protocol.CompletionItemKind) do
				vim.lsp.protocol.CompletionItemKind[i] = ({
					Class = " ", Color = " ", Constant = " ",
					Constructor = " ", Enum = " ", EnumMember = " ",
					Field = " ", File = " ", Folder = " ",
					Function = " ", Interface = " ", Keyword = " ",
					Method = " ", Module = " ", Property = " ",
					Snippet = " ", Struct = " ", Text = " ",
					Unit = " ", Value = " ", Variable = " "
				})[kind] or kind
			end

			local open_floating_preview = vim.lsp.util.open_floating_preview
			function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
				opts = opts or {}
				opts.border = opts.border or "single"
				return open_floating_preview(contents, syntax, opts, ...)
			end

			local lspconfig_win = require("lspconfig.ui.windows")
			local lspconfig_win_opts = lspconfig_win.default_opts
			function lspconfig_win.default_opts(opts)
				local win_opts = lspconfig_win_opts(opts)
				win_opts.border = "single"
				return win_opts
			end

			require("mason").setup({
				ui = {
					border = "single",
					icons = {package_installed = "-", package_pending = "-", package_uninstalled = "-"}
				}
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"angularls", "asm_lsp", "bashls", "clangd", "cmake", "cssls", "dockerls",
					"gopls", "hls", "html", "jdtls", "jsonls", "kotlin_language_server", "lemminx", "marksman",
					"pylsp", "rust_analyser", "sumneko_lua", "texlab", "tsserver", "vimls", "vuels"
				}
			})

			local function on_attach(client, bufnr)
				if client.server_capabilities.document_highlight then
					local previous_result = {}
					local function update_document_highlighting(_, result)
						if not vim.deep_equal(result, previous_result) then
							previous_result = result
							vim.lsp.buf.clear_references()
							vim.lsp.buf.document_highlight()
						end
					end
					vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {buffer = bufnr, callback = function()
						local params = vim.lsp.util.make_position_params()
						return vim.lsp.buf_request(0, "textDocument/documentHighlight", params, update_document_highlighting)
					end})
				end
			end

			vim.lsp.stop_client(vim.lsp.get_active_clients())
			for _, server in ipairs(require("mason-lspconfig").get_installed_servers()) do
				local opts = {on_attach = on_attach}
				if server == "sumneko_lua" then
					opts.settings = {Lua = {diagnostics = {globals = {"vim"}}}}
				elseif server == "tsserver" then
					opts.init_options = {preferences = {disableSuggestions = true}}
				elseif server == "clangd" then
					opts.on_attach = function(client, bufnr)
						on_attach(client, bufnr)
						vim.keymap.set({"n","v"}, "<leader>a", "<cmd>ClangdSwitchSourceHeader<cr>")
						vim.keymap.set({"n","v"}, "<leader>A", ":new +set\\ buftype=nofile|set\\ ft=asm | r !gcc # -S -o - -Og ")
					end
				end
				require("lspconfig")[server].setup(opts)
			end
		end})

		use({"ray-x/lsp_signature.nvim", after = "nvim-lspconfig", config = function()
			require("lsp_signature").setup({
				bind = true,
				floating_window = false,
				hint_prefix = "",
				toggle_key = "<c-s>",
				handler_opts = {border = "single"}
			})
		end})

		-- Text editing --

		use({"tpope/vim-sensible"})

		use({"tpope/vim-repeat"})

		use({"kylechui/nvim-surround", config = function()
			require("nvim-surround").setup({})
		end})

		use({"numToStr/Comment.nvim", config = function()
			require("Comment").setup()
		end})

		use({"tommcdo/vim-lion", config = function()
			vim.g.lion_map_left = "<leader>,"
			vim.g.lion_map_right = "<leader>."
			vim.g.lion_squeeze_spaces = 1
		end})

		use({"mbbill/undotree", config = function()
			vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>")
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_TreeNodeShape = "┼"
			vim.g.undotree_TreeVertShape = "│"
			vim.g.undotree_TreeSplitShape = "⡐"
			vim.g.undotree_TreeReturnShape = "⠢"
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_HelpLine = 0
		end})

		-- VCS --

		use({"lewis6991/gitsigns.nvim", requires = "nvim-lua/plenary.nvim", config = function()
			local gs = require("gitsigns")
			vim.keymap.set("n", "]c", function() gs.next_hunk(); vim.schedule(gs.preview_hunk); end)
			vim.keymap.set("n", "[c", function() gs.prev_hunk(); vim.schedule(gs.preview_hunk); end)
			vim.keymap.set("n", "<leader>gg", function() gs.setqflist("all") end)
			vim.keymap.set("n", "<leader>gh", function() local s = gs.toggle_word_diff(); gs.toggle_linehl(s); gs.toggle_deleted(s); end)
			vim.keymap.set("n", "<leader>gd", gs.diffthis)
			vim.keymap.set("n", "<leader>gD", function() gs.diffthis("~"); end)
			vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame)
			vim.keymap.set("n", "<leader>gB", function() gs.blame_line({full=true}) end)
			vim.keymap.set({"n","v"}, "<leader>gs", gs.stage_hunk)
			vim.keymap.set("n", "<leader>gS", gs.stage_buffer)
			vim.keymap.set({"n","v"}, "<leader>gr", gs.reset_hunk)
			vim.keymap.set("n", "<leader>gR", gs.reset_buffer)
			vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk)
			gs.setup({
				numhl = true,
				signcolumn = false,
				current_line_blame_opts = {delay = 0},
			})
		end})

		use({"tpope/vim-fugitive", config = function()
			-- TODO
		end})

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = function()
				return require("packer.util").float({border = "single"})
			end
		}
	}
})

local g = vim.api.nvim_create_augroup("vimrc", {})
vim.api.nvim_create_autocmd("TextYankPost", {group = g, callback = function() vim.highlight.on_yank({higroup="Visual", timeout=150}) end})
vim.api.nvim_create_autocmd("BufEnter",     {group = g, command = "set formatoptions-=c formatoptions-=o"})
vim.api.nvim_create_autocmd("FileType",     {group = g, pattern = "lua,vim", callback = function() vim.g.keywordprg = "" end})
vim.api.nvim_create_autocmd("BufWritePost", {group = g, pattern = vim.env.MYVIMRC, command = [[
	source <afile> |
	exe 'silent! PackerCompile' |
	redraw | echohl String | echo 'Saved and reloaded Neovim configuration' | echohl None"
]]})
vim.api.nvim_create_autocmd("BufWritePre",  {group = g, command = [[
	let b:v = winsaveview() |
	keeppatterns %s/\s\+$//e |
	call winrestview(b:v)
]]})
vim.api.nvim_create_autocmd("BufReadPost",  {group = g, command = [[
	if expand('%:p') !~# '\m/\.git/' && line("'\"") > 0 && line("'\"") <= line("$") |
		exe "normal! g`\"" |
	endif
]]})

vim.o.title = true
vim.o.shell = "sh"
vim.o.updatetime = 100
vim.o.timeoutlen = 10000
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.modeline = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.swapfile = true
vim.o.lazyredraw = true
vim.o.path = "**"
vim.o.completeopt = "menuone,noselect"
vim.o.wildmode = "longest:full,full"
vim.o.spellsuggest = "best,9"
vim.o.shada = "!,'20,<50,s10,h"
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.virtualedit = "onemore"
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.showmode = false
vim.o.pumheight = 6
vim.o.list = true
vim.o.listchars = "tab:› ,trail:•,precedes:<,extends:>,nbsp:␣"
vim.o.guicursor="n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400"
vim.opt.shortmess:append("sIc")
vim.o.foldenable = false
vim.o.wrap = false

vim.g.mapleader = " "
vim.keymap.set("", "Q", "", {nowait = true})
vim.keymap.set({"n","v"}, "j", "gj")
vim.keymap.set({"n","v"}, "k", "gk")
vim.keymap.set({"n","v"}, "<leader>w", "<cmd>w<cr>")
vim.keymap.set({"n","v"}, "<leader>W", "<cmd>wq<cr>")
vim.keymap.set({"n","v"}, "<leader>q", "<cmd>q<cr>")
vim.keymap.set({"n","v"}, "<leader>Q", "<cmd>q!<cr>")
vim.keymap.set({"n","v"}, "<leader>c", "<cmd>split " .. vim.env.MYVIMRC .. "<cr>")
vim.keymap.set({"n","v"}, "<leader>z", "<cmd>set spell!<cr>")
vim.keymap.set("n", "<leader>r", "*:%s///gcI<left><left><left><left>")
vim.keymap.set("n", "<leader>b", "<cmd>ls<cr>:b ")
vim.keymap.set("n", "<leader>f", ":find ")
vim.keymap.set("n", "<leader>o", "<cmd>browse oldfiles<cr>")
vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
vim.keymap.set("n", "<a-o>", ":set paste<cr>m`o<esc>``:set nopaste<cr>")
vim.keymap.set("n", "<a-O>", ":set paste<cr>m`O<esc>``:set nopaste<cr>")
