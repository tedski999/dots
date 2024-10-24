# power menu
{ pkgs, ... }: {

  imports = [ ./bemenu.nix ./libnotify.nix ./procps.nix ./sway.nix ./swayidle.nix ./swaylock.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "powerctl" ''
      case "$([ -n "$1" ] && echo $1 || printf "%s\n" lock suspend $(pidof -q swayidle && echo caffeinate || echo decafeinate) reload logout reboot shutdown | bemenu -p "Power" -l 9)" in
        "lock") loginctl lock-session;;
        "suspend") systemctl suspend;;
        "reload") swaymsg reload;;
        "logout") swaymsg exit;;
        "reboot") systemctl reboot;;
        "shutdown") systemctl poweroff;;
        "caffeinate") pkill swayidle;;
        "decafeinate") pidof swayidle || swayidle -w idlehint 300 \
          lock 'swaylock --daemonize' \
          unlock 'pkill -USR1 swaylock' \
          before-sleep 'loginctl lock-session' \
          timeout 590  'notify-send -i clock -t 10000 "Idle Warning" "Locking in 10 seconds..."' \
          timeout 600  'loginctl lock-session' \
          timeout 3600 'systemctl suspend' &;;
        *) exit 1;;
      esac
    '')
  ];

  wayland.windowManager.sway.config.startup = [ { command = "powerctl decafeinate"; } ];
  wayland.windowManager.sway.config.keybindings."Mod4+Escape"                        = "exec powerctl";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Escape"                  = "exec powerctl lock";
  wayland.windowManager.sway.config.keybindings."--locked Mod4+Control+Escape"       = "exec powerctl suspend";
  wayland.windowManager.sway.config.keybindings."--locked Mod4+Control+Shift+Escape" = "exec powerctl reload";

}
