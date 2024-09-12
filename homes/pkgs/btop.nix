# htop but better
{ ... }: {

  programs.btop.enable = true;
  programs.btop.settings.theme_background = false;
  programs.btop.settings.vim_keys = true;
  programs.btop.settings.rounded_corners = false;
  programs.btop.settings.update_ms = 1000;
  programs.btop.settings.proc_sorting = "cpu lazy";
  programs.btop.settings.proc_tree = false;
  programs.btop.settings.proc_filter_kernel = true;
  programs.btop.settings.proc_aggregate = true;

  wayland.windowManager.sway.config.keybindings."Mod4+Shift+u" = ''exec scratch floating-btop btop'';

}
