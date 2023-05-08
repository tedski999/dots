
local function config()
	local f = require("nightfox")
	local s = require("nightfox.lib.shade")
	f.setup({
		options = {
			dim_inactive = true,
			module_default = false,
			modules = { ["dap-ui"] = true, ["mini"] = true, ["signify"] = true }

		},
		palettes = {
			all = {
				-- TODO(aesthetics): colors
				-- black
				-- red
				-- green
				-- yellow
				-- blue
				-- magenta
				-- cyan
				-- white
				-- orange
				-- pink
				comment = "#666666",
				bg0 = "#000000",
				bg1 = "#111111",
				bg2 = "#222222",
				bg3 = "#222222",
				bg4 = "#333333",
				fg0 = "#ff00ff",
				fg1 = "#ffffff",
				fg2 = "#999999",
				fg3 = "#666666",
				sel0 = "#222222",
				sel1 = "#555555"
			}
		},
		specs = {
			all = {
				-- TODO(aesthetics): syntax highlighting colors
				syntax = {
				},
				diag = {
				},
				diag_bg = {
				},
				diff = {
				},
				git = {
				}
			}
		},
		groups = {
			all = {
				Visual = { bg = "palette.bg4" },
				Search = { fg = "black", bg = "yellow" },
				IncSearch = { fg = "black", bg = "white" },
				NormalFloat = { bg = "palette.bg1" },
				ScrollView = { bg = "palette.bg2" },
				CursorLineNr = { bg = "palette.bg2" },
				CursorWord = { style = "bold" },
				Whitespace = { fg = "palette.sel1" },
				ExtraWhitespace = { bg = "red", fg = "red" },
				Todo = { bg = "NONE", fg = "palette.blue" },
			}
		}
	})
	vim.cmd("colorscheme carbonfox")
end

if require("lazy.core.config").plugins["nightfox.nvim"] then
	config()
end

return {
	"EdenEast/nightfox.nvim",
	lazy = false,
	priority = 1000,
	config = config
}
