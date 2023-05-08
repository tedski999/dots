return {
	"gelguy/wilder.nvim",
	event = "CmdlineEnter",
	config = function()
		local w = require("wilder")
		w.setup({ modes = {":", "/", "?"} })
		w.set_option("pipeline", {
			w.branch(
				w.cmdline_pipeline({ fuzzy = 2 }),
				w.search_pipeline({ pattern = w.python_fuzzy_pattern() })
				-- TODO(wilder): filepaths
			)
		})
		-- TODO(aesthetic): match and scrollbar theming
		w.set_option("renderer", w.popupmenu_renderer({
			apply_incsearch_fix = true,
			highlighter = w.basic_highlighter()
		}))
	end
}
