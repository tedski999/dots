{pkgs, lib, config, inputs, ...}: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.keyboard = { layout = "ie"; options = [ "caps:escape" ]; };
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    # core cli
    coreutils
    diffutils
    man
    curl
    gnused
    procps
    file
    # bonus cli
    cht-sh
    python3
    # temporary file share
    (writeShellScriptBin "0x0" ''curl -F"file=@$1" https://0x0.st;'')
    # decompression utility
    (writeShellScriptBin "un" ''
      ft="$(file -b "$1" | tr "[:upper:]" "[:lower:]" || exit 1)"
      mkdir -p "''${2:-.}" || exit 1
      case "$ft" in
        "zip archive"*) unzip -d "''${2:-.}" "$1";;
        "gzip compressed"*) tar -xvzf "$1" -C "''${2:-.}";;
        "bzip2 compressed"*) tar -xvjf "$1" -C "''${2:-.}";;
        "posix tar archive"*) tar -xvf "$1" -C "''${2:-.}";;
        "xz compressed data"*) tar -xvJf "$1" -C "''${2:-.}";;
        "rar archive"*) unrar x "$1" "''${2:-.}";;
        "7-zip archive"*) 7zz x "$1" "-o''${2:-.}";;
        *) echo "Unable to un: $ft"; exit 1;;
      esac
    '')
    # safe rm
    (writeShellScriptBin "del" ''
      IFS=$'\n'
      trash="${config.xdg.dataHome}/trash"
      format="trashed-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]Z[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"

      case "$1" in "-u") shift; mode=u;; "-f") shift; mode=f;; *) mode=n;; esac
      [ -n "$1" ] || exit 1

      for file in $@; do
        case $mode in
          u) [ -n "$(find "$trash$(readlink -m -- "$file")" -maxdepth 1 -name "$format" 2>/dev/null)" ] \
            || { echo "'$file' not in trash" >&2; exit 1; };;
          *) [ -e "$file" ] \
            || { echo "'$file' does not exist" >&2; exit 1; };;
        esac
      done

      for file in $@; do
        dir="$trash$(readlink -m -- "$file")"
        case $mode in
          u)
            trashed="$(find "$dir" -maxdepth 1 -name "$format" -printf %f\\n)"
            [ "$(echo "$trashed" | wc -l)" -gt 1 ] && {
              echo "Multiple trashed files '$file'"
              echo "$trashed" | awk '{ printf "%d: %s\n", NR, $0 }'
              read -p "Choice: " i
              trashed="$(echo "$trashed" | awk "NR == $i { print; exit }")"
              [ -n "$trashed" ] || exit 1
            }
            mv -i -- "$dir/$trashed" "$file" || exit 1;;
          f) rm -rf "$file" || exit 1;;
          n) mkdir -p "$dir" && mv -i -- "$file" "$dir/$(date --utc +trashed-%FZ%T)" || exit 1;;
        esac
      done
    '')
  ];

  home.sessionVariables.PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
  xdg.configFile."python/pythonrc" = {
    text = ''
      import atexit, readline

      try:
          readline.read_history_file("${config.xdg.dataHome}/python_history")
      except OSError as e:
          pass
      if readline.get_current_history_length() == 0:
          readline.add_history("# history created")

      def write_history(path):
          try:
              import os, readline
              os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)
              readline.write_history_file(path)
          except OSError:
              pass

      atexit.register(write_history, "${config.xdg.dataHome}/python_history")
      del (atexit, readline, write_history)
    '';
  };

  programs.home-manager = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    extraOptions = [ "--header" "--sort=name" "--group-directories-first" ];
    git = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      vim_keys = true;
      rounded_corners = false;
      update_ms = 500;
      proc_sorting = "cpu lazy";
      proc_tree = false;
      proc_filter_kernel = true;
      proc_aggregate = true;
    };
  };

  programs.bat = {
    enable = true;
    config = { style = "plain"; wrap = "never"; map-syntax = [ "*.tin:C++" "*.tac:C++" ]; };
  };

  programs.git = {
    enable = true;
    userEmail = "ski@h8c.de";
    userName = "tedski999";
    signing = { signByDefault = true; key = "00ADEF0A!"; };
    aliases.l = "log";
    aliases.s = "status";
    aliases.a = "add";
    aliases.c = "commit";
    aliases.cm = "commit --message";
    aliases.ps = "push";
    aliases.pl = "pull";
    aliases.d = "diff";
    aliases.ds = "diff --staged";
    aliases.rs = "restore --staged";
    aliases.un = "reset --soft HEAD~";
    aliases.b = "branch";
    delta.enable = true;
    delta.options.features = "navigate";
    delta.options.relative-paths = true;
    delta.options.width = "variable";
    delta.options.paging = "always";
    delta.options.line-numbers = true;
    delta.options.line-numbers-left-format = "";
    delta.options.line-numbers-right-format = "{np:>4} ";
    delta.options.navigate-regex = "^[-+=!>]";
    delta.options.file-added-label = "+";
    delta.options.file-copied-label = "=";
    delta.options.file-modified-label = "!";
    delta.options.file-removed-label = "-";
    delta.options.file-renamed-label = ">";
    delta.options.file-style = "brightyellow";
    delta.options.file-decoration-style = "omit";
    delta.options.hunk-label = "#";
    delta.options.hunk-header-style = "file line-number";
    delta.options.hunk-header-file-style = "blue";
    delta.options.hunk-header-line-number-style = "grey";
    delta.options.hunk-header-decoration-style = "omit";
    delta.options.blame-palette = "#101010 #282828";
    delta.options.blame-separator-format = "{n:^5}";
    # TODO(later)
    #[pull] rebase = false
    #[push] default = current
    #[merge] conflictstyle = diff3
    #[diff] colorMoved = default
  };

  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [ ".git/" ];
  };

  programs.jq = {
    enable = true;
  };

  home.sessionVariables.LESS="--incsearch --ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT --RAW-CONTROL-CHARS";
  programs.less = {
    enable = true;
    keys = "h left-scroll\nl right-scroll";
  };

  programs.man = {
    enable = true;
  };

  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.sessionVariables.MANWIDTH = 80;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = pkgs.vimPlugins.nvim-surround;
        config = ''lua require("nvim-surround").setup({ move_cursor = false })'';
      }
      {
        plugin = pkgs.vimPlugins.mini-nvim;
        config = ''
          lua << END
          require("mini.align").setup({})
          local function normalise_string(str, max)
            str = (str or ""):match("[!-~].*[!-~]") or ""
            return #str > max and vim.fn.strcharpart(str, 0, max-1).."…" or str..(" "):rep(max-#str)
          end
          require("mini.completion").setup({
            set_vim_settings = false,
            window = { info = { border = { " ", "", "", " " } }, signature = { border = { " ", "", "", " " } } },
            lsp_completion = {
              process_items = function(items, base)
                items = require("mini.completion").default_process_items(items, base)
                for _, item in ipairs(items) do
                  item.label = normalise_string(item.label, 40)
                  item.detail = normalise_string(item.detail, 10)
                  item.additionalTextEdits = {}
                end
                return items
              end
            }
          })
          require("mini.cursorword").setup({ delay = 0 })
          require("mini.splitjoin").setup({ mappings = { toggle = "", join = "<space>j", split = "<space>J" } })
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-rsi;
        config = "";
      }
      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        config = ''
          lua << END
          local p = require("nightfox.palette").load("carbonfox")
          require("lualine").setup({
            options = {
              icons_enabled = false,
              section_separators = "",
              component_separators = "",
              refresh = { statusline = 100, tabline = 100, winbar = 100 },
              theme = {
                normal =   { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                insert =   { a = { bg = p.green.base,   fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                visual =   { a = { bg = p.magenta.dim,  fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                replace =  { a = { bg = p.red.base,     fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                command =  { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                terminal = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
                inactive = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg0, fg = p.fg2 }, c = { bg = p.bg0, fg = p.fg3 } },
              }
            },
            sections = {
              lualine_a = {{"mode", fmt = function(m) return m:sub(1,1) end}},
              lualine_b = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
              lualine_c = {"diff"},
              lualine_x = {{"diagnostics", sections={"error", "warn"}}},
              lualine_y = {"filetype"},
              lualine_z = {{"searchcount", maxcount=9999}, "progress", "location"},
            },
            inactive_sections = {
              lualine_a = {{"mode", fmt=function() return " " end}},
              lualine_b = {},
              lualine_c = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
              lualine_x = {{"diagnostics", sections={"error", "warn"}}},
              lualine_y = {},
              lualine_z = {}
            }
          })
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.nightfox-nvim;
        config = ''
          lua << END
          require("nightfox").setup({
            options = {
              dim_inactive = true,
              module_default = false,
              modules = { ["mini"] = true, ["signify"] = true }
            },
            palettes = {
              all = {
                fg0 = "#ff00ff", fg1 = "#ffffff", fg2 = "#999999", fg3 = "#666666",
                bg0 = "#0c0c0c", bg1 = "#121212", bg2 = "#222222", bg3 = "#222222", bg4 = "#333333",
                sel0 = "#222222", sel1 = "#555555", comment = "#666666"
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
                MiniCursorword = { bg = "none", fg = "none", style = "underline,bold" },
                MiniCursorwordCurrent = { bg = "none", fg = "none", style = "underline,bold" },
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
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-signify;
        config = ''
          lua << END
          vim.g.signify_number_highlight = 1
          vim.keymap.set("n", "[d", "<plug>(signify-prev-hunk)")
          vim.keymap.set("n", "]d", "<plug>(signify-next-hunk)")
          vim.keymap.set("n", "[D", "9999<plug>(signify-prev-hunk)")
          vim.keymap.set("n", "]D", "9999<plug>(signify-next-hunk)")
          vim.keymap.set("n", "<space>gd", "<cmd>SignifyHunkDiff<cr>")
          vim.keymap.set("n", "<space>gD", "<cmd>SignifyDiff!<cr>")
          vim.keymap.set("n", "<space>gr", "<cmd>SignifyHunkUndo<cr>")
          -- if vim.g.arista then
          --   local vcs_cmds = vim.g.signify_vcs_cmds or {}
          --   local vcs_cmds_diffmode = vim.g.signify_vcs_cmds_diffmode or {}
          --   vcs_cmds.perforce = "env P4DIFF= P4COLORS= a p4 diff -du 0 %f"
          --   vcs_cmds_diffmode.perforce = "a p4 print %f"
          --   vim.g.signify_vcs_cmds = vcs_cmds
          --   vim.g.signify_vcs_cmds_diffmode = vcs_cmds_diffmode
          -- end
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.satellite-nvim;
        config = ''
          lua << END
          require("satellite").setup({
            winblend = 0,
            handlers = {
              cursor = { enable = false, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
              search = { enable = true },
              diagnostic = { enable = true, min_severity = vim.diagnostic.severity.WARN },
              gitsigns = { enable = false },
              marks = { enable = false }
            }
          })
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.fzf-lua;
        config = ''
        lua << END
        -- Yank selected entries
        local function yank_selection(selected)
          for i = 1, #selected do
            vim.fn.setreg("+", selected[i])
          end
        end

        --- File explorer to replace netrw
        local function explore_files(root)
          root = vim.fn.resolve(vim.fn.expand(root)):gsub("/$", "").."/"
          local fzf = require("fzf-lua")
          fzf.fzf_exec("echo .. && fd --base-directory "..root.." --hidden --exclude '**/.git/' --exclude '**/node_modules/'", {
            prompt = root,
            cwd = root,
            fzf_opts = { ["--header"] = "<ctrl-x> to exec|<ctrl-s> to grep|<ctrl-r> to cwd" },
            previewer = "builtin",
            actions = {
              ["default"] = function(s, opts)
                for i = 1, #s do s[i] = vim.fn.resolve(root..s[i]) end
                if #s > 1 then
                  fzf.actions.file_sel_to_qf(s, opts)
                elseif (vim.loop.fs_stat(s[1]) or {}).type == "directory" then
                  explore_files(s[1])
                else
                  vim.cmd("edit "..s[1])
                end
              end,
              ["ctrl-x"] = function(s)
                local k = ": " for i = 1, #s do k = k.." "..root..s[i] end
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(k.."<home>", false, false, true), "n", {})
              end,
              ["ctrl-s"] = function() fzf.grep_project({ cwd=root, cwd_only=true }) end,
              ["ctrl-r"] = { function() vim.fn.chdir(root) end, fzf.actions.resume },
              ["ctrl-v"] = fzf.actions.file_vsplit,
              ["ctrl-t"] = fzf.actions.file_tabedit,
              ["ctrl-y"] = function(s) for i = 1, #s do s[i] = root..s[i] end yank_selection(s) end,
            },
            fn_transform = function(x)
              local dir = x:match(".*/") or ""
              local file = x:sub(#dir+1)
              return fzf.utils.ansi_codes.blue(dir)..fzf.utils.ansi_codes.white(file)
            end,
          })
        end

        -- Switch to an alternative file based on extension
        local altfile_map = {
          [".c"] = { ".h", ".hpp", ".tin" },
          [".h"] = { ".c", ".cpp", ".tac" },
          [".cpp"] = { ".hpp", ".h", ".tin" },
          [".hpp"] = { ".cpp", ".c", ".tac" },
          [".vert.glsl"] = { ".frag.glsl" },
          [".frag.glsl"] = { ".vert.glsl" },
          [".tac"] = { ".tin", ".cpp", ".c" },
          [".tin"] = { ".tac", ".hpp", ".h" }
        }
        local function find_altfiles()
          local fzf = require("fzf-lua")
          local dir = vim.g.getfile():match(".*/")
          local file = vim.g.getfile():sub(#dir+1)
          local possible, existing = {}, {}
          for ext, altexts in pairs(altfile_map) do
            if file:sub(-#ext) == ext then
              for _, altext in ipairs(altexts) do
                local altfile = file:sub(1, -#ext-1)..altext
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
            fzf.fzf_exec(possible, { actions = fzf.config.globals.actions.files, cwd = dir, fzf_opts = { ["--header"] = "No altfiles found" } })
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
            fzf_opts = { ["--no-multi"] = "", ["--header"] = "<ctrl-x> to delete|<ctrl-e> to edit" },
            actions = {
              ["default"] = function(s) vim.cmd("source "..vim.fn.fnameescape(projects_dir..s[1])) end,
              ["ctrl-e"] = function(s) vim.cmd("edit "..projects_dir..s[1].." | setf vim") end,
              ["ctrl-x"] = function(s) for i = 1, #s do vim.fn.delete(vim.fn.fnameescape(projects_dir..s[i])) end end
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
              local c = fzf.utils.ansi_codes[cs[math.fmod(depth, #cs) + 1]]
              local e = tree[i].seq..""
              if tree[i].save then e = e.."*" end
              local t = os.time() - tree[i].time
              if t > 86400 then t = math.floor(t/86400).."d" elseif t > 3600 then t = math.floor(t/3600).."h" elseif t > 60 then t = math.floor(t/60).."m" else t = t.."s" end
              if tree[i].seq == undotree.seq_cur then t = fzf.utils.ansi_codes.white(t.." <") else t = fzf.utils.ansi_codes.grey(t) end
              table.insert(entries, c(e).." "..t)
              if tree[i].alt then
                local subentries = build_entries(tree[i].alt, depth + 1)
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
              local change = s[1]:match("%d+")
              vim.api.nvim_set_current_buf(curbuf)
              vim.cmd("undo "..change)
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              vim.cmd("undo "..undotree.seq_cur)
              vim.fn.writefile(lines, tmpfile)
              vim.api.nvim_set_current_buf(newbuf)
              return "delta --file-modified-label ''' --hunk-header-style ''' --file-transformation 's/tmp.*//' "..curfile.." "..tmpfile
            end)
          })
        end

        vim.keymap.set("n", "z=", "<cmd>FzfLua spell_suggest<cr>")
        vim.keymap.set("n", "<space>b", "<cmd>FzfLua buffers cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>B", "<cmd>FzfLua buffers<cr>")
        vim.keymap.set("n", "<space>t", "<cmd>FzfLua tabs<cr>")
        vim.keymap.set("n", "<space>T", "<cmd>FzfLua tags<cr>")
        vim.keymap.set("n", "<space>l", "<cmd>FzfLua blines<cr>")
        vim.keymap.set("n", "<space>L", "<cmd>FzfLua lines<cr>")
        vim.keymap.set("n", "<space>f", function() explore_files(vim.g.getfile():match(".*/")) end)
        vim.keymap.set("n", "<space>F", function() explore_files(vim.fn.getcwd()) end)
        vim.keymap.set("n", "<space>o", "<cmd>FzfLua oldfiles cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>O", "<cmd>FzfLua oldfiles<cr>")
        vim.keymap.set("n", "<space>s", "<cmd>FzfLua grep_project cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>S", "<cmd>FzfLua grep_project<cr>")
        vim.keymap.set("n", "<space>m", "<cmd>FzfLua marks cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>M", "<cmd>FzfLua marks<cr>")
        vim.keymap.set("n", "<space>gg", "<cmd>lua require('fzf-lua').git_status({ cwd='%:p:h', file_ignore_patterns={ '^../' } })<cr>")
        vim.keymap.set("n", "<space>gG", "<cmd>FzfLua git_status<cr>")
        vim.keymap.set("n", "<space>gf", "<cmd>FzfLua git_files cwd_only=true cwd=%:p:h<cr>")
        vim.keymap.set("n", "<space>gF", "<cmd>FzfLua git_files<cr>")
        vim.keymap.set("n", "<space>gl", "<cmd>FzfLua git_bcommits<cr>")
        vim.keymap.set("n", "<space>gL", "<cmd>FzfLua git_commits<cr>")
        vim.keymap.set("n", "<space>gb", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color HEAD..$b; git diff HEAD $b | delta' })<cr>")
        vim.keymap.set("n", "<space>gB", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color origin/HEAD..$b; git diff origin/HEAD $b | delta' })<cr>")
        vim.keymap.set("n", "<space>gs", "<cmd>FzfLua git_stash<cr>")
        -- TODO(later): help_tags doesnt work (command works), man_pages doesnt work (command complains about nil value)
        vim.keymap.set("n", "<space>k", "<cmd>FzfLua help_tags<cr>")
        vim.keymap.set("n", "<space>K", "<cmd>FzfLua man_pages<cr>")
        vim.keymap.set("n", "<space>E", "<cmd>FzfLua diagnostics_document<cr>")
        vim.keymap.set("n", "<space>d", "<cmd>FzfLua lsp_definitions<cr>")
        vim.keymap.set("n", "<space>D", "<cmd>FzfLua lsp_typedefs<cr>")
        vim.keymap.set("n", "<space>r", "<cmd>FzfLua lsp_finder<cr>")
        vim.keymap.set("n", "<space>R", "<cmd>FzfLua lsp_document_symbols<cr>")
        vim.keymap.set("n", "<space>A", "<cmd>FzfLua lsp_code_actions<cr>")
        vim.keymap.set("n", "<space>c", "<cmd>FzfLua quickfix<cr>")
        vim.keymap.set("n", "<space>C", "<cmd>FzfLua quickfix_stack<cr>")
        vim.keymap.set("n", "<space>a", find_altfiles)
        vim.keymap.set("n", "<space>p", find_projects)
        vim.keymap.set("n", "<space>P", save_project)
        vim.keymap.set("n", "<space>u", view_undotree)

        local fzf = require("fzf-lua")
        fzf.setup({
          winopts = {
            fullscreen = false,
            height = 0.33, width = 1.0, row = 1.0, col = 0.5,
            border = { "─", "─", "─", " ", "", "", "", " " },
            hl = { normal = "Normal", border = "NormalBorder", preview_border = "NormalBorder" },
            preview = { flip_columns = 100, scrollchars = { "│", "" }, winopts = { list = true } }
          },
          keymap = {
            builtin = {
              ["<c-_>"] = "toggle-preview",
              ["<c-o>"] = "toggle-fullscreen",
              ["<m-n>"] = "preview-page-down",
              ["<m-p>"] = "preview-page-up",
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
          fzf_opts = { ["--separator='''"] = "", ["--preview-window"] = "border-none" },
          previewers = { man = { cmd = "man %s | col -bx" } },
          defaults = { preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS", file_icons = false, git_icons = true, color_icons = true, cwd_header = false, copen = function() fzf.quickfix() end },
          oldfiles = { include_current_session = true },
          quickfix_stack = { actions = { ["default"] = function() fzf.quickfix() end } },
          git = { status = { actions = { ["right"] = false, ["left"] = false, ["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume } } } }
        })
        if vim.g.arista then
          -- Perforce
          vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\\//]],                                              { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
          vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
          vim.keymap.set("n", "<space>gs", "<cmd>Achanged<cr>")
          vim.keymap.set("n", "<space>go", "<cmd>Aopened<cr>")
          -- Opengrok
          vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(vim.g.getfile():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          -- Agid
          vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
          vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(vim.g.getfile():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.keymap.set("n", "<space>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
        end
        END
      '';
      }
      # TODO(later): neogit/vim-fugitive
    ];
    extraLuaConfig = ''

      -- Get full path of path or current buffer
      vim.g.getfile = function(path)
        return vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")
      end

      -- Consistent aesthetics
      vim.lsp.protocol.CompletionItemKind = {
        '""', ".f", "fn", "()", ".x",
        "xy", "{}", "{}", "[]", ".p",
        "$$", "00", "∀e", ";;", "~~",
        "rg", "/.", "&x", "//", "∃e",
        "#x", "{}", "ev", "++", "<>"
      }

      -- Provide method to apply ftplugin and syntax settings to all filetypes
      -- TODO(later): still used? maybe for snippets and arista .tac syntax
      -- vim.g.myfiletypefile = vim.fn.stdpath("config").."/ftplugin/ftplugin.vim"
      -- vim.g.mysyntaxfile = vim.fn.stdpath("config").."/syntax/syntax.vim"

      vim.opt.title = true                                   -- Update window title
      vim.opt.mouse = "a"                                    -- Enable mouse support
      vim.opt.updatetime = 100                               -- Faster refreshing
      vim.opt.timeoutlen = 5000                              -- 5 seconds to complete mapping
      vim.opt.clipboard = "unnamedplus"                      -- Use system clipboard
      vim.opt.undofile = true                                -- Write undo history to disk
      vim.opt.swapfile = false                               -- No need for swap files
      vim.opt.modeline = false                               -- Don't read mode line
      vim.opt.virtualedit = "onemore"                        -- Allow cursor to extend one character past the end of the line
      vim.opt.grepprg = "rg --vimgrep --smart-case --follow" -- Use ripgrep for grepping
      vim.opt.number = true                                  -- Enable line numbers...
      vim.opt.relativenumber = false                         -- ...and not relative line numbers
      vim.opt.ruler = false                                  -- No need to show line/column number with lightline
      vim.opt.showmode = false                               -- No need to show current mode with lightline
      vim.opt.scrolloff = 3                                  -- Keep lines above/below the cursor when scrolling
      vim.opt.sidescrolloff = 5                              -- Keep columns to the left/right of the cursor when scrolling
      vim.opt.signcolumn = "no"                              -- Keep the sign column closed
      vim.opt.shortmess:append("sSIcC")                      -- Be quieter
      vim.opt.expandtab = false                              -- Tab key inserts tabs
      vim.opt.tabstop = 4                                    -- 4-spaced tabs
      vim.opt.shiftwidth = 0                                 -- Tab-spaced indentation
      vim.opt.cinoptions = "N-s"                             -- Don't indent C++ namespaces
      vim.opt.list = true                                    -- Enable whitespace characters below
      vim.opt.listchars="space:·,tab:› ,trail:•,precedes:<,extends:>,nbsp:␣"
      vim.opt.suffixes:remove(".h")                          -- Header files are important...
      vim.opt.suffixes:append(".git")                        -- ...but .git files are not
      vim.opt.foldmethod = "indent"                          -- Fold based on indent
      vim.opt.foldlevelstart = 20                            -- ...and start with everything open
      vim.opt.wrap = false                                   -- Don't wrap
      vim.opt.lazyredraw = true                              -- Redraw only after commands have completed
      vim.opt.termguicolors = true                           -- Enable true colors and gui cursor
      vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400"
      vim.opt.ignorecase = true                              -- Ignore case when searching...
      vim.opt.smartcase = true                               -- ...except for searching with uppercase characters
      vim.opt.complete = ".,w,kspell"                        -- Complete menu contents
      vim.opt.completeopt = "menu,menuone,noinsert,noselect" -- Complete menu functionality
      vim.opt.pumheight = 8                                  -- Limit complete menu height
      vim.opt.spell = true                                   -- Enable spelling by default
      vim.opt.spelloptions = "camel"                         -- Enable CamelCase word spelling
      vim.opt.spellsuggest = "best,20"                       -- Only show best spelling corrections
      vim.opt.spellcapcheck = ""                             -- Don't care about capitalisation
      vim.opt.dictionary = "/usr/share/dict/words"           -- Dictionary file
      vim.opt.shada = "!,'256,<50,s100,h,r/media"            -- Specify removable media for shada
      vim.opt.undolevels = 2048                              -- More undo space
      vim.opt.diffopt = "internal,filler,context:512"        -- I like lots of diff context
      vim.opt.hidden = true                                  -- Modified buffers can be hidden
      vim.opt.wildmode = "longest:full,full"                 -- Match common and show wildmenu
      vim.opt.wildoptions = "fuzzy,pum"                      -- Wildmenu fuzzy matching and ins-completion menu
      vim.opt.wildignorecase = true                          -- Don't care about wildmenu file capitalisation

      -- Is this an Arista environment?
      vim.g.arista = vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and vim.fn.getcwd():find("^/src") ~= nil
      if vim.g.arista then
        vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})

        -- Always rooted at /src
        vim.fn.chdir("/src")

        -- Source arista.vim but override A4edit and A4revert
        vim.cmd([[
          let g:a4_auto_edit = 0
          source /usr/share/vim/vimfiles/arista.vim
          function! A4edit()
            if strlen(glob(expand('%')))
              belowright split
              exec 'terminal a p4 login && a p4 edit '.shellescape(expand('%:p'))
            endif
          endfunction
          function! A4revert()
            if strlen(glob(expand('%'))) && confirm('Revert Perforce file changes?', '&Yes\n&No', 1) == 1
              exec 'terminal a p4 login && a p4 revert '.shellescape(expand('%:p'))
              set readonly
            endif
          endfunction
        ]])
        vim.api.nvim_create_user_command("Aedit", "call A4edit()", {})
        vim.api.nvim_create_user_command("Arevert", "call A4revert()", {})
      end

      -- Return the alphabetically previous and next files
      local function prev_next_file(file)
        file = (file or vim.g.getfile()):gsub("/$", "")
        local prev, dir = file, file:match(".*/") or "/"
        local files = (vim.fn.glob(dir..".[^.]*").."\n"..vim.fn.glob(dir.."*")):gmatch("[^\n]+")
        for next in files do
          if next == file then return prev, files() or next
          elseif next > file then return prev, next
          else prev = next end
        end
        return prev, file
      end

      vim.g.mapleader = " "
      vim.keymap.set("n", "<space>", "")
      -- Split lines at cursor, opposite of <s-j>
      vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
      -- Terminal shortcuts
      vim.keymap.set("n", "<space><return>", "<cmd>belowright split | terminal<cr>")
      vim.keymap.set("t", "<esc>", "(&filetype == 'fzf') ? '<esc>' : '<c-\\><c-n>'", { expr = true })
      -- Open notes
      vim.keymap.set("n", "<space>n", "<cmd>lcd ~/Documents/notes | enew | set filetype=markdown<cr>")
      vim.keymap.set("n", "<space>N", "<cmd>lcd ~/Documents/notes | edit `=strftime('./journal/%Y/%m/%d.md')` | call mkdir(expand('%:h'), 'p')<cr>")
      -- LSP
      vim.keymap.set("n", "<space><space>", "<cmd>lua vim.lsp.buf.hover()<cr>")
      vim.keymap.set("n", "<space>k",        "<cmd>lua vim.lsp.buf.code_action()<cr>")
      vim.keymap.set("n", "]e",               "<cmd>lua vim.diagnostic.goto_next()<cr>")
      vim.keymap.set("n", "[e",               "<cmd>lua vim.diagnostic.goto_prev()<cr>")
      vim.keymap.set("n", "<space>e",        "<cmd>lua vim.diagnostic.open_float()<cr>")
      vim.keymap.set("n", "<space>E",        "<cmd>lua vim.diagnostic.setqflist()<cr>")
      vim.keymap.set("n", "<space>d",        "<cmd>lua vim.lsp.buf.definition()<cr>")
      vim.keymap.set("n", "<space>t",        "<cmd>lua vim.lsp.buf.type_definition()<cr>")
      vim.keymap.set("n", "<space>r",        "<cmd>lua vim.lsp.buf.references()<cr>")
      -- Buffers
      vim.keymap.set("n", "[b", "<cmd>bprevious<cr>")
      vim.keymap.set("n", "]b", "<cmd>bnext<cr>")
      vim.keymap.set("n", "[B", "<cmd>bfirst<cr>")
      vim.keymap.set("n", "]B", "<cmd>blast<cr>")
      -- Files
      vim.keymap.set("n", "[f", function() vim.cmd("edit "..select(1, prev_next_file())) end)
      vim.keymap.set("n", "]f", function() vim.cmd("edit "..select(2, prev_next_file())) end)
      vim.keymap.set("n", "[F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; cur, _ = prev_next_file(cur) end vim.cmd("edit "..cur) end)
      vim.keymap.set("n", "]F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; _, cur = prev_next_file(cur) end vim.cmd("edit "..cur) end)
      -- Quickfix
      vim.keymap.set("n", "[c", "<cmd>cprevious<cr>")
      vim.keymap.set("n", "]c", "<cmd>cnext<cr>")
      vim.keymap.set("n", "[C", "<cmd>cfirst<cr>")
      vim.keymap.set("n", "]C", "<cmd>clast<cr>")
      -- Toggles
      vim.keymap.set("n", "yo", "")
      vim.keymap.set("n", "yot", "<cmd>set expandtab! expandtab?<cr>")
      vim.keymap.set("n", "yow", "<cmd>set wrap! wrap?<cr>")
      vim.keymap.set("n", "yon", "<cmd>set number! number?<cr>")
      vim.keymap.set("n", "yor", "<cmd>set relativenumber! relativenumber?<cr>")
      vim.keymap.set("n", "yoi", "<cmd>set ignorecase! ignorecase?<cr>")
      vim.keymap.set("n", "yol", "<cmd>set list! list?<cr>")
      vim.keymap.set("n", "yoz", "<cmd>set spell! spell?<cr>")
      vim.keymap.set("n", "yod", "<cmd>if &diff | diffoff | else | diffthis | endif<cr>")

      -- Highlight suspicious whitespace
      local function get_whitespace_pattern()
        local pattern = [[[\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff]\+\|\s\+$\|[\u0020]\+\ze[\u0009]\+]]
        return "\\("..(vim.o.expandtab and pattern..[[\|^[\u0009]\+]] or pattern..[[\|^[\u0020]\+]]).."\\)"
      end
      local function apply_whitespace_pattern(pattern)
        local no_ft = { diff=1, git=1, gitcommit=1, markdown=1 }
        local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
        if no_ft[vim.o.ft] or no_bt[vim.o.bt] then vim.cmd("match none") else vim.cmd("match ExtraWhitespace '"..pattern.."'") end
      end
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen", "InsertLeave" }, { callback = function()
        apply_whitespace_pattern(get_whitespace_pattern())
      end })
      vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, { callback = function()
        local line, pattern = vim.fn.line("."), get_whitespace_pattern()
        apply_whitespace_pattern("\\%<"..line.."l"..pattern.."\\|\\%>"..line.."l"..pattern)
      end })

      -- Remember last cursor position
      vim.api.nvim_create_autocmd("BufWinEnter", { callback = function()
        local no_ft = { diff=1, git=1, gitcommit=1, gitrebase=1 }
        local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
        if not (no_ft[vim.o.ft] or no_bt[vim.o.buftype] or vim.fn.line(".") > 1 or vim.fn.line("'\"") <= 0 or vim.fn.line("'\"") > vim.fn.line("$")) then
          vim.cmd([[normal! g`"]])
        end
      end })

      -- Hide cursorline if not in current buffer
      vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = false, false end })
      vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "FocusGained" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = true, true end })

      -- Keep universal formatoptions
      vim.api.nvim_create_autocmd("Filetype", { callback = function() vim.o.formatoptions = "rqlj" end })

      -- Swap to manual folding after loading
      vim.api.nvim_create_autocmd("BufWinEnter", { callback = function() vim.o.foldmethod = "manual" end })
    '';
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--follow"
      "--hidden"
      "--smart-case"
      "--max-columns=512"
      "--max-columns-preview"
      "--glob=!{**/node_modules/*,**/.git/*}"
      "--type-add=tac:*.tac"
      "--type-add=tac:*.tac"
      "--type-add=tin:*.tin"
      "--type-add=itin:*.itin"
    ];
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "12h";
    serverAliveCountMax = 3;
    serverAliveInterval = 5;
    #matchBlocks."bus".host = "bus-*";
    #matchBlocks."bus".user = "tedj";
    #matchBlocks."bus".forwardAgent = true;
    #matchBlocks."bus".extraOptions = {
    #  StrictHostKeyChecking = "false";
    #  UserKnownHostsFile = "/dev/null";
    #  RemoteForward = "/bus/gnupg/S.gpg-agent $HOME/.gnupg/S.gpg-agent.extra";
    #};
    #matchBlocks."bus-home".host = "bus-home";
    #matchBlocks."bus-home".hostname = "10.244.168.5";
    #matchBlocks."bus-home".port = 22110;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';
    defaultKeymap = "emacs";
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit -d '${config.xdg.cacheHome}/zcompdump'";
    history = { path = "${config.xdg.dataHome}/zsh_history"; extended = true; ignoreAllDups = true; share = true; save = 1000000; size = 1000000; };
    localVariables.PROMPT = "\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f ";
    localVariables.TIMEFMT = "\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P";
    shellAliases.z = "exec zsh ";
    shellAliases.v = "nvim ";
    shellAliases.p = "python3 ";
    shellAliases.c = "cargo ";
    shellAliases.g = "git ";
    shellAliases.rm = "2>&1 echo rm disabled, use del; return 1 && ";
    shellAliases.ls = "eza ";
    shellAliases.ll = "ls -la ";
    shellAliases.lt = "ll -T ";
    shellAliases.ip = "ip --color ";
    shellAliases.sudo = "sudo --preserve-env ";
    shellGlobalAliases.cat = "bat --paging=never ";
    shellGlobalAliases.grep = "rg ";
    autosuggestion = { enable = true; strategy = [ "history" "completion" ]; };
    localVariables.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 100;
    localVariables.ZSH_AUTOSUGGEST_ACCEPT_WIDGETS = [ "end-of-line" "vi-end-of-line" "vi-add-eol" ];
    localVariables.ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS = [ "forward-char" "vi-forward-char" "forward-word" "emacs-forward-word" "vi-forward-word" "vi-forward-word-end" "vi-forward-blank-word" "vi-forward-blank-word-end" "vi-find-next-char" "vi-find-next-char-skip" ];
    syntaxHighlighting.enable = true;
    syntaxHighlighting.styles.default = "fg=cyan";
    syntaxHighlighting.styles.unknown-token = "fg=red";
    syntaxHighlighting.styles.reserved-word = "fg=blue";
    syntaxHighlighting.styles.path = "fg=cyan,underline";
    syntaxHighlighting.styles.suffix-alias = "fg=blue,underline";
    syntaxHighlighting.styles.precommand = "fg=blue,underline";
    syntaxHighlighting.styles.commandseparator = "fg=magenta";
    syntaxHighlighting.styles.globbing = "fg=magenta";
    syntaxHighlighting.styles.history-expansion = "fg=magenta";
    syntaxHighlighting.styles.single-hyphen-option = "fg=green";
    syntaxHighlighting.styles.double-hyphen-option = "fg=green";
    syntaxHighlighting.styles.rc-quote = "fg=cyan,bold";
    syntaxHighlighting.styles.dollar-double-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.back-double-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.back-dollar-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.assign = "none";
    syntaxHighlighting.styles.redirection = "fg=yellow,bold";
    syntaxHighlighting.styles.named-fd = "none";
    syntaxHighlighting.styles.arg0 = "fg=blue";
    initExtra = ''
      setopt autopushd pushdsilent
      setopt promptsubst notify
      setopt completeinword globcomplete globdots

      # word delimiters
      autoload -U select-word-style
      select-word-style bash

      # home end delete
      bindkey "^[[H"  beginning-of-line
      bindkey "^[[F"  end-of-line
      bindkey "^[[3~" delete-char

      # command line editor
      autoload edit-command-line
      zle -N edit-command-line
      bindkey "^V" edit-command-line

      # beam cursor
      zle -N zle-line-init
      zle-line-init() { echo -ne "\e[6 q" }

      # history search
      autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      for k in "^[p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
      for k in "^[n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search

      # completion
      autoload -U bashcompinit && bashcompinit
      bindkey "^[[Z" reverse-menu-complete
      zstyle ":completion:*" menu select
      zstyle ":completion:*" completer _complete _match _approximate
      zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "+l:|=* r:|=*"
      zstyle ":completion:*" expand prefix suffix 
      zstyle ":completion:*" use-cache on
      zstyle ":completion:*" cache-path "${config.xdg.cacheHome}/zcompcache"
      zstyle ":completion:*" group-name ""
      zstyle ":completion:*" list-colors "''${(s.:.)LS_COLORS}"
      zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
      zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
      zstyle ":completion:*:warnings" format " %F{red}-- no matches --%f"

      # gpg+ssh
      # TODO(gpg): this should probably be done in gpg-agent config
      # export SSH_AGENT_PID=""
      # export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      # (gpgconf --launch gpg-agent &)

      cht() { cht.sh "$@?style=paraiso-dark"; }
      _cht() { compadd $commands:t; }; compdef _cht cht

      #ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ''${@:+-c -- a4c shell $@}; }
      #_ash() { compadd "$(ssh us260 -- a4c ps -N)"; }; compdef _ash ash
    '';
  };

  programs.fzf = {
    enable = true;
    colors = { "fg" = "bold"; "pointer" = "red"; "hl" = "red"; "hl+" = "red"; "gutter" = "-1"; "marker" = "red"; };
    defaultCommand = "rg --files --no-messages";
    defaultOptions = [ "--multi" "--bind='ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview'" "--preview-window sharp" "--marker=k" "--color=fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red" "--history ${config.xdg.dataHome}/fzf_history" ];
    changeDirWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules' --type d";
    fileWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules'";
  };

  programs.fastfetch = {
    enable = true;
    settings = {};
  };

  # TODO: tmux?

  nix.package = pkgs.nix;
  nix.settings = { auto-optimise-store = true; use-xdg-base-directories = true; experimental-features = [ "nix-command" "flakes" ]; };
  nixpkgs.config.allowUnfree = true;
  systemd.user.startServices = "sd-switch";
  targets.genericLinux.enable = true;
}
