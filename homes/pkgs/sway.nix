# i3 but better
{ pkgs, ... }: {

  imports = [ ./alacritty.nix ./coreutils.nix ./fontconfig.nix ./grim.nix ./jq.nix ./procps.nix ./pulsemixer.nix ./slurp.nix ./wl-clipboard.nix ];

  home.sessionVariables.QT_QPA_PLATFORM = "wayland";
  home.sessionVariables.LIBSEAT_BACKEND = "logind";

  home.packages = with pkgs; [
    (writeShellScriptBin "scratch" ''
      id="$1"; shift
      swaymsg -t get_tree | jq -re "recurse(.nodes[]?, .floating_nodes[]?) | select(.focused == true).app_id == \"$id\"" \
      && swaymsg "move scratchpad" \
      || swaymsg "[app_id=\"^$id$\"] focus" \
      || alacritty --class "$id" --command $@
    '')
  ];

  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.wrapperFeatures.gtk = true;
  wayland.windowManager.sway.systemd.enable = true;
  wayland.windowManager.sway.systemd.variables = [ "--all" ];

  wayland.windowManager.sway.extraConfigEarly = ''
    set $get_output o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial')
    set $get_workspaces ws=$(swaymsg -rt get_workspaces | jq -r '. as $i | $i[] | select(.focused).output as $o | $i[] | select(.output==$o).num')
    set $get_prev_workspace w=$(( $( swaymsg -rt get_workspaces | jq -r '.[] | first(select(.focused).num)' ) - 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
    set $get_next_workspace w=$(( $( swaymsg -rt get_workspaces | jq -r '.[] | first(select(.focused).num)' ) + 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
    set $get_empty_workspace w=$(swaymsg -rt get_workspaces | jq -r '. as $i | first(range(1; 10) as $n | $n | select($i[] | select(.focused).output as $o | [$i[] | select(.output==$o).num] | all(. != $n))) // 9')
    # TODO(later): doesnt work well at high speeds (e.g. key held down)
    set $group swaymsg "mark --add g" || swaymsg "splitv, mark --add g"
    set $ungroup swaymsg "[con_mark=g] focus, unmark g" || swaymsg "focus parent; focus parent; focus parent; focus parent"
  '';

  wayland.windowManager.sway.config.modifier = "Mod4";
  wayland.windowManager.sway.config.workspaceLayout = "default";
  wayland.windowManager.sway.config.focus = { followMouse = true; mouseWarping = "output"; wrapping = "no"; };
  wayland.windowManager.sway.config.floating = { modifier = "Mod4"; border = 1; titlebar = false; };
  wayland.windowManager.sway.config.window = { border = 1; hideEdgeBorders = "none"; titlebar = false; commands = [ { criteria.class = ".*"; command = "border pixel 1"; } { criteria.app_id = ".*"; command = "border pixel 1"; } { criteria.app_id = "floating.*"; command = "floating enable"; } ]; };
  wayland.windowManager.sway.config.gaps = { inner = 5; };
  wayland.windowManager.sway.config.modes = {};
  wayland.windowManager.sway.config.fonts = {};
  wayland.windowManager.sway.config.output = { "*".bg = "#101010 solid_color"; };
  wayland.windowManager.sway.config.bars = [ { command = "waybar"; mode = "hide"; } ];

  wayland.windowManager.sway.config.colors.focused         = { border = "#202020"; background = "#ffffff"; text = "#000000"; indicator = "#ff0000"; childBorder = "#ffffff"; };
  wayland.windowManager.sway.config.colors.focusedInactive = { border = "#202020"; background = "#202020"; text = "#ffffff"; indicator = "#202020"; childBorder = "#202020"; };
  wayland.windowManager.sway.config.colors.unfocused       = { border = "#202020"; background = "#202020"; text = "#808080"; indicator = "#202020"; childBorder = "#202020"; };
  wayland.windowManager.sway.config.colors.urgent          = { border = "#2f343a"; background = "#202020"; text = "#ffffff"; indicator = "#900000"; childBorder = "#900000"; };

  wayland.windowManager.sway.config.input."type:keyboard".xkb_layout = "ie";
  wayland.windowManager.sway.config.input."type:keyboard".xkb_options = "caps:escape";
  wayland.windowManager.sway.config.input."type:keyboard".repeat_delay = "250";
  wayland.windowManager.sway.config.input."type:keyboard".repeat_rate = "30";
  wayland.windowManager.sway.config.input."type:touchpad".dwt = "disabled";
  wayland.windowManager.sway.config.input."type:touchpad".tap = "enabled";
  wayland.windowManager.sway.config.input."type:touchpad".natural_scroll = "enabled";
  wayland.windowManager.sway.config.input."type:touchpad".click_method = "clickfinger";
  wayland.windowManager.sway.config.input."type:touchpad".scroll_method = "two_finger";

  wayland.windowManager.sway.config.keybindings."Mod4+space"  = "exec $LAUNCHER";
  wayland.windowManager.sway.config.keybindings."Mod4+Return" = "exec $TERMINAL";
  wayland.windowManager.sway.config.keybindings."Mod4+t"      = "exec $TERMINAL";
  wayland.windowManager.sway.config.keybindings."Mod4+w"      = "exec $BROWSER";

  wayland.windowManager.sway.config.keybindings."Mod4+g"       = "focus parent";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+g" = "focus child";
  wayland.windowManager.sway.config.keybindings."Mod4+f"       = "focus mode_toggle";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+f" = "border pixel 1, floating toggle";
  wayland.windowManager.sway.config.keybindings."Mod4+p"       = "split vertical";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+p" = "split none";
  wayland.windowManager.sway.config.keybindings."Mod4+o"       = "layout toggle splitv splith";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+o" = "layout toggle split tabbed";
  wayland.windowManager.sway.config.keybindings."Mod4+x"       = "sticky toggle";
  wayland.windowManager.sway.config.keybindings."Mod4+m"       = "fullscreen";
  wayland.windowManager.sway.config.keybindings."Mod4+q"       = "kill";

  wayland.windowManager.sway.config.keybindings."Mod4+h"         = "focus left";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+h"   = "exec $group && swaymsg 'move left 50px' && $ungroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+h" = "resize shrink width 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+j"         = "focus down";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+j"   = "exec $group && swaymsg 'move down 50px' && $ungroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+j" = "resize grow height 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+k"         = "focus up";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+k"   = "exec $group && swaymsg 'move up 50px' && $ungroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+k" = "resize shrink height 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+l"         = "focus right";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+l"   = "exec $group && swaymsg 'move right 50px' && $ungroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+l" = "resize grow width 50px";

  wayland.windowManager.sway.config.keybindings."Mod4+1" = ''exec $get_output && swaymsg "workspace 1:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+2" = ''exec $get_output && swaymsg "workspace 2:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+3" = ''exec $get_output && swaymsg "workspace 3:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+4" = ''exec $get_output && swaymsg "workspace 4:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+5" = ''exec $get_output && swaymsg "workspace 5:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+6" = ''exec $get_output && swaymsg "workspace 6:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+7" = ''exec $get_output && swaymsg "workspace 7:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+8" = ''exec $get_output && swaymsg "workspace 8:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+9" = ''exec $get_output && swaymsg "workspace 9:$o"'';

  wayland.windowManager.sway.config.keybindings."Mod4+Shift+1" = ''exec $group && $get_output && swaymsg "move container workspace 1:$o, workspace 1:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+2" = ''exec $group && $get_output && swaymsg "move container workspace 2:$o, workspace 2:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+3" = ''exec $group && $get_output && swaymsg "move container workspace 3:$o, workspace 3:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+4" = ''exec $group && $get_output && swaymsg "move container workspace 4:$o, workspace 4:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+5" = ''exec $group && $get_output && swaymsg "move container workspace 5:$o, workspace 5:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+6" = ''exec $group && $get_output && swaymsg "move container workspace 6:$o, workspace 6:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+7" = ''exec $group && $get_output && swaymsg "move container workspace 7:$o, workspace 7:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+8" = ''exec $group && $get_output && swaymsg "move container workspace 8:$o, workspace 8:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+9" = ''exec $group && $get_output && swaymsg "move container workspace 9:$o, workspace 9:$o" && $ungroup'';

  wayland.windowManager.sway.config.keybindings."Mod4+Control+1" = ''exec $get_output && swaymsg "move container workspace 1:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+2" = ''exec $get_output && swaymsg "move container workspace 2:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+3" = ''exec $get_output && swaymsg "move container workspace 3:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+4" = ''exec $get_output && swaymsg "move container workspace 4:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+5" = ''exec $get_output && swaymsg "move container workspace 5:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+6" = ''exec $get_output && swaymsg "move container workspace 6:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+7" = ''exec $get_output && swaymsg "move container workspace 7:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+8" = ''exec $get_output && swaymsg "move container workspace 8:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+9" = ''exec $get_output && swaymsg "move container workspace 9:$o"'';

  wayland.windowManager.sway.config.keybindings."Mod4+Comma"                = ''exec $get_output && $get_prev_workspace && swaymsg "workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Period"               = ''exec $get_output && $get_next_workspace && swaymsg "workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Comma"          = ''exec $group && $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Period"         = ''exec $group && $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Comma"        = ''exec $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Period"       = ''exec $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+Comma"  = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name' | cut -d: -f2) && $get_workspaces                         && [ $(echo $ws | cut -b1) != 1 ] && for w in $ws; do i=$(( $w - 1 )); swaymsg rename workspace $w:$o to $i:$o; done" '';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+Period" = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name' | cut -d: -f2) && $get_workspaces && ws=$(echo $ws | rev) && [ $(echo $ws | cut -b1) != 9 ] && for w in $ws; do i=$(( $w + 1 )); swaymsg rename workspace $w:$o to $i:$o; done" '';

  wayland.windowManager.sway.config.keybindings."Mod4+z"               = ''exec $get_output && $get_empty_workspace && swaymsg "workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+z"         = ''exec $group && $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+z"       = ''exec $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+z" = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name' | cut -d: -f2) && $get_workspaces && i=1 && for w in $ws; do swaymsg rename workspace $w:$o to $i:$o; i=$(( $i + 1 )); done" '';

  wayland.windowManager.sway.config.keybindings."Mod4+Tab"       = ''exec swaymsg "workspace $(swaymsg -rt get_workspaces | jq -r '. as $i | $i[] | select(.focused) as { num: $n, name: $m } | [$i[] | select(.num==$n).name] | sort as $a | $a[[$a | index($m) + 1, ($a | length - 1)] | min]')"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Tab" = ''exec swaymsg "workspace $(swaymsg -rt get_workspaces | jq -r '. as $i | $i[] | select(.focused) as { num: $n, name: $m } | [$i[] | select(.num==$n).name] | sort as $a | $a[[$a | index($m) - 1, 0                ] | max]')"'';

  wayland.windowManager.sway.config.keybindings."Mod4+equal"         = ''exec $get_output && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.make+" "+.model+" "+.serial == "'"$o"'") | .scale * 1.1')'';
  wayland.windowManager.sway.config.keybindings."Mod4+minus"         = ''exec $get_output && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.make+" "+.model+" "+.serial == "'"$o"'") | .scale / 1.1')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+equal"   = ''exec $get_output && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.make+" "+.model+" "+.serial == "'"$o"'") | .scale * 1.5')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+minus"   = ''exec $get_output && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.make+" "+.model+" "+.serial == "'"$o"'") | .scale / 1.5')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+equal" = ''exec $get_output && swaymsg output \\'$o\\' scale 1'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+minus" = ''exec $get_output && swaymsg output \\'$o\\' scale 2'';

  wayland.windowManager.sway.config.keybindings."Mod4+0"       = "scratchpad show";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+0" = "move scratchpad";

  wayland.windowManager.sway.config.keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
  wayland.windowManager.sway.config.keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
  wayland.windowManager.sway.config.keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
}
