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
    set $group swaymsg "mark --add g" || swaymsg "splitv, mark --add g"
    set $regroup swaymsg "[con_mark=g] focus, unmark g" || swaymsg "focus parent; focus parent; focus parent; focus parent"
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
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+h"   = "exec $group && swaymsg 'move left 50px' && $regroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+h" = "resize shrink width 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+j"         = "focus down";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+j"   = "exec $group && swaymsg 'move down 50px' && $regroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+j" = "resize grow height 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+k"         = "focus up";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+k"   = "exec $group && swaymsg 'move up 50px' && $regroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+k" = "resize shrink height 50px";
  wayland.windowManager.sway.config.keybindings."Mod4+l"         = "focus right";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+l"   = "exec $group && swaymsg 'move right 50px' && $regroup";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+l" = "resize grow width 50px";

  wayland.windowManager.sway.config.keybindings."Mod4+1" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):1 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+2" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):2 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+3" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):3 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+4" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):4 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+5" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):5 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+6" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):6 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+7" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):7 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+8" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):8 && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+9" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):9 && swaymsg "workspace $w"'';

  wayland.windowManager.sway.config.keybindings."Mod4+Shift+1" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):1 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+2" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):2 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+3" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):3 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+4" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):4 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+5" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):5 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+6" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):6 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+7" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):7 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+8" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):8 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+9" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):9 && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';

  wayland.windowManager.sway.config.keybindings."Mod4+Control+1" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):1 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+2" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):2 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+3" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):3 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+4" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):4 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+5" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):5 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+6" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):6 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+7" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):7 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+8" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):8 && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+9" = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[0]'):9 && swaymsg "move container workspace $w"'';

  wayland.windowManager.sway.config.keybindings."Mod4+Tab"         = ''exec n=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[1]') && os=$((echo 0 && swaymsg -rt get_workspaces | jq -r '.[].num') | sort -u) && o=$( (echo "$os" && echo "$os") | grep -Fm 1 -A 1 $(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') | tail -1) && swaymsg "workspace $o:$n"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Tab"   = ''exec n=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[1]') && os=$((echo 0 && swaymsg -rt get_workspaces | jq -r '.[].num') | sort -u) && o=$( (echo "$os" && echo "$os") | grep -Fm 1 -A 1 $(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') | tail -1) && $group && swaymsg "move container workspace $o:$n, workspace $o:$n" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Tab" = ''exec n=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":")[1]') && os=$((echo 0 && swaymsg -rt get_workspaces | jq -r '.[].num') | sort -u) && o=$( (echo "$os" && echo "$os") | grep -Fm 1 -A 1 $(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') | tail -1) && swaymsg "move container workspace $o:$n"'';

  wayland.windowManager.sway.config.keybindings."Mod4+Period"               = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) + 1, 9] | min | tostring)') && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Comma"                = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) - 1, 1] | max | tostring)') && swaymsg "workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Period"         = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) + 1, 9] | min | tostring)') && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Comma"          = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) - 1, 1] | max | tostring)') && $group && swaymsg "move container workspace $w, workspace $w" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Period"       = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) + 1, 9] | min | tostring)') && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Comma"        = ''exec w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name | split(":") as [ $o, $n ] | $o+":"+([($n | tonumber) - 1, 1] | max | tostring)') && swaymsg "move container workspace $w"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+Period" = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2) && ns=$(echo $ns | rev) && [ $(echo $ns | cut -b1) != 9 ] && for n in $ns; do i=$(( $n + 1 )); swaymsg rename workspace $o:$n to $o:$i; done" '';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+Comma"  = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2)                         && [ $(echo $ns | cut -b1) != 1 ] && for n in $ns; do i=$(( $n - 1 )); swaymsg rename workspace $o:$n to $o:$i; done" '';

  wayland.windowManager.sway.config.keybindings."Mod4+z"               = ''exec o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2) && n=$(seq 9 | grep -Fvm 1 "$ns") && swaymsg "workspace $o:$n"'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+z"         = ''exec o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2) && n=$(seq 9 | grep -Fvm 1 "$ns") && $group && swaymsg "move container workspace $o:$n, workspace $o:$n" && $regroup'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+z"       = ''exec o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2) && n=$(seq 9 | grep -Fvm 1 "$ns") && swaymsg "move container workspace $o:$n'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Shift+z" = ''exec "o=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num') && ns=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.num == '$o').name' | cut -d: -f2) && i=1 && for n in $ns; do swaymsg rename workspace $o:$n to $o:$i; i=$(( $i + 1 )); done" '';

  wayland.windowManager.sway.config.keybindings."Mod4+equal"         = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .scale * 1.1')'';
  wayland.windowManager.sway.config.keybindings."Mod4+minus"         = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .scale / 1.1')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+equal"   = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .scale * 1.5')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+minus"   = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale $(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .scale / 1.5')'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+equal" = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale 2'';
  wayland.windowManager.sway.config.keybindings."Mod4+Control+minus" = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial') && swaymsg output \\'$o\\' scale 1'';

  wayland.windowManager.sway.config.keybindings."Mod4+0"       = "scratchpad show";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+0" = "move scratchpad";

  wayland.windowManager.sway.config.keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
  wayland.windowManager.sway.config.keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
  wayland.windowManager.sway.config.keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
}
