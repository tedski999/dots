
local function find_altfiles()
	local fzf = require("fzf-lua")
	local dir = vim.api.nvim_buf_get_name(0):match(".*/") or ""
	local file = vim.api.nvim_buf_get_name(0):sub(#dir+1)
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
		fzf.fzf_exec(existing, { actions = fzf.defaults.actions.files, cwd = dir, previewer = "builtin" })
	elseif #possible ~= 0 then
		fzf.fzf_exec(possible, { actions = fzf.defaults.actions.files, cwd = dir, fzf_opts = { ["--header"] = [["No altfiles found"]]  } })
	else
		vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
	end
end

local projects_dir = vim.fn.stdpath("data").."/projects/"

local function find_projects()
	local projects = {}
	for path in vim.fn.glob(projects_dir.."*"):gmatch("[^\n]+") do
		table.insert(projects, path:match("[^/]*$"))
	end
	require("fzf-lua").fzf_exec(projects, { actions = {
		["default"] = function(projects) vim.cmd("source "..vim.fn.fnameescape(projects_dir..projects[1])) end,
		["ctrl-x"] = function(projects) for i = 1, #projects do vim.fn.delete(vim.fn.fnameescape(projects_dir..projects[o])) end end
	}})
end

local function save_project()
	local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
	if project == "" then return end
	vim.fn.mkdir(projects_dir, "p")
	vim.cmd("mksession! "..vim.fn.fnameescape(projects_dir..project))
end

local function find_hunks(files)
	local hunks, cur, file = {}, vim.api.nvim_buf_get_name(0) or "", nil
	local cmd = { "git", "diff", "-U0", unpack(files or { cur ~= "" and cur or "."}) }
	for line in vim.fn.system(cmd):gmatch("[^\n]+") do
		file = line:match("^%+%+%+ b/(.-)$") or file
		lnum, count = line:match("^@@ %-[%d,]+ %+(%d+),(%d+) @@")
		if file and lnum and count then
			lnum = lnum + math.floor(count / 2)
			table.insert(hunks, file..":"..lnum)
		end
	end
	-- TODO(git): ctrl-s stage/unstage, ctrl-x reset
	-- this would likely require generating diffs and using "git apply --cached"
	fzf.fzf_exec(hunks, { actions = fzf.defaults.actions.files, previewer = "builtin" })
end

local function yank_selection(selected)
	for i = 1, #selected do
		vim.fn.setreg("+", selected[i])
	end
end

return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	keys = {
		{ "z=", "<cmd>FzfLua spell_suggest<cr>" },
		{ "<leader>b", "<cmd>FzfLua buffers<cr>" },
		{ "<leader>l", "<cmd>FzfLua blines<cr>" },
		{ "<leader>f", "<cmd>FzfLua files cwd=%:p:h<cr>" },
		{ "<leader>F", "<cmd>FzfLua files<cr>" },
		{ "<leader>s", "<cmd>FzfLua grep_project cwd=%:p:h<cr>" },
		{ "<leader>S", "<cmd>FzfLua grep_project<cr>" },
		{ "<leader>h", "<cmd>FzfLua help_tags prompt=>\\ <cr>" },
		{ "<leader>H", "<cmd>FzfLua man_pages prompt=>\\ <cr>" },
		{ "<leader>o", "<cmd>FzfLua oldfiles cwd_only=true<cr>" },
		{ "<leader>O", "<cmd>FzfLua oldfiles<cr>" },
		{ "<leader>E", "<cmd>FzfLua diagnostics_document<cr>" },
		{ "<leader>gs", "<cmd>FzfLua git_status<cr>" },
		{ "<leader>gf", "<cmd>FzfLua git_files<cr>" },
		{ "<leader>gl", "<cmd>FzfLua git_bcommits<cr>" },
		{ "<leader>gL", "<cmd>FzfLua git_commits<cr>" },
		{ "<leader>gb", "<cmd>FzfLua git_branches<cr>" },
		{ "<leader>d", "<cmd>FzfLua lsp_definitions<cr>" },
		-- TODO(fzf): previewer currently broken
		-- { "<leader>r", "<cmd>FzfLua lsp_finder<cr>" },
		{ "<leader>r", "<cmd>FzfLua lsp_references<cr>" },
		{ "<leader>c", "<cmd>FzfLua quickfix<cr>" },
		{ "<leader>C", "<cmd>FzfLua quickfix_stack<cr>" },
		{ "<leader>a", find_altfiles },
		{ "<leader>p", find_projects },
		{ "<leader>P", save_project },
		{ "<leader>gh", find_hunks },
		{ "<leader>gH", function() find_hunks({ "." }) end },
	},
	config = function()
		fzf = require("fzf-lua")
		fzf.setup({
			winopts = {
				height = 0.9,
				width = 0.9,
				row = 0.2,
				col = 0.5,
				border = vim.g.border_chars,
				-- TODO(aesthetic): fix colorscheme FloatBorder
				hl = { normal = "Normal", border = "FloatBorder" }
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
			global_git_icons = false,
			global_color_icons = false,
			keymap = { builtin = { ["<c-_>"] = "toggle-preview" } },
			previewers = { man = { cmd = "man %s | col -bx" } },
			files = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			grep = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, no_header = true },
			oldfiles = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, include_current_session = true },
			buffers = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			tabs = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			lines = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			blines = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			quickfix_stack = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, marker = "<" },
			diagnostics = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
			git = {
				commits = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				bcommits = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				branches = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				stash = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				status = {
					prompt = "> ",
					copen = "FzfLua quickfix",
					show_cwd_header = false,
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
				prompt_postfix = "> ",
				file_icons = false,
				code_actions = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false },
				finder = { prompt = "> ", copen = "FzfLua quickfix", show_cwd_header = false, async = false, separator = " " }
			}
		})
		if vim.g.arista then
			vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\//]], { previewer = "builtin" }) end, {})
			vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { previewer = "builtin" }) end, {})
			vim.keymap.set("n", "<leader>gs", "<cmd>Achanged<cr>")
			vim.keymap.set("n", "<leader>go", "<cmd>Aopened<cr>")
			vim.api.nvim_create_user_command("Agid",  function() fzf.fzf_exec("a grok -em 99", { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("AgidP", function() fzf.fzf_exec("a grok -em 99 -f "..(vim.api.nvim_buf_get_name(0):match("^/.-/.-/") or "/"), { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
			vim.api.nvim_create_user_command("Agid",  function() fzf.fzf_exec("a ws gid -cq", { previewer = "builtin" }) end, { nargs = 1 })
			vim.api.nvim_create_user_command("AgidP", function() fzf.fzf_exec("a ws gid -cqp "..(vim.api.nvim_buf_get_name(0):match("^/.-/(.-)/") or "/"), { previewer = "builtin" }) end, { nargs = 1 })
			vim.keymap.set("n", "<leader>r", "<cmd>AgidP    "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>R", "<cmd>Agid     "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>d", "<cmd>AgidP -D "..vim.fn.expand("<cword>").."<cr>")
			vim.keymap.set("n", "<leader>D", "<cmd>Agid  -D "..vim.fn.expand("<cword>").."<cr>")
		end
	end
}
