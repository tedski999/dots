# backlight brightness
{ pkgs, ... }: {

  imports = [ ./libnotify.nix ];

  home.packages = with pkgs; [ brightnessctl ];

  wayland.windowManager.sway.extraConfigEarly = ''set $send_brightness_notif b=$(($(brightnessctl get)00/$(brightnessctl max))) && notify-send -i brightness-high --category osd --hint "int:value:$b" "Brightness: $b%"'';
  wayland.windowManager.sway.config.keybindings."--locked XF86MonBrightnessDown"         = "exec brightnessctl set 1%-  && $send_brightness_notif";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86MonBrightnessDown"   = "exec brightnessctl set 10%- && $send_brightness_notif";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86MonBrightnessDown" = "exec brightnessctl set 1    && $send_brightness_notif";
  wayland.windowManager.sway.config.keybindings."--locked XF86MonBrightnessUp"           = "exec brightnessctl set 1%+  && $send_brightness_notif";
  wayland.windowManager.sway.config.keybindings."--locked Shift+XF86MonBrightnessUp"     = "exec brightnessctl set 10%+ && $send_brightness_notif";
  wayland.windowManager.sway.config.keybindings."--locked Control+XF86MonBrightnessUp"   = "exec brightnessctl set 100% && $send_brightness_notif";

}
