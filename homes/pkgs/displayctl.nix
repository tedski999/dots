# display meneu
{ pkgs, ... }: {

  imports = [ ./bemenu.nix ./coreutils.nix ./jq.nix ./libnotify.nix ./sway.nix ];

  home.packages = with pkgs; [

    (writeShellScriptBin "displayctl" ''
      choice="$([ -n "$1" ] && echo $1 || printf "%s\n" auto laptop work home | bemenu -p "Display" -l 5)"

      [ "$choice" = "auto" ] && case "$(swaymsg -rt get_outputs | jq -r '.[] | .make+" "+.model+" "+.serial' | sort | xargs)" in
        "AOC 2270W GNKJ1HA001311 AU Optronics 0xD291 Unknown Pixio USA Pixio PXC348C Unknown") choice="home";;
        "AU Optronics 0xD291 Unknown Lenovo Group Limited P24q-30 V90CP3VM")                   choice="work";;
        *)                                                                                     choice="laptop";;
      esac

      case "$choice" in
        "laptop")
          swaymsg output \"\*\" disable
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos 0 0 transform 0 mode 1920x1200@60Hz
          swaymsg "focus output \"AU Optronics 0xD291 Unknown\"" && swaymsg "workspace 1:AU Optronics 0xD291 Unknown"
          ;;
        "work")
          swaymsg output \"\*\" disable
          swaymsg output \"Lenovo Group Limited P24q-30 V90CP3VM\" enable pos 0 0 transform 0 mode 2560x1440@74.780Hz
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((2560/2 - 1920/2)) 1440 transform 0 mode 1920x1200@60Hz
          swaymsg "focus output \"AU Optronics 0xD291 Unknown\"" && swaymsg "workspace 1:AU Optronics 0xD291 Unknown"
          swaymsg "focus output \"Lenovo Group Limited P24q-30 V90CP3VM\"" && swaymsg "workspace 1:Lenovo Group Limited P24q-30 V90CP3VM"
          ;;
        "home")
          swaymsg output \"\*\" disable
          swaymsg output \"Pixio USA Pixio PXC348C Unknown\" enable pos 1080 $((1920/2 - 1440/2)) transform 0 mode 3440x1440@100Hz
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((3440/2 - 1920/2 + 1080)) $((1440 + 1920/2 - 1440/2)) transform 0 mode 1920x1200@60Hz
          swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 90 mode 1920x1080@60Hz
          sleep 0.1
          swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 270 mode 1920x1080@60Hz
          swaymsg "focus output \"AU Optronics 0xD291 Unknown\"" && swaymsg "workspace 1:AU Optronics 0xD291 Unknown"
          swaymsg "focus output \"AOC 2270W GNKJ1HA001311\"" && swaymsg "workspace 1:AOC 2270W GNKJ1HA001311"
          swaymsg "focus output \"Pixio USA Pixio PXC348C Unknown\"" && swaymsg "workspace 1:Pixio USA Pixio PXC348C Unknown"
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
  wayland.windowManager.sway.config.keybindings."Mod4+Control+Apostrophe"       = "exec displayctl laptop";

}
