
vim.api.nvim_create_autocmd("TextYankPost", { callback = function()
	vim.highlight.on_yank({ higroup = "Visual" })
end })

vim.api.nvim_create_autocmd("BufEnter", { callback = function()
	vim.opt.formatoptions:remove("c")
	vim.opt.formatoptions:remove("o")
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
