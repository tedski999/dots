# display meneu
# TODO(later): fix race conditions
# TODO(later): automate with a daemon or at least autoselection?
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "displayctl" ''
      case "$(printf "Home\nWork" | bemenu --list 10 --width-factor 0.2)" in
        "Home")
          swaymsg output \"AOC 2270W GNKJ1HA001311\" disable
          swaymsg output \"AU Optronics 0xD291 Unknown\" disable
          sleep 1
          swaymsg output \"Pixio USA Pixio PXC348C Unknown\" enable pos 1080 $((1920/2 - 1440/2)) transform 0 mode 3440x1440@100Hz
          sleep 1
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((3440/2 - 1920/2 + 1080)) $((1440 + 1920/2 - 1440/2)) transform 0 mode 1920x1200@60Hz
          sleep 1
          swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 90 mode 1920x1080@60Hz
          sleep 1
          swaymsg output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 270 mode 1920x1080@60Hz
          sleep 1
          swaymsg "focus output \"AU Optronics 0xD291 Unknown\"" && swaymsg "workspace 1:AU Optronics 0xD291 Unknown"
          swaymsg "focus output \"AOC 2270W GNKJ1HA001311\"" && swaymsg "workspace 1:AOC 2270W GNKJ1HA001311"
          swaymsg "focus output \"Pixio USA Pixio PXC348C Unknown\"" && swaymsg "workspace 1:Pixio USA Pixio PXC348C Unknown"
          ;;
        "Work")
          swaymsg output \"Lenovo Group Limited P24q-30 V90CP3VM\" enable pos 0 0 transform 0 mode 2560x1440@74.780Hz
          swaymsg output \"AU Optronics 0xD291 Unknown\" enable pos $((2560/2 - 1920/2)) 1440 transform 0 mode 1920x1200@60Hz
          sleep 1
          swaymsg "focus output \"AU Optronics 0xD291 Unknown\"" && swaymsg "workspace 1:AU Optronics 0xD291 Unknown"
          swaymsg "focus output \"Lenovo Group Limited P24q-30 V90CP3VM\"" && swaymsg "workspace 1:Lenovo Group Limited P24q-30 V90CP3VM"
          ;;
      esac
    '')
  ];
}
