let is_arista = filereadable('/usr/share/vim/vimfiles/arista.vim')

" Ensure plug.vim is installed
let plug_vim = stdpath('data').'/site/autoload/plug.vim'
if !filereadable(g:plug_vim)
	silent execute '!curl -fLo '.g:plug_vim.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	silent execute 'source '.g:plug_vim
endif

call plug#begin()
Plug 'whatyouhide/vim-gotham'                       " Colorscheme
Plug 'tpope/vim-repeat'                             " tpope period-repeat
Plug 'tpope/vim-sensible'                           " Sane defaults
Plug 'tpope/vim-vinegar'                            " Better file browsing
Plug 'tpope/vim-surround'                           " Surround motion
Plug 'tpope/vim-unimpaired'                         " More bracket mappings
Plug 'tpope/vim-commentary'                         " Comment keybinding
Plug 'tpope/vim-fugitive'                           " Git integration
Plug 'mhinz/vim-signify'                            " Git changes
Plug 'tommcdo/vim-lion'                             " Text aligning
Plug 'ojroques/vim-oscyank'                         " OSC52 yank
Plug 'mbbill/undotree'                              " Visualised undo tree
Plug 'junegunn/fzf.vim'                             " FZF shortcuts
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Install FZF
Plug 'nvim-lualine/lualine.nvim'                    " Status bar
Plug 'sheerun/vim-polyglot'                         " Language packs
Plug 'neovim/nvim-lspconfig'                        " LSP client
Plug 'hrsh7th/vim-vsnip'                            " Snippets engine
Plug 'hrsh7th/nvim-cmp'                             " Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'                         " LSP completion source
Plug 'hrsh7th/cmp-buffer'                           " Buffer completion source
Plug 'hrsh7th/cmp-path'                             " Path completion source
Plug 'hrsh7th/cmp-cmdline'                          " Cmd completion source
Plug 'hrsh7th/cmp-vsnip'                            " Snippets completion source
call plug#end()

" Ensure plugins are installed
if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
	PlugInstall --sync
	runtime! plugin/rplugin.vim
	silent! UpdateRemotePlugins
	echo 'Plugins have been modified. Neovim must be restarted. Press any key to quit...'
	call getchar()
	qall!
endif

" Set the colorscheme and extra highlights
colorscheme gotham
highlight SpellBad guibg=NONE guifg=NONE gui=undercurl guisp=red
highlight SpellCap guibg=NONE guifg=NONE gui=undercurl guisp=blue
highlight SpellRare guibg=NONE guifg=NONE gui=undercurl guisp=purple
highlight SpellLocal guibg=NONE guifg=NONE gui=undercurl guisp=yellow
highlight CmpItemAbbrMatch gui=bold guifg=#569cd6

" VCS sign column
let g:signify_number_highlight = 1
highlight SignifySignAdd    guifg=#2aa889 guibg=#11151c gui=bold
highlight SignifySignChange guifg=#d26937 guibg=#11151c gui=bold
highlight SignifySignDelete guifg=#c23127 guibg=#11151c gui=bold
highlight LspReferenceText gui=bold
highlight LspReferenceRead gui=bold
highlight LspReferenceWrite gui=bold

" Use , and . to align text by a deliminator
let lion_map_left = '<leader>,'
let lion_map_right = '<leader>.'
let lion_squeeze_spaces = 1

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
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.6, 'yoffset': 1.0 } }
command! ManSearch call fzf#run(fzf#wrap({'source': 'man -k '.shellescape(<q-args>).' | cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', 'man {}']}))

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

-- Autocompletion
local cmp = require('cmp')
cmp.setup({
	enabled = function() return not require('cmp.config.context').in_syntax_group('Comment') end,
	mapping = cmp.mapping.preset.insert({['<c-j>']=cmp.mapping.confirm({select=true})}),
	sources = cmp.config.sources({{name='nvim_lsp'},{name='vsnip'}},{{name='path'},{name='buffer'}}),
	snippet = { expand = function(args) vim.fn['vsnip#anonymous'](args.body) end },
	experimental = { ghost_text = true },
	formatting = {
		expandable_indicator = false,
		format = function(_, item)
			local max_len = 50
			item.abbr = #item.abbr > max_len
				and vim.fn.strcharpart(item.abbr, 0, max_len-1) .. '…'
				or item.abbr .. (' '):rep(max_len - #item.abbr)
			item.kind = ({
				Text = '""',     Method = '.f', Function = 'fn',  Constructor = '()', Field = '.x',
				Variable = 'xy', Class = '{}',  Interface = '{}', Module = '[]',      Property = '.p',
				Unit = '$$',     Value = '00',  Enum = '∀e',      Keyword = ';;',     Snippet = '~~',
				Color = 'rgb',   File = '/.',   Reference = '&x', Folder = './',      EnumMember = '∃e',
				Constant = '#x', Struct = '{}', Event = 'ev',     Operator = '++',    TypeParameter = '<>'
			})[item.kind]
			return item
		end
	},
})
cmp.setup.cmdline({'/','?'}, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {{name='buffer'}},
	formatting = { format = function(_, item) item.kind = ''; return item end }
})
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({{name='path'}, {name='cmdline'}}),
	formatting = { format = function(_, item) item.kind = ''; return item end }
})

-- LSP server configs
local lsp = require('lspconfig')
lsp.util.on_setup = lsp.util.add_hook_before(lsp.util.on_setup, function(cfg)
	-- Generic settings
	cfg.capabilities = require('cmp_nvim_lsp').default_capabilities()
	cfg.on_attach = function(client, bufnr)
		if client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_autocmd('CursorMoved', {buffer=bufnr, callback=vim.lsp.buf.clear_references})
			vim.api.nvim_create_autocmd('CursorMoved', {buffer=bufnr, callback=vim.lsp.buf.document_highlight})
		end
	end
	-- Arista-specifics
	if is_arista and cfg.name == 'clangd' then
		-- TODO: clangd settings
		-- TODO: auto include self somehow
	end
end)
--lsp.clangd.setup({})
--lsp.pylsp.setup({})

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
set relativenumber                                " ...relative to the current line
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
set list                                          " Enable whitespace characters below
set listchars=space:·,tab:›\ ,trail:•,precedes:<,extends:>,nbsp:␣
set suffixes-=.h                                  " Header files are important...
set suffixes+=.git                                " ...but .git files are not
set nofoldenable                                  " Don't fold
set nowrap                                        " Don't wrap
set lazyredraw                                    " Redraw only after commands have completed
set termguicolors                                 " Enable true colors
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400
set ignorecase                                    " Ignore case when searching...
set smartcase                                     " ...except for searching with uppercase characters
set wildmode=longest:full,full                    " Show command complete menu after matching longest common command
set completeopt=menu,menuone,noselect             " (Auto)complete menu
set omnifunc=syntaxcomplete#Complete              " Generic completion
set pumheight=8                                   " Limit complete menu height
set spellsuggest=best,20                          " Only show best spelling corrections

" Highlight trailing whitespace
match Error /\s\+$/

" Rg from current buffer
command! -nargs=* BRg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,  fzf#vim#with_preview({'dir': expand('%:p:h')}))

augroup vimrc
autocmd!
" Highlight on yank
autocmd TextYankPost * lua vim.highlight.on_yank({higroup='Visual', timeout=150})
" Don't format new-line comments
autocmd BufEnter     * set formatoptions-=c formatoptions-=o
" Restore cursor position when opening buffers
autocmd BufReadPost  * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 0 && line("'\"") <= line('$') | exe 'normal! g`"' | endif
augroup END

let mapleader = ' '
nnoremap Q nop
" Don't jump over wrapped lines with j and k
nnoremap j gj
nnoremap k gk
" Handy buffer shortcuts
nnoremap <nowait> <leader>w <cmd>w<cr>
nnoremap <nowait> <leader>W <cmd>wq<cr>
nnoremap <nowait> <leader>q <cmd>q<cr>
nnoremap <nowait> <leader>Q <cmd>q!<cr>
" Switch between header and source files
nnoremap <leader>a <cmd>e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<cr>
" Open config
nnoremap <leader>c <cmd>edit $MYVIMRC<cr>
" Search and replace
nnoremap <leader>r *:%s///gcI<left><left><left><left>
" Split lines at cursor, opposite of <s-j>
nnoremap <s-k> m`i<cr><esc>``
" Git
nnoremap <leader>gd <cmd>SignifyHunkDiff<cr>
" Undotree
nnoremap <leader>u <cmd>UndotreeToggle<cr>
" Open notes
nnoremap <leader>n <cmd>lcd ~/Documents/notes \| enew \| set filetype=markdown<cr>
nnoremap <leader>N <cmd>lcd ~/Documents/notes \| execute 'edit'.strftime('./journal/%Y/%V.md') \| call mkdir(expand('%:h'), 'p')<cr>
" FZF search
nnoremap <leader>f <cmd>Files %:p:h<cr>
nnoremap <leader>F <cmd>Files<cr>
nnoremap <leader>s <cmd>BRg<cr>
nnoremap <leader>S <cmd>Rg<cr>
nnoremap <leader>h <cmd>Helptags<cr>
nnoremap <leader>m <cmd>ManSearch<cr>
" LSP
nnoremap <leader><leader> <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <leader>k <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap <leader>e <cmd>lua vim.diagnostic.open_float()<cr>
nnoremap <leader>E <cmd>lua vim.diagnostic.setloclist()<cr>
nnoremap <leader>R <cmd>lua vim.lsp.buf.rename()<cr>
nnoremap <leader>jd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <leader>jt <cmd>lua vim.lsp.buf.type_definition()<cr>
nnoremap <leader>jr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <leader>ji <cmd>lua vim.lsp.buf.implementation()<cr>
vnoremap <leader>f <esc><cmd>lua vim.lsp.buf.range_formatting()<cr>
" Snippets
imap <expr> <tab>   vsnip#jumpable(+1) ? '<Plug>(vsnip-jump-next)' : '<tab>'
smap <expr> <tab>   vsnip#jumpable(+1) ? '<Plug>(vsnip-jump-next)' : '<tab>'
imap <expr> <s-tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<s-tab>'
smap <expr> <s-tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<s-tab>'

" Arista-specifics
if is_arista
	" Manual control
	let a4_auto_edit = 0
	command! A4edit call A4edit()
	" Include Arista config
	source /usr/share/vim/vimfiles/arista.vim
	" 85-column width
	highlight! link ColorColumn CursorColumn
	let &colorcolumn=join(range(86,999),',')
	" In-house VCS based on Perforce
	let g:signify_vcs_cmds = { 'perforce': 'env P4DIFF= P4COLORS= a p4 diff -du 0 %f' }
	let g:signify_vcs_cmds_diffmode = { 'perforce': 'a p4 print %f' }
	" Throw yank through a remote tmux session to local terminal
	let g:oscyank_term = 'default'
	augroup vimrc
	autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif
	" Polyglot breaks tacc filetype detection so here's a fix
	autocmd BufNewFile,BufRead *.tin :set filetype=cpp
	autocmd BufNewFile,BufRead *.tac :set filetype=tac
	augroup filetypedetect
	autocmd! BufNewFile,BufRead *.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.tac,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript setf foo
	autocmd! BufNewFile,BufRead *.cgi,*.fcgi,*.gyp,*.gypi,*.lmi,*.ptl,*.py,*.py3,*.pyde,*.pyi,*.pyp,*.pyt,*.pyw,*.rpy,*.smk,*.spec,*.wsgi,*.xpy,{.,}gclient,{.,}pythonrc,{.,}pythonstartup,DEPS,SConscript,SConstruct,Snakefile,wscript setf python
	augroup END
	" Add TACC LSP server
	" TODO: this doesnt seem to do anything
	lua require('lspconfig.configs').tacc = {default_config={cmd={'artaclsp'}, filetypes={'tac'}}}
	lua require('lspconfig').tacc.setup({})
	" AGid search
	command! -nargs=1 AGid call AGid(<f-args>)
	function! AGid(args)
		let output = system('a ws gid '.a:args)
		if v:shell_error && output != '' | echomsg output | return | endif
		" Remove blanks and ---- lines
		let output = substitute(output, '\(^\|\n\)\zs\n', '', 'g')
		let output = substitute(output, '\(^\|\n\)\zs----.\{-}\n', '', 'g')
		" Send to location list
		let old_efm = &efm
		set efm=%f:%l:%m
		lexpr output
		let &efm = old_efm
		" Open location list window if not one result
		if count(output, '\n') != 1 | lopen | endif
	endfunction
	nnoremap <leader>g <cmd>execute 'AGid    -p '.split(expand('%:p:h'), '/')[1].' '.expand('<cword>')<cr>
	nnoremap <leader>d <cmd>execute 'AGid -D -p '.split(expand('%:p:h'), '/')[1].' '.expand('<cword>')<cr>
	nnoremap <leader>G <cmd>execute 'AGid    '.expand('<cword>')<cr>
	nnoremap <leader>D <cmd>execute 'AGid -D '.expand('<cword>')<cr>
endif
