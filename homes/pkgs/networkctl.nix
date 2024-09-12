# network menu
{ pkgs, ... }: {

  # TODO(deps): bluetoothctl nmcli
  imports = [ ./bemenu.nix ./coreutils.nix ./libnotify.nix ./sed.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "networkctl" ''
      IFS=$'\n'

      case "$([ -n "$1" ] && echo $1 || printf "%s\n" wifi bluetooth | bemenu -p "Network" -l 3)" in

        "wifi") while true; do
          function n() { notify-send -i network-wireless "Wi-Fi Control" $@; }

          power="enable"; rescan=""; choices=""
          nmcli radio wifi | grep --fixed-strings "enabled" && {
            power="disable"; rescan="rescan"
            info="$(nmcli --get-values SSID,SECURITY,SIGNAL,IN-USE device wifi list --rescan no)"
            choices="$(for id in $(nmcli --get-values SSID device wifi list --rescan no | sed 's/\\:/;/g' | sort --unique); do
              sav="$(nmcli --get-values "" connection show "$id" && echo " | Saved")"
              sec="$(echo "$info" | grep --fixed-strings "$id" | cut -d: -f2 | head -1)"
              sig="$(echo "$info" | grep --fixed-strings "$id" | cut -d: -f3 | sort --reverse --numeric-sort | head -1)"
              use="$(echo "$info" | grep --fixed-strings "$id" | cut -d: -f4 | sort --reverse | head -1)"
              echo "$id [''${sec:-None}$sav] $sig% $use"
            done)"
          }

          choice="$(printf "%s\n" $power $rescan $choices | bemenu -p "Wi-Fi" -l 10)"
          case "$choice" in
            "") exit;;
            "rescan") nmcli --get-values "" device wifi list --rescan yes;;
            "disable") nmcli radio wifi off && n "Wi-Fi disabled" || n "Failed to disable Wi-Fi";;
            "enable") nmcli radio wifi on && n "Wi-Fi enabled" || n "Failed to disable Wi-Fi";;
            *) while true; do
              id=''${choice% \[*}; connect="connect"; forget=""
              [ -n "$(nmcli --get-values "connection.id" connection show --active "$id")" ] \
                && { connect="disconnect"; forget="forget"; } \
                || [ -z "$(nmcli --get-values "connection.id" connection show "$id")" ] \
                || { connect="connect"; forget="forget"; }
              case "$(printf "%s\n" $connect $forget | bemenu -p "$id" -l 10)" in
                "") exit;;
                "disconnect") nmcli connection down "$id" && n "Disconencted from $id" && exit || n "Failed to disconnect from $id";;
                "connect") [ -n "$forget" ] \
                    && nmcli device wifi connect "$id" && n "Connected to $id" && exit \
                    || nmcli device wifi connect "$id" password "$(: | bemenu -x indicator -p "$id" -l 0)" && n "Connected to $id" && exit \
                    || n "Failed to connect to $id";;
                "forget") nmcli connection delete "$id" n "$id forgotten" || n "Failed to forget $id";;
              esac
            done;;
          esac
        done;;

        "bluetooth") while true; do
          function n() { notify-send -i network-bluetooth "Bluetooth Control" $@; }

          power="enable"; rescan=""; choices=""
          bluetoothctl show | grep --fixed-strings "Powered: yes" && {
            power="disable"; rescan="rescan"
            devices="$(bluetoothctl devices | cut -d " " -f 2 | sort --unique)"
            choices="$(for device in $devices; do
              pair="Unknown"; use=""
              info="$(bluetoothctl info "$device")"
              name="$(echo "$info" | grep --fixed-strings "Name: " | cut -d " " -f 2-)"
              echo "$info" | grep --quiet --fixed-strings "Paired: yes" && pair="Paired"
              echo "$info" | grep --quiet --fixed-strings "Trusted: yes" && pair="Trusted"
              echo "$info" | grep --quiet --fixed-strings "Connected: yes" && use="*"
              echo "$device''${name:+ $name} [$pair] $use"
            done)"
          }

          choice="$(printf "%s\n" $power $rescan $choices | bemenu -p "Bluetooth" -l 10)"
          case "$choice" in
            "") exit;;
            "rescan") bluetoothctl --timeout 5 scan on;;
            "disable") bluetoothctl power off && n "Bluetooth disabled" || n "Failed to disable bluetooth";;
            "enable") bluetoothctl power on && n "Bluetooth enabled" || n "Failed to enable bluetooth";;
            # TODO(later): advertise / discovery
            *) while true; do
              id=''${choice%% *}; info="$(bluetoothctl info "$id")"
              connect=""; pair="pair"; trust=""
              name="$(echo "$info" | grep --fixed-strings "Name: " | cut -d " " -f 2-)"
              echo "$info" | grep --fixed-strings "Paired: yes" && {
                echo "$info" | grep --fixed-strings "Trusted: yes" && trust="untrust" || trust="trust"
                echo "$info" | grep --fixed-strings "Connected: yes" && connect="disconnect" || connect="connect"
                pair="forget"
              }
              case "$(printf "%s\n" $connect $pair $trust | bemenu -p "''${name:-$id}" -l 10)" in
                "") exit;;
                "disconnect") bluetoothctl disconnect "$id" && n "Disconnected from $id" && exit || n "Failed to disconnect from $id";;
                "connect") bluetoothctl connect "$id" && n "Connected to $id" && exit || n "Failed to connect to $id";;
                # TODO(later): pairing not working here but does in cli
                "pair") bluetoothctl pair "$id" && n "Paired with $id" || n "Failed to pair with $id";;
                "forget") bluetoothctl remove "$id" && n "$id forgotten" || n "Failed to forget $id";;
                "trust") bluetoothctl trust "$id" && n "$id trusted" || n "Failed to trust $id";;
                "untrust") bluetoothctl untrust "$id" && n "$id untrusted" || n "Failed to untrust $id";;
              esac
            done;;
          esac
        done;;

        *) exit 1;;
      esac
    '')
  ];

  wayland.windowManager.sway.config.keybindings."Mod4+n"         = "exec networkctl";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+n"   = "exec networkctl wifi";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+n" = "exec networkctl bluetooth";

}
