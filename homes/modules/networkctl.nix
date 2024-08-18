# network menu
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "networkctl" ''
      IFS=$'\n'

      case "$([ -n "$1" ] && echo $1 || printf "%s\n" wifi bluetooth | bemenu -p "Network" -l 3 -W 0.3)" in

        "wifi") while true; do
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
          choice="$(printf "%s\n" $power $rescan $choices | bemenu -p "Wifi" -l 10 -W 0.3)"
          case "$choice" in
            "") exit;;
            "rescan") nmcli --get-values "" device wifi list --rescan yes;;
            "disable") nmcli radio wifi off || notify-send "Failed to turn off wifi";;
            "enable") nmcli radio wifi on || notify-send "Failed to turn on wifi";;
            *) while true; do
              id=''${choice% \[*}; connect="connect"; forget=""
              [ -n "$(nmcli --get-values "connection.id" connection show --active "$id")" ] \
                && { connect="disconnect"; forget="forget"; } \
                || [ -z "$(nmcli --get-values "connection.id" connection show "$id")" ] \
                || { connect="connect"; forget="forget"; }
              case "$(printf "%s\n" $connect $forget | bemenu -p "$id" -l 10 -W 0.3)" in
                "") exit;;
                "disconnect") nmcli connection down "$id" || notify-send "Failed to disconnect from $id";;
                "forget") nmcli connection delete "$id" || notify-send "Failed to forget $id";;
                "connect") [ -n "$forget" ] \
                    && nmcli device wifi connect "$id" \
                    || nmcli device wifi connect "$id" password "$(: | bemenu -x indicator -p "$id" -l 0 -W 0.3)" \
                    || notify-send "Failed to connect to $id";;
              esac
            done;;
          esac
        done;;

        "bluetooth") while true; do
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
          choice="$(printf "%s\n" $power $rescan $choices | bemenu -p "Bluetooth" -l 10 -W 0.3)"
          case "$choice" in
            "") exit;;
            "rescan") bluetoothctl --timeout 5 scan on;;
            "disable") bluetoothctl power off || notify-send "Failed to turn off bluetooth";;
            "enable") bluetoothctl power on || notify-send "Failed to turn on bluetooth";;
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
              case "$(printf "%s\n" $connect $pair $trust | bemenu -p "''${name:-$id}" -l 10 -W 0.3)" in
                "") exit;;
                "disconnect") bluetoothctl --timeout 5 disconnect "$id" || notify-send "Failed to disconnect from $id";;
                "forget") bluetoothctl --timeout 5 remove "$id" || notify-send "Failed to forget $id";;
                "trust") bluetoothctl --timeout 5 trust "$id" || notify-send "Failed to trust $id";;
                "untrust") bluetoothctl --timeout 5 untrust "$id" || notify-send "Failed to untrust $id";;
                "connect") bluetoothctl --timeout 5 connect "$id" || notify-send "Failed to connect to $id";;
                # TODO(later): pairing not working here but does in cli
                "pair") bluetoothctl --timeout 5 pair "$id" || notify-send "Failed to pair with $id";;
              esac
            done;;
          esac
        done;;

        *) exit 1;;
      esac
    '')
  ];
}
