let mapleader = ' '

" Ensure plug.vim is installed
let plug_vim = stdpath('data').'/site/autoload/plug.vim'
if !filereadable(plug_vim)
	silent exe '!curl -fLo '.plug_vim.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	silent exe 'source '.plug_vim
endif

" TODO: look into mini.nvim
call plug#begin()
Plug 'whatyouhide/vim-gotham'                       " Colorscheme
Plug 'tpope/vim-repeat'                             " tpope period-repeat
Plug 'tpope/vim-vinegar'                            " Better file browsing *
Plug 'tpope/vim-surround'                           " Surround motion
Plug 'tpope/vim-unimpaired'                         " More bracket mappings *reimplement
"Plug 'tpope/vim-fugitive'                           " Git integration
Plug 'mhinz/vim-signify'                            " Git changes *
Plug 'tommcdo/vim-lion'                             " Text aligning *replaced?
Plug 'ojroques/vim-oscyank'                         " OSC52 yank *reimplement?
Plug 'numToStr/Comment.nvim'                        " Comment keybinding
Plug 'mbbill/undotree'                              " Visualised undo tree *fix
Plug 'ggandor/leap.nvim'                            " Better mid-range movement
Plug 'junegunn/fzf.vim'                             " FZF shortcuts *
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Install FZF *needed?
Plug 'nvim-lualine/lualine.nvim'                    " Status bar *
Plug 'sheerun/vim-polyglot'                         " Language packs
Plug 'neovim/nvim-lspconfig'                        " LSP client
Plug 'hrsh7th/vim-vsnip'                            " Snippets engine
Plug 'hrsh7th/nvim-cmp'                             " Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'                         " LSP completion source
Plug 'hrsh7th/cmp-buffer'                           " Buffer completion source
Plug 'hrsh7th/cmp-path'                             " Path completion source
Plug 'hrsh7th/cmp-cmdline'                          " Cmd completion source
Plug 'hrsh7th/cmp-vsnip'                            " Snippets completion source
Plug 'ray-x/lsp_signature.nvim'                     " Function signature
Plug 'ojroques/nvim-lspfuzzy'                       " Use FZF for LSP results
call plug#end()

" Ensure plugins are installed
if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
	PlugInstall --sync
	echo 'Neovim must be restarted. Press any key to quit...'
	call getchar() | qall!
endif

" Set the colorscheme and extra highlights
colorscheme gotham
highlight Folded guibg=NONE guifg=#888ca6
highlight SpellBad guibg=NONE guifg=NONE gui=undercurl guisp=red
highlight SpellCap guibg=NONE guifg=NONE gui=undercurl guisp=blue
highlight SpellRare guibg=NONE guifg=NONE gui=undercurl guisp=purple
highlight SpellLocal guibg=NONE guifg=NONE gui=undercurl guisp=yellow
highlight CmpItemAbbrMatch gui=bold guifg=#569cd6
highlight SignifySignAdd    guifg=#2aa889 guibg=#11151c
highlight SignifySignChange guifg=#d26937 guibg=#11151c
highlight SignifySignDelete guifg=#c23127 guibg=#11151c
highlight LspReferenceText gui=bold
highlight LspReferenceRead gui=bold
highlight LspReferenceWrite gui=bold

" Try dots repo as git alternative
let dotsrepo = '--git-dir=$HOME/.local/dots --work-tree=$HOME'
let g:signify_vcs_cmds = { 'git': 'git diff --no-color --no-ext-diff -U0 -- %f || git '.dotsrepo.' diff --no-color --no-ext-diff -U0 -- %f' }
let g:signify_vcs_cmds_diffmode = { 'git': 'git show HEAD:./%f || git '.dotsrepo.' show HEAD:./%f' }
let g:signify_number_highlight = 1

" Use , and . to align text by a deliminator
let lion_map_left = '<leader>,'
let lion_map_right = '<leader>.'
let lion_squeeze_spaces = 1

" Throw yank straight to local terminal using OSC52
let g:oscyank_trim = v:false
let g:oscyank_silent = v:true

" Visualise the undo history tree
let undotree_ShortIndicators = 1
let undotree_SetFocusWhenToggle = 1
let undotree_TreeNodeShape = '┼'
let undotree_TreeVertShape = '│'
let undotree_TreeSplitShape = '⡐'
let undotree_TreeReturnShape = '⠢'
let undotree_DiffAutoOpen = 0
let undotree_HelpLine = 0

" FZF for fuzzy searching files, lines, help tags and man pages
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9, 'border': 'sharp' } }
let g:fzf_action = { 'ctrl-t': 'tab split', 'ctrl-s': 'split', 'ctrl-v': 'vsplit' }

" Snippets location
let g:vsnip_snippet_dir = stdpath('config').'/snippets'

lua << EOF

-- A better status bar
require('lualine').setup({
	options = {
		icons_enabled = false,
		section_separators = '',
		component_separators = '',
		refresh = {statusline=100, tabline=100, winbar=100},
		theme = {
			normal =   {a={bg='#195466', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			insert =   {a={bg='#009368', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			visual =   {a={bg='#cb6635', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			replace =  {a={bg='#c23127', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			command =  {a={bg='#62477c', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			terminal = {a={bg='#111a23', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}},
			inactive = {a={bg='#111a23', fg='#d3ebe9', gui='bold'}, b={bg='#0a3749', fg='#99d1ce'}, c={bg='#111a23', fg='#599cab'}}
		}
	},
	sections = {
		lualine_a = {{'mode', fmt=function(mode) return mode:sub(1,1) end}},
		lualine_b = {{'filename', symbols={modified='*', readonly='-'}}},
		lualine_c = {'diff'},
		lualine_x = {{'diagnostics', sections={'error', 'warn'}}},
		lualine_y = {'filetype'},
		lualine_z = {'progress', 'location'},
	},
	inactive_sections = {
		lualine_a = {{'mode', fmt=function() return ' ' end}},
		lualine_b = {},
		lualine_c = {{'filename', symbols={modified='*', readonly='-'}}, 'diff'},
		lualine_x = {{'diagnostics', sections={'error', 'warn'}}},
		lualine_y = {},
		lualine_z = {}
	}
})

-- Commenting
require('Comment').setup({})

-- Leaping
local leap = require('leap')
leap.opts.safe_labels = {}
vim.api.nvim_set_hl(0, 'LeapBackdrop', { fg = 'grey', bg = '' })
vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = 'red', bg = '' })
vim.api.nvim_set_hl(0, 'LeapLabelSecondary', { fg = 'white', bg = '' })
vim.keymap.set({'n', 'x', 'o'}, '<leader>j', '<Plug>(leap-forward-to)')
vim.keymap.set({'n', 'x', 'o'}, '<leader><s-j>', '<Plug>(leap-backward-to)')

-- Autocompletion
local cmp = require('cmp')
local cmpmap = {
	['<c-j>'] = cmp.mapping(cmp.mapping.confirm({select=true}), { 'i', 's', 'c' }),
	['<c-n>'] = cmp.mapping(function() if not cmp.select_next_item() then cmp.complete() end end, { 'i', 's', 'c' }),
	['<c-p>'] = cmp.mapping(function() if not cmp.select_prev_item() then cmp.complete() end end, { 'i', 's', 'c' }),
}
cmp.setup({
	mapping = cmpmap,
	sources = cmp.config.sources({{name='nvim_lsp'},{name='vsnip'}},{{name='path'},{name='buffer'}}),
	snippet = { expand = function(args) vim.fn['vsnip#anonymous'](args.body) end },
	view = { entries = { name = 'custom', selection_order = 'near_cursor' } },
	completion = { completeopt = "menu,menuone,preview" },
	experimental = { ghost_text = true },
	formatting = {
		format = function(_, item)
			item.abbr = #item.abbr > 50 and vim.fn.strcharpart(item.abbr, 0, 49)..'…' or item.abbr..(' '):rep(50-#item.abbr)
			item.kind = ({
				Text = '""',     Method = '.f', Function = 'fn',  Constructor = '()', Field = '.x',
				Variable = 'xy', Class = '{}',  Interface = '{}', Module = '[]',      Property = '.p',
				Unit = '$$',     Value = '00',  Enum = '∀e',      Keyword = ';;',     Snippet = '~~',
				Color = 'rgb',   File = '/.',   Reference = '&x', Folder = '//',      EnumMember = '∃e',
				Constant = '#x', Struct = '{}', Event = 'ev',     Operator = '++',    TypeParameter = '<>'
			})[item.kind]
			return item
		end
	}
})
cmp.setup.cmdline({'/','?'}, { mapping = cmpmap, sources = cmp.config.sources({{name='buffer'}}) })
cmp.setup.cmdline(':', { mapping = cmpmap, sources = cmp.config.sources({{name='path'}}, {{name='cmdline'}}) })

-- LSP server configs
local lsp = require('lspconfig')
lsp.util.on_setup = lsp.util.add_hook_before(lsp.util.on_setup, function(cfg)
	cfg.capabilities = require('cmp_nvim_lsp').default_capabilities()
	cfg.on_attach = function(client, bufnr)
		if client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_autocmd('CursorMoved', {buffer=bufnr, callback=vim.lsp.buf.clear_references})
			vim.api.nvim_create_autocmd('CursorMoved', {buffer=bufnr, callback=vim.lsp.buf.document_highlight})
		end
	end
end)
lsp.clangd.setup({})
lsp.pylsp.setup({})
lsp.rust_analyzer.setup({
	cmd = {'rustup', 'run', 'stable', 'rust-analyzer'},
	settings = { ['rust-analyzer'] = { checkOnSave = { overrideCommand = { 'cargo', 'clippy', '--workspace', '--message-format=json', '--all-targets', '--all-features' } } } }
})

-- LSP function signatures
-- TODO: this seems like very simple usage, roll own handler?
require('lsp_signature').setup({ floating_window = false, hint_prefix = '' })

-- FZF LSP results
-- TODO: replace
require('lspfuzzy').setup({ jump_one = false })
local function lsphandler(err, result, ctx, config)
	if err then return vim.cmd('echohl ErrorMsg | echom "'..err.message..'" | echohl None') end
	vim.cmd('call fzf#run(fzf#vim#with_preview(fzf#wrap({\'source\': '..result..' })))')
	--vim.c['fzf#run'](vim.fn['fzf#vim#with_preview'](vim.fn['fzf#wrap']({source = result})))
	-- result = vim.tbl_islist(result) and result or {result}
	-- local items = vim.lsp.util.locations_to_items(result, offset_encoding)
	-- local source = vim.tbl_map(lsp_to_fzf, items)
	-- fzf(source, label, jump, true, true)
end
--vim.lsp.handlers['textDocument/references'] = lsphandler

EOF

" Settings
set title                                         " Update window title
set mouse=a                                       " Enable mouse support
set updatetime=100                                " Faster refreshing
set timeoutlen=5000                               " 5 seconds to complete mapping
set clipboard=unnamedplus                         " Use system clipboard
set undofile                                      " Write undo history to disk
set noswapfile                                    " No need for swap files
set nomodeline                                    " Don't read mode line
set virtualedit=onemore                           " Allow cursor to extend one character past the end of the line
set grepprg=rg\ --vimgrep\ --smart-case\ --follow " Use ripgrep for grepping
set number                                        " Enable line numbers...
set cursorline                                    " Highlight current line...
set cursorcolumn                                  " ...and column
set noruler                                       " No need to show line/column number with lightline
set noshowmode                                    " No need to show current mode with lightline
set scrolloff=3                                   " Keep lines above/below the cursor when scrolling
set sidescrolloff=5                               " Keep columns to the left/right of the cursor when scrolling
set signcolumn=no                                 " Keep the sign column closed
set shortmess+=sIc                                " Be quieter
set noexpandtab                                   " Tab key inserts tabs
set tabstop=4                                     " 4-spaced tabs
set shiftwidth=0                                  " Tab-spaced indentation
set cinoptions=N-s                                " Don't indent C++ namespaces
set list                                          " Enable whitespace characters below
set listchars=space:·,tab:›\ ,trail:•,precedes:<,extends:>,nbsp:␣
set suffixes-=.h                                  " Header files are important...
set suffixes+=.git                                " ...but .git files are not
set foldmethod=indent                             " Fold based on indent
set foldlevelstart=20                             " ...and start with everything open
set nowrap                                        " Don't wrap
set lazyredraw                                    " Redraw only after commands have completed
set termguicolors                                 " Enable true colors
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400
set ignorecase                                    " Ignore case when searching...
set smartcase                                     " ...except for searching with uppercase characters
set pumheight=8                                   " Limit complete menu height
set spell                                         " Enable spelling by default
set spelloptions=camel                            " Enable CamelCase word spelling
set spellsuggest=best,20                          " Only show best spelling corrections
set shada=!,'50,<50,s100,h,r/media                " Specify removable media for shada

" Highlight trailing whitespace
match Error /\s\+$/

" Switch to alternative file based on provided extensions
function! AltFile(exts)
	let files = map(split(a:exts, ','), 'expand("%:p:r:r:r:r").".".v:val')
	for file in files | if filereadable(file) | edit `=file` | return | endif | endfor
	edit `=files[0]`
endfunction

augroup vimrc
autocmd!
" Highlight on yank
autocmd TextYankPost * lua vim.highlight.on_yank({higroup='Visual', timeout=150})
" Yank with OSC52
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | exe 'OSCYankRegister "' | endif
" Comment formatting
autocmd BufEnter * set formatoptions-=c formatoptions-=o
" Restore cursor position when opening buffers
autocmd BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 0 && line("'\"") <= line('$') | exe 'normal! g`"' | endif
" Switch between alternative files
autocmd BufEnter *.c,*.cpp nnoremap <leader>a <cmd>call AltFile('h,hpp')<cr>
autocmd BufEnter *.h,*.hpp nnoremap <leader>a <cmd>call AltFile('c,cpp')<cr>
autocmd BufEnter *.vert.glsl nnoremap <leader>a <cmd>call AltFile('frag.glsl')<cr>
autocmd BufEnter *.frag.glsl nnoremap <leader>a <cmd>call AltFile('vert.glsl')<cr>
augroup END

nnoremap Q nop
" Don't jump over wrapped lines with j and k
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
" Handy buffer shortcuts
nnoremap <nowait> <leader>w <cmd>w<cr>
nnoremap <nowait> <leader>W <cmd>wq<cr>
nnoremap <nowait> <leader>q <cmd>q<cr>
nnoremap <nowait> <leader>Q <cmd>q!<cr>
" Disable cmdline tab completion
cnoremap <tab> <tab>
cnoremap <s-tab> <s-tab>
" Terminal
nnoremap <leader><return> <cmd>exec 'terminal' \| startinsert<cr>
tnoremap <expr> <esc> (&filetype == "fzf") ? "<esc>" : "<c-\><c-n>"
" Open config
nnoremap <leader>c <cmd>edit $MYVIMRC<cr>
" Search and replace
nnoremap <leader>R *:%s///gcI<left><left><left><left>
" Split lines at cursor, opposite of <s-j>
nnoremap <c-j> m`i<cr><esc>``
" Git
nnoremap <leader>gd <cmd>SignifyHunkDiff<cr>
" Undotree
nnoremap <leader>u <cmd>UndotreeToggle<cr>
" Open notes
nnoremap <leader>n <cmd>lcd ~/Documents/notes \| enew \| set filetype=markdown<cr>
nnoremap <leader>N <cmd>lcd ~/Documents/notes \| edit `=strftime('./journal/%Y/%V.md')` \| call mkdir(expand('%:h'), 'p')<cr>
" FZF search
nnoremap <leader>b <cmd>Buffers<cr>
nnoremap <leader>l <cmd>Lines<cr>
nnoremap <leader>f <cmd>Files %:p:h<cr>
nnoremap <leader>F <cmd>Files<cr>
nnoremap <leader>s <cmd>call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case ""', 1, fzf#vim#with_preview({'dir': expand('%:p:h')}))<cr>
nnoremap <leader>S <cmd>Rg<cr>
nnoremap <leader>h <cmd>Helptags<cr>
nnoremap <leader>m <cmd>call fzf#run(fzf#wrap({'source': 'man -k "" \| cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', 'man {}']}))<cr>
nnoremap <leader>o <cmd>History<cr>
" LSP
nnoremap <leader><leader> <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <leader>k <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap ]e <cmd>lua vim.diagnostic.goto_next()<cr>
nnoremap [e <cmd>lua vim.diagnostic.goto_prev()<cr>
nnoremap <leader>e <cmd>lua vim.diagnostic.open_float()<cr>
nnoremap <leader>E <cmd>lua vim.diagnostic.setqflist()<cr>
nnoremap <leader>d <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <leader>t <cmd>lua vim.lsp.buf.type_definition()<cr>
nnoremap <leader>r <cmd>lua vim.lsp.buf.references()<cr>
vnoremap <leader>f <esc><cmd>lua vim.lsp.buf.range_formatting()<cr>
" Snippets
inoremap <expr> <tab>   vsnip#jumpable(+1) ? '<Plug>(vsnip-jump-next)' : '<tab>'
snoremap <expr> <tab>   vsnip#jumpable(+1) ? '<Plug>(vsnip-jump-next)' : '<tab>'
inoremap <expr> <s-tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<s-tab>'
snoremap <expr> <s-tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<s-tab>'

" Arista-specifics if in /src directory
if getcwd() =~# '^/src\(/\|$\)' && filereadable('/usr/share/vim/vimfiles/arista.vim')
	echohl MoreMsg | echo 'Arista-specifics enabled!' | echohl None
	chdir /src
	" Include Arista config
	let a4_auto_edit = 0
	source /usr/share/vim/vimfiles/arista.vim
	" Override A4edit and A4revert
	function! A4edit()
		if strlen(glob(expand("%")))
			belowright split
			exec 'terminal a p4 login && a p4 edit '.shellescape(expand('%:p'))
			set noreadonly
		endif
	endfunction
	function! A4revert()
		if strlen(glob(expand("%"))) && confirm("Revert Perforce file changes?", "&Yes\n&No", 1) == 1
			exec 'terminal a p4 login && a p4 revert '.shellescape(expand('%:p'))
			set readonly
		endif
	endfunction
	" 85-column width
	highlight! link ColorColumn CursorColumn
	let &colorcolumn=join(range(86,999),',')
	" In-house VCS based on Perforce
	let g:signify_vcs_cmds = { 'perforce': 'env P4DIFF= P4COLORS= a p4 diff -du 0 %f' }
	let g:signify_vcs_cmds_diffmode = { 'perforce': 'a p4 print %f' }
	let g:signify_skip = { 'vcs': { 'allow': ['perforce'] } }
	" TODO: generalise some of these non-arista as well with git
	command! Achanged call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': 'a p4 diff --summary | sed "s/^/\//"'})))
	command! Aopened let o = system('a p4 opened') | if o != '' | echo o | else | echo 'Nothing opened' | endif
	command! Aedit call A4edit()
	command! Arevert call A4revert()
	nnoremap <leader>gg <cmd>Achanged<cr>
	nnoremap <leader>go <cmd>Aopened<cr>
	nnoremap <leader>ge <cmd>Aedit<cr>
	nnoremap <leader>gr <cmd>Arevert<cr>
	" Fix TACC indentation
	function! TaccIndentOverrides()
		let prevLine = getline(SkipTaccBlanksAndComments(v:lnum - 1))
		if prevLine =~# 'Tac::Namespace\s*{\s*$' | return 0 | endif
		return GetTaccIndent()
	endfunction
	augroup vimrc
	autocmd BufNewFile,BufRead *.tac setlocal indentexpr=TaccIndentOverrides()
	" Switch between tac and tin files
	autocmd BufEnter *.tin nnoremap <leader>a <cmd>call AltFile('tac,h,hpp')<cr>
	autocmd BufEnter *.tac nnoremap <leader>a <cmd>call AltFile('tin,c,cpp')<cr>
	" Polyglot breaks tacc filetype detection so here's a fix
	autocmd BufNewFile,BufRead *.tin set filetype=cpp
	autocmd BufNewFile,BufRead *.tac set filetype=tac
	augroup filetypedetect
	autocmd! BufNewFile,BufRead *.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.tac,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript setf foo
	autocmd! BufNewFile,BufRead *.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript setf python
	augroup END
	" OpenGrok search
	command! -nargs=1 Agrok  call fzf#vim#grep('a grok -em 99                                                   '.shellescape(<q-args>).' | grep "^/src/.*"', 1, fzf#vim#with_preview({'options':['--prompt','Grok>']}))
	command! -nargs=1 AgrokP call fzf#vim#grep('a grok -em 99 -f '.join(split(expand('%:p:h'), '/')[:1], '/').' '.shellescape(<q-args>).' | grep "^/src/.*"', 1, fzf#vim#with_preview({'options':['--prompt','Grok>']}))
	" Agid
	command! Amkid belowright split | terminal echo "Generating ID file..." && a ws mkid
	command! -nargs=1 Agid  call fzf#vim#grep('a ws gid -cq                                                  '.<q-args>, 1, fzf#vim#with_preview({'options':['--prompt','Gid>']}))
	command! -nargs=1 AgidP call fzf#vim#grep('a ws gid -cqp '.join(split(expand('%:p:h'), '/')[1:1], '/').' '.<q-args>, 1, fzf#vim#with_preview({'options':['--prompt','Gid>']}))
	nnoremap <leader>r <cmd>exe 'AgidP    '.expand('<cword>')<cr>
	nnoremap <leader>d <cmd>exe 'AgidP -D '.expand('<cword>')<cr>
	nnoremap <leader>R <cmd>exe 'Agid     '.expand('<cword>')<cr>
	nnoremap <leader>D <cmd>exe 'Agid  -D '.expand('<cword>')<cr>
	" cdbtool
	command! -nargs=1 Acdb belowright split | exec 'terminal echo "Generating compile_commands.json for '.<q-args>.'" && cdbtool --tin '.<q-args>
	" TACC language server
lua << EOF
	require('lspconfig.configs').tac = {
		default_config = {
			cmd = {'/usr/bin/artaclsp'},
			cmd_args = {'-I', '/bld/'},
			filetypes = { 'tac' },
			root_dir = function() return '/src' end
		}
	}
	require('lspconfig').tac.setup({})
EOF
endif

" Below here is the pit of shame

" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
" Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
"
" highlight TelescopeBorder guifg=#195466
"
" local actions = require("telescope.actions")
" require('telescope').setup {
" 	defaults = {
" 		mappings = { i = {
" 			["<down>"] = actions.cycle_history_next,
" 			["<up>"] = actions.cycle_history_prev,
" 			["<esc>"] = actions.close
" 		} },
" 		layout_strategy = 'flex',
" 		borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
" 		dynamic_preview_title = true,
" 	},
" 	extensions = {
" 		fzf = { }
" 	}
" }
" require('telescope').load_extension('fzf')
"
" nnoremap <leader>b <cmd>Telescope buffers<cr>
" nnoremap <leader>l <cmd>Telescope current_buffer_fuzzy_find<cr>
" nnoremap <leader>f <cmd>Telescope find_files hidden=true search_dirs={"%:p:h"}<cr>
" nnoremap <leader>F <cmd>Telescope find_files hidden=true<cr>
" nnoremap <leader>s <cmd>Telescope grep_string search= search_dirs={"%:p:h"}<cr>
" nnoremap <leader>S <cmd>Telescope grep_string search=<cr>
" nnoremap <leader>h <cmd>Telescope help_tags<cr>
" nnoremap <leader>m <cmd>Telescope man_pages sections=ALL<cr>
" nnoremap <leader>o <cmd>Telescope oldfiles<cr>
"
" " lsp_dynamic_workspace_symbols	Dynamically Lists LSP for all workspace symbols
" " lsp_implementations	Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope
" nnoremap <leader>E <cmd>Telescope diagnostics bufnr=0<cr>
" nnoremap <leader>d <cmd>Telescope lsp_definitions jump_type=never<cr>
" nnoremap <leader>r <cmd>Telescope lsp_references<cr>
" nnoremap <leader>t <cmd>Telescope lsp_type_definitions jump_type=never<cr>
