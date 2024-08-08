# low battery notification
{ pkgs, ... }: {
  home.packages = with pkgs; [
    acpi
    libnotify
    (writeShellScriptBin "batteryd" ''
      old_charge=100
      while true; do
        sleep 1
        info="$(acpi | sed "s/.*: //")"
        state="$(echo "$info" | cut -f 1 -d ',')"
        charge="$(echo "$info" | cut -f 2 -d ',')"
        time="$(echo "$info" | cut -f 3 -d ',')"
        [ "$state" = "Discharging" ] && {
          charge="$(echo "$charge" | tr -d '%')"
          [ "$old_charge" -gt 5 ] && [ "$charge" -le 5 ] && {
            for i in $(seq 5 -1 1); do notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery empty!" "Suspending in $i..."; sleep 1; done
            powerctl suspend
          } || {
            [ "$old_charge" -gt 10 ] && [ "$charge" -le 10 ] && {
              notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery critical!" "Less than$time"
            } || {
              [ "$old_charge" -gt 20 ] && [ "$charge" -le 20 ] && {
                notify-send -i battery-020 -u normal -r "$$" "Battery low!" "Less than$time"
              }
            }
          }
          old_charge="$charge"
        }
      done
    '')
  ];
}
