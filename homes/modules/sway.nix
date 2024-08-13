# i3 but better
{ pkgs, config, ... }: {
  home.sessionVariables.QT_QPA_PLATFORM = "wayland";
  home.sessionVariables.LIBSEAT_BACKEND = "logind";
  home.packages = with pkgs; [ nixgl.nixGLIntel wl-clipboard brightnessctl grim slurp pulsemixer ];
  services.cliphist.enable = true;
  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.wrapperFeatures.gtk = true;
  wayland.windowManager.sway.systemd.enable = true;
  wayland.windowManager.sway.systemd.variables = [ "--all" ];
  wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];

  wayland.windowManager.sway.extraConfigEarly = ''
    set $send_volume_notif v=$(pulsemixer --get-volume | cut -d' ' -f1) && notify-send -i audio-volume-high --category osd --hint "int:value:$v" "Volume: $v% $([ $(pulsemixer --get-mute) = 1 ] && echo '[MUTED]')"
    set $send_brightness_notif b=$(($(brightnessctl get)00/$(brightnessctl max))) && notify-send -i brightness-high --category osd --hint "int:value:$b" "Brightness: $b%"
    set $get_views vs=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | select(.visible).id")
    set $get_focused f=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | first(select(.focused)).id")
    set $get_output o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial')
    set $get_workspaces ws=$(swaymsg -rt get_workspaces | jq -r ".[].num")
    set $get_prev_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) - 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
    set $get_next_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) + 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
    set $get_empty_workspace w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num as $w | first(range(1; 9) | select(. != $w))')
    # TODO(later): doesnt work well at high speeds (e.g. key held down)
    set $group swaymsg "mark --add g" || swaymsg "splitv, mark --add g"
    set $ungroup swaymsg "[con_mark=g] focus, unmark g" || swaymsg "focus parent; focus parent; focus parent; focus parent"
  '';

  wayland.windowManager.sway.config = {
    modifier = "Mod4";
    workspaceLayout = "default";
    output."*".bg = "#101010 solid_color";
    focus = { followMouse = true; mouseWarping = "output"; wrapping = "no"; };
    floating = { modifier = "Mod4"; border = 1; titlebar = false; };
    window = { border = 1; hideEdgeBorders = "none"; titlebar = false; commands = [
      { criteria.class = ".*"; command = "border pixel 1"; }
      { criteria.app_id = ".*"; command = "border pixel 1"; }
      { criteria.app_id = "floating.*"; command = "floating enable"; }
    ]; };
    gaps.inner = 5;
    colors.focused         = { border = "#202020"; background = "#ffffff"; text = "#000000"; indicator = "#ff0000"; childBorder = "#ffffff"; };
    colors.focusedInactive = { border = "#202020"; background = "#202020"; text = "#ffffff"; indicator = "#202020"; childBorder = "#202020"; };
    colors.unfocused       = { border = "#202020"; background = "#202020"; text = "#808080"; indicator = "#202020"; childBorder = "#202020"; };
    colors.urgent          = { border = "#2f343a"; background = "#202020"; text = "#ffffff"; indicator = "#900000"; childBorder = "#900000"; };
    input."type:keyboard".xkb_layout = "ie";
    input."type:keyboard".xkb_options = "caps:escape";
    input."type:keyboard".repeat_delay = "250";
    input."type:keyboard".repeat_rate = "30";
    input."type:touchpad".dwt = "disabled";
    input."type:touchpad".tap = "enabled";
    input."type:touchpad".natural_scroll = "enabled";
    input."type:touchpad".click_method = "clickfinger";
    input."type:touchpad".scroll_method = "two_finger";
    modes = {};
    fonts = {};
    bars = [ { command = "waybar"; mode = "hide"; } ];
    startup = [
      { command = "pidof -x batteryd || batteryd"; always = true; }
      { command = "pidof -x bmbwd || bmbwd"; always = true; }
      { command = "displayctl";  always = true; }
      { command = "powerctl decafeinate"; }
      #{ command = "scratch floating-btop btop"; }
      #{ command = "scratch floating-pulsemixer pulsemixer"; }
    ];
    # shortcuts
    keybindings."Mod4+space" = "exec bemenu-run";
    keybindings."Mod4+Return" = "exec alacritty";
    keybindings."Mod4+t" = "exec alacritty";
    keybindings."Mod4+w" = "exec firefox";
    keybindings."Mod4+d" = "exec firefox 'https://discord.com/app'";
    keybindings."Mod4+Escape"                        = "exec powerctl";
    keybindings."Mod4+Shift+Escape"                  = "exec powerctl lock";
    keybindings."--locked Mod4+Control+Escape"       = "exec powerctl suspend";
    keybindings."--locked Mod4+Control+Shift+Escape" = "exec powerctl reload";
    keybindings."Mod4+Apostrophe"               = "exec displayctl";
    keybindings."Mod4+Shift+Apostrophe"         = "exec displayctl external";
    keybindings."Mod4+Control+Apostrophe"       = "exec displayctl internal";
    keybindings."Mod4+Control+Shift+Apostrophe" = "exec displayctl both";
    keybindings."Mod4+n"         = "exec networkctl";
    keybindings."Mod4+Shift+n"   = "exec networkctl wifi";
    keybindings."Mod4+Control+n" = "exec networkctl bluetooth";
    keybindings."Mod4+u"       = ''exec scratch floating-pulsemixer pulsemixer'';
    keybindings."Mod4+Shift+u" = ''exec scratch floating-btop btop'';
    keybindings."Mod4+b"         = "exec pkill -USR1 bmbwd";
    keybindings."Mod4+Shift+b"   = "exec pkill -USR2 bmbwd";
    keybindings."Mod4+Control+b" = "exec pkill -TERM bmbwd";
    keybindings."Mod4+v" = "exec cliphist list | bemenu --prompt 'Clipboard' | cliphist decode | wl-copy";
    keybindings."Mod4+grave"         = "exec makoctl dismiss";
    keybindings."Mod4+Shift+grave"   = "exec makoctl restore";
    keybindings."Mod4+Control+grave" = "exec makoctl menu bemenu --prompt 'Action'";
    # containers
    keybindings."Mod4+h"         = "focus left";
    keybindings."Mod4+Shift+h"   = "exec $group && swaymsg 'move left 50px' && $ungroup";
    keybindings."Mod4+Control+h" = "resize shrink width 50px";
    keybindings."Mod4+j"         = "focus down";
    keybindings."Mod4+Shift+j"   = "exec $group && swaymsg 'move down 50px' && $ungroup";
    keybindings."Mod4+Control+j" = "resize grow height 50px";
    keybindings."Mod4+k"         = "focus up";
    keybindings."Mod4+Shift+k"   = "exec $group && swaymsg 'move up 50px' && $ungroup";
    keybindings."Mod4+Control+k" = "resize shrink height 50px";
    keybindings."Mod4+l"         = "focus right";
    keybindings."Mod4+Shift+l"   = "exec $group && swaymsg 'move right 50px' && $ungroup";
    keybindings."Mod4+Control+l" = "resize grow width 50px";
    # TODO(later): doesnt really work
    #keybindings."Mod4+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | cat | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
    #keybindings."Mod4+Shift+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | tac | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
    keybindings."Mod4+f" = "focus mode_toggle";
    keybindings."Mod4+Shift+f" = "border pixel 1, floating toggle";
    keybindings."Mod4+x" = "sticky toggle";
    keybindings."Mod4+m" = "fullscreen";
    keybindings."Mod4+q" = "kill";
    # workspaces
    keybindings."Mod4+1" = ''exec $get_output && swaymsg "workspace 1:$o"'';
    keybindings."Mod4+2" = ''exec $get_output && swaymsg "workspace 2:$o"'';
    keybindings."Mod4+3" = ''exec $get_output && swaymsg "workspace 3:$o"'';
    keybindings."Mod4+4" = ''exec $get_output && swaymsg "workspace 4:$o"'';
    keybindings."Mod4+5" = ''exec $get_output && swaymsg "workspace 5:$o"'';
    keybindings."Mod4+6" = ''exec $get_output && swaymsg "workspace 6:$o"'';
    keybindings."Mod4+7" = ''exec $get_output && swaymsg "workspace 7:$o"'';
    keybindings."Mod4+8" = ''exec $get_output && swaymsg "workspace 8:$o"'';
    keybindings."Mod4+9" = ''exec $get_output && swaymsg "workspace 9:$o"'';
    keybindings."Mod4+Shift+1" = ''exec $group && $get_output && swaymsg "move container workspace 1:$o, workspace 1:$o" && $ungroup'';
    keybindings."Mod4+Shift+2" = ''exec $group && $get_output && swaymsg "move container workspace 2:$o, workspace 2:$o" && $ungroup'';
    keybindings."Mod4+Shift+3" = ''exec $group && $get_output && swaymsg "move container workspace 3:$o, workspace 3:$o" && $ungroup'';
    keybindings."Mod4+Shift+4" = ''exec $group && $get_output && swaymsg "move container workspace 4:$o, workspace 4:$o" && $ungroup'';
    keybindings."Mod4+Shift+5" = ''exec $group && $get_output && swaymsg "move container workspace 5:$o, workspace 5:$o" && $ungroup'';
    keybindings."Mod4+Shift+6" = ''exec $group && $get_output && swaymsg "move container workspace 6:$o, workspace 6:$o" && $ungroup'';
    keybindings."Mod4+Shift+7" = ''exec $group && $get_output && swaymsg "move container workspace 7:$o, workspace 7:$o" && $ungroup'';
    keybindings."Mod4+Shift+8" = ''exec $group && $get_output && swaymsg "move container workspace 8:$o, workspace 8:$o" && $ungroup'';
    keybindings."Mod4+Shift+9" = ''exec $group && $get_output && swaymsg "move container workspace 9:$o, workspace 9:$o" && $ungroup'';
    keybindings."Mod4+Control+1" = ''exec $get_output && swaymsg "move container workspace 1:$o"'';
    keybindings."Mod4+Control+2" = ''exec $get_output && swaymsg "move container workspace 2:$o"'';
    keybindings."Mod4+Control+3" = ''exec $get_output && swaymsg "move container workspace 3:$o"'';
    keybindings."Mod4+Control+4" = ''exec $get_output && swaymsg "move container workspace 4:$o"'';
    keybindings."Mod4+Control+5" = ''exec $get_output && swaymsg "move container workspace 5:$o"'';
    keybindings."Mod4+Control+6" = ''exec $get_output && swaymsg "move container workspace 6:$o"'';
    keybindings."Mod4+Control+7" = ''exec $get_output && swaymsg "move container workspace 7:$o"'';
    keybindings."Mod4+Control+8" = ''exec $get_output && swaymsg "move container workspace 8:$o"'';
    keybindings."Mod4+Control+9" = ''exec $get_output && swaymsg "move container workspace 9:$o"'';
    keybindings."Mod4+Comma"                = ''exec $get_output && $get_prev_workspace && swaymsg "workspace $w:$o"'';
    keybindings."Mod4+Period"               = ''exec $get_output && $get_next_workspace && swaymsg "workspace $w:$o"'';
    keybindings."Mod4+Shift+Comma"          = ''exec $group && $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
    keybindings."Mod4+Shift+Period"         = ''exec $group && $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
    keybindings."Mod4+Control+Comma"        = ''exec $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o"'';
    keybindings."Mod4+Control+Period"       = ''exec $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o"'';
    keybindings."Mod4+Control+Shift+Comma"  = ''exec '$group && $get_output && $get_workspaces && ws=$(echo "$ws" | cat) && [ "$(echo "$ws" | head -1)" != "1" ] && for w in $ws; do i=$(( $w - 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done && ungroup' '';
    keybindings."Mod4+Control+Shift+Period" = ''exec '$group && $get_output && $get_workspaces && ws=$(echo "$ws" | tac) && [ "$(echo "$ws" | head -1)" != "9" ] && for w in $ws; do i=$(( $w + 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done && ungroup' '';
    keybindings."Mod4+z"               = ''exec $get_output && $get_empty_workspace && swaymsg "workspace $w:$o"'';
    keybindings."Mod4+Shift+z"         = ''exec $group && $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
    keybindings."Mod4+Control+z"       = ''exec '$get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o"' '';
    keybindings."Mod4+Control+Shift+z" = ''exec '$group && $get_output && $get_workspaces && i=1; for w in $ws; do swaymsg rename workspace $w:$o to $i:$o; i=$(( $i + 1 )); done && $ungroup' '';
    # outputs
    # TODO(now): fix output naming
    keybindings."Mod4+equal"         = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.1)"')'';
    keybindings."Mod4+minus"         = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.1)"')'';
    keybindings."Mod4+Shift+equal"   = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.5)"')'';
    keybindings."Mod4+Shift+minus"   = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.5)"')'';
    keybindings."Mod4+Control+equal" = ''exec $get_output && swaymsg output "$o" scale 1'';
    keybindings."Mod4+Control+minus" = ''exec $get_output && swaymsg output "$o" scale 2'';
    # layout
    keybindings."Mod4+g"       = "focus parent";
    keybindings."Mod4+Shift+g" = "focus child";
    keybindings."Mod4+p"       = "split vertical";
    keybindings."Mod4+Shift+p" = "split none";
    keybindings."Mod4+o"       = "layout toggle splitv splith";
    keybindings."Mod4+Shift+o" = "layout toggle split tabbed";
    # scratchpads
    keybindings."Mod4+0"       = "scratchpad show";
    keybindings."Mod4+Shift+0" = "move scratchpad";
    # media
    keybindings."--locked XF86AudioPlay"         = "exec playerctl play-pause";
    keybindings."--locked Shift+XF86AudioPlay"   = "exec playerctl pause";
    keybindings."--locked Control+XF86AudioPlay" = "exec playerctl stop";
    keybindings."--locked XF86AudioPrev"         = "exec playerctl position 1-";
    keybindings."--locked Shift+XF86AudioPrev"   = "exec playerctl position 10-";
    keybindings."--locked Control+XF86AudioPrev" = "exec playerctl previous";
    keybindings."--locked XF86AudioNext"         = "exec playerctl position 1+";
    keybindings."--locked Shift+XF86AudioNext"   = "exec playerctl position 10+";
    keybindings."--locked Control+XF86AudioNext" = "exec playerctl next";
    # volume
    keybindings."--locked XF86AudioMute"                = "exec pulsemixer --toggle-mute       && $send_volume_notif";
    keybindings."--locked Shift+XF86AudioMute"          = "exec                                   $send_volume_notif";
    keybindings."--locked Control+XF86AudioMute"        = "exec pulsemixer --toggle-mute       && $send_volume_notif";
    keybindings."--locked XF86AudioLowerVolume"         = "exec pulsemixer --change-volume  -1 && $send_volume_notif";
    keybindings."--locked Shift+XF86AudioLowerVolume"   = "exec pulsemixer --change-volume -10 && $send_volume_notif";
    keybindings."--locked Control+XF86AudioLowerVolume" = "exec pulsemixer --set-volume      0 && $send_volume_notif";
    keybindings."--locked XF86AudioRaiseVolume"         = "exec pulsemixer --change-volume  +1 && $send_volume_notif";
    keybindings."--locked Shift+XF86AudioRaiseVolume"   = "exec pulsemixer --change-volume +10 && $send_volume_notif";
    keybindings."--locked Control+XF86AudioRaiseVolume" = "exec pulsemixer --set-volume    100 && $send_volume_notif";
    # microphone
    keybindings."--locked --no-repeat Pause"                            = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --unmute";
    keybindings."--locked --no-repeat --release Pause"                  = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --mute";
    keybindings."--locked --no-repeat --release --whole-window button8" = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";
    keybindings."--locked XF86AudioMicMute"                             = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";
    # backlight
    keybindings."--locked XF86MonBrightnessDown"         = "exec brightnessctl set 1%-  && $send_brightness_notif";
    keybindings."--locked Shift+XF86MonBrightnessDown"   = "exec brightnessctl set 10%- && $send_brightness_notif";
    keybindings."--locked Control+XF86MonBrightnessDown" = "exec brightnessctl set 1    && $send_brightness_notif";
    keybindings."--locked XF86MonBrightnessUp"           = "exec brightnessctl set 1%+  && $send_brightness_notif";
    keybindings."--locked Shift+XF86MonBrightnessUp"     = "exec brightnessctl set 10%+ && $send_brightness_notif";
    keybindings."--locked Control+XF86MonBrightnessUp"   = "exec brightnessctl set 100% && $send_brightness_notif";
    # screenshots
    keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | wl-copy --type image/png'';
    keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | wl-copy --type image/png'';
    keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | wl-copy --type image/png'';
  };
}
