-- Fzf in Neovim

--- File explorer to replace netrw
local function explore_files(root)
	local fzf = require("fzf-lua")
	fzf.fzf_exec("fd --hidden", {
		prompt = root,
		cwd = root,
		fzf_opts = { ["--no-multi"] = "" },
		previewer = "builtin",
		actions = {
			["default"] = function(s)
				f = root..s[1]
				s = vim.loop.fs_stat(f)
				if s and s.type == "directory" then explore_files(f) else vim.cmd("edit "..f) end
			end,
			["ctrl-k"] = function() explore_files(root:sub(1, -2):match(".*/") or "/") end,
			["ctrl-h"] = function() explore_files("$HOME") end,
			["ctrl-s"] = function() fzf.grep_project({ cwd=root, cwd_only=true }) end,
			["ctrl-r"] = { function(s)
				if #s == 0 then return end
				local i = vim.fn.input(s[1].." > "):gsub("$d", root):gsub("$f", s[1])
				if i == "" then return end
				local d = vim.fn.chdir(root)
				vim.notify(vim.fn.system(i))
				vim.fn.chdir(d)
			end, fzf.actions.resume },
		},
		fn_transform = function(x)
			local dir = x:match(".*/") or ""
			local file = x:sub(#dir+1)
			return fzf.utils.ansi_codes.blue(dir)..fzf.utils.ansi_codes.white(file)
		end,
	})
end

-- Switch to an alternative file based on extension
local function find_altfiles()
	local fzf = require("fzf-lua")
	local dir = vim.g.getfile():match(".*/")
	local file = vim.g.getfile():sub(#dir+1)
	local possible, existing = {}, {}
	for ext, altexts in pairs(vim.g.altfile_map) do
		if file:sub(-#ext) == ext then
			for _, altext in ipairs(altexts) do
				altfile = file:sub(1, -#ext-1)..altext
				table.insert(possible, altfile)
				if vim.loop.fs_stat(dir..altfile) then
					table.insert(existing, altfile)
				end
			end
		end
	end
	if #existing == 1 then
		vim.cmd("edit "..dir..existing[1])
	elseif #existing ~= 0 then
		fzf.fzf_exec(existing, { actions = fzf.config.globals.actions.files, cwd = dir, previewer = "builtin" })
	elseif #possible ~= 0 then
		fzf.fzf_exec(possible, { actions = fzf.config.globals.actions.files, cwd = dir, fzf_opts = { ["--header"] = [["No altfiles found"]] } })
	else
		vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
	end
end

-- Save and load projects using mksession
local projects_dir = vim.fn.stdpath("data").."/projects/"
local function find_projects()
	local fzf = require("fzf-lua")
	local projects = {}
	for path in vim.fn.glob(projects_dir.."*"):gmatch("[^\n]+") do
		table.insert(projects, path:match("[^/]*$"))
	end
	fzf.fzf_exec(projects, {
		prompt = "Project>",
		fzf_opts = { ["--header"] = [["<ctrl-x> to delete|<ctrl-e> to edit"]] },
		actions = {
			["default"] = function(projects) vim.cmd("source "..vim.fn.fnameescape(projects_dir..projects[1])) end,
			["ctrl-e"] = function(projects) vim.cmd("edit "..projects_dir..projects[1].." | setf vim") end,
			["ctrl-x"] = function(projects) for i = 1, #projects do vim.fn.delete(vim.fn.fnameescape(projects_dir..projects[i])) end end
		}
	})
end
local function save_project()
	local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
	if project == "" then return end
	vim.fn.mkdir(projects_dir, "p")
	vim.cmd("mksession! "..vim.fn.fnameescape(projects_dir..project))
end

-- Visualise and select from the branched undotree
local function view_undotree()
	local fzf = require("fzf-lua")
	local undotree = vim.fn.undotree()
	local function build_entries(tree, depth)
		local entries = {}
		for i = #tree, 1, -1  do
			local cs = { "magenta", "blue", "yellow", "green", "red" }
			c = fzf.utils.ansi_codes[cs[math.fmod(depth, #cs) + 1]]
			if tree[i].save then e = tree[i].seq.."*" else e = tree[i].seq.."" end
			t = os.time() - tree[i].time
			if t > 86400 then t = math.floor(t/86400).."d" elseif t > 3600 then t = math.floor(t/3600).."h" elseif t > 60 then t = math.floor(t/60).."m" else t = t.."s" end
			if tree[i].seq == undotree.seq_cur then t = fzf.utils.ansi_codes.white(t.." <") else t = fzf.utils.ansi_codes.grey(t) end
			table.insert(entries, c(e).." "..t)
			if tree[i].alt then
				subentries = build_entries(tree[i].alt, depth + 1)
				for j = 1, #subentries do table.insert(entries, " "..subentries[j]) end
			end
		end
		return entries
	end
	local curbuf = vim.api.nvim_get_current_buf()
	local curfile = vim.g.getfile()
	fzf.fzf_exec(build_entries(undotree.entries, 0), {
		prompt = "Undotree>",
		fzf_opts = { ["--no-multi"] = "" },
		actions = { ["default"] = function(s) vim.cmd("undo "..s[1]:match("%d+")) end },
		previewer = false,
		preview = fzf.shell.raw_preview_action_cmd(function(s)
			if #s == 0 then return end
			local newbuf = vim.api.nvim_get_current_buf()
			local tmpfile = vim.fn.tempname()
			change = s[1]:match("%d+")
			vim.api.nvim_set_current_buf(curbuf)
			vim.cmd("undo "..change)
			lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			vim.cmd("undo "..undotree.seq_cur)
			vim.fn.writefile(lines, tmpfile)
			vim.api.nvim_set_current_buf(newbuf)
			return "delta --file-modified-label '' --hunk-header-style '' --file-transformation 's/tmp.*//' "..curfile.." "..tmpfile
		end)
	})
end

-- Yank selected entries
local function yank_selection(selected)
	for i = 1, #selected do
		vim.fn.setreg("+", selected[i])
	end
end

return {
	"ibhagwan/fzf-lua",
	cmd = { "FzfLua", "Achanged", "Aopened", "Agrok", "Agrokp", "Amkid", "Agid", "Agidp" },
	keys = {
		{ "z=", "<cmd>FzfLua spell_suggest<cr>" },
		{ "<leader>b", "<cmd>FzfLua buffers cwd=%:p:h cwd_only=true<cr>" },
		{ "<leader>B", "<cmd>FzfLua buffers<cr>" },
		{ "<leader>t", "<cmd>FzfLua tabs<cr>" },
		{ "<leader>T", "<cmd>FzfLua tags<cr>" },
		{ "<leader>l", "<cmd>FzfLua blines<cr>" },
		{ "<leader>L", "<cmd>FzfLua lines<cr>" },
		{ "<leader>f", function() explore_files(vim.g.getfile():match(".*/")) end },
		{ "<leader>F", function() explore_files(vim.fn.getcwd()) end },
		{ "<leader>o", "<cmd>FzfLua oldfiles cwd=%:p:h cwd_only=true<cr>" },
		{ "<leader>O", "<cmd>FzfLua oldfiles<cr>" },
		{ "<leader>s", "<cmd>FzfLua grep_project cwd=%:p:h cwd_only=true<cr>" },
		{ "<leader>S", "<cmd>FzfLua grep_project<cr>" },
		{ "<leader>m", "<cmd>FzfLua marks cwd=%:p:h cwd_only=true<cr>" },
		{ "<leader>M", "<cmd>FzfLua marks<cr>" },
		{ "<leader>gg", "<cmd>lua require('fzf-lua').git_status({ cwd='%:p:h', file_ignore_patterns={ '^../' } })<cr>" },
		{ "<leader>gG", "<cmd>FzfLua git_status<cr>" },
		{ "<leader>gf", "<cmd>FzfLua git_files cwd_only=true cwd=%:p:h<cr>" },
		{ "<leader>gF", "<cmd>FzfLua git_files<cr>" },
		{ "<leader>gl", "<cmd>FzfLua git_bcommits<cr>" },
		{ "<leader>gL", "<cmd>FzfLua git_commits<cr>" },
		{ "<leader>gb", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color HEAD..$b; git diff HEAD $b | delta' })<cr>" },
		{ "<leader>gB", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color origin/HEAD..$b; git diff origin/HEAD $b | delta' })<cr>" },
		{ "<leader>gs", "<cmd>FzfLua git_stash<cr>" },
		{ "<leader>k", "<cmd>FzfLua help_tags<cr>" },
		{ "<leader>K", "<cmd>FzfLua man_pages<cr>" },
		{ "<leader>E", "<cmd>FzfLua diagnostics_document<cr>" },
		{ "<leader>d", "<cmd>FzfLua lsp_definitions<cr>" },
		{ "<leader>D", "<cmd>FzfLua lsp_typedefs<cr>" },
		{ "<leader>r", "<cmd>FzfLua lsp_finder<cr>" },
		{ "<leader>R", "<cmd>FzfLua lsp_code_actions<cr>" },
		{ "<leader>c", "<cmd>FzfLua quickfix<cr>" },
		{ "<leader>C", "<cmd>FzfLua quickfix_stack<cr>" },
		{ "<leader>a", find_altfiles },
		{ "<leader>p", find_projects },
		{ "<leader>P", save_project },
		{ "<leader>u", view_undotree },
	},
	config = function()
		fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				fullscreen = true,
				height = 0.25, width = 1.0, row = 1.0, col = 0.5,
				border = { "─", "─", "─", " ", "", "", "", " " },
				hl = { normal = "Normal", border = "NormalBorder", preview_border = "NormalBorder" },
				preview = { hidden = "nohidden", border = "noborder", scrollchars = { "│", "" }, winopts = { list = true } }
			},
			keymap = {
				builtin = {
					["<c-_>"] = "toggle-preview",
					["<c-o>"] = "toggle-fullscreen",
					["<m-d>"] = "preview-page-down",
					["<m-u>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-d"] = "half-page-down",
					["ctrl-u"] = "half-page-up",
					["alt-n"] = "preview-page-down",
					["alt-p"] = "preview-page-up",
				},
			},
			actions = {
				files = {
					["default"] = fzf.actions.file_edit_or_qf,
					["ctrl-s"] = fzf.actions.file_split,
					["ctrl-v"] = fzf.actions.file_vsplit,
					["ctrl-t"] = fzf.actions.file_tabedit,
					["ctrl-y"] = yank_selection
				},
				buffers = {
					["default"] = fzf.actions.buf_edit_or_qf,
					["ctrl-s"] = fzf.actions.buf_split,
					["ctrl-v"] = fzf.actions.buf_vsplit,
					["ctrl-t"] = fzf.actions.buf_tabedit,
					["ctrl-y"] = yank_selection
				}
			},
			fzf_opts = { ["--separator"] = [[""]] },
			global_file_icons = false,
			global_git_icons = true,
			global_color_icons = true,
			previewers = { man = { cmd = "man %s | col -bx" } },
			files = { copen = fzf.quickfix, cwd_header = false },
			grep = { copen = fzf.quickfix, cwd_header = false },
			oldfiles = { copen = fzf.quickfix, cwd_header = false, include_current_session = true },
			buffers = { copen = fzf.quickfix, cwd_header = false },
			tabs = { copen = fzf.quickfix, cwd_header = false },
			lines = { copen = fzf.quickfix, cwd_header = false },
			blines = { copen = fzf.quickfix, cwd_header = false },
			quickfix = { copen = fzf.quickfix, cwd_header = false },
			quickfix_stack = { copen = fzf.quickfix, cwd_header = false, marker = "<" },
			diagnostics = { copen = fzf.quickfix, cwd_header = false },
			lsp = {
				code_actions = { copen = fzf.quickfix, cwd_header = false },
				finder = { copen = fzf.quickfix, cwd_header = false, separator = fzf.utils.nbsp }
			},
			git = {
				files = { copen = fzf.quickfix, cwd_header = false },
				stash = { copen = fzf.quickfix, cwd_header = false },
				branches = { copen = fzf.quickfix, cwd_header = false },
				commits = { copen = fzf.quickfix, cwd_header = false, preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS" },
				bcommits = { copen = fzf.quickfix, cwd_header = false, preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS" },
				status = { copen = fzf.quickfix, cwd_header = false, preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
					actions = { ["right"] = false, ["left"] = false, ["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume } }
				}
			}
		})
		if vim.g.arista then
			-- Perforce
			vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\\//]],                                              { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, {})
			vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, {})
			vim.keymap.set("n", "<leader>gs", "<cmd>Achanged<cr>")
			vim.keymap.set("n", "<leader>go", "<cmd>Aopened<cr>")
			-- Opengrok
			vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(vim.g.getfile():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, { nargs = 1 })
			-- Agid
			vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
			vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(vim.g.getfile():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = fzf.quickfix }) end, { nargs = 1 })
			vim.keymap.set("n", "<leader>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
		end
	end
}
