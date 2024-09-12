# media management
{ pkgs, ... }: {

  services.playerctld.enable = true;

  wayland.windowManager.sway.config.keybindings."--locked XF86AudioPlay"         = "exec playerctl play-pause";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioPlay"   = "exec playerctl pause";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioPlay" = "exec playerctl stop";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioPrev"         = "exec playerctl position 1-";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioPrev"   = "exec playerctl position 10-";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioPrev" = "exec playerctl previous";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioNext"         = "exec playerctl position 1+";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioNext"   = "exec playerctl position 10+";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioNext" = "exec playerctl next";

}
