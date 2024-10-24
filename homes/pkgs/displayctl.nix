# display meneu
{ pkgs, ... }: {

  imports = [ ./bemenu.nix ./coreutils.nix ./jq.nix ./libnotify.nix ./sway.nix ];

  home.packages = with pkgs; [

    (writeShellScriptBin "displayctl" ''
      choice="$([ -n "$1" ] && echo $1 || printf "%s\n" auto none work home | bemenu -p "Display" -l 5)"

      [ "$choice" = "auto" ] && case "$(swaymsg -rt get_outputs | jq -r '.[] | .make+" "+.model+" "+.serial' | sort | xargs)" in
        "AOC 2270W GNKJ1HA001311 AU Optronics 0xD291 Unknown Pixio USA Pixio PXC348C Unknown") choice="home";;
        "AU Optronics 0xD291 Unknown Lenovo Group Limited P24q-30 V90CP3VM")                   choice="work";;
        *)                                                                                     choice="none";;
      esac

      case "$choice" in
        "none")
          swaymsg output \"\*\" disable
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos 0 0 transform 0 mode 1920x1200@60Hz
          swaymsg "workspace 0:1 output \"AU Optronics 0xD291 Unknown\", workspace 0:2 output \"AU Optronics 0xD291 Unknown\", workspace 0:3 output \"AU Optronics 0xD291 Unknown\", workspace 0:4 output \"AU Optronics 0xD291 Unknown\", workspace 0:5 output \"AU Optronics 0xD291 Unknown\", workspace 0:6 output \"AU Optronics 0xD291 Unknown\", workspace 0:7 output \"AU Optronics 0xD291 Unknown\", workspace 0:8 output \"AU Optronics 0xD291 Unknown\", workspace 0:9 output \"AU Optronics 0xD291 Unknown\", workspace 0:1"
          # TODO: add other outputs:
          # swaymsg output "*" enable
          ;;
        "work")
          swaymsg output \"\*\" disable
          swaymsg output \"Lenovo Group Limited P24q-30 V90CP3VM\" enable pos 0 0 transform 0 mode 2560x1440@74.780Hz
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((2560/2 - 1920/2)) 1440 transform 0 mode 1920x1200@60Hz
          swaymsg "workspace 0:1 output \"AU Optronics 0xD291 Unknown\", workspace 0:2 output \"AU Optronics 0xD291 Unknown\", workspace 0:3 output \"AU Optronics 0xD291 Unknown\", workspace 0:4 output \"AU Optronics 0xD291 Unknown\", workspace 0:5 output \"AU Optronics 0xD291 Unknown\", workspace 0:6 output \"AU Optronics 0xD291 Unknown\", workspace 0:7 output \"AU Optronics 0xD291 Unknown\", workspace 0:8 output \"AU Optronics 0xD291 Unknown\", workspace 0:9 output \"AU Optronics 0xD291 Unknown\", workspace 0:1"
          swaymsg "workspace 1:1 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:2 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:3 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:4 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:5 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:6 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:7 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:8 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:9 output \"Lenovo Group Limited P24q-30 V90CP3VM\" \"AU Optronics 0xD291 Unknown\", workspace 1:1"
          ;;
        "home")
          swaymsg output \"\*\" disable
          swaymsg output \"Pixio USA Pixio PXC348C Unknown\" enable pos 1080 $((1920/2 - 1440/2)) transform 0 mode 3440x1440@100Hz
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((3440/2 - 1920/2 + 1080)) $((1440 + 1920/2 - 1440/2)) transform 0 mode 1920x1200@60Hz
          swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 90 mode 1920x1080@60Hz && sleep 0.1 && swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 270 mode 1920x1080@60Hz
          swaymsg "workspace 0:1 output \"AU Optronics 0xD291 Unknown\", workspace 0:2 output \"AU Optronics 0xD291 Unknown\", workspace 0:3 output \"AU Optronics 0xD291 Unknown\", workspace 0:4 output \"AU Optronics 0xD291 Unknown\", workspace 0:5 output \"AU Optronics 0xD291 Unknown\", workspace 0:6 output \"AU Optronics 0xD291 Unknown\", workspace 0:7 output \"AU Optronics 0xD291 Unknown\", workspace 0:8 output \"AU Optronics 0xD291 Unknown\", workspace 0:9 output \"AU Optronics 0xD291 Unknown\", workspace 0:1"
          swaymsg "workspace 3:1 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:2 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:3 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:4 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:5 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:6 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:7 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:8 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:9 output \"AOC 2270W GNKJ1HA001311\" \"AU Optronics 0xD291 Unknown\", workspace 3:1"
          swaymsg "workspace 2:1 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:2 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:3 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:4 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:5 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:6 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:7 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:8 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:9 output \"Pixio USA Pixio PXC348C Unknown\" \"AU Optronics 0xD291 Unknown\", workspace 2:1"
          ;;
        *)
          exit 1
          ;;
      esac

      notify-send -i monitor -t 5000 "Set display configuration" "Profile: $choice"
    '')
  ];

  wayland.windowManager.sway.config.startup = [ { command = "displayctl auto"; always = true; } ];
  wayland.windowManager.sway.config.keybindings."Mod4+Apostrophe"               = "exec displayctl";
  wayland.windowManager.sway.config.keybindings."Mod4+Shift+Apostrophe"         = "exec displayctl auto";
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Apostrophe"       = "exec displayctl none";

}
