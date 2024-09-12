# lf but better
{ ... }: {

  # TODO(later): DDS for multiclient usage
  programs.yazi.enable = true;
  programs.yazi.enableZshIntegration = true;
  programs.yazi.shellWrapperName = "y";
  programs.yazi.settings.manager.ratio =  [0  3  2];
  programs.yazi.settings.manager.show_hidden = true;
  programs.yazi.settings.manager.scrolloff = 3;
  programs.yazi.settings.preview.tab_size = 4;
  programs.yazi.theme.manager.border_symbol = " ";
  programs.yazi.theme.manager.cwd.fg = "blue";
  programs.yazi.theme.manager.hovered.reversed = true;
  programs.yazi.theme.manager.preview_hovered.reversed = true;
  programs.yazi.theme.status.separator_open = "";
  programs.yazi.theme.status.separator_close = "";
  programs.yazi.theme.status.separator_style = { bg = "black"; fg = "black"; };
  programs.yazi.theme.status.mode_normal = { bg = "darkgrey"; bold = true; };
  programs.yazi.theme.status.mode_select = { bg = "blue"; bold = true; };
  programs.yazi.theme.status.mode_unset  = { bg = "blue"; bold = true; };
  programs.yazi.theme.filetype.rules = [
   { mime = "image/*"; fg = "yellow"; }
   { mime = "{audio;video}/*"; fg = "magenta"; }
   { mime = "application/{;g}zip"; fg = "red"; }
   { mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}"; fg = "red"; }
   { mime = "application/{pdf,doc,rtf,vnd.*}"; fg = "cyan"; }
   { mime = "inode/x-empty"; fg = "darkgrey"; }
   { name = "*"; is = "orphan"; bg = "red"; }
   { name = "*"; is = "exec"  ; fg = "green"; }
   { name = "*"; is = "dummy"; bg = "red"; }
   { name = "*/"; is = "dummy"; bg = "red"; }
   { name = "*"; fg = "white"; }
   { name = "*/"; fg = "blue"; }
  ];
  programs.yazi.theme.icon.globs = [];
  programs.yazi.theme.icon.dirs  = [];
  programs.yazi.theme.icon.files = [];
  programs.yazi.theme.icon.exts  = [];
  programs.yazi.theme.icon.conds = [];
  programs.yazi.keymap.manager.prepend_keymap = [
    { on = "z"; run = "plugin fzf"; } # TODO
    { on = "<C-s>"; run = "shell \"$SHELL\" --block --confirm"; }
  ];
  programs.yazi.initLua = ''
    Header:children_add(function()
      return ui.Span(ya.user_name().."@"..ya.host_name().." "):fg("red")
    end, 500, Header.LEFT)
    Status:children_add(function()
      local c = cx.active.current.hovered.cha
      return ui.Span((ya.user_name(c.uid) or tostring(c.uid))..":"..(ya.group_name(c.gid) or tostring(c.gid)).." "):fg("magenta")
    end, 500, Status.RIGHT)
  '';

}
