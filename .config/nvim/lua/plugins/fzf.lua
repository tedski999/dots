-- TODO: fzf lsp handlers

function find_altfiles(file, exists)
	-- TODO: relative to current file
	local altfiles_cmd = "printf %s\\\\n "
	for key, exts in pairs(vim.g.altfile_map) do
		if file:sub(-#key) == key then
			for _, ext in ipairs(exts) do
				altfile = file:sub(1, -#key-1)..ext
				if not exists or vim.loop.fs_stat(altfile) then
					altfiles_cmd = altfiles_cmd.." "..altfile
				end
			end
		end
	end
	vim.cmd("call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': '"..altfiles_cmd.."'})))")
end

return {
	"junegunn/fzf.vim",
	event = "VeryLazy",
	dependencies = { "junegunn/fzf" },
	keys = {
		{ "<leader>b", "<cmd>Buffers<cr>" },
		{ "<leader>l", "<cmd>Lines<cr>" },
		{ "<leader>f", "<cmd>Files %:p:h<cr>" },
		{ "<leader>F", "<cmd>Files<cr>" },
		{ "<leader>s", "<cmd>call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case \"\"', 1, fzf#vim#with_preview({'dir': expand('%:p:h')}))<cr>" },
		{ "<leader>S", "<cmd>Rg<cr>" },
		{ "<leader>h", "<cmd>Helptags<cr>" },
		{ "<leader>H", "<cmd>call fzf#run(fzf#wrap({'source': 'man -k \"\" | cut -d \" \" -f 1', 'sink': 'tab Man', 'options': ['--preview', 'man {}']}))<cr>" },
		{ "<leader>o", "<cmd>History<cr>" },
		{ "<leader>a", function() find_altfiles(vim.fn.expand("%:p:~:."), true) end },
		{ "<leader>A", function() find_altfiles(vim.fn.expand("%:p:~:."), false) end }
	},
	config = function()
		vim.g.fzf_layout = { window = { width = 0.9, height = 0.9, border = vim.g.border_type } }
		vim.g.fzf_action = { ["ctrl-t"] = "tab split", ["ctrl-s"] = "split", ["ctrl-v"] = "vsplit" }
		if vim.g.arista then
			-- TODO: luaify
			vim.cmd([[
				" Perforce
				command! Achanged call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': 'a p4 diff --summary | sed "s/^/\//"'})))
				command! Aopened let o = system('a p4 opened') | if o != '' | echo o | else | echo 'Nothing opened' | endif
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
			]])
		end
	end
}
