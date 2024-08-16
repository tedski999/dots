-- Spaceman
vim.g.mapleader = " "

-- Consistent aesthetics
vim.lsp.protocol.CompletionItemKind = {
	'""', ".f", "fn", "()", ".x",
	"xy", "{}", "{}", "[]", ".p",
	"$$", "00", "∀e", ";;", "~~",
	"rg", "/.", "&x", "//", "∃e",
	"#x", "{}", "ev", "++", "<>"
}

-- We don't need netrw where we're going
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Better signify highlighting
vim.g.signify_number_highlight = 1

-- OPTIONS --

vim.opt.title = true                                   -- Update window title
vim.opt.mouse = "a"                                    -- Enable mouse support
vim.opt.updatetime = 100                               -- Faster refreshing
vim.opt.timeoutlen = 5000                              -- 5 seconds to complete mapping
vim.opt.clipboard = "unnamedplus"                      -- Use system clipboard
vim.opt.undofile = true                                -- Write undo history to disk
vim.opt.swapfile = false                               -- No need for swap files
vim.opt.modeline = false                               -- Don't read mode line
vim.opt.virtualedit = "onemore"                        -- Allow cursor to extend one character past the end of the line
vim.opt.grepprg = "rg --vimgrep "                      -- Use ripgrep for grepping
vim.opt.number = true                                  -- Enable line numbers...
vim.opt.relativenumber = false                         -- ...and not relative line numbers
vim.opt.ruler = false                                  -- No need to show line/column number with lightline
vim.opt.showmode = false                               -- No need to show current mode with lightline
vim.opt.scrolloff = 3                                  -- Keep lines above/below the cursor when scrolling
vim.opt.sidescrolloff = 5                              -- Keep columns to the left/right of the cursor when scrolling
vim.opt.signcolumn = "no"                              -- Keep the sign column closed
vim.opt.shortmess:append("sSIcC")                      -- Be quieter
vim.opt.expandtab = false                              -- Tab key inserts tabs
vim.opt.tabstop = 2                                    -- 4-spaced tabs
vim.opt.shiftwidth = 0                                 -- Tab-spaced indentation
vim.opt.cinoptions = "N-s"                             -- Don't indent C++ namespaces
vim.opt.list = true                                    -- Enable whitespace characters below
vim.opt.listchars="space:·,tab:› ,trail:•,precedes:<,extends:>,nbsp:␣"
vim.opt.suffixes:remove(".h")                          -- Header files are important...
vim.opt.suffixes:append(".git")                        -- ...but .git files are not
vim.opt.foldmethod = "indent"                          -- Fold based on indent
vim.opt.foldlevelstart = 20                            -- ...and start with everything open
vim.opt.wrap = false                                   -- Don't wrap
vim.opt.lazyredraw = true                              -- Redraw only after commands have completed
vim.opt.termguicolors = true                           -- Enable true colors and gui cursor
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400"
vim.opt.ignorecase = true                              -- Ignore case when searching...
vim.opt.smartcase = true                               -- ...except for searching with uppercase characters
vim.opt.complete = ".,w,kspell"                        -- Complete menu contents
vim.opt.completeopt = "menu,menuone,noinsert,noselect" -- Complete menu functionality
vim.opt.pumheight = 8                                  -- Limit complete menu height
vim.opt.spell = true                                   -- Enable spelling by default
vim.opt.spelloptions = "camel"                         -- Enable CamelCase word spelling
vim.opt.spellsuggest = "best,20"                       -- Only show best spelling corrections
vim.opt.spellcapcheck = ""                             -- Don't care about capitalisation
vim.opt.dictionary = "/usr/share/dict/words"           -- Dictionary file
vim.opt.shada = "!,'256,<50,s100,h,r/media"            -- Specify removable media for shada
vim.opt.undolevels = 2048                              -- More undo space
vim.opt.diffopt = "internal,filler,context:512"        -- I like lots of diff context
vim.opt.hidden = true                                  -- Modified buffers can be hidden
vim.opt.wildmode = "longest:full,full"                 -- Match common and show wildmenu
vim.opt.wildoptions = "fuzzy,pum"                      -- Wildmenu fuzzy matching and ins-completion menu
vim.opt.wildignorecase = true                          -- Don't care about wildmenu file capitalisation

-- LOCAL FUNCTIONS --

local fzf = require("fzf-lua")

local function fullpath(path)
	return vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")
end

-- Return the alphabetically previous and next files
local function prev_next_file(file)
	file = (file or fullpath()):gsub("/$", "")
	local prev, dir = file, file:match(".*/") or "/"
	local files = (vim.fn.glob(dir..".[^.]*").."\n"..vim.fn.glob(dir.."*")):gmatch("[^\n]+")
	for next in files do
		if next == file then return prev, files() or next
		elseif next > file then return prev, next
		else prev = next end
	end
	return prev, file
end

-- Yank selected entries
local function fzf_yank_selection(selected)
	local x = table.concat(selected, "\n")
	vim.fn.setreg("+", x)
	print("Yanked "..#x.." bytes")
end

-- Crude method to change to or temporally access directories
local function fzf_directories(root)
	root = vim.fn.resolve(root or fullpath():gsub("[^/]*$", ""))
	vim.cmd("edit "..root)
	fzf.fzf_exec("fd --type directory --absolute-path --follow --hidden --exclude '**/.git/' --exclude '**/node_modules/'", {
		prompt = root.."/",
		cwd = root,
		fzf_opts = { ["--no-multi"] = true, ["--header"] = "<ctrl-r> to reroot" },
		fn_transform = function(x) return fzf.utils.ansi_codes.blue(x:sub(0, #x-1)) end,
		actions = {
			["default"] = function(sel) fzf_directories(sel[1]) end,
			["-"] = function() fzf_directories(root.."/..") end,
			["ctrl-r"] = { function() vim.fn.chdir(root) print("cd "..root) end, fzf.actions.resume },
			["ctrl-y"] = { fzf_yank_selection, fzf.actions.resume },
		},
	})
end

-- Restore vim session
local function fzf_projects()
	local projects = {}
	for path in vim.fn.glob(vim.fn.stdpath("data").."/projects/*"):gmatch("[^\n]+") do
		projects[#projects + 1] = path:match("[^/]*$")
	end
	fzf.fzf_exec(projects, {
		prompt = "Project>",
		fzf_opts = { ["--no-multi"] = true, ["--header"] = "<ctrl-x> to delete|<ctrl-e> to edit" },
		actions = {
			["default"] = function(sel) vim.cmd("source "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1])) end,
			["ctrl-e"] = function(sel) vim.cmd("edit "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1]).." | setf vim") end,
			["ctrl-x"] = function(sel) vim.fn.delete(vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1])) end,
		}
	})
end

-- Save vim session
local function fzf_projects_save()
	local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
	if project == "" then return end
	vim.fn.mkdir(vim.fn.stdpath("data").."/projects/", "p")
	vim.cmd("mksession! "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..project))
end

-- Visualise and select from the branched undotree
local function fzf_undotree()
	local undotree = vim.fn.undotree()
	local function build_entries(tree, depth)
		local entries = {}
		for i = #tree, 1, -1  do
			local colors = { "magenta", "blue", "yellow", "green", "red" }
			local color = fzf.utils.ansi_codes[colors[math.fmod(depth, #colors) + 1]]
			local entry = tree[i].seq..""
			if tree[i].save then entry = entry.."*" end
			local t = os.time() - tree[i].time
			if t > 86400 then t = math.floor(t/86400).."d" elseif t > 3600 then t = math.floor(t/3600).."h" elseif t > 60 then t = math.floor(t/60).."m" else t = t.."s" end
			if tree[i].seq == undotree.seq_cur then t = fzf.utils.ansi_codes.white(t.." <") else t = fzf.utils.ansi_codes.grey(t) end
			entries[#entries+1] = color(entry).." "..t
			if tree[i].alt then
				local subentries = build_entries(tree[i].alt, depth + 1)
				for j = 1, #subentries do entries[#entries+1] = " "..subentries[j] end
			end
		end
		return entries
	end
	local buf = vim.api.nvim_get_current_buf()
	local file = fullpath()
	fzf.fzf_exec(build_entries(undotree.entries, 0), {
		prompt = "Undotree>",
		fzf_opts = { ["--no-multi"] = "" },
		actions = { ["default"] = function(s) vim.cmd("undo "..s[1]:match("%d+")) end },
		previewer = false,
		preview = fzf.shell.raw_preview_action_cmd(function(s)
			if #s == 0 then return end
			local newbuf = vim.api.nvim_get_current_buf()
			local tmp = vim.fn.tempname()
			vim.api.nvim_set_current_buf(buf)
			vim.cmd("undo "..s[1]:match("%d+"))
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			vim.cmd("undo "..undotree.seq_cur)
			vim.fn.writefile(lines, tmp)
			vim.api.nvim_set_current_buf(newbuf)
			return "delta --file-modified-label '' --hunk-header-style '' --file-transformation 's/tmp.*//' "..file.." "..tmp
		end)
	})
end

-- Get all alternative files based on extension
local function get_altfiles()
	local ext_altexts = {
		[".c"] = { ".h", ".hpp", ".tin" },
		[".h"] = { ".c", ".cpp", ".tac" },
		[".cpp"] = { ".hpp", ".h", ".tin" },
		[".hpp"] = { ".cpp", ".c", ".tac" },
		[".vert.glsl"] = { ".frag.glsl" },
		[".frag.glsl"] = { ".vert.glsl" },
		[".tac"] = { ".tin", ".cpp", ".c" },
		[".tin"] = { ".tac", ".hpp", ".h" }
	}
	local file = fullpath()
	local hits, more = {}, {}
	for ext, altexts in pairs(ext_altexts) do
		if file:sub(-#ext) == ext then
			for i=1,#altexts do
				local alt = file:sub(0,#file-#ext)..altexts[i]
				if vim.loop.fs_stat(alt) then hits[#hits+1] = alt else more[#more+1] = alt end
			end
		end
	end
	return hits, more
end

-- Switch to an alternative file
local function fzf_altfiles(hits, more)
	for i=1,#hits do hits[i] = fzf.utils.ansi_codes.green(hits[i]:match("[^/]*$")) end
	for i=1,#more do hits[#hits+1] = fzf.utils.ansi_codes.red(more[i]:match("[^/]*$")) end
	fzf.fzf_exec(hits, { prompt = "Altfiles>", actions = fzf.config.globals.actions.files, previewer = "builtin" })
end

-- AUTOCMDS --

-- Highlight suspicious whitespace
local function get_whitespace_pattern()
	local pattern = [[[\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff]\+\|\s\+$\|[\u0020]\+\ze[\u0009]\+]]
	return "\\("..(vim.o.expandtab and pattern..[[\|^[\u0009]\+]] or pattern..[[\|^[\u0020]\+]]).."\\)"
end
local function apply_whitespace_pattern(pattern)
	local no_ft = { diff=1, git=1, gitcommit=1, markdown=1 }
	local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
	if no_ft[vim.o.ft] or no_bt[vim.o.bt] then vim.cmd("match none") else vim.cmd("match ExtraWhitespace '"..pattern.."'") end
end
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen", "InsertLeave" }, { callback = function()
	apply_whitespace_pattern(get_whitespace_pattern())
end })
vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, { callback = function()
	local line, pattern = vim.fn.line("."), get_whitespace_pattern()
	apply_whitespace_pattern("\\%<"..line.."l"..pattern.."\\|\\%>"..line.."l"..pattern)
end })

-- If I can read it I can edit it (even if I can't write it)
vim.api.nvim_create_autocmd("BufEnter", { callback = function()
	vim.o.readonly = false
end })

-- Remember last cursor position
vim.api.nvim_create_autocmd("BufWinEnter", { callback = function()
	local no_ft = { diff=1, git=1, gitcommit=1, gitrebase=1 }
	local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
	if not (no_ft[vim.o.ft] or no_bt[vim.o.buftype] or vim.fn.line(".") > 1 or vim.fn.line("'\"") <= 0 or vim.fn.line("'\"") > vim.fn.line("$")) then
		vim.cmd([[normal! g`"]])
	end
end })

-- Hide cursorline if not in current buffer
vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = false, false end })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "FocusGained" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = true, true end })

-- Keep universal formatoptions
vim.api.nvim_create_autocmd("Filetype", { callback = function() vim.o.formatoptions = "rqlj" end })

-- Swap to manual folding after loading
vim.api.nvim_create_autocmd("BufWinEnter", { callback = function() vim.o.foldmethod = "manual" end })

-- Use OSC-52 to copy
vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
	if vim.v.event.operator == "y" and vim.v.event.regname == "" then
		require("osc52").copy_register("")
	end
end })

-- Per filetype config
vim.api.nvim_create_autocmd("FileType", { pattern = "nix", command = "setlocal tabstop=2 shiftwidth=2 expandtab" })
vim.api.nvim_create_autocmd("FileType", { pattern = { "c", "cpp", "tac" }, command = "setlocal commentstring=//\\ %s" })

-- PLUGIN INITIALISATION --

fzf.register_ui_select()
fzf.setup({
	winopts = {
		height = 0.25, width = 1.0, row = 1.0, col = 0.5,
		border = { "─", "─", "─", " ", "", "", "", " " },
		hl = { border = "NormalBorder", preview_border = "NormalBorder" },
		preview = { scrollchars = { "│", "" }, winopts = { list = true } }
	},
	keymap = {
		builtin = {
			["<esc>"] = "hide",
			["<c-j>"] = "accept",
			["<m-o>"] = "toggle-preview",
			["<c-o>"] = "toggle-fullscreen",
			["<c-d>"] = "half-page-down",
			["<c-u>"] = "half-page-up",
			["<m-n>"] = "preview-down",
			["<m-p>"] = "preview-up",
			["<m-d>"] = "preview-half-page-down",
			["<m-u>"] = "preview-half-page-up",
		},
		fzf = {
			["ctrl-j"] = "accept",
			["ctrl-d"] = "half-page-down",
			["ctrl-u"] = "half-page-up",
			["alt-n"] = "preview-down",
			["alt-p"] = "preview-up",
			["alt-d"] = "preview-half-page-down",
			["alt-u"] = "preview-half-page-up",
		},
	},
	actions = {
		files = {
			["default"] = fzf.actions.file_edit_or_qf,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
			["ctrl-y"] = { fzf_yank_selection, fzf.actions.resume },
		},
		buffers = {
			["default"] = fzf.actions.buf_edit_or_qf,
			["ctrl-s"] = fzf.actions.buf_split,
			["ctrl-v"] = fzf.actions.buf_vsplit,
			["ctrl-t"] = fzf.actions.buf_tabedit,
			["ctrl-y"] = { fzf_yank_selection, fzf.actions.resume },
		}
	},
	fzf_opts = { ["--separator=''"] = "", ["--preview-window"] = "border-none" },
	previewers = { man = { cmd = "man %s | col -bx" } },
	defaults = { preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS", file_icons = false, git_icons = true, color_icons = true, cwd_header = false, copen = function() fzf.quickfix() end },
	grep = { RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH },
	oldfiles = { include_current_session = true },
	quickfix_stack = { actions = { ["default"] = function() fzf.quickfix() end } },
	git = { status = { actions = { ["right"] = false, ["left"] = false, ["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume } } } }
})

require("nightfox").setup({
	options = {
		dim_inactive = true,
		module_default = false,
		modules = { ["mini"] = true, ["signify"] = true }
	},
	palettes = {
		all = {
			fg0 = "#ff00ff", fg1 = "#ffffff", fg2 = "#999999", fg3 = "#666666",
			bg0 = "#0c0c0c", bg1 = "#121212", bg2 = "#222222", bg3 = "#222222", bg4 = "#333333",
			sel0 = "#222222", sel1 = "#555555", comment = "#666666"
		}
	},
	specs = {
		all = {
			diag = { info = "green", error = "red", warn = "#ffaa00" },
			diag_bg = { error = "none", warn = "none", info = "none", hint = "none" },
			diff = { add = "green", removed = "red", changed = "#ffaa00" },
			git = { add = "green", removed = "red", changed = "#ffaa00" }
		}
	},
	groups = {
		all = {
			Visual = { bg = "palette.bg4" },
			Search = { fg = "black", bg = "yellow" },
			IncSearch = { fg = "black", bg = "white" },
			NormalBorder = { bg = "palette.bg1", fg = "palette.fg3" },
			NormalFloat = { bg = "palette.bg2" },
			FloatBorder = { bg = "palette.bg2" },
			MiniCursorword = { bg = "none", fg = "none", style = "underline,bold" },
			MiniCursorwordCurrent = { bg = "none", fg = "none", style = "underline,bold" },
			CursorLineNr = { fg = "palette.fg1" },
			Whitespace = { fg = "palette.sel1" },
			ExtraWhitespace = { bg = "red", fg = "red" },
			Todo = { bg = "none", fg = "palette.blue" },
			WinSeparator = { bg = "palette.bg0", fg = "palette.bg0" },
			PmenuKind = { bg = "palette.sel0", fg = "palette.blue" },
			PmenuKindSel = { bg = "palette.sel1", fg = "palette.blue" },
			PmenuExtra = { bg = "palette.sel0", fg = "palette.fg2" },
			PmenuExtraSel = { bg = "palette.sel1", fg = "palette.fg2" },
			TabLine     = { bg = "palette.bg1", fg = "palette.fg2", gui = "none" },
			TabLineSel  = { bg = "palette.bg2", fg = "palette.fg1", gui = "none" },
			TabLineFill = { bg = "palette.bg0", fg = "palette.fg2", gui = "none" },
			SatelliteBar = { bg = "palette.bg4" },
			SatelliteCursor = { fg = "palette.fg2" },
			SatelliteQuickfix = { fg = "palette.fg0" },
		}
	}
})

vim.cmd("colorscheme carbonfox")

local p = require("nightfox.palette").load("carbonfox")

require("lualine").setup({
	options = {
		icons_enabled = false,
		section_separators = "",
		component_separators = "",
		refresh = { statusline = 100, tabline = 100, winbar = 100 },
		theme = {
			normal =   { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			insert =   { a = { bg = p.green.base,   fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			visual =   { a = { bg = p.magenta.dim,  fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			replace =  { a = { bg = p.red.base,     fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			command =  { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			terminal = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
			inactive = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg0, fg = p.fg2 }, c = { bg = p.bg0, fg = p.fg3 } },
		}
	},
	sections = {
		lualine_a = {{"mode", fmt = function(m) return m:sub(1,1) end}},
		lualine_b = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
		lualine_c = {"diff"},
		lualine_x = {{"diagnostics", sections={"error", "warn"}}},
		lualine_y = {"filetype"},
		lualine_z = {{"searchcount", maxcount=9999}, "progress", "location"},
	},
	inactive_sections = {
		lualine_a = {{"mode", fmt=function() return " " end}},
		lualine_b = {},
		lualine_c = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
		lualine_x = {{"diagnostics", sections={"error", "warn"}}},
		lualine_y = {},
		lualine_z = {}
	}
})

-- TODO(later): neogit

require("nvim-surround").setup({ move_cursor = false })

require("mini.align").setup({})

require("mini.completion").setup({
	set_vim_settings = false,
	window = { info = { border = { " ", "", "", " " } }, signature = { border = { " ", "", "", " " } } },
	lsp_completion = {
		process_items = function(items, base)
			items = require("mini.completion").default_process_items(items, base)
			local normalise_string = function(str, max)
				str = (str or ""):match("[!-~].*[!-~]") or ""
				return #str > max and vim.fn.strcharpart(str, 0, max-1).."…" or str..(" "):rep(max-#str)
			end
			for _, item in ipairs(items) do
				item.label = normalise_string(item.label, 40)
				item.detail = normalise_string(item.detail, 10)
				item.additionalTextEdits = {}
			end
			return items
		end
	}
})

require("mini.cursorword").setup({ delay = 0 })

require("mini.splitjoin").setup({ mappings = { toggle = "", join = "<leader>j", split = "<leader>J" } })

require("osc52").setup({ silent = true })

require("satellite").setup({
	winblend = 0,
	handlers = {
		cursor = { enable = false, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
		search = { enable = true },
		diagnostic = { enable = true, min_severity = vim.diagnostic.severity.WARN },
		gitsigns = { enable = false },
		marks = { enable = false }
	}
})

-- KEYBINDINGS --

vim.keymap.set("n", "<leader>", "")
-- Split lines at cursor, opposite of <s-j>
vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
-- Terminal shortcuts
vim.keymap.set("n", "<leader><return>", "<cmd>belowright split | terminal<cr>")
-- Open notes
vim.keymap.set("n", "<leader>n", "<cmd>lcd ~/Documents/notes | edit todo.txt<cr>")
vim.keymap.set("n", "<leader>N", "<cmd>lcd ~/Documents/notes | edit `=strftime('./journal/%Y/%m/%d.md')` | call mkdir(expand('%:h'), 'p')<cr>")
-- LSP
vim.keymap.set("n", "<leader><leader>", "<cmd>lua vim.lsp.buf.hover()<cr>")
vim.keymap.set("n", "<leader>k",        "<cmd>lua vim.lsp.buf.code_action()<cr>")
vim.keymap.set("n", "]e",               "<cmd>lua vim.diagnostic.goto_next()<cr>")
vim.keymap.set("n", "[e",               "<cmd>lua vim.diagnostic.goto_prev()<cr>")
vim.keymap.set("n", "<leader>e",        "<cmd>lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "<leader>E",        "<cmd>lua vim.diagnostic.setqflist()<cr>")
vim.keymap.set("n", "<leader>d",        "<cmd>lua vim.lsp.buf.definition()<cr>")
vim.keymap.set("n", "<leader>t",        "<cmd>lua vim.lsp.buf.type_definition()<cr>")
vim.keymap.set("n", "<leader>r",        "<cmd>lua vim.lsp.buf.references()<cr>")
-- Buffers
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>")
vim.keymap.set("n", "]b", "<cmd>bnext<cr>")
vim.keymap.set("n", "[B", "<cmd>bfirst<cr>")
vim.keymap.set("n", "]B", "<cmd>blast<cr>")
-- Files
vim.keymap.set("n", "[f", function() vim.cmd("edit "..select(1, prev_next_file())) end)
vim.keymap.set("n", "]f", function() vim.cmd("edit "..select(2, prev_next_file())) end)
vim.keymap.set("n", "[F", function() local cur, old = fullpath(); while cur ~= old do old = cur; cur, _ = prev_next_file(cur) end vim.cmd("edit "..cur) end)
vim.keymap.set("n", "]F", function() local cur, old = fullpath(); while cur ~= old do old = cur; _, cur = prev_next_file(cur) end vim.cmd("edit "..cur) end)
-- Quickfix
vim.keymap.set("n", "[c", "<cmd>cprevious<cr>")
vim.keymap.set("n", "]c", "<cmd>cnext<cr>")
vim.keymap.set("n", "[C", "<cmd>cfirst<cr>")
vim.keymap.set("n", "]C", "<cmd>clast<cr>")
-- Toggles
vim.keymap.set("n", "yo", "")
vim.keymap.set("n", "yot", "<cmd>set expandtab! expandtab?<cr>")
vim.keymap.set("n", "yow", "<cmd>set wrap! wrap?<cr>")
vim.keymap.set("n", "yon", "<cmd>set number! number?<cr>")
vim.keymap.set("n", "yor", "<cmd>set relativenumber! relativenumber?<cr>")
vim.keymap.set("n", "yoi", "<cmd>set ignorecase! ignorecase?<cr>")
vim.keymap.set("n", "yol", "<cmd>set list! list?<cr>")
vim.keymap.set("n", "yoz", "<cmd>set spell! spell?<cr>")
vim.keymap.set("n", "yod", "<cmd>if &diff | diffoff | else | diffthis | endif<cr>")
-- Signify
vim.keymap.set("n", "[d", "<plug>(signify-prev-hunk)")
vim.keymap.set("n", "]d", "<plug>(signify-next-hunk)")
vim.keymap.set("n", "[D", "9999<plug>(signify-prev-hunk)")
vim.keymap.set("n", "]D", "9999<plug>(signify-next-hunk)")
vim.keymap.set("n", "<leader>gd", "<cmd>SignifyHunkDiff<cr>")
vim.keymap.set("n", "<leader>gD", "<cmd>SignifyDiff!<cr>")
vim.keymap.set("n", "<leader>gr", "<cmd>SignifyHunkUndo<cr>")
-- Fzf
vim.keymap.set("n", "<leader><bs>", "<cmd>FzfLua resume<cr>")
vim.keymap.set("n", "<leader>f", "<cmd>FzfLua files cwd=%:p:h<cr>")
vim.keymap.set("n", "<leader>F", "<cmd>FzfLua files hidden=true<cr>")
vim.keymap.set("n", "<leader>o", "<cmd>FzfLua oldfiles cwd=%:p:h cwd_only=true<cr>")
vim.keymap.set("n", "<leader>O", "<cmd>FzfLua oldfiles<cr>")
vim.keymap.set("n", "<leader>s", "<cmd>FzfLua live_grep_native cwd=%:p:h<cr>")
vim.keymap.set("n", "<leader>S", "<cmd>FzfLua live_grep_native<cr>")
vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers cwd=%:p:h cwd_only=true<cr>")
vim.keymap.set("n", "<leader>B", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<leader>t", "<cmd>FzfLua grep cwd=%:p:h no_esc=true search=\\b(TODO|FIX(ME)?|BUG|TBD|XXX)(\\([^\\)]*\\))?:?<cr>")
vim.keymap.set("n", "<leader>T", "<cmd>FzfLua grep no_esc=true search=\\b(TODO|FIX(ME)?|BUG|TBD|XXX)(\\([^\\)]*\\))?:?<cr>")
vim.keymap.set("n", "<leader>l", "<cmd>FzfLua blines<cr>")
vim.keymap.set("n", "<leader>L", "<cmd>FzfLua lines<cr>")
vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua search_history<cr>")
vim.keymap.set("n", "<leader>m", "<cmd>FzfLua marks<cr>")
vim.keymap.set("n", "<leader>\"", "<cmd>FzfLua registers<cr>")
vim.keymap.set("n", "<leader>gg", "<cmd>FzfLua git_status<cr>")
vim.keymap.set("n", "<leader>gf", "<cmd>FzfLua git_files cwd=%:p:h only_cwd=true<cr>")
vim.keymap.set("n", "<leader>gF", "<cmd>FzfLua git_files<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>FzfLua git_bcommits<cr>")
vim.keymap.set("n", "<leader>gL", "<cmd>FzfLua git_commits<cr>")
vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>")
vim.keymap.set("n", "<leader>gt", "<cmd>FzfLua git_tags<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_stash<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>FzfLua helptags<cr>")
vim.keymap.set("n", "<leader>K", "<cmd>FzfLua manpages sections=ALL<cr>")
vim.keymap.set("n", "<leader>E", "<cmd>FzfLua lsp_workspace_diagnostics<cr>")
vim.keymap.set("n", "<leader>d", "<cmd>FzfLua lsp_definitions<cr>")
vim.keymap.set("n", "<leader>D", "<cmd>FzfLua lsp_type_definitions<cr>")
vim.keymap.set("n", "<leader>r", "<cmd>FzfLua lsp_finder<cr>")
vim.keymap.set("n", "<leader>R", "<cmd>FzfLua lsp_document_symbols<cr>")
vim.keymap.set("n", "<leader>c", "<cmd>FzfLua quickfix<cr>")
vim.keymap.set("n", "<leader>C", "<cmd>FzfLua quickfix_stack<cr>")
vim.keymap.set("n", "<leader>a", function() local hits, more = get_altfiles() if #hits==1 then vim.cmd("edit "..hits[1]) else fzf_altfiles(hits, more) end end)
vim.keymap.set("n", "<leader>A", function() local hits, more = get_altfiles() fzf_altfiles(hits, more) end)
vim.keymap.set("n", "<leader>u", fzf_undotree)
vim.keymap.set("n", "<leader>U", "<cmd>FzfLua changes<cr>")
vim.keymap.set("n", "<leader>p", fzf_projects)
vim.keymap.set("n", "<leader>P", fzf_projects_save)
vim.keymap.set("n", "z=", "<cmd>FzfLua spell_suggest<cr>")
vim.keymap.set("n", "-", fzf_directories)

-- Arista-specifics switch
if vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and vim.fn.getcwd():find("^/src") then
	vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})
	vim.fn.chdir("/src")
	vim.opt.shiftwidth = 3
	vim.opt.tabstop = 3
	vim.opt.expandtab = true
	vim.opt.colorcolumn = "86"
	vim.cmd[[
	let a4_auto_edit = 0
	source /usr/share/vim/vimfiles/arista.vim
	function! TaccIndentOverrides()
		let prevLine = getline(SkipTaccBlanksAndComments(v:lnum - 1))
		if prevLine =~# 'Tac::Namespace\s*{\s*$' | return 0 | endif
		return GetTaccIndent()
	endfunction
	augroup vimrc
	autocmd BufNewFile,BufRead *.tac setlocal indentexpr=TaccIndentOverrides()
	]]
	-- File search
	vim.keymap.set("n", "<leader>f", "<cmd>FzfLua files cwd=%:p:h<cr>")
	vim.keymap.set("n", "<leader>F", "<cmd>FzfLua files hidden=true<cr>")
	-- Agrok
	vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                 { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
	vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(fullpath():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
	-- Agid
	vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
	vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                 { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
	vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(fullpath():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
	vim.keymap.set("n", "<leader>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
	vim.keymap.set("n", "<leader>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
	vim.keymap.set("n", "<leader>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
	vim.keymap.set("n", "<leader>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
end
