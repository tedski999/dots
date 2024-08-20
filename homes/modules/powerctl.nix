# power menu
{ pkgs, ... }: {
  home.packages = with pkgs; [
    swayidle
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
          timeout 590 'notify-send -i clock "Idle Warning" "Locking in 10 seconds..."' \
          timeout 600 'loginctl lock-session' \
          timeout 900 'systemctl suspend' &;;
        *) exit 1;;
      esac
    '')
  ];
}
