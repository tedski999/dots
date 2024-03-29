-- Colorscheme
return {
	"EdenEast/nightfox.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nightfox").setup({
			options = {
				dim_inactive = true,
				module_default = false,
				modules = { ["mini"] = true, ["signify"] = true }
			},
			palettes = {
				all = {
					comment = "#666666",
					bg0 = "#0c0c0c",
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
					NormalBorder = { bg = "palette.bg1", fg = "palette.fg3" },
					NormalFloat = { bg = "palette.bg2" },
					FloatBorder = { bg = "palette.bg2" },
					CursorWord = { bg = "none", fg = "none", style = "underline,bold" },
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
					SatelliteBar = { bg = "palette.bg4" },
					SatelliteCursor = { fg = "palette.fg2" },
					SatelliteQuickfix = { fg = "palette.fg0" },
				}
			}
		})
		vim.cmd("colorscheme carbonfox")
	end
}
