
function get_whitespace_pattern()
	local pattern = [[[\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff]\+\|\s\+$\|[\u0020]\+\ze[\u0009]\+]]
	return "\\("..(vim.o.expandtab and pattern..[[\|^[\u0009]\+]] or pattern..[[\|^[\u0020]\+]]).."\\)"
end

function apply_whitespace_pattern(pattern)
	local disabled_filetypes = { diff=1, git=1, gitcommit=1, markdown=1, fugitive=1, lazy=1, undotree=1 }
	local disabled_buftypes = { quickfix=1, nofile=1, help=1, terminal=1 }
	local disabled = disabled_filetypes[vim.o.ft] or disabled_buftypes[vim.o.buftype]
	if disabled then vim.cmd("match none") else vim.cmd("match ExtraWhitespace '"..pattern.."'") end
end

vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "InsertLeave" }, { callback = function()
	apply_whitespace_pattern(get_whitespace_pattern())
end })

vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, { callback = function()
	local line = vim.fn.line(".")
	local pattern = get_whitespace_pattern()
	apply_whitespace_pattern("\\%<"..line.."l"..pattern.."\\|\\%>"..line.."l"..pattern)
end })

vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
	vim.highlight.on_yank({ higroup = "Visual" })
end })

vim.api.nvim_create_autocmd("BufEnter", { callback = function()
	vim.opt.formatoptions:remove("c")
	vim.opt.formatoptions:remove("o")
end })

vim.api.nvim_create_autocmd("BufWinEnter", { callback = function()
	local disabled_filetypes = { diff=1, git=1, gitcommit=1, gitrebase=1, lazy=1 }
	local disabled_buftypes = { quickfix=1, nofile=1, help=1, terminal=1 }
	local disabled = disabled_filetypes[vim.o.ft] or disabled_buftypes[vim.o.buftype]
	if not (disabled or vim.fn.line(".") > 1 or vim.fn.line("'\"") <= 0 or vim.fn.line("'\"") > vim.fn.line("$")) then
		vim.cmd([[normal! g`"]])
	end
end })

if vim.g.arista then
	vim.cmd([[
		autocmd BufNewFile,BufRead *.tac setlocal indentexpr=TaccIndentOverrides()
		function! TaccIndentOverrides()
			let prevLine = getline(SkipTaccBlanksAndComments(v:lnum - 1))
			if prevLine =~# 'Tac::Namespace\s*{\s*$' | return 0 | endif
			return GetTaccIndent()
		endfunction
	]])
end
