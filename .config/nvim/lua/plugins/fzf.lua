-- TODO(lsp): fzf lsp handlers

-- TODO(alt): relative to file
function find_altfiles(file)
	local possible_files_set = {}
	for key, exts in pairs(vim.g.altfile_map) do
		if file:sub(-#key) == key then
			for _, ext in ipairs(exts) do
				possible_files_set[file:sub(1, -#key-1)..ext] = true
			end
		end
	end

	local possible_files = {}
	for file in pairs(possible_files_set) do
		table.insert(possible_files, file)
	end

	local existing_files = {}
	for _, file in pairs(possible_files) do
		if vim.loop.fs_stat(file) then
			table.insert(existing_files, file)
		end
	end

	if #existing_files ~= 0 then
		vim.g.altfiles = existing_files
		vim.cmd("call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': g:altfiles, 'options': '-1'})))")
	elseif #possible_files ~= 0 then
		vim.g.altfiles = possible_files
		vim.api.nvim_echo({ { "Warning: No altfile found, create one?", "Error" } }, false, {})
		vim.cmd("call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': g:altfiles})))")
	else
		vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
	end
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
		{ "<leader>a", function() find_altfiles(vim.fn.expand("%:p:~:.")) end },
		{ "<leader>gg", "<cmd>BCommits<cr>" },
		{ "<leader>gG", "<cmd>Commits<cr>" },
	},
	config = function()
		vim.g.fzf_layout = { window = { width = 0.9, height = 0.9, border = vim.g.border_type } }
		vim.g.fzf_action = { ["ctrl-t"] = "tab split", ["ctrl-s"] = "split", ["ctrl-v"] = "vsplit" }
		vim.g.fzf_history_dir = vim.fn.stdpath("data").."/fzf-history"
		if vim.g.arista then
			-- Perforce
			vim.api.nvim_create_user_command("Achanged", "call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': 'a p4 diff --summary | sed s/^/\\//'})))", {})
			vim.api.nvim_create_user_command("Aopened",  "let o = system('a p4 opened') | if o != '' | echo o | else | echo 'Nothing opened' | endif", {})
			-- OpenGrok search
			vim.api.nvim_create_user_command("Agrok",  "call fzf#vim#grep('a grok -em 99                                                   '.shellescape(<q-args>).' | grep \"^/src/.*\"', 1, fzf#vim#with_preview({'options':['--prompt','Grok>']}))", { nargs = 1 })
			vim.api.nvim_create_user_command("AgrokP", "call fzf#vim#grep('a grok -em 99 -f '.join(split(expand('%:p:h'), '/')[:1], '/').' '.shellescape(<q-args>).' | grep \"^/src/.*\"', 1, fzf#vim#with_preview({'options':['--prompt','Grok>']}))", { nargs = 1 })
			-- Agid
			vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
			vim.api.nvim_create_user_command("Agid",  "call fzf#vim#grep('a ws gid -cq                                                  '.<q-args>, 1, fzf#vim#with_preview({'options':['--prompt','Gid>']}))", { nargs = 1 })
			vim.api.nvim_create_user_command("AgidP", "call fzf#vim#grep('a ws gid -cqp '.join(split(expand('%:p:h'), '/')[1:1], '/').' '.<q-args>, 1, fzf#vim#with_preview({'options':['--prompt','Gid>']}))", { nargs = 1 })
			vim.keymap.set("n", "<leader>r", "<cmd>AgidP    "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>R", "<cmd>Agid     "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>d", "<cmd>AgidP -D "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>D", "<cmd>Agid  -D "..vim.fn.expand("<cword>").."<cr>")
		end
	end
}
