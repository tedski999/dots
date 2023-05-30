-- Fzf in Neovim

-- TODO(3): previewer with last cursor position

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
		fzf.fzf_exec(possible, { actions = fzf.config.globals.actions.files, cwd = dir, fzf_opts = { ["--header"] = [["No altfiles found"]]  } })
	else
		vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
	end
end

-- Save and load projects using mksession
local projects_dir = vim.fn.stdpath("data").."/projects/"
local function find_projects()
	local projects = {}
	for path in vim.fn.glob(projects_dir.."*"):gmatch("[^\n]+") do
		table.insert(projects, path:match("[^/]*$"))
	end
	require("fzf-lua").fzf_exec(projects, { actions = {
		["default"] = function(projects) vim.cmd("source "..vim.fn.fnameescape(projects_dir..projects[1])) end,
		["ctrl-e"] = function(projects) vim.cmd("edit "..projects_dir..projects[1].." | setf vim") end,
		["ctrl-x"] = function(projects) for i = 1, #projects do vim.fn.delete(vim.fn.fnameescape(projects_dir..projects[o])) end end
	}})
end
local function save_project()
	local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
	if project == "" then return end
	vim.fn.mkdir(projects_dir, "p")
	vim.cmd("mksession! "..vim.fn.fnameescape(projects_dir..project))
end

-- List all git hunks
local function find_hunks(files)
	local hunks, cur, file = {}, vim.g.getfile(), nil
	local cmd = { "git", "diff", "-U0", unpack(files or { cur ~= "" and cur or "." }) }
	for line in vim.fn.system(cmd):gmatch("[^\n]+") do
		file = line:match("^%+%+%+ b/(.-)$") or file
		lnum, count = line:match("^@@ %-[%d,]+ %+(%d+),(%d+) @@") or line:match("^@@ %-[%d,]+ %+(%d+) @@"), 0
		if file and lnum and count then
			lnum = lnum + math.floor(count / 2)
			table.insert(hunks, file..":"..lnum)
		end
	end
	-- TODO(3, git): show diff in preview
	-- TODO(3, git): ctrl-s stage/unstage, ctrl-x reset
	-- this would likely require generating diffs and using "git apply --cached"
	fzf.fzf_exec(hunks, { actions = fzf.config.globals.actions.files, previewer = "builtin" })
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
		{ "<leader>b", "<cmd>FzfLua buffers<cr>" },
		{ "<leader>t", "<cmd>FzfLua tabs<cr>" },
		{ "<leader>l", "<cmd>FzfLua blines<cr>" },
		{ "<leader>f", "<cmd>FzfLua files cwd=%:p:h<cr>" },
		{ "<leader>F", "<cmd>FzfLua files<cr>" },
		{ "<leader>s", "<cmd>FzfLua grep_project cwd=%:p:h<cr>" },
		{ "<leader>S", "<cmd>FzfLua grep_project<cr>" },
		{ "<leader>h", "<cmd>FzfLua help_tags<cr>" },
		{ "<leader>H", "<cmd>FzfLua man_pages<cr>" },
		{ "<leader>o", "<cmd>FzfLua oldfiles cwd_only=true<cr>" },
		{ "<leader>O", "<cmd>FzfLua oldfiles<cr>" },
		{ "<leader>m", "<cmd>FzfLua marks cwd_only=true<cr>" },
		{ "<leader>M", "<cmd>FzfLua marks<cr>" },
		{ "<leader>E", "<cmd>FzfLua diagnostics_document<cr>" },
		{ "<leader>gs", "<cmd>FzfLua git_status<cr>" },
		{ "<leader>go", "<cmd>FzfLua git_files<cr>" },
		{ "<leader>gf", "<cmd>FzfLua git_files<cr>" },
		{ "<leader>gl", "<cmd>FzfLua git_bcommits<cr>" },
		{ "<leader>gL", "<cmd>FzfLua git_commits<cr>" },
		{ "<leader>gb", "<cmd>FzfLua git_branches<cr>" },
		{ "<leader>gh", find_hunks },
		{ "<leader>gH", function() find_hunks({ "." }) end },
		{ "<leader>d", "<cmd>FzfLua lsp_definitions<cr>" },
		{ "<leader>D", "<cmd>FzfLua lsp_typedefs<cr>" },
		-- TODO(3, fzf): previewer currently broken
		-- { "<leader>r", "<cmd>FzfLua lsp_finder<cr>" },
		{ "<leader>r", "<cmd>FzfLua lsp_references<cr>" },
		{ "<leader>c", "<cmd>FzfLua quickfix<cr>" },
		{ "<leader>C", "<cmd>FzfLua quickfix_stack<cr>" },
		{ "<leader>a", find_altfiles },
		{ "<leader>p", find_projects },
		{ "<leader>P", save_project },
	},
	config = function()
		fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				height = 0.25, width = 1.0, row = 1.0, col = 0.5,
				border = { "─", "─", "─", " ", "", "", "", " " },
				hl = { normal = "NormalFloat", border = "FloatBorder" },
				preview = {
					layout = "horizontal",
					border = "noborder",
					scrollbar = "border",
					scrollchars = { "│", "" },
					winopts = { list = true }
				}
			},
			keymap = {
				builtin = {
					["<c-_>"] = "toggle-preview",
					["<c-o>"] = "toggle-fullscreen",
					["<m-j>"] = "preview-page-reset",
					-- TODO(2): half-page is borked
					["<m-n>"] = "preview-page-down",
					["<m-p>"] = "preview-page-up",
				}
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
			global_file_icons = false,
			global_git_icons = true,
			global_color_icons = true,
			previewers = { man = { cmd = "man %s | col -bx" } },
			files = { copen = "FzfLua quickfix", show_cwd_header = false },
			grep = { copen = "FzfLua quickfix", show_cwd_header = false, no_header = true },
			oldfiles = { copen = "FzfLua quickfix", show_cwd_header = false, include_current_session = true },
			buffers = { copen = "FzfLua quickfix", show_cwd_header = false },
			tabs = { copen = "FzfLua quickfix", show_cwd_header = false },
			lines = { copen = "FzfLua quickfix", show_cwd_header = false },
			blines = { copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix = { copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix_stack = { copen = "FzfLua quickfix", show_cwd_header = false, marker = "<" },
			diagnostics = { copen = "FzfLua quickfix", show_cwd_header = false },
			git = {
				commits = { copen = "FzfLua quickfix", show_cwd_header = false, preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS" },
				bcommits = { copen = "FzfLua quickfix", show_cwd_header = false, preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS" },
				branches = { copen = "FzfLua quickfix", show_cwd_header = false },
				files = { copen = "FzfLua quickfix", show_cwd_header = false },
				stash = { copen = "FzfLua quickfix", show_cwd_header = false },
				status = {
					copen = "FzfLua quickfix",
					show_cwd_header = false,
					preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
					actions = {
						["right"] = false,
						["left"] = false,
						["ctrl-x"] = { fzf.actions.git_reset, fzf.actions.resume },
						["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume },
						["ctrl-h"] = function(files)
							for i = 1, #files do
								files[i] = files[i]:match("[^\128-\254]+$")
							end
							find_hunks(files)
						end
					}
				}
			},
			lsp = {
				code_actions = { copen = "FzfLua quickfix", show_cwd_header = false },
				finder = { copen = "FzfLua quickfix", show_cwd_header = false, async = false, separator = " " }
			}
		})
		if vim.g.arista then
			-- Perforce
			vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\\//]],                                              { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, {})
			vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, {})
			vim.keymap.set("n", "<leader>gs", "<cmd>Achanged<cr>")
			vim.keymap.set("n", "<leader>go", "<cmd>Aopened<cr>")
			-- Opengrok
			vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(vim.g.getfile():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, { nargs = 1 })
			-- Agid
			vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
			vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(vim.g.getfile():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin", copen = "FzfLua quickfix" }) end, { nargs = 1 })
			vim.keymap.set("n", "<leader>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
			vim.keymap.set("n", "<leader>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
		end
	end
}
