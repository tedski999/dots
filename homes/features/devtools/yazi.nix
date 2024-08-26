# lf but better
{ ... }: {
  # TODO(later): DDS for multiclient usage
  programs.yazi.enable = true;
  programs.yazi.enableZshIntegration = true;
  programs.yazi.shellWrapperName = "y";
  programs.yazi.settings = {
    manager.ratio =  [0  3  2];
    manager.show_hidden = true;
    manager.scrolloff = 3;
    preview.tab_size = 4;
  };
  programs.yazi.theme = {
    manager.border_symbol = " ";
    manager.cwd.fg = "blue";
    manager.hovered.reversed = true;
    manager.preview_hovered.reversed = true;
    status.separator_open = "";
    status.separator_close = "";
    status.separator_style = { bg = "black"; fg = "black"; };
    status.mode_normal = { bg = "darkgrey"; bold = true; };
    status.mode_select = { bg = "blue"; bold = true; };
    status.mode_unset  = { bg = "blue"; bold = true; };
    filetype.rules = [
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
    icon.globs = [];
    icon.dirs  = [];
    icon.files = [];
    icon.exts  = [];
    icon.conds = [];
  };
  programs.yazi.keymap = {
    manager.prepend_keymap = [
      { on = "z"; run = "plugin fzf"; } # TODO
      { on = "<C-s>"; run = "shell \"$SHELL\" --block --confirm"; }
    ];
  };
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
