# low battery notification
{ pkgs, ... }: {

  imports = [ ./acpi.nix ./coreutils.nix ./libnotify.nix ./powerctl.nix ./sed.nix ];

  home.packages = with pkgs; [

    (writeShellScriptBin "batteryd" ''
      while true; do
        sleep 1

        prev_charge="''${charge:-100}"
        acpi="$(acpi | sed "s/.*: //")"
        state="$(echo "$acpi" | cut -f 1 -d ',')"
        charge="$(echo "$acpi" | cut -f 2 -d ',' | tr -d '%')"
        time="$(echo "$acpi" | cut -f 3 -d ',')"

        if [ "$state" = "Discharging" ]; then
          if [ "$prev_charge" -gt 5 ] && [ "$charge" -le 5 ]; then
            for i in $(seq 5 -1 1); do notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery empty!" "Suspending in $i..."; sleep 1; done
            powerctl suspend
          elif [ "$prev_charge" -gt 10 ] && [ "$charge" -le 10 ]; then
            notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery critical!" "Less than$time"
          elif [ "$prev_charge" -gt 20 ] && [ "$charge" -le 20 ]; then
            notify-send -i battery-020 -u normal -r "$$" "Battery low!" "Less than$time"
          fi
        fi
      done
    '')
  ];

  wayland.windowManager.sway.config.startup = [ { command = "pidof -x batteryd || batteryd"; always = true; } ];

}
