# volume mixer
{ pkgs, ... }: {

  home.packages = with pkgs; [ pulsemixer ];

  wayland.windowManager.sway.extraConfigEarly = ''set $send_volume_notif v=$(pulsemixer --get-volume | cut -d' ' -f1) && notify-send -i audio-volume-high --category osd --hint "int:value:$v" "Volume: $v% $([ $(pulsemixer --get-mute) = 1 ] && echo '[MUTED]')"'';
  wayland.windowManager.sway.config.keybindings."Mod4+u"                                                = "exec scratch floating-pulsemixer pulsemixer";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioMute"                                = "exec pulsemixer --toggle-mute       && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioMute"                          = "exec                                   $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioMute"                        = "exec pulsemixer --toggle-mute       && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioLowerVolume"                         = "exec pulsemixer --change-volume  -1 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioLowerVolume"                   = "exec pulsemixer --change-volume -10 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioLowerVolume"                 = "exec pulsemixer --set-volume      0 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioRaiseVolume"                         = "exec pulsemixer --change-volume  +1 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86AudioRaiseVolume"                   = "exec pulsemixer --change-volume +10 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86AudioRaiseVolume"                 = "exec pulsemixer --set-volume    100 && $send_volume_notif";
  wayland.windowManager.sway.config.keybindings."--locked --no-repeat Pause"                            = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --unmute";
  wayland.windowManager.sway.config.keybindings."--locked --no-repeat --release Pause"                  = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --mute";
  wayland.windowManager.sway.config.keybindings."--locked --no-repeat --release --whole-window button8" = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";
  wayland.windowManager.sway.config.keybindings."--locked XF86AudioMicMute"                             = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";

}
