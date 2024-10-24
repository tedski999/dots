# swaybar but better
{ pkgs, config, ... }: {

  programs.waybar.enable = true;

  programs.waybar.settings = [
    {
      output = "eDP-1";
      ipc = true;
      layer = "top";
      position = "top";
      height = 30;
      spacing = 0;
      modules-left = [ "sway/workspaces" "sway/window" ];
      modules-center = [];
      modules-right = [ "custom/media" "sway/scratchpad" "custom/caffeinated" "gamemode" "bluetooth" "cpu" "memory" "power-profiles-daemon" "temperature" "disk" "network" "pulseaudio" "battery" "clock" ];
      "sway/workspaces".format = "{name}";
      "sway/window".max-length = 200;
      "custom/media" = {
        exec = pkgs.writeShellScript "waybar-media" ''
          max_len=25
          out=""
          tooltip=""
          status="$(playerctl status 2>/dev/null)"
          [ "$status" = "Playing" ] || [ "$status" = "Paused" ] && {
            out="$(playerctl metadata title)"
            tooltip="$out"
            [ ''${#out} -gt "$max_len" ] && {
              i="$(( ( $(date +%s) % ( ''${#out} + 3 ) ) + 1 ))"
              out="$(echo "$out   $out" | tail -c +$i)"
            }
          }
          out="$(echo "$out" | head -c "$(( $max_len - 1 ))")"
          printf '{"text": %s, "tooltip": %s, "class": %s}\n' \
            "$(echo -n "$out" | jq --raw-input --slurp --ascii-output)" \
            "$(echo -n "$tooltip" | jq --raw-input --slurp --ascii-output)" \
            "$(echo -n "$status" | jq --raw-input --slurp --ascii-output)"
        '';
        return-type = "json";
        interval = 1;
        on-click = "playerctl play-pause";
        on-scroll-up = "playerctl position 5+";
        on-scroll-down = "playerctl position 5-";
      };
      "custom/caffeinated" = {
        exec = pkgs.writeShellScript "waybar-coffee" ''printf '{"text": "%s", "tooltip": "%s" }\n' $(pidof -q swayidle && echo "" || echo "C Caffeinated")'';
        return-type = "json";
        tooltip = true;
        interval = 1;
        on-click = "powerctl decafeinate";
      };
      gamemode = {
        format = "{count}";
        format-alt = "{count}";
        tooltip-format = "Gaming™";
        use-icon = false;
        icon-spacing = 0;
        icon-size = 0;
      };
      bluetooth = {
        format = "";
        format-connected = "{num_connections}";
        tooltip-format = "{device_alias}";
        on-click = "networkctl bluetooth";
      };
      cpu = {
        interval = 1;
        format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}{icon12}{icon13}{icon14}{icon15}";
        format-icons = [
          "<span color='#00ff00'>▁</span>"
          "<span color='#00ff00'>▂</span>"
          "<span color='#00ff00'>▃</span>"
          "<span color='#00ff00'>▄</span>"
          "<span color='#ff8000'>▅</span>"
          "<span color='#ff8000'>▆</span>"
          "<span color='#ff8000'>▇</span>"
          "<span color='#ff0000'>█</span>"
        ];
        on-click = "scratch floating-btop btop";
      };
      memory = {
        interval = 5;
        format = "{icon}";
        format-icons = [
          "<span color='#00ff00'>▁</span>"
          "<span color='#00ff00'>▂</span>"
          "<span color='#00ff00'>▃</span>"
          "<span color='#00ff00'>▄</span>"
          "<span color='#ff8000'>▅</span>"
          "<span color='#ff8000'>▆</span>"
          "<span color='#ff8000'>▇</span>"
          "<span color='#ff0000'>█</span>"
        ];
        tooltip-format = "RAM: {used:0.1f}Gib ({percentage}%)\nSWP: {swapUsed:0.1f}Gib ({swapPercentage}%)";
        on-click = "scratch floating-btop btop";
      };
      power-profiles-daemon = {
        format-icons = {
          default = "D";
          performance = "P";
          balanced = "B";
          power-saver = "Q";
        };
      };
      temperature = {
        tooltip-format = "{temperatureC}°C / {temperatureF}°F\nThermal zone 6";
        thermal-zone = 6;
        critical-threshold = 80;
        interval = 5;
        on-click = "scratch floating-btop btop";
      };
      disk = {
        format = "{free}";
        on-click = "scratch floating-btop btop";
      };
      network = {
        interval = 10;
        max-length = 10;
        format-wifi = "{essid}";
        format-ethernet = "wired";
        format-disconnected = "offline";
        on-click = "networkctl wifi";
        on-click-right = ''case "$(nmcli radio wifi)" in "enabled") nmcli radio wifi off;; *) nmcli radio wifi on;; esac'';
      };
      pulseaudio = {
        max-volume = 150;
        states.high = 75;
        on-click = "scratch floating-pulsemixer pulsemixer";
        on-click-right = "pulsemixer --toggle-mute";
      };
      battery = {
        interval = 10;
        states = { warning = 30; critical = 15; };
        format = "{capacity}%";
        on-click = "powerctl";
        on-scroll-up = "brightnessctl set 1%-";
        on-scroll-down = "brightnessctl set 1%+";
      };
      clock = {
        format = "{:%m-%d %H:%M}";
        tooltip-format = "{calendar}";
        on-click = ''notify-send -i clock "$(date)" "$(date "+Day %j, Week %V, %Z (%:z)")"'';
        actions.on-click-right = "mode";
        actions.on-scroll-up = "shift_up";
        actions.on-scroll-down = "shift_down";
        calender.mode = "month";
        calender.mode-mon-col = 3;
        calender.on-click-right = "mode";
        calender.on-scroll = 1;
        calender.format.months =   "<span color='#8080ff'>{}</span>";
        calender.format.days =     "<span color='#ffffff'>{}</span>";
        calender.format.weekdays = "<span color='#ff8000'><b>{}</b></span>";
        calender.format.today =    "<span color='#ff0000'><b>{}</b></span>";
      };
    }
    {
      output = "!eDP-1";
      ipc = true;
      layer = "top";
      position = "top";
      height = 30;
      spacing = 0;
      modules-left = [ "sway/workspaces" "sway/window" ];
      modules-center = [];
      modules-right = [];
      "sway/workspaces".format = "{name}";
      "sway/window".max-length = 200;
    }
  ];

  programs.waybar.style = ''
    * { font-family: "Terminess Nerd Font", monospace; font-size: 16px; margin: 0; }
    window#waybar { background-color: rgba(0,0,0,0.75); }

    @keyframes pulse { to { color: #ffffff; } }
    @keyframes flash { to { background-color: #ffffff; } }
    @keyframes luminate { to { background-color: #b0b0b0; } }

    #workspaces, #scratchpad, #window, #custom-media, #custom-caffeinated, #gamemode, #bluetooth, #cpu, #memory, #disk, #temperature, #battery, #network, #pulseaudio {
      padding: 0 5px;
    }
    #workspaces button:hover, #scratchpad:hover, #custom-caffeinated:hover, #gamemode:hover, #bluetooth:hover, #cpu:hover, #memory:hover, #disk:hover, #power-profiles-daemon:hover, #temperature:hover, #battery:hover, #network:hover, #pulseaudio:hover, #clock:hover {
      background-color: #404040;
    }

    #workspaces { padding: 0 5px 0 0; }
    #workspaces button { border: none; border-radius: 0; padding: 0 5px; min-width: 20px; animation: none; }
    #workspaces button.focused { background-color: #ffffff; color: #000000; }
    #workspaces button.urgent { background-color: #404040; animation: luminate 1s steps(30) infinite alternate; }

    #workspaces button#sway-workspace-1\:1:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:2:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:3:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:4:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:5:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:6:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:7:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:8:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:9:not(.focused) { color: #ff8080; }
    #workspaces button#sway-workspace-1\:1.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:2.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:3.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:4.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:5.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:6.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:7.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:8.focused { background-color: #ffcccc; }
    #workspaces button#sway-workspace-1\:9.focused { background-color: #ffcccc; }

    #workspaces button#sway-workspace-2\:1:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:2:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:3:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:4:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:5:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:6:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:7:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:8:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:9:not(.focused) { color: #8080ff; }
    #workspaces button#sway-workspace-2\:1.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:2.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:3.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:4.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:5.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:6.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:7.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:8.focused { background-color: #aaaaff; }
    #workspaces button#sway-workspace-2\:9.focused { background-color: #aaaaff; }

    #workspaces button#sway-workspace-3\:1:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:2:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:3:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:4:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:5:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:6:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:7:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:8:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:9:not(.focused) { color: #80ff80; }
    #workspaces button#sway-workspace-3\:1.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:2.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:3.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:4.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:5.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:6.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:7.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:8.focused { background-color: #aaffaa; }
    #workspaces button#sway-workspace-3\:9.focused { background-color: #aaffaa; }

    #scratchpad { color: #ffff00; padding: 0 10px 0 0; }

    #custom-media.Paused { color: #606060; }

    #custom-caffeinated { color: #ff8000; }

    #gamemode { color: #00ff00; }

    #bluetooth { color: #00ffff; }

    #temperature.critical { color: #800000; animation: pulse .5s steps(15) infinite alternate; }

    #power-profiles-daemon { padding: 0 5px 0 10px; color: #c000ff; }

    #network.disabled { color: #ff0000; }
    #network.disconnected { color: #ff8000; }
    #network.linked, #network.ethernet, #network.wifi { color: #00ff00; }

    /*#pulseaudio.high { color: #ff8000; }*/
    #pulseaudio.muted { color: #ff0000; }

    #battery:not(.charging) { color: #ff8000; }
    #battery.charging, #battery.full { color: #00ff00; }
    #battery.warning:not(.charging) { color: #800000; animation: pulse .5s steps(15) infinite alternate; }
    #battery.critical:not(.charging) { color: #000000; background-color: #800000; animation: flash .25s steps(10) infinite alternate; }

    #clock { padding: 0 5px; }
  '';

}
