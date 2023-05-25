-- Colorscheme
-- TODO(2, aesthetics): replace with my own

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
				comment = "#666666",
				bg0 = "#000000",
				bg1 = "#121212",
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
				-- TODO(2, aesthetics): syntax highlighting colors
				syntax = { },
				diag = { info = "green", error = "red", warn = "#ffaa00" },
				diag_bg = { error = "none", warn = "none", info = "none", hint = "none" },
				diff = { add = "green", removed = "red", changed = "#ffaa00" },
				git = { add = "green", removed = "red", changed = "#ffaa00" }
			}
		},
		groups = {
			all = {
				Visual = { bg = "palette.bg4" },
				Search = { fg = "black", bg = "yellow" },
				IncSearch = { fg = "black", bg = "white" },
				NormalFloat = { bg = "palette.bg1" },
				FloatBorder = { bg = "palette.bg1" },
				ScrollView = { bg = "palette.bg2" },
				CursorWord = { style = "bold" },
				CursorLineNr = { fg = "palette.fg1" },
				Whitespace = { fg = "palette.sel1" },
				ExtraWhitespace = { bg = "red", fg = "red" },
				Todo = { bg = "none", fg = "palette.blue" },
				WinSeparator = { bg = "palette.bg0", fg = "palette.bg0" },
				PmenuKind = { bg = "palette.sel0", fg = "palette.blue" },
				PmenuKindSel = { bg = "palette.sel1", fg = "palette.blue" },
				PmenuExtra = { bg = "palette.sel0", fg = "palette.fg2" },
				PmenuExtraSel = { bg = "palette.sel1", fg = "palette.fg2" },
				TabLine     = { bg = "palette.bg1", fg = "palette.fg2", gui = "none" },
				TabLineSel  = { bg = "palette.bg2", fg = "palette.fg1", gui = "none" },
				TabLineFill = { bg = "palette.bg0", fg = "palette.fg2", gui = "none" },
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
