# TODO(later): replace with foot
{ ... }: {
  home.sessionVariables.TERMINAL = "alacritty";
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    live_config_reload = false;
    scrolling = { history = 10000; multiplier = 5; };
    window = { dynamic_padding = true; opacity = 0.85; dimensions = { columns = 120; lines = 40; }; };
    font = { size = 13.5; normal.family = "Terminess Nerd Font"; };
    selection.save_to_clipboard = true;
    keyboard.bindings = [
      { key = "Return"; mods = "Shift|Control"; action = "SpawnNewInstance"; }
      { key = "Escape"; mods = "Shift|Control"; action = "ToggleViMode"; }
      { key = "Escape"; mode = "Vi"; action = "ToggleViMode"; }
    ];
    colors.draw_bold_text_with_bright_colors = true;
    colors.primary = { background = "#000000"; foreground = "#dddddd"; };
    colors.cursor = { cursor = "#cccccc"; text = "#111111"; };
    colors.normal = { black = "#000000"; blue = "#0d73cc"; cyan = "#0dcdcd"; green = "#19cb00"; magenta = "#cb1ed1"; red = "#cc0403"; white = "#dddddd"; yellow = "#cecb00"; };
    colors.bright = { black = "#767676"; blue = "#1a8fff"; cyan = "#14ffff"; green = "#23fd00"; magenta = "#fd28ff"; red = "#f2201f"; white = "#ffffff"; yellow = "#fffd00"; };
    colors.search.focused_match = { background = "#ffffff"; foreground = "#000000"; };
    colors.search.matches = { background = "#edb443"; foreground = "#091f2e"; };
    colors.footer_bar = { background = "#000000"; foreground = "#ffffff"; };
    colors.line_indicator = { background = "#000000"; foreground = "#ffffff"; };
    colors.selection = { background = "#fffacd"; text = "#000000"; };
  };
}
