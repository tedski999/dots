local o = vim.opt

o.title = true                                   -- Update window title
o.mouse = "a"                                    -- Enable mouse support
o.updatetime = 100                               -- Faster refreshing
o.timeoutlen = 5000                              -- 5 seconds to complete mapping
o.clipboard = "unnamedplus"                      -- Use system clipboard
o.undofile = true                                -- Write undo history to disk
o.swapfile = false                               -- No need for swap files
o.modeline = false                               -- Don't read mode line
o.virtualedit = "onemore"                        -- Allow cursor to extend one character past the end of the line
o.grepprg = "rg --vimgrep --smart-case --follow" -- Use ripgrep for grepping
o.number = true                                  -- Enable line numbers...
o.relativenumber = true                          -- ...and relative line numbers
o.ruler = false                                  -- No need to show line/column number with lightline
o.showmode = false                               -- No need to show current mode with lightline
o.scrolloff = 3                                  -- Keep lines above/below the cursor when scrolling
o.sidescrolloff = 5                              -- Keep columns to the left/right of the cursor when scrolling
o.signcolumn = "no"                              -- Keep the sign column closed
o.shortmess:append("sIcC")                       -- Be quieter
o.expandtab = false                              -- Tab key inserts tabs
o.tabstop = 4                                    -- 4-spaced tabs
o.shiftwidth = 0                                 -- Tab-spaced indentation
o.cinoptions = "N-s"                             -- Don't indent C++ namespaces
o.list = true                                    -- Enable whitespace characters below
o.listchars="space:·,tab:› ,trail:•,precedes:<,extends:>,nbsp:␣"
o.suffixes:remove(".h")                          -- Header files are important...
o.suffixes:append(".git")                        -- ...but .git files are not
o.foldmethod = "indent"                          -- Fold based on indent
o.foldlevelstart = 20                            -- ...and start with everything open
o.wrap = false                                   -- Don't wrap
o.lazyredraw = true                              -- Redraw only after commands have completed
o.termguicolors = true                           -- Enable true colors and gui cursor
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400"
o.ignorecase = true                              -- Ignore case when searching...
o.smartcase = true                               -- ...except for searching with uppercase characters
o.complete = ".,w,kspell"                        -- Complete menu contents
o.completeopt = "menu,menuone,noinsert,noselect" -- Complete menu functionality
o.pumheight = 8                                  -- Limit complete menu height
o.spell = true                                   -- Enable spelling by default
o.spelloptions = "camel"                         -- Enable CamelCase word spelling
o.spellsuggest = "best,20"                       -- Only show best spelling corrections
o.spellcapcheck = ""                             -- Don't care about capitalisation
o.dictionary = "/usr/share/dict/words"           -- Dictionary file
o.shada = "!,'256,<50,s100,h,r/media"            -- Specify removable media for shada
o.undolevels = 2048                              -- More undo space
o.hidden = false                                 -- Don't let modified buffers hide
o.wildmode = "longest:full,full"                 -- Match common and show wildmenu
o.wildoptions = "fuzzy,pum"                      -- Wildmenu fuzzy matching and ins-completion menu
o.wildignorecase = true                          -- Don't care about wildmenu file capitalisation

-- Arista is a bit weird like that
if vim.g.arista then
	o.shiftwidth = 3
	o.tabstop = 3
	o.expandtab = true
end
