# xterm but better
{ ... }: {

  imports = [ ./fontconfig.nix ];

  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty.enable = true;
  programs.alacritty.settings.live_config_reload = false;
  programs.alacritty.settings.scrolling = { history = 10000; multiplier = 5; };
  programs.alacritty.settings.window = { dynamic_padding = true; opacity = 0.85; dimensions = { columns = 120; lines = 40; }; };
  programs.alacritty.settings.font = { size = 13.5; normal.family = "Terminess Nerd Font"; };
  programs.alacritty.settings.selection.save_to_clipboard = true;
  programs.alacritty.settings.keyboard.bindings = [
    { key = "Return"; mods = "Shift|Control"; action = "SpawnNewInstance"; }
    { key = "Escape"; mods = "Shift|Control"; action = "ToggleViMode"; }
    { key = "Escape"; mode = "Vi"; action = "ToggleViMode"; }
  ];
  programs.alacritty.settings.colors.draw_bold_text_with_bright_colors = true;
  programs.alacritty.settings.colors.primary = { background = "#000000"; foreground = "#dddddd"; };
  programs.alacritty.settings.colors.cursor = { cursor = "#cccccc"; text = "#111111"; };
  programs.alacritty.settings.colors.normal = { black = "#000000"; blue = "#0d73cc"; cyan = "#0dcdcd"; green = "#19cb00"; magenta = "#cb1ed1"; red = "#cc0403"; white = "#dddddd"; yellow = "#cecb00"; };
  programs.alacritty.settings.colors.bright = { black = "#767676"; blue = "#1a8fff"; cyan = "#14ffff"; green = "#23fd00"; magenta = "#fd28ff"; red = "#f2201f"; white = "#ffffff"; yellow = "#fffd00"; };
  programs.alacritty.settings.colors.search.focused_match = { background = "#ffffff"; foreground = "#000000"; };
  programs.alacritty.settings.colors.search.matches = { background = "#edb443"; foreground = "#091f2e"; };
  programs.alacritty.settings.colors.footer_bar = { background = "#000000"; foreground = "#ffffff"; };
  programs.alacritty.settings.colors.line_indicator = { background = "#000000"; foreground = "#ffffff"; };
  programs.alacritty.settings.colors.selection = { background = "#fffacd"; text = "#000000"; };

}
