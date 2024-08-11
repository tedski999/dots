-- Arista-specifics switch
if vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and vim.fn.getcwd():find("^/src") then
  vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})
  vim.g.arista = true
  vim.fn.chdir("/src")
end

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

-- Provide method to apply ftplugin and syntax settings to all filetypes
-- TODO(later): still used? maybe for snippets and arista .tac syntax
-- vim.g.myfiletypefile = vim.fn.stdpath("config").."/ftplugin/ftplugin.vim"
-- vim.g.mysyntaxfile = vim.fn.stdpath("config").."/syntax/syntax.vim"

vim.filetype.add({ pattern = { [vim.fn.stdpath("data").."/projects/.*"] = "vim" } })

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
vim.opt.tabstop = 4                                    -- 4-spaced tabs
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

local ts_pickers = require("telescope.pickers")
local ts_finders = require("telescope.finders")
local ts_conf = require("telescope.config").values
local ts_actions = require("telescope.actions")
local ts_actions_set = require("telescope.actions.set")
local ts_actions_state = require("telescope.actions.state")
local ts_actions_layout = require("telescope.actions.layout")

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

-- Load projects using mksession
local function ts_projects(opts)
  local projects = {}
  for path in vim.fn.glob(vim.fn.stdpath("data").."/projects/*"):gmatch("[^\n]+") do
    projects[#projects + 1] = path
  end
  ts_pickers.new(opts or {}, {
    prompt_title = "Projects",
    finder = ts_finders.new_table({
      results = projects,
      entry_maker = function(line) return { value = line, display = line:match("[^/]*$"), ordinal = line } end
    }),
    sorter = ts_conf.generic_sorter(opts or {}),
    previewer = ts_conf.file_previewer(opts or {}),
    attach_mappings = function(prompt_bufnr, map)
      ts_actions_set.select:replace(function()
        ts_actions.close(prompt_bufnr)
        vim.cmd("source "..ts_actions_state.get_selected_entry().value)
      end)
      map("i", "<C-e>", ts_actions.file_edit)
      map("i", "<C-x>", function() end) --  TODO(later): function(s) for i = 1, #s do vim.fn.delete(s[i]) end end
      return true
    end,
  }):find()
end

local function ts_toggle_fullscreen(prompt_bufnr)
  local height = { padding = 0 }
  local picker = ts_actions_state.get_current_picker(prompt_bufnr)
  if picker.layout_config[picker.__flex_strategy].height ~= 15 then height = 15 end
  picker.layout_config.horizontal.height = height
  picker.layout_config.vertical.height = height
  picker:full_layout_update()
end

local function ts_yank_values(prompt_bufnr)
  local picker = ts_actions_state.get_current_picker(prompt_bufnr)
  local entries = picker:get_multi_selection()
  if #entries == 0 then entries[1] = picker:get_selection() end
  for k, v in pairs(entries) do entries[k] = v.value end
  vim.fn.setreg("+", table.concat(entries, "\n"))
  print("Values yanked: "..tostring(#entries))
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

-- PLUGIN INITIALISATION --

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

require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    scroll_strategy = "limit",
    path_display = { "truncate" },
    dynamic_preview_title = true,
    borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
    cache_picker = { num_pickers = 3, ignore_empty_prompt = true },
    layout_strategy = "flex",
    layout_config = {
        anchor = "S",
        anchor_padding = -1,
        prompt_position = "top",
        height = 15,
        width = { padding = 0 },
        flex = { flip_columns = 100 },
        vertical = { mirror = true, preview_cutoff = 20 },
        horizontal = { preview_cutoff = 20 },
    },
    mappings = {
      i = {
        ["<esc>"] = ts_actions.close,
        ["<C-j>"] = ts_actions.select_default,
        ["<M-o>"] = ts_actions_layout.toggle_preview,
        ["<C-o>"] = ts_toggle_fullscreen,
        ["<C-y>"] = ts_yank_values,
      }
    },
    preview = { filesize_limit = 1.0 },
  },
  extensions = {
    file_browser = {
      hijack_netrw = true,
      dir_icon = "",
      hidden = { file_browser = true, folder_browser = true },
    },
    undo = {
      side_by_side = true,
      layout_strategy = "vertical",
      layout_config = { height = { padding = 0 } },
    },
  },
})

require("telescope").load_extension("file_browser")
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("undo")

-- KEYBINDINGS --

vim.keymap.set("n", "<leader>", "")
-- Split lines at cursor, opposite of <s-j>
vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
-- Terminal shortcuts
vim.keymap.set("n", "<leader><return>", "<cmd>belowright split | terminal<cr>")
-- Open notes
vim.keymap.set("n", "<leader>n", "<cmd>lcd ~/Documents/notes | enew | set filetype=markdown<cr>")
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
-- Telescope
vim.keymap.set("n", "z=", "<cmd>Telescope spell_suggest<cr>")
vim.keymap.set("n", "-", "<cmd>Telescope file_browser<cr>")
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files cwd=%:p:h hidden=true<cr>")
vim.keymap.set("n", "<leader>F", "<cmd>Telescope find_files hidden=true<cr>")
vim.keymap.set("n", "<leader>o", "<cmd>Telescope oldfiles cwd=%:p:h only_cwd=true<cr>")
vim.keymap.set("n", "<leader>O", "<cmd>Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>s", "<cmd>Telescope live_grep cwd=%:p:h<cr>")
vim.keymap.set("n", "<leader>S", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>t", "<cmd>Telescope tags<cr>")
vim.keymap.set("n", "<leader>l", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
vim.keymap.set("n", "<leader>L", "<cmd>Telescope live_grep cwd=%:p:h grep_open_files=true<cr>")
vim.keymap.set("n", "<leader>:", "<cmd>Telescope command_history<cr>")
vim.keymap.set("n", "<leader>m", "<cmd>Telescope marks")
vim.keymap.set("n", "<leader>\"", "<cmd>Telescope registers<cr>")
vim.keymap.set("n", "<leader>gg", "<cmd>Telescope git_status cwd=%:p:h use_git_root=false<cr>")
vim.keymap.set("n", "<leader>gG", "<cmd>Telescope git_status<cr>")
vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_files cwd=%:p:h use_git_root=false<cr>")
vim.keymap.set("n", "<leader>gF", "<cmd>Telescope git_files<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>Telescope git_bcommits cwd=%:p:h use_git_root=false<cr>")
vim.keymap.set("n", "<leader>gL", "<cmd>Telescope git_commits<cr>")
vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_stash<cr>")
vim.keymap.set("n", "<leader>k", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>K", "<cmd>Telescope man_pages sections=ALL<cr>")
vim.keymap.set("n", "<leader>E", "<cmd>Telescope diagnostics<cr>")
vim.keymap.set("n", "<leader>d", "<cmd>Telescope lsp_definitions<cr>")
vim.keymap.set("n", "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>")
vim.keymap.set("n", "<leader>r", "<cmd>Telescope lsp_references<cr>")
vim.keymap.set("n", "<leader>R", "<cmd>Telescope lsp_document_symbols<cr>") -- TODO(lsp): {dynamic_}workspace_symbols
vim.keymap.set("n", "<leader>c", "<cmd>Telescope quickfix<cr>")
vim.keymap.set("n", "<leader>C", "<cmd>Telescope quickfixhistory<cr>")
vim.keymap.set("n", "<leader>/", "<cmd>Telescope search_history<cr>")
-- TODO
--vim.keymap.set("n", "<leader>A", "LinArcX/telescope-changes.nvim"
--vim.keymap.set("n", "<leader>a", fzf_find_altfiles) "otavioschwanck/telescope-alternate"
-- local altfile_map = {
--   [".c"] = { ".h", ".hpp", ".tin" },
--   [".h"] = { ".c", ".cpp", ".tac" },
--   [".cpp"] = { ".hpp", ".h", ".tin" },
--   [".hpp"] = { ".cpp", ".c", ".tac" },
--   [".vert.glsl"] = { ".frag.glsl" },
--   [".frag.glsl"] = { ".vert.glsl" },
--   [".tac"] = { ".tin", ".cpp", ".c" },
--   [".tin"] = { ".tac", ".hpp", ".h" }
-- }
vim.keymap.set("n", "<leader>p", ts_projects)
vim.keymap.set("n", "<leader>P", function()
  local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
  if project == "" then return end
  vim.fn.mkdir(vim.fn.stdpath("data").."/projects/", "p")
  vim.cmd("mksession! "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..project))
end)
vim.keymap.set("n", "<leader><esc>", "<cmd>Telescope resume<cr>")
vim.keymap.set("n", "<leader><s-esc>", "<cmd>Telescope pickers<cr>")

vim.cmd("colorscheme carbonfox")


-- TODO(work): cached find_files
-- TODO(work): agid/agrok? or just supercharged grep
-- TODO(work): arista.vim needed?

-- if vim.g.arista then
--   -- Perforce
--   vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\\//]],                                              { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
--   vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
--   vim.keymap.set("n", "<leader>gs", "<cmd>Achanged<cr>")
--   vim.keymap.set("n", "<leader>go", "<cmd>Aopened<cr>")
--   -- Opengrok
--   vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
--   vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(fullpath():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
--   -- Agid
--   vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
--   vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
--   vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(fullpath():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
--   vim.keymap.set("n", "<leader>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
--   vim.keymap.set("n", "<leader>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
--   vim.keymap.set("n", "<leader>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
--   vim.keymap.set("n", "<leader>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })

--   local vcs_cmds = vim.g.signify_vcs_cmds or {}
--   local vcs_cmds_diffmode = vim.g.signify_vcs_cmds_diffmode or {}
--   vcs_cmds.perforce = "env P4DIFF= P4COLORS= a p4 diff -du 0 %f"
--   vcs_cmds_diffmode.perforce = "a p4 print %f"
--   vim.g.signify_vcs_cmds = vcs_cmds
--   vim.g.signify_vcs_cmds_diffmode = vcs_cmds_diffmode

--   -- Source arista.vim but override A4edit and A4revert
--   -- TODO(work): still needed?
--   vim.cmd([[
--     let g:a4_auto_edit = 0
--     source /usr/share/vim/vimfiles/arista.vim
--     function! A4edit()
--       if strlen(glob(expand('%')))
--         belowright split
--         exec 'terminal a p4 login && a p4 edit '.shellescape(expand('%:p'))
--       endif
--     endfunction
--     function! A4revert()
--       if strlen(glob(expand('%'))) && confirm('Revert Perforce file changes?', '&Yes\n&No', 1) == 1
--         exec 'terminal a p4 login && a p4 revert '.shellescape(expand('%:p'))
--         set readonly
--       endif
--     endfunction
--   ]])
--   vim.api.nvim_create_user_command("Aedit", "call A4edit()", {})
--   vim.api.nvim_create_user_command("Arevert", "call A4revert()", {})
-- end
