# TODO(test) test git on wbus
# TODO(sync) remove work from work

{ pkgs, config, lib, home, inputs, ... }:
let
  msung = home == 0;
  septs = home == 1;
  work = home == 2;
  wbus = home == 3;
in {

  imports = [ inputs.agenix.homeManagerModules.default ];

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.use-xdg-base-directories = true;
  nix.settings.warn-dirty = false;
  nix.settings.max-jobs = lib.mkIf (!wbus) "auto";
  nix.settings.cores = lib.mkIf (!wbus) 0;
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux.enable = lib.mkIf (work || wbus) true;
  systemd.user.startServices = lib.mkIf (!wbus) "sd-switch";

  home.stateVersion = "25.05";
  home.username = if msung || septs then "ski" else "tedj";
  home.homeDirectory = if msung || septs then "/home/ski" else "/home/tedj";
  home.preferXdgDirectories = true;
  home.language = { base = "en_IE.UTF-8"; };
  home.keyboard = { layout = "ie"; options = [ "caps:escape" ]; };
  home.sessionVariables = lib.mkMerge [
    {
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
      MANWIDTH = 80;
      LESS = "--incsearch --ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT --RAW-CONTROL-CHARS";
      PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
    }

    (lib.mkIf (msung || work) {
      TERMINAL = "alacritty";
      LAUNCHER = "bemenu-run";
      QT_QPA_PLATFORM = "wayland";
    })

    (lib.mkIf msung { BROWSER = "firefox"; MOZ_ENABLE_WAYLAND = 1; })
    (lib.mkIf work { BROWSER = "chromium"; })
  ];

  home.packages = with pkgs; lib.mkMerge [
    [
      nix

      coreutils
      curl
      diffutils
      file
      gawk
      gnused
      gnutar
      gzip
      jq
      p7zip
      procps
      python3
      trashy # TODO(later): fix on wbus and other permission issues
      unrar
      unzip
      xz
      zip
      inputs.agenix.packages.${system}.default
      (writeShellScriptBin "0x0" "curl -F\"file=@$1\" https://0x0.st;")
    ]

    (lib.mkIf (msung || work) [
      acpi
      bitwarden-cli
      brightnessctl
      grim
      libnotify
      nerd-fonts.terminess-ttf
      playerctl
      pulsemixer
      slurp
      swayidle
      wl-clipboard

      (writeShellScriptBin "batteryd" ''
        while true; do
          sleep 1
          prev_charge="''${charge:-100}"
          acpi="$(acpi | sed "s/.*: //")"
          state="$(echo "$acpi" | cut -f 1 -d ',')"
          charge="$(echo "$acpi" | cut -f 2 -d ',' | tr -d '%')"
          time="$(echo "$acpi" | cut -f 3 -d ',')"
          if [ "$state" = "Discharging" ]; then
            if [ "$prev_charge" -gt 3 ] && [ "$charge" -le 3 ]; then
              for i in $(seq 3 -1 1); do notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery empty!" "Suspending in $i..."; sleep 1; done
              powerctl suspend
            elif [ "$prev_charge" -gt 10 ] && [ "$charge" -le 10 ]; then
              notify-send -i battery-020 -u critical -r "$$" -t 0 "Battery critical!" "Less than$time"
            elif [ "$prev_charge" -gt 20 ] && [ "$charge" -le 20 ]; then
              notify-send -i battery-020 -u normal -r "$$" "Battery low!" "Less than$time"
            fi
          fi
        done
      '')

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

      (writeShellScriptBin "networkctl" ''
        IFS=$'\n'

        case "$([ -n "$1" ] && echo $1 || printf "%s\n" wifi bluetooth | bemenu -p "Network" -l 3)" in

          "wifi") while true; do
            function n() { notify-send -i network-wireless -t 5000 "Wi-Fi Control" $@; }

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
            function n() { notify-send -i network-bluetooth -t 5000 "Bluetooth Control" $@; }

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

      (writeShellScriptBin "displayctl" ''
        IFS=$'\n'
        choice="$([ -n "$1" ] && echo $1 || printf "%s\n" auto none work home | bemenu -p "Display" -l 5)"
        [ "$choice" = "auto" ] && case "$(swaymsg -rt get_outputs | jq -r '.[] | .make+" "+.model+" "+.serial' | sort | xargs)" in
          "AOC 2270W GNKJ1HA001311 AU Optronics 0xD291 Unknown Pixio USA Pixio PXC348C Unknown") choice="home";;
          "AU Optronics 0xD291 Unknown Lenovo Group Limited P24q-30 V90CP3VM")                   choice="work";;
          *)                                                                                     choice="none";;
        esac
        case "$choice" in
          "none") swaymsg \
            output \* disable, \
            $(printf "output \"%s\" enable, " $(swaymsg -rt get_outputs | jq -r '.[] | .make+" "+.model+" "+.serial')) ;;
          "work") swaymsg \
            output \* disable, \
            output \"Lenovo Group Limited P24q-30 V90CP3VM\" enable pos 0 0 transform 0 mode 2560x1440@74.780Hz, \
            output \"AU Optronics 0xD291 Unknown\" enable pos $((2560/2 - 1920/2)) 1440 transform 0 mode 1920x1200@60Hz ;;
          "home") swaymsg \
            output \* disable, \
            output \"Pixio USA Pixio PXC348C Unknown\" enable pos 1080 $((1920/2 - 1440/2)) transform 0 mode 3440x1440@100Hz, \
            output \"AU Optronics 0xD291 Unknown\" enable pos $((3440/2 - 1920/2 + 1080)) $((1440 + 1920/2 - 1440/2)) transform 0 mode 1920x1200@60Hz, \
            output \"AOC 2270W GNKJ1HA001311\" enable pos 0 0 transform 270 mode 1920x1080@60Hz ;;
          *) exit 1 ;;
        esac
        notify-send -i monitor -t 5000 "Set display configuration" "Profile: $choice"
      '')

      (writeShellScriptBin "swaytaskinput" ''
        c=$(cat /tmp/swaytask)
        t=$({ echo $c; swaymsg -rt get_workspaces | jq -r '.[].name' | grep "^0|" | cut -d'|' -f2; } | sort -u | bemenu -l 10 -p "Task")
        case "$t" in *\|*|*:*|*\ *|""|"$c") echo $c; exit 1;; *) echo $t;; esac
      '')

      (writeShellScriptBin "swaytaskset" ''
        c=$(cat /tmp/swaytask)
        swaymsg -q $(
          for w in $(swaymsg -rt get_workspaces | jq -r '.[].name' | grep -v "^\(0|\|\(14:q\|15:a\|16:z\)$\)"); do echo "rename workspace $w to 0|$c|$(echo $w | tr ':' '|'):#, "; done
          for w in $(swaymsg -rt get_workspaces | jq -r '.[].name' | grep -P "^\Q0|$1|\E"); do echo "rename workspace $w to $(echo $w | cut -d'|' -f3- | cut -d ':' -f1 | tr '|' ':'), "; done)
        notify-send -i task-complete -t 2000 "Switched to $1" "Was on $c"
        echo "$1" >/tmp/swaytask
      '')

      (writeShellScriptBin "bmbwd" ''
        # TODO(later): extend to allow creation of items and choosing to copy other fields
        # bw get template item | jq ".name=\"My Login Item\" | .login=$(bw get template item.login | jq '.username="jdoe" | .password="myp@ssword123"')" | bw encode | bw create item

        bmbw() {
          [ -z "$BW_SESSION" ] \
          && export BW_SESSION="$(: | bemenu -x indicator -l 0 -p 'Bitwarden Password:' | tr -d '\n' | base64 | bw unlock --raw)" \
          && [ -z "$BW_SESSION" ] \
          && notify-send -i lock -u critical -t 5000 "Bitwarden Failed" "Wrong password?" \
          && return 1

          [ -z "$items" ] \
          && notify-send -i lock "Bitwarden" -t 5000 "Updating items..." \
          && items="$(bw list items)"

          #echo "$items" | jq -r 'range(length) as $i | .[$i] | select(.type==1) | ($i | tostring)+" "+.name+" <"+.login.username+">"' | bemenu | cut -d' ' -f1
          echo "$items" | jq -r '.[] | select(.type==1) | .name+" <"+.login.username+"> "+.login.password' | bemenu -p 'Bitwarden' | rev | cut -d' ' -f1 | rev | wl-copy --trim-newline
        }

        trap "bmbw" USR1
        # TODO(later): doesnt work sometimes
        trap "unset items && bmbw" USR2
        trap "unset items BW_SESSION && bmbw" TERM
        while true; do sleep infinity & wait; done
      '')
    ])

    (lib.mkIf (work || wbus) [
      mosh
    ])

    (lib.mkIf msung [
      firefox
    ])

    (lib.mkIf work [
      openconnect
      (writeShellScriptBin "avpn" ''
        sudo openconnect \
          --protocol=gp ''${1:-gp-ie.arista.com} \
          -u tedj \
          -c "$XDG_RUNTIME_DIR/agenix/tedj@arista.com.crt" \
          -k "$XDG_RUNTIME_DIR/agenix/tedj@arista.com.pem"
      '')
      (writeShellScriptBin "ash" ''
        host="''${1:+tedj-$1}"
        mosh \
          --server="~/.local/bin/zsh -c mosh-server" \
          --predict=always --predict-overwrite --experimental-remote-ip=remote \
          "''${host:-bus-home}"
      '')
      (writeShellScriptBin "asl" "arista-ssh check-auth || arista-ssh login")
    ])

    (lib.mkIf wbus [
      (writeShellScriptBin "ahome" ''
        [ "$(hostname | cut -d- -f-2)" = "tedj-home" ] || exit 1
        export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
        for n in $(a4c ps -N); do
          echo; echo "Rehoming $n..."
          a4c shell --env NIX_CONFIG $n sh -c '
            sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes
            . ~/.local/state/nix/profile/etc/profile.d/nix.sh
            nix-env --set-flag priority 0 nix
            rm -f ~/.local/state/nix/profiles/home-manager* ~/.local/state/home-manager/gcroots/current-home
            nix run home-manager -- switch --flake github:tedski999/dots#tedj@wbus
        done
        echo; echo "Rehoming bus.."
        sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes
        . ~/.local/state/nix/profile/etc/profile.d/nix.sh
        nix-env --set-flag priority 0 nix
        rm -f ~/.local/state/nix/profiles/home-manager* ~/.local/state/home-manager/gcroots/current-home
        nix run home-manager -- switch --flake github:tedski999/dots#tedj@wbus
        unset NIX_CONFIG
      '')
      (writeShellScriptBin "ag" ''
        # TODO(later) superseded by arista
        if   [ "$1" = "a"  ]; then shift; a git add $@
        elif [ "$1" = "c"  ]; then shift; a git commit $@
        elif [ "$1" = "cm" ]; then shift; a git commit --message $@
        elif [ "$1" = "ca" ]; then shift; a git commit --amend $@
        elif [ "$1" = "d"  ]; then shift; a git diff $@
        elif [ "$1" = "ds" ]; then shift; a git diff --staged $@
        elif [ "$1" = "l"  ]; then shift; a git log $@
        elif [ "$1" = "ps" ]; then shift; a git ps $@
        elif [ "$1" = "s"  ]; then shift; a git status $@
        elif [ "$1" = "ch" ]; then shift; a git checkout $@
        else a git $@
        fi
      '')
    ])
  ];

  home.file = lib.mkMerge [
    {
      ".config/python/pythonrc".text = ''
        import atexit, readline
        try:
            readline.read_history_file("${config.xdg.dataHome}/python_history")
        except OSError as e:
            pass
        if readline.get_current_history_length() == 0:
            readline.add_history("# history created")
        def write_history(path):
            try:
                import os, readline
                os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)
                readline.write_history_file(path)
            except OSError:
                pass
        atexit.register(write_history, "${config.xdg.dataHome}/python_history")
        del (atexit, readline, write_history)
      '';
    }

    (lib.mkIf wbus {
      ".local/bin/git".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.git}/bin/git";
      ".local/bin/man".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.man}/bin/man";
      ".local/bin/man-recode".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.man}/bin/man-recode";
      ".local/bin/mandb".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.man}/bin/mandb";
      ".local/bin/manpath".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.man}/bin/manpath";
      ".local/bin/mosh".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mosh}/bin/mosh";
      ".local/bin/mosh-client".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mosh}/bin/mosh-client";
      ".local/bin/mosh-server".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.mosh}/bin/mosh-server";
      ".local/bin/tmux".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.tmux}/bin/tmux";
      ".local/bin/vi".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.neovim}/bin/nvim";
      ".local/bin/vim".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.neovim}/bin/nvim";
      ".local/bin/zsh".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.zsh}/bin/zsh";
      ".bashrc".text = ''[[ $- == *i* ]] && [ -z "$ARTEST_RANDSEED" ] && { shopt -q login_shell && exec ${pkgs.zsh}/bin/zsh --login $@ || exec ${pkgs.zsh}/bin/zsh $@; }'';
      ".bash_profile".text = ''. ~/.bashrc'';
    })

    (lib.mkIf work {
      ".hushlogin".text = "";
      ".config/xdg-desktop-portal-wlr/config".text = ''
        [screencast]
        output_name=
        max_fps=30
        chooser_cmd=slurp -f %o -o
        chooser_type=simple
      '';
    })
  ];

  age.identityPaths = lib.mkMerge [
    (lib.mkIf msung [ "/home/ski/.ssh/ski@msung.agenix.key" ])
    (lib.mkIf septs [ "/home/ski/.ssh/ski@septs.agenix.key" ])
    (lib.mkIf work [ "/home/tedj/.ssh/tedj@work.agenix.key" ])
    (lib.mkIf wbus [ "/home/tedj/.ssh/tedj@wbus.agenix.key" ])
  ];
  age.secrets = lib.mkMerge [
    (lib.mkIf (msung || work) {
      "ski@h8c.de.gpg"           = { file = ./secrets/ski_h8c.de/subkey.age; };
    })
    (lib.mkIf work {
      "tedj@arista.com.cer"      = { file = ./secrets/arista/work_cer.age; };
      "tedj@arista.com.crt"      = { file = ./secrets/arista/work_crt.age; };
      "tedj@arista.com.csr"      = { file = ./secrets/arista/work_csr.age; };
      "tedj@arista.com.pem"      = { file = ./secrets/arista/work_pem.age; };
      "mailfilters.xml"          = { file = ./secrets/arista/mailfilters.age; };
      "syncthing/config.xml"     = { file = ./secrets/syncthing/tedj_work/config.xml.age;     path = "${config.xdg.configHome}/syncthing/config.xml";     };
      "syncthing/cert.pem"       = { file = ./secrets/syncthing/tedj_work/cert.pem.age;       path = "${config.xdg.configHome}/syncthing/cert.pem";       };
      "syncthing/key.pem"        = { file = ./secrets/syncthing/tedj_work/key.pem.age;        path = "${config.xdg.configHome}/syncthing/key.pem";        };
      "syncthing/https_cert.pem" = { file = ./secrets/syncthing/tedj_work/https-cert.pem.age; path = "${config.xdg.configHome}/syncthing/https-cert.pem"; };
      "syncthing/https_key.pem"  = { file = ./secrets/syncthing/tedj_work/https-key.pem.age;  path = "${config.xdg.configHome}/syncthing/https-key.pem";  };
    })
  ];

  fonts.fontconfig = lib.mkIf (msung || work) {
    enable = true;
    defaultFonts.monospace = [ "Terminess Nerd Font" ];
    defaultFonts.sansSerif = [];
    defaultFonts.serif = [];
    defaultFonts.emoji = [];
  };

  programs.alacritty = lib.mkIf (msung || work) {
    enable = true;
    settings.general.live_config_reload = false;
    settings.scrolling = { history = 10000; multiplier = 5; };
    settings.window = { dynamic_padding = true; opacity = 0.85; dimensions = { columns = 120; lines = 40; }; };
    settings.font = { size = 13.5; normal.family = "Terminess Nerd Font"; };
    settings.selection.save_to_clipboard = true;
    settings.keyboard.bindings = [
      { key = "Return"; mods = "Shift|Control"; action = "SpawnNewInstance"; }
      { key = "Escape"; mods = "Shift|Control"; action = "ToggleViMode"; }
      { key = "Escape"; mode = "Vi"; action = "ToggleViMode"; }
    ];
    settings.colors.draw_bold_text_with_bright_colors = true;
    settings.colors.primary = { background = "#000000"; foreground = "#dddddd"; };
    settings.colors.cursor = { cursor = "#cccccc"; text = "#111111"; };
    settings.colors.normal = { black = "#000000"; blue = "#0d73cc"; cyan = "#0dcdcd"; green = "#19cb00"; magenta = "#cb1ed1"; red = "#cc0403"; white = "#dddddd"; yellow = "#cecb00"; };
    settings.colors.bright = { black = "#767676"; blue = "#1a8fff"; cyan = "#14ffff"; green = "#23fd00"; magenta = "#fd28ff"; red = "#f2201f"; white = "#ffffff"; yellow = "#fffd00"; };
    settings.colors.search.focused_match = { background = "#ffffff"; foreground = "#000000"; };
    settings.colors.search.matches = { background = "#edb443"; foreground = "#091f2e"; };
    settings.colors.footer_bar = { background = "#000000"; foreground = "#ffffff"; };
    settings.colors.line_indicator = { background = "#000000"; foreground = "#ffffff"; };
    settings.colors.selection = { background = "#fffacd"; text = "#000000"; };
  };

  programs.bash = lib.mkIf (!wbus) {
    enable = true;
    initExtra = ''shopt -q login_shell && exec ${pkgs.zsh}/bin/zsh --login $@ || exec ${pkgs.zsh}/bin/zsh $@'';
  };

  programs.bat = {
    enable = true;
    config.style = "plain";
    config.wrap = "never";
    config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  };

  programs.bemenu = lib.mkIf (msung || work) {
    enable = true;
    settings.single-instance = true;
    settings.list = 32;
    settings.center = true;
    settings.fixed-height = true;
    settings.width-factor = 0.5;
    settings.grab = true;
    settings.ignorecase = true;
    settings.border = 1;
    settings.bdr = "#ffffff";
    settings.tb = "#000000";
    settings.tf = "#ffffff";
    settings.fb = "#000000";
    settings.ff = "#ffffff";
    settings.cb = "#ffffff";
    settings.cf = "#ffffff";
    settings.nb = "#000000";
    settings.nf = "#ffffff";
    settings.hb = "#ffffff";
    settings.hf = "#000000";
    settings.fbb = "#ff0000";
    settings.fbf = "#00ff00";
    settings.sb = "#ff0000";
    settings.sf = "#ffffff";
    settings.ab = "#000000";
    settings.af = "#ffffff";
    settings.fn = "Terminess Nerd Font";
  };

  programs.btop = {
    enable = true;
    settings.theme_background = false;
    settings.vim_keys = true;
    settings.rounded_corners = false;
    settings.update_ms = 1000;
    settings.proc_sorting = "cpu lazy";
    settings.proc_tree = false;
    settings.proc_filter_kernel = true;
    settings.proc_aggregate = true;
  };

  programs.chromium = lib.mkIf work {
    enable = true;
    package = (pkgs.chromium.override { enableWideVine = true; }).overrideAttrs (old: {
      buildCommand = ''
        ${old.buildCommand}
        wrapProgram "$out"/bin/chromium --set NIXOS_OZONE_WL 1 \
          --set GOOGLE_DEFAULT_CLIENT_ID "77185425430.apps.googleusercontent.com" \
          --set GOOGLE_DEFAULT_CLIENT_SECRET "OTJgUOQcT7lO7GsGZq2G4IlT" \
          --append-flags "--enable-blink-features=MiddleClickAutoscroll"
      '';
    });
  };

  programs.eza = {
    enable = true;
    extraOptions = [ "--header" "--sort=name" "--group-directories-first" ];
    git = true;
  };

  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [ ".git/" ];
  };

  programs.fzf = {
    enable = true;
    colors = { "fg" = "bold"; "pointer" = "red"; "hl" = "red"; "hl+" = "red"; "gutter" = "-1"; "marker" = "red"; };
    changeDirWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules' --type d";
    fileWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules'";
    defaultCommand = "rg --files --no-messages";
    defaultOptions = [
      "--multi"
      "--bind='ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview'"
      "--preview-window sharp"
      "--marker=k"
      "--color=fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red"
      "--history ${config.xdg.dataHome}/fzf_history"
    ];
  };

  programs.git = {
    enable = true;
    userName = if !wbus then "tedski999" else "tedj";
    userEmail = if !wbus then "ski@h8c.de" else "tedj@arista.com";
    signing = lib.mkIf (!wbus) { key = "00ADEF0A!"; signByDefault = true; };
    extraConfig = if !wbus then {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.default = "current";
    } else ''
      [gitar]
        configured = true
      [safe]
        directory = /src/GitarBandMutDb
    '';
    aliases.l = "log";
    aliases.s = "status";
    aliases.a = "add";
    aliases.c = "commit";
    aliases.cm = "commit --message";
    aliases.ps = "push";
    aliases.pl = "pull";
    aliases.d = "diff";
    aliases.ds = "diff --staged";
    aliases.rs = "restore --staged";
    aliases.un = "reset --soft HEAD~";
    aliases.b = "branch";
    aliases.st = "stash";
    aliases.ch = "checkout";
    aliases.sw = "switch";
    delta.enable = true;
    delta.options.features = "navigate";
    delta.options.relative-paths = true;
    delta.options.width = "variable";
    delta.options.paging = "always";
    delta.options.line-numbers = true;
    delta.options.line-numbers-left-format = "";
    delta.options.line-numbers-right-format = "{np:>4} ";
    delta.options.navigate-regex = "^[-+=!>]";
    delta.options.file-added-label = "+";
    delta.options.file-copied-label = "=";
    delta.options.file-modified-label = "!";
    delta.options.file-removed-label = "-";
    delta.options.file-renamed-label = ">";
    delta.options.file-style = "brightyellow";
    delta.options.file-decoration-style = "omit";
    delta.options.hunk-label = "#";
    delta.options.hunk-header-style = "file line-number";
    delta.options.hunk-header-file-style = "blue";
    delta.options.hunk-header-line-number-style = "grey";
    delta.options.hunk-header-decoration-style = "omit";
    delta.options.blame-palette = "#101010 #282828";
    delta.options.blame-separator-format = "{n:^5}";
  };

  programs.go = lib.mkIf work {
    enable = true;
    goPath = "${config.xdg.dataHome}/go";
  };

  programs.gpg = lib.mkIf (!wbus) {
    enable = true;
    settings.keyid-format = "LONG";
    settings.with-fingerprint = true;
    settings.with-subkey-fingerprint = true;
    settings.with-keygrip = true;
    settings.trusted-key = "DDA5B1D740B877AA";
  };

  services.gpg-agent = lib.mkIf (!wbus) {
    enable = true;
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 2592000;
    maxCacheTtlSsh = 2592000;
    pinentryPackage = pkgs.pinentry-curses;
    enableSshSupport = true;
    sshKeys = [ "613AB861624F38ECCEBBB3764CF4A761DBE24D1B" ];
  };

  programs.home-manager = {
    enable = true;
  };

  programs.less = {
    enable = true;
    keys = "h left-scroll\nl right-scroll";
  };

  programs.man = {
    enable = true;
    #generateCaches = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      fzf-lua
      lualine-nvim
      mini-nvim
      neogit
      nightfox-nvim
      nvim-surround
      satellite-nvim
      vim-rsi
      vim-signify
    ];
    extraLuaConfig = lib.mkMerge [
      (lib.mkIf (work || wbus) ''
        local a = vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and not vim.fn.getcwd():find("^/home")
        if a then
          vim.api.nvim_echo({ { "Note: Arista-specifics enabled for this Neovim instance", "MoreMsg" } }, false, {})
          vim.cmd[[ let a4_auto_edit = 0 | source /usr/share/vim/vimfiles/arista.vim ]]
        end
      '')
      (''
        -- Spaceman
        vim.g.mapleader = " "

        -- Consistent aesthetics
        vim.lsp.protocol.CompletionItemKind = {
          '""', ".f", "fn", "()", ".x",
          "xy", "{}", "{}", "[]", ".p",
          "$$", "00", "∀e", ";;", "~~",
          "rg", "/.", "&x", "//", "∃e",
          "#x", "{}", "ev", "++", "<>"
        }

        -- We don't need netrw where we're going
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- Better signify highlighting
        vim.g.signify_number_highlight = 1

        -- Use OSC-52 to copy
        vim.g.clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
          },
          paste = {
            ["+"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end,
            ["*"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end,
          },
        }

        -- OPTIONS --

        vim.opt.title = true                                   -- Update window title
        vim.opt.mouse = "a"                                    -- Enable mouse support
        vim.opt.updatetime = 100                               -- Faster refreshing
        vim.opt.timeoutlen = 5000                              -- 5 seconds to complete mapping
        vim.opt.clipboard = "unnamedplus"                      -- Use system clipboard
        vim.opt.undofile = true                                -- Write undo history to disk
        vim.opt.swapfile = false                               -- No need for swap files
        vim.opt.modeline = false                               -- Don't read mode line
        vim.opt.virtualedit = "onemore"                        -- Allow cursor to extend one character past the end of the line
        vim.opt.grepprg = "rg --vimgrep "                      -- Use ripgrep for grepping
        vim.opt.number = true                                  -- Enable line numbers...
        vim.opt.relativenumber = false                         -- ...and not relative line numbers
        vim.opt.ruler = false                                  -- No need to show line/column number with lightline
        vim.opt.showmode = false                               -- No need to show current mode with lightline
        vim.opt.scrolloff = 3                                  -- Keep lines above/below the cursor when scrolling
        vim.opt.sidescrolloff = 5                              -- Keep columns to the left/right of the cursor when scrolling
        vim.opt.signcolumn = "no"                              -- Keep the sign column closed
        vim.opt.shortmess:append("sSIcC")                      -- Be quieter
        vim.opt.expandtab =false                               -- Tab key inserts tabs
        vim.opt.tabstop = 2                                    -- 2-spaced tabs
        vim.opt.shiftwidth = 0                                 -- Tab-spaced indentation
        vim.opt.cinoptions = "N-s"                             -- Don't indent C++ namespaces
        vim.opt.list = true                                    -- Enable whitespace characters below
        vim.opt.listchars="space:·,tab:› ,trail:•,precedes:<,extends:>,nbsp:␣"
        vim.opt.suffixes:remove(".h")                          -- Header files are important...
        vim.opt.suffixes:append(".git")                        -- ...but .git files are not
        vim.opt.foldmethod = "indent"                          -- Fold based on indent
        vim.opt.foldlevelstart = 20                            -- ...and start with everything open
        vim.opt.wrap = false                                   -- Don't wrap
        vim.opt.lazyredraw = true                              -- Redraw only after commands have completed
        vim.opt.termguicolors = true                           -- Enable true colors and gui cursor
        vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait400-blinkoff400-blinkon400"
        vim.opt.ignorecase = true                              -- Ignore case when searching...
        vim.opt.smartcase = true                               -- ...except for searching with uppercase characters
        vim.opt.complete = ".,w,kspell"                        -- Complete menu contents
        vim.opt.completeopt = "menu,menuone,noinsert,noselect" -- Complete menu functionality
        vim.opt.pumheight = 8                                  -- Limit complete menu height
        vim.opt.spell = true                                   -- Enable spelling by default
        vim.opt.spelloptions = "camel"                         -- Enable CamelCase word spelling
        vim.opt.spellsuggest = "best,20"                       -- Only show best spelling corrections
        vim.opt.spellcapcheck = ""                             -- Don't care about capitalisation
        vim.opt.dictionary = "/usr/share/dict/words"           -- Dictionary file
        vim.opt.shada = "!,'256,<50,s100,h,r/media"            -- Specify removable media for shada
        vim.opt.undolevels = 2048                              -- More undo space
        vim.opt.diffopt = "internal,filler,context:512"        -- I like lots of diff context
        vim.opt.hidden = true                                  -- Modified buffers can be hidden
        vim.opt.wildmode = "longest:full,full"                 -- Match common and show wildmenu
        vim.opt.wildoptions = "fuzzy,pum"                      -- Wildmenu fuzzy matching and ins-completion menu
        vim.opt.wildignorecase = true                          -- Don't care about wildmenu file capitalisation

        -- LOCAL FUNCTIONS --

        local fzf = require("fzf-lua")

        local function fullpath(path)
          return vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")
        end

        -- Return the alphabetically previous and next files
        local function prev_next_file(file)
          file = (file or fullpath()):gsub("/$", "")
          local prev, dir = file, file:match(".*/") or "/"
          local files = (vim.fn.glob(dir..".[^.]*").."\n"..vim.fn.glob(dir.."*")):gmatch("[^\n]+")
          for next in files do
            if next == file then return prev, files() or next
            elseif next > file then return prev, next
            else prev = next end
          end
          return prev, file
        end

        -- Yank selected entries
        local function fzf_yank_selection(selected)
          local x = table.concat(selected, "\n")
          vim.fn.setreg("+", x)
          print("Yanked "..#x.." bytes")
        end

        -- Restore vim session
        local function fzf_projects()
          local projects = {}
          for path in vim.fn.glob(vim.fn.stdpath("data").."/projects/*"):gmatch("[^\n]+") do
            projects[#projects + 1] = path:match("[^/]*$")
          end
          fzf.fzf_exec(projects, {
            prompt = "Project>",
            fzf_opts = { ["--no-multi"] = true, ["--header"] = "<ctrl-x> to delete|<ctrl-e> to edit" },
            actions = {
              ["default"] = function(sel) vim.cmd("source "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1])) end,
              ["ctrl-e"] = function(sel) vim.cmd("edit "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1]).." | setf vim") end,
              ["ctrl-x"] = function(sel) vim.fn.delete(vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..sel[1])) end,
            }
          })
        end

        -- Save vim session
        local function fzf_projects_save()
          local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
          if project == "" then return end
          vim.fn.mkdir(vim.fn.stdpath("data").."/projects/", "p")
          vim.cmd("mksession! "..vim.fn.fnameescape(vim.fn.stdpath("data").."/projects/"..project))
        end

        -- Visualise and select from the branched undotree
        local function fzf_undotree()
          local undotree = vim.fn.undotree()
          local function build_entries(tree, depth)
            local entries = {}
            for i = #tree, 1, -1  do
              local colors = { "magenta", "blue", "yellow", "green", "red" }
              local color = fzf.utils.ansi_codes[colors[math.fmod(depth, #colors) + 1]]
              local entry = tree[i].seq..""
              if tree[i].save then entry = entry.."*" end
              local t = os.time() - tree[i].time
              if t > 86400 then t = math.floor(t/86400).."d" elseif t > 3600 then t = math.floor(t/3600).."h" elseif t > 60 then t = math.floor(t/60).."m" else t = t.."s" end
              if tree[i].seq == undotree.seq_cur then t = fzf.utils.ansi_codes.white(t.." <") else t = fzf.utils.ansi_codes.grey(t) end
              entries[#entries+1] = color(entry).." "..t
              if tree[i].alt then
                local subentries = build_entries(tree[i].alt, depth + 1)
                for j = 1, #subentries do entries[#entries+1] = " "..subentries[j] end
              end
            end
            return entries
          end
          local buf = vim.api.nvim_get_current_buf()
          local file = fullpath()
          fzf.fzf_exec(build_entries(undotree.entries, 0), {
            prompt = "Undotree>",
            fzf_opts = { ["--no-multi"] = "" },
            actions = { ["default"] = function(s) vim.cmd("undo "..s[1]:match("%d+")) end },
            previewer = false,
            preview = fzf.shell.raw_preview_action_cmd(function(s)
              if #s == 0 then return end
              local newbuf = vim.api.nvim_get_current_buf()
              local tmp = vim.fn.tempname()
              vim.api.nvim_set_current_buf(buf)
              vim.cmd("undo "..s[1]:match("%d+"))
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              vim.cmd("undo "..undotree.seq_cur)
              vim.fn.writefile(lines, tmp)
              vim.api.nvim_set_current_buf(newbuf)
              return "delta --file-modified-label ''' --hunk-header-style ''' --file-transformation 's/tmp.*//' "..file.." "..tmp
            end)
          })
        end

        -- Get all alternative files based on extension
        local function get_altfiles()
          local ext_altexts = {
            [".c"] = { ".h", ".hpp", ".tin" },
            [".h"] = { ".c", ".cpp", ".tac" },
            [".cpp"] = { ".hpp", ".h", ".tin" },
            [".hpp"] = { ".cpp", ".c", ".tac" },
            [".vert.glsl"] = { ".frag.glsl" },
            [".frag.glsl"] = { ".vert.glsl" },
            [".tac"] = { ".tin", ".cpp", ".c" },
            [".tin"] = { ".tac", ".hpp", ".h" }
          }
          local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
          local hits, more = {}, {}
          for ext, altexts in pairs(ext_altexts) do
            if file:sub(-#ext) == ext then
              for i=1,#altexts do
                local alt = file:sub(0,#file-#ext)..altexts[i]
                if vim.loop.fs_stat(alt) then hits[#hits+1] = alt else more[#more+1] = alt end
              end
            end
          end
          return hits, more
        end

        -- Switch to an alternative file
        local function fzf_altfiles(hits, more)
          for i=1,#hits do hits[i] = fzf.utils.ansi_codes.green(hits[i]) end
          for i=1,#more do hits[#hits+1] = fzf.utils.ansi_codes.red(more[i]) end
          fzf.fzf_exec(hits, { prompt = "Altfiles>", actions = fzf.config.globals.actions.files, previewer = "builtin" })
        end

        -- AUTOCMDS --

        -- Highlight suspicious whitespace
        local function get_whitespace_pattern()
          local pattern = [[[\u00a0\u1680\u180e\u2000-\u200b\u202f\u205f\u3000\ufeff]\+\|\s\+$\|[\u0020]\+\ze[\u0009]\+]]
          return "\\("..(vim.o.expandtab and pattern..[[\|^[\u0009]\+]] or pattern..[[\|^[\u0020]\+]]).."\\)"
        end
        local function apply_whitespace_pattern(pattern)
          local no_ft = { diff=1, git=1, gitcommit=1, markdown=1 }
          local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
          if no_ft[vim.o.ft] or no_bt[vim.o.bt] then vim.cmd("match none") else vim.cmd("match ExtraWhitespace '"..pattern.."'") end
        end
        vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen", "InsertLeave" }, { callback = function()
          apply_whitespace_pattern(get_whitespace_pattern())
        end })
        vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, { callback = function()
          local line, pattern = vim.fn.line("."), get_whitespace_pattern()
          apply_whitespace_pattern("\\%<"..line.."l"..pattern.."\\|\\%>"..line.."l"..pattern)
        end })

        -- If I can read it I can edit it (even if I can't write it)
        vim.api.nvim_create_autocmd("BufEnter", { callback = function()
          vim.o.readonly = false
        end })

        -- Remember last cursor position
        vim.api.nvim_create_autocmd("BufWinEnter", { callback = function()
          local no_ft = { diff=1, git=1, gitcommit=1, gitrebase=1 }
          local no_bt = { quickfix=1, nofile=1, help=1, terminal=1 }
          if not (no_ft[vim.o.ft] or no_bt[vim.o.buftype] or vim.fn.line(".") > 1 or vim.fn.line("'\"") <= 0 or vim.fn.line("'\"") > vim.fn.line("$")) then
            vim.cmd([[normal! g`"]])
          end
        end })

        -- Hide cursorline if not in current buffer
        vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = false, false end })
        vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "FocusGained" }, { callback = function() vim.opt.cursorline, vim.opt.cursorcolumn = true, true end })

        -- Keep universal formatoptions
        vim.api.nvim_create_autocmd("Filetype", { callback = function() vim.o.formatoptions = "rqlj" end })

        -- Swap to manual folding after loading
        vim.api.nvim_create_autocmd("BufWinEnter", { callback = function() vim.o.foldmethod = "manual" end })

        -- Per filetype config
        vim.api.nvim_create_autocmd("FileType", { pattern = "nix", command = "setlocal tabstop=2 shiftwidth=2 expandtab" })
        vim.api.nvim_create_autocmd("FileType", { pattern = { "c", "cpp" }, command = "setlocal commentstring=//\\ %s" })

        -- Disable satellite on long files (search highlighting causes stuttering)
        vim.api.nvim_create_autocmd("BufWinEnter", { callback = function() if vim.api.nvim_buf_line_count(0) > 10000 then vim.cmd("SatelliteDisable") end end })

        -- Show directory listings
        vim.api.nvim_create_autocmd("BufEnter", { command = "if isdirectory(expand('%')) | setlocal buftype=nowrite bufhidden=wipe | %delete _ | exec '.!echo '..expand('%:p')..'; echo; eza -laah '..expand('%') | end" })

        -- Autodetect indentation type
        vim.api.nvim_create_autocmd("BufReadPost", { command = "if search('^\\t\\+[^\\s]', 'nw') | setlocal noexpandtab | elseif search('^ \\+[^\\s]', 'nw') | setlocal expandtab | end" })

        -- PLUGIN INITIALISATION --

        fzf.register_ui_select()
        fzf.setup({
          hls = { border = "NormalBorder", preview_border = "NormalBorder" },
          winopts = {
            height = 0.25, width = 1.0, row = 1.0, col = 0.5,
            border = { "─", "─", "─", " ", "", "", "", " " },
            preview = { scrollchars = { "│", "" }, winopts = { list = true } }
          },
          keymap = {
            builtin = {
              ["<esc>"] = "hide",
              ["<c-j>"] = "accept",
              ["<m-o>"] = "toggle-preview",
              ["<c-o>"] = "toggle-fullscreen",
              ["<c-d>"] = "half-page-down",
              ["<c-u>"] = "half-page-up",
              ["<m-n>"] = "preview-down",
              ["<m-p>"] = "preview-up",
              ["<m-d>"] = "preview-half-page-down",
              ["<m-u>"] = "preview-half-page-up",
            },
            fzf = {
              ["ctrl-j"] = "accept",
              ["ctrl-d"] = "half-page-down",
              ["ctrl-u"] = "half-page-up",
              ["alt-n"] = "preview-down",
              ["alt-p"] = "preview-up",
              ["alt-d"] = "preview-half-page-down",
              ["alt-u"] = "preview-half-page-up",
            },
          },
          actions = {
            files = {
              ["default"] = fzf.actions.file_edit_or_qf,
              ["ctrl-s"] = fzf.actions.file_split,
              ["ctrl-v"] = fzf.actions.file_vsplit,
              ["ctrl-t"] = fzf.actions.file_tabedit,
              ["ctrl-y"] = { fzf_yank_selection, fzf.actions.resume },
            },
            buffers = {
              ["default"] = fzf.actions.buf_edit_or_qf,
              ["ctrl-s"] = fzf.actions.buf_split,
              ["ctrl-v"] = fzf.actions.buf_vsplit,
              ["ctrl-t"] = fzf.actions.buf_tabedit,
              ["ctrl-y"] = { fzf_yank_selection, fzf.actions.resume },
            }
          },
          fzf_opts = { ["--separator='''"] = "", ["--preview-window"] = "border-none" },
          previewers = { man = { cmd = "man %s | col -bx" } },
          defaults = { preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS", file_icons = false, git_icons = true, color_icons = true, cwd_header = false, copen = function() fzf.quickfix() end },
          files = { cmd = "fd --hidden --color=never --follow --exclude .git --exclude flake.lock" },
          grep = { RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH },
          oldfiles = { include_current_session = true },
          quickfix_stack = { actions = { ["default"] = function() fzf.quickfix() end } },
          git = { status = { actions = { ["right"] = false, ["left"] = false, ["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume } } } }
        })

        require("nightfox").setup({
          options = {
            dim_inactive = true,
            module_default = false,
            modules = { ["mini"] = true, ["signify"] = true }
          },
          palettes = {
            all = {
              fg0 = "#ff00ff", fg1 = "#ffffff", fg2 = "#999999", fg3 = "#666666",
              bg0 = "#0c0c0c", bg1 = "#121212", bg2 = "#222222", bg3 = "#222222", bg4 = "#333333",
              sel0 = "#222222", sel1 = "#555555", comment = "#666666"
            }
          },
          specs = {
            all = {
              diag = { info = "green", error = "red", warn = "#ffaa00" },
              diag_bg = { error = "none", warn = "none", info = "none", hint = "none" },
              diff = { add = "green", removed = "red", changed = "#ffaa00" },
              git = { add = "green", removed = "red", changed = "#ffaa00" }
            }
          },
          groups = {
            all = {
              Visual = { bg = "palette.bg4" },
              Search = { fg = "black", bg = "yellow" },
              IncSearch = { fg = "black", bg = "white" },
              NormalBorder = { bg = "palette.bg1", fg = "palette.fg3" },
              NormalFloat = { bg = "palette.bg2" },
              FloatBorder = { bg = "palette.bg2" },
              MiniCursorword = { bg = "none", fg = "none", style = "underline,bold" },
              MiniCursorwordCurrent = { bg = "none", fg = "none", style = "underline,bold" },
              CursorLineNr = { fg = "palette.fg1" },
              Whitespace = { fg = "palette.sel1" },
              ExtraWhitespace = { bg = "red", fg = "red" },
              Todo = { bg = "none", fg = "palette.blue" },
              WinSeparator = { bg = "palette.bg0", fg = "palette.bg0" },
              PmenuKind = { bg = "palette.sel0", fg = "palette.blue" },
              PmenuKindSel = { bg = "palette.sel1", fg = "palette.blue" },
              PmenuExtra = { bg = "palette.sel0", fg = "palette.fg2" },
              PmenuExtraSel = { bg = "palette.sel1", fg = "palette.fg2" },
              TabLine     = { bg = "palette.bg1", fg = "palette.fg2", gui = "none" },
              TabLineSel  = { bg = "palette.bg2", fg = "palette.fg1", gui = "none" },
              TabLineFill = { bg = "palette.bg0", fg = "palette.fg2", gui = "none" },
              SatelliteBar = { bg = "palette.bg4" },
              SatelliteCursor = { fg = "palette.fg2" },
              SatelliteQuickfix = { fg = "palette.fg0" },
            }
          }
        })

        vim.cmd("colorscheme carbonfox")

        local p = require("nightfox.palette").load("carbonfox")

        require("lualine").setup({
          options = {
            icons_enabled = false,
            section_separators = "",
            component_separators = "",
            theme = {
              normal =   { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              insert =   { a = { bg = p.green.base,   fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              visual =   { a = { bg = p.magenta.dim,  fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              replace =  { a = { bg = p.red.base,     fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              command =  { a = { bg = p.black.bright, fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              terminal = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg4, fg = p.fg2 }, c = { bg = p.bg3, fg = p.fg3 } },
              inactive = { a = { bg = p.bg0,          fg = p.fg1, gui = "bold" }, b = { bg = p.bg0, fg = p.fg2 }, c = { bg = p.bg0, fg = p.fg3 } },
            }
          },
          sections = {
            lualine_a = {{"mode", fmt = function(m) return m:sub(1,1) end}},
            lualine_b = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
            lualine_c = {"diff"},
            lualine_x = {{"diagnostics", sections={"error", "warn"}}},
            lualine_y = {"filetype"},
            lualine_z = {{"searchcount", maxcount=9999}, "progress", "location"},
          },
          inactive_sections = {
            lualine_a = {{"mode", fmt=function() return " " end}},
            lualine_b = {},
            lualine_c = {{"filename", newfile_status=true, path=1, symbols={newfile="?", modified="*", readonly="-"}}},
            lualine_x = {{"diagnostics", sections={"error", "warn"}}},
            lualine_y = {},
            lualine_z = {}
          }
        })

        require("neogit").setup({
          disable_hint = true,
          graph_style = "unicode",
          kind = "split",
          commit_editor = { kind = "split" },
          commit_select_view = { kind = "tab" },
          commit_view = { kind = "split" },
          log_view = { kind = "split" },
          rebase_editor = { kind = "split" },
          reflog_view = { kind = "split" },
          merge_editor = { kind = "split" },
          tag_editor = { kind = "split" },
          preview_buffer = { kind = "split" },
          popup = { kind = "split" },
          integrations = { fzf_lua = true },
          use_default_keymaps = false,
          -- TODO(later): learn neogit
          mappings = {
            commit_editor = {
              ["q"] = "Close",
            },
            commit_editor_I = {
            },
            rebase_editor = {
            },
            rebase_editor_I = {
            },
            finder = {
            },
            popup = {
              ["?"] = "HelpPopup",
            },
            status = {
              ["k"] = "MoveUp",
              ["j"] = "MoveDown",
              ["q"] = "Close",
            },
          },
        })

        require("nvim-surround").setup({ move_cursor = false })

        require("mini.align").setup({})

        require("mini.completion").setup({
          set_vim_settings = false,
          window = { info = { border = { " ", "", "", " " } }, signature = { border = { " ", "", "", " " } } },
          lsp_completion = {
            process_items = function(items, base)
              items = require("mini.completion").default_process_items(items, base)
              local normalise_string = function(str, max)
                str = (str or ""):match("[!-~].*[!-~]") or ""
                return #str > max and vim.fn.strcharpart(str, 0, max-1).."…" or str..(" "):rep(max-#str)
              end
              for _, item in ipairs(items) do
                item.label = normalise_string(item.label, 40)
                item.detail = normalise_string(item.detail, 10)
                item.additionalTextEdits = {}
              end
              return items
            end
          }
        })

        require("mini.cursorword").setup({ delay = 0 })

        require("mini.splitjoin").setup({ mappings = { toggle = "", join = "<leader>j", split = "<leader>J" } })

        require("satellite").setup({
          winblend = 50,
          handlers = {
            cursor = { enable = false, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
            search = { enable = true },
            diagnostic = { enable = true, min_severity = vim.diagnostic.severity.WARN },
            gitsigns = { enable = false },
            marks = { enable = false }
          }
        })

        -- KEYBINDINGS --

        vim.keymap.set("n", "<leader>", "")
        -- Split lines at cursor, opposite of <s-j>
        vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
        -- Terminal shortcuts
        vim.keymap.set("n", "<leader><return>", "<cmd>belowright split | terminal<cr>")
        -- Open notes
        vim.keymap.set("n", "<leader>n", "<cmd>lcd ~/Documents/notes | edit todo.txt<cr>")
        vim.keymap.set("n", "<leader>N", "<cmd>lcd ~/Documents/notes | edit `=strftime('./journal/%Y/%m/%d.md', strptime('%a %W %y', strftime('Mon %W %y')))` | call mkdir(expand('%:h'), 'p')<cr>")
        -- LSP
        vim.keymap.set("n", "<leader><leader>", "<cmd>lua vim.lsp.buf.hover()<cr>")
        vim.keymap.set("n", "<leader>k",        "<cmd>lua vim.lsp.buf.code_action()<cr>")
        vim.keymap.set("n", "]e",               "<cmd>lua vim.diagnostic.goto_next()<cr>")
        vim.keymap.set("n", "[e",               "<cmd>lua vim.diagnostic.goto_prev()<cr>")
        vim.keymap.set("n", "<leader>e",        "<cmd>lua vim.diagnostic.open_float()<cr>")
        vim.keymap.set("n", "<leader>E",        "<cmd>lua vim.diagnostic.setqflist()<cr>")
        vim.keymap.set("n", "<leader>d",        "<cmd>lua vim.lsp.buf.definition()<cr>")
        vim.keymap.set("n", "<leader>t",        "<cmd>lua vim.lsp.buf.type_definition()<cr>")
        vim.keymap.set("n", "<leader>r",        "<cmd>lua vim.lsp.buf.references()<cr>")
        -- Buffers
        vim.keymap.set("n", "[b", "<cmd>bprevious<cr>")
        vim.keymap.set("n", "]b", "<cmd>bnext<cr>")
        vim.keymap.set("n", "[B", "<cmd>bfirst<cr>")
        vim.keymap.set("n", "]B", "<cmd>blast<cr>")
        -- Files
        vim.keymap.set("n", "<leader>-", function() vim.cmd("edit "..fullpath():gsub("/$", ""):gsub("/[^/]*$", "").."/") end)
        vim.keymap.set("n", "[f", function() vim.cmd("edit "..select(1, prev_next_file())) end)
        vim.keymap.set("n", "]f", function() vim.cmd("edit "..select(2, prev_next_file())) end)
        vim.keymap.set("n", "[F", function() local cur, old = fullpath(); while cur ~= old do old = cur; cur, _ = prev_next_file(cur) end vim.cmd("edit "..cur) end)
        vim.keymap.set("n", "]F", function() local cur, old = fullpath(); while cur ~= old do old = cur; _, cur = prev_next_file(cur) end vim.cmd("edit "..cur) end)
        -- Quickfix
        vim.keymap.set("n", "[c", "<cmd>cprevious<cr>")
        vim.keymap.set("n", "]c", "<cmd>cnext<cr>")
        vim.keymap.set("n", "[C", "<cmd>cfirst<cr>")
        vim.keymap.set("n", "]C", "<cmd>clast<cr>")
        -- Toggles
        vim.keymap.set("n", "yo", "")
        vim.keymap.set("n", "yot", "<cmd>set expandtab! expandtab?<cr>")
        vim.keymap.set("n", "yow", "<cmd>set wrap! wrap?<cr>")
        vim.keymap.set("n", "yon", "<cmd>set number! number?<cr>")
        vim.keymap.set("n", "yor", "<cmd>set relativenumber! relativenumber?<cr>")
        vim.keymap.set("n", "yoi", "<cmd>set ignorecase! ignorecase?<cr>")
        vim.keymap.set("n", "yol", "<cmd>set list! list?<cr>")
        vim.keymap.set("n", "yoz", "<cmd>set spell! spell?<cr>")
        vim.keymap.set("n", "yod", "<cmd>if &diff | diffoff | else | diffthis | endif<cr>")
        vim.keymap.set("n", "yos", function() if next(vim.api.nvim_get_autocmds({ group = "satellite" })) then vim.cmd("SatelliteDisable") else vim.cmd("SatelliteEnable") end end)
        -- Signify
        vim.keymap.set("n", "[d", "<plug>(signify-prev-hunk)")
        vim.keymap.set("n", "]d", "<plug>(signify-next-hunk)")
        vim.keymap.set("n", "[D", "9999<plug>(signify-prev-hunk)")
        vim.keymap.set("n", "]D", "9999<plug>(signify-next-hunk)")
        vim.keymap.set("n", "<leader>gd", "<cmd>SignifyHunkDiff<cr>")
        vim.keymap.set("n", "<leader>gD", "<cmd>SignifyDiff!<cr>")
        vim.keymap.set("n", "<leader>gr", "<cmd>SignifyHunkUndo<cr>")
        -- Fzf
        vim.keymap.set("n", "<leader><bs>", "<cmd>FzfLua resume<cr>")
        vim.keymap.set("n", "<leader>f", "<cmd>exe 'FzfLua files hidden=true cwd='.expand('%:p:h')<cr>")
        vim.keymap.set("n", "<leader>F", "<cmd>exe 'FzfLua files hidden=true'<cr>")
        vim.keymap.set("n", "<leader>o", "<cmd>exe 'FzfLua oldfiles cwd='.expand('%:p:h').' cwd_only=true'<cr>")
        vim.keymap.set("n", "<leader>O", "<cmd>exe 'FzfLua oldfiles'<cr>")
        vim.keymap.set("n", "<leader>s", "<cmd>exe 'FzfLua live_grep_native cwd='.expand('%:p:h')<cr>")
        vim.keymap.set("n", "<leader>S", "<cmd>exe 'FzfLua live_grep_native'<cr>")
        vim.keymap.set("n", "<leader>b", "<cmd>exe 'FzfLua buffers cwd='.expand('%:p:h').' cwd_only=true'<cr>")
        vim.keymap.set("n", "<leader>B", "<cmd>exe 'FzfLua buffers'<cr>")
        vim.keymap.set("n", "<leader>t", "<cmd>exe 'FzfLua grep cwd='.expand('%:p:h').' no_esc=true search=\\b(TODO|FIX(ME)?|BUG|TBD|XXX)(\\([^\\)]*\\))?:?'<cr>")
        vim.keymap.set("n", "<leader>T", "<cmd>exe 'FzfLua grep no_esc=true search=\\b(TODO|FIX(ME)?|BUG|TBD|XXX)(\\([^\\)]*\\))?:?'<cr>")
        vim.keymap.set("n", "<leader>l", "<cmd>exe 'FzfLua blines'<cr>")
        vim.keymap.set("n", "<leader>L", "<cmd>exe 'FzfLua lines'<cr>")
        vim.keymap.set("n", "<leader>:", "<cmd>exe 'FzfLua command_history'<cr>")
        vim.keymap.set("n", "<leader>/", "<cmd>exe 'FzfLua search_history'<cr>")
        vim.keymap.set("n", "<leader>m", "<cmd>exe 'FzfLua marks'<cr>")
        vim.keymap.set("n", "<leader>\"", "<cmd>exe 'FzfLua registers'<cr>")
        vim.keymap.set("n", "<leader>gg", "<cmd>lua require('fzf-lua').git_status({ cwd = require('fzf-lua').path.git_root({ cwd = '%:p:h' }, true) })<cr>")
        vim.keymap.set("n", "<leader>gG", "<cmd>exe 'FzfLua git_status'<cr>")
        vim.keymap.set("n", "<leader>gf", "<cmd>exe 'FzfLua git_files cwd='.expand('%:p:h').' only_cwd=true'<cr>")
        vim.keymap.set("n", "<leader>gF", "<cmd>exe 'FzfLua git_files'<cr>")
        vim.keymap.set("n", "<leader>gl", "<cmd>exe 'FzfLua git_bcommits'<cr>")
        vim.keymap.set("n", "<leader>gL", "<cmd>exe 'FzfLua git_commits'<cr>")
        vim.keymap.set("n", "<leader>gb", "<cmd>exe 'FzfLua git_branches'<cr>")
        vim.keymap.set("n", "<leader>gt", "<cmd>exe 'FzfLua git_tags'<cr>")
        vim.keymap.set("n", "<leader>gs", "<cmd>exe 'FzfLua git_stash'<cr>")
        vim.keymap.set("n", "<leader>k", "<cmd>exe 'FzfLua helptags'<cr>")
        vim.keymap.set("n", "<leader>K", "<cmd>exe 'FzfLua manpages sections=ALL'<cr>")
        vim.keymap.set("n", "<leader>E", "<cmd>exe 'FzfLua lsp_workspace_diagnostics'<cr>")
        vim.keymap.set("n", "<leader>d", "<cmd>exe 'FzfLua lsp_definitions'<cr>")
        vim.keymap.set("n", "<leader>D", "<cmd>exe 'FzfLua lsp_type_definitions'<cr>")
        vim.keymap.set("n", "<leader>r", "<cmd>exe 'FzfLua lsp_finder'<cr>")
        vim.keymap.set("n", "<leader>R", "<cmd>exe 'FzfLua lsp_document_symbols'<cr>")
        vim.keymap.set("n", "<leader>c", "<cmd>exe 'FzfLua quickfix'<cr>")
        vim.keymap.set("n", "<leader>C", "<cmd>exe 'FzfLua quickfix_stack'<cr>")
        vim.keymap.set("n", "<leader>a", function() local hits, more = get_altfiles() if #hits==1 then vim.cmd("edit "..hits[1]) else fzf_altfiles(hits, more) end end)
        vim.keymap.set("n", "<leader>A", function() local hits, more = get_altfiles() fzf_altfiles(hits, more) end)
        vim.keymap.set("n", "<leader>u", fzf_undotree)
        vim.keymap.set("n", "<leader>U", "<cmd>exe 'FzfLua changes'<cr>")
        vim.keymap.set("n", "<leader>p", fzf_projects)
        vim.keymap.set("n", "<leader>P", fzf_projects_save)
        vim.keymap.set("n", "z=", "<cmd>exe 'FzfLua spell_suggest'<cr>")
      '')
      (lib.mkIf (work || wbus) ''
        if a then
          vim.opt.expandtab = true
          vim.opt.tabstop = 8
          vim.opt.shiftwidth = 3
          vim.opt.colorcolumn = "86"
          -- Tacc
          vim.cmd([[
            function! TaccIndentOverrides()
              if getline(SkipTaccBlanksAndComments(v:lnum - 1)) =~# 'Tac::Namespace\s*{\s*$' | return 0 | else | return GetTaccIndent() | endif
            endfunction
            augroup vimrc | autocmd BufNewFile,BufRead *.tac setlocal indentexpr=TaccIndentOverrides() | augroup NONE
          ]])
          vim.api.nvim_create_autocmd("FileType", { pattern = "tac", command = "setlocal commentstring=//\\ %s" })
          -- Agrok
          vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                 { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(fullpath():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          -- Agid
          vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
          vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                 { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(fullpath():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.keymap.set("n", "<leader>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<leader>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<leader>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<leader>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
          if not vim.loop.fs_stat("/src/ID") then
            vim.api.nvim_echo({ { "Warn: /src/ID not found! Run :Amkid", "ErrorMsg" } }, false, {})
          end
          -- Gitarband
          function fzf_gitarband()
            fzf.fzf_exec(vim.fn.readfile("/src/.repo/project.list"), {
              prompt = "Package>",
              fzf_opts = { ["--no-multi"] = true },
              actions = { ["default"] = function(sel) fzf.git_status({ cwd = '/src/'..sel[1] }) end }
            })
          end
          vim.keymap.set("n", "<leader>gG", fzf_gitarband)
        end
      '')
    ];
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--follow"
      "--hidden"
      "--smart-case"
      "--max-columns=512"
      "--max-columns-preview"
      "--glob=!{**/node_modules/*,**/.git/*,**/RPMS/*,**/SRPMS/*}"
      "--type-add=tac:*.tac"
      "--type-add=tac:*.tac"
      "--type-add=tin:*.tin"
      "--type-add=itin:*.itin"
    ];
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "12h";
    serverAliveCountMax = 3;
    serverAliveInterval = 5;
    matchBlocks."gpg-agent" = lib.mkIf (!wbus) {
      match = ''host * exec "gpg-connect-agent updatestartuptty /bye"'';
    };
    matchBlocks."bus" = lib.mkIf work {
      host = "bus-* tedj-*";
      user = "tedj";
      forwardAgent = true;
      extraOptions.StrictHostKeyChecking = "false";
      extraOptions.UserKnownHostsFile = "/dev/null";
      extraOptions.RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
    };
    matchBlocks."bus-home" = lib.mkIf work {
      host = "bus-home";
      hostname = "tedj-home";
      port = 22;
    };
  };

  programs.tmux = lib.mkIf wbus {
    enable = true;
    prefix = "M-a";
    baseIndex = 1;
    historyLimit = 100000;
    extraConfig = ''
      set -g escape-time 0
      set -g repeat-time 0
      set -g status off
      set -g status-style "bg=yellow,fg=black"
      set -g status-right "#(cat /tmp/arostest/.arostest-duts | sed \"s/\([',]\|rdam:\/\/\)//g\")"
      set -g status-right-length 128
      set -g status-left "#(tmux-status-left) #{session_name} #{server_sessions}"
      set -g status-left-length 128
      set -g window-status-current-format ""
      set -g window-status-format ""
      set -g set-clipboard on
      set -g set-titles on
      set -g set-titles-string "#S:#W"
      set -ga terminal-overrides ",xterm-256color:Ms=\\E]52;c;%p2%s\\7"
      # i'll take it from here
      unbind -aT prefix
      unbind -aT root
      unbind -aT copy-mode
      unbind -aT copy-mode-vi
      # client
      bind d   detach
      bind r   refresh-client
      bind C-z suspend-client
      # sessions
      bind \$ command-prompt -I "#S" { rename-session "%%" }
      bind s  set status
      bind S  choose-tree -s
      # copy-mode
      bind a   copy-mode
      bind M-a copy-mode
      bind -T copy-mode r      send-keys -X refresh-from-pane
      bind -T copy-mode y      send-keys -X copy-pipe
      bind -T copy-mode q      if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
      bind -T copy-mode i      if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
      bind -T copy-mode Escape if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
      bind -T copy-mode C-c    if-shell -F "#{selection_present}" { send-keys -X clear-selection } { send-keys -X cancel }
      # copy-mode cursor
      bind -T copy-mode k    send-keys -X cursor-up
      bind -T copy-mode C-p  send-keys -X cursor-up
      bind -T copy-mode j    send-keys -X cursor-down
      bind -T copy-mode C-n  send-keys -X cursor-down
      bind -T copy-mode h    send-keys -X cursor-left
      bind -T copy-mode C-b  send-keys -X cursor-left
      bind -T copy-mode l    send-keys -X cursor-right
      bind -T copy-mode C-f  send-keys -X cursor-right
      bind -T copy-mode ^    send-keys -X back-to-indentation
      bind -T copy-mode 0    send-keys -X start-of-line
      bind -T copy-mode C-a  send-keys -X start-of-line
      bind -T copy-mode Home send-keys -X start-of-line
      bind -T copy-mode \$   send-keys -X end-of-line
      bind -T copy-mode C-e  send-keys -X end-of-line
      bind -T copy-mode End  send-keys -X end-of-line
      bind -T copy-mode w    send-keys -X next-word
      bind -T copy-mode b    send-keys -X previous-word
      bind -T copy-mode e    send-keys -X next-word-end
      bind -T copy-mode M-b  send-keys -X previous-word
      bind -T copy-mode M-f  send-keys -X next-word-end
      bind -T copy-mode B    send-keys -X previous-space
      bind -T copy-mode E    send-keys -X next-space-end
      bind -T copy-mode W    send-keys -X next-space
      bind -T copy-mode \{   send-keys -X previous-paragraph
      bind -T copy-mode \}   send-keys -X next-paragraph
      bind -T copy-mode H    send-keys -X top-line
      bind -T copy-mode L    send-keys -X bottom-line
      bind -T copy-mode M    send-keys -X middle-line
      bind -T copy-mode G    send-keys -X history-bottom
      bind -T copy-mode g    send-keys -X history-top
      bind -T copy-mode f    command-prompt -1 -p "(jump forward)"  { send-keys -X jump-forward  "%%" }
      bind -T copy-mode F    command-prompt -1 -p "(jump backward)" { send-keys -X jump-backward "%%" }
      bind -T copy-mode t    command-prompt -1 -p "(jump to forward)"  { send-keys -X jump-to-forward  "%%" }
      bind -T copy-mode T    command-prompt -1 -p "(jump to backward)" { send-keys -X jump-to-backward "%%" }
      bind -T copy-mode \;   send-keys -X jump-again
      bind -T copy-mode ,    send-keys -X jump-reverse
      # copy-mode search
      bind -T copy-mode /  command-prompt -T search -p "(search down)" { send-keys -X search-forward "%%" }
      bind -T copy-mode ?  command-prompt -T search -p "(search up)" { send-keys -X search-backward "%%" }
      bind -T copy-mode :  command-prompt -p "(goto line)" { send-keys -X goto-line "%%" }
      bind -T copy-mode *  send-keys -FX search-forward  "#{copy_cursor_word}"
      bind -T copy-mode \# send-keys -FX search-backward "#{copy_cursor_word}"
      bind -T copy-mode \% send-keys -X next-matching-bracket
      bind -T copy-mode n  send-keys -X search-again
      bind -T copy-mode N  send-keys -X search-reverse
      # copy-mode scroll
      bind -T root      PPage copy-mode \; send-keys -X page-up
      bind -T copy-mode C-b   send-keys -X page-up
      bind -T copy-mode PPage send-keys -X page-up
      bind -T copy-mode C-f   send-keys -X page-down
      bind -T copy-mode NPage send-keys -X page-down
      bind -T copy-mode C-u   send-keys -X halfpage-up
      bind -T copy-mode C-d   send-keys -X halfpage-down
      bind -T copy-mode C-y   send-keys -X scroll-up
      bind -T copy-mode C-e   send-keys -X scroll-down
      bind -T copy-mode z     send-keys -X scroll-middle
      bind -T copy-mode Up    send-keys -X -N 2 scroll-up
      bind -T copy-mode Down  send-keys -X -N 2 scroll-down
      bind -T copy-mode Left  send-keys -X -N 2 scroll-left
      bind -T copy-mode Right send-keys -X -N 2 scroll-right
      # copy-mode selection
      bind -T copy-mode v   send-keys -X begin-selection
      bind -T copy-mode V   send-keys -X select-line
      bind -T copy-mode C-v if-shell -F "#{selection_present}" { send-keys -X rectangle-toggle } { send-keys -X begin-selection; if-shell -F "#{rectangle_toggle}" {} { send-keys -X rectangle-toggle } }
      bind -T copy-mode o   send-keys -X other-end
      # copy-mode repeats
      bind -T copy-mode 1 command-prompt -N -I 1 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 2 command-prompt -N -I 2 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 3 command-prompt -N -I 3 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 4 command-prompt -N -I 4 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 5 command-prompt -N -I 5 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 6 command-prompt -N -I 6 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 7 command-prompt -N -I 7 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 8 command-prompt -N -I 8 -p (repeat) { send-keys -N "%%" }
      bind -T copy-mode 9 command-prompt -N -I 9 -p (repeat) { send-keys -N "%%" }
    '';
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings.manager.ratio =  [0  3  2];
    settings.manager.show_hidden = true;
    settings.manager.scrolloff = 3;
    settings.preview.tab_size = 4;
    theme.manager.border_symbol = " ";
    theme.manager.cwd.fg = "blue";
    theme.manager.hovered.reversed = true;
    theme.manager.preview_hovered.reversed = true;
    theme.status.separator_open = "";
    theme.status.separator_close = "";
    theme.status.separator_style = { bg = "black"; fg = "black"; };
    theme.status.mode_normal = { bg = "darkgrey"; bold = true; };
    theme.status.mode_select = { bg = "blue"; bold = true; };
    theme.status.mode_unset  = { bg = "blue"; bold = true; };
    theme.filetype.rules = [
     { mime = "image/*"; fg = "yellow"; }
     { mime = "{audio;video}/*"; fg = "magenta"; }
     { mime = "application/{;g}zip"; fg = "red"; }
     { mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}"; fg = "red"; }
     { mime = "application/{pdf,doc,rtf,vnd.*}"; fg = "cyan"; }
     { mime = "inode/x-empty"; fg = "darkgrey"; }
     { name = "*"; is = "orphan"; bg = "red"; }
     { name = "*"; is = "exec"  ; fg = "green"; }
     { name = "*"; is = "dummy"; bg = "red"; }
     { name = "*/"; is = "dummy"; bg = "red"; }
     { name = "*"; fg = "white"; }
     { name = "*/"; fg = "blue"; }
    ];
    theme.icon.globs = [];
    theme.icon.dirs  = [];
    theme.icon.files = [];
    theme.icon.exts  = [];
    theme.icon.conds = [];
    keymap.manager.prepend_keymap = [
      { on = "z"; run = "plugin fzf"; } # TODO(later)
      { on = "<C-s>"; run = "shell \"$SHELL\" --block --confirm"; }
    ];
    initLua = ''
      Header:children_add(function()
        return ui.Span(ya.user_name().."@"..ya.host_name().." "):fg("red")
      end, 500, Header.LEFT)
      Status:children_add(function()
        local c = cx.active.current.hovered.cha
        return ui.Span((ya.user_name(c.uid) or tostring(c.uid))..":"..(ya.group_name(c.gid) or tostring(c.gid)).." "):fg("magenta")
      end, 500, Status.RIGHT)
    '';
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    autocd = true;
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit -d '${config.xdg.cacheHome}/zcompdump'";
    history = { path = "${config.xdg.dataHome}/zsh_history"; extended = true; ignoreAllDups = true; share = true; save = 1000000; size = 1000000; };
    localVariables.PROMPT = "\n%F{red}%n@%m%f %F{blue}%~%f %F{red}%(?..%?)%f\n>%f ";
    localVariables.TIMEFMT = "\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P";
    autosuggestion.enable = true;
    autosuggestion.strategy = [ "history" "completion" ];
    localVariables.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 100;
    localVariables.ZSH_AUTOSUGGEST_ACCEPT_WIDGETS = [ "end-of-line" "vi-end-of-line" "vi-add-eol" ];
    localVariables.ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS = [ "forward-char" "vi-forward-char" "forward-word" "emacs-forward-word" "vi-forward-word" "vi-forward-word-end" "vi-forward-blank-word" "vi-forward-blank-word-end" "vi-find-next-char" "vi-find-next-char-skip" ];
    syntaxHighlighting.enable = true;
    syntaxHighlighting.styles.default = "fg=cyan";
    syntaxHighlighting.styles.unknown-token = "fg=red";
    syntaxHighlighting.styles.reserved-word = "fg=blue";
    syntaxHighlighting.styles.path = "fg=cyan,underline";
    syntaxHighlighting.styles.suffix-alias = "fg=blue,underline";
    syntaxHighlighting.styles.precommand = "fg=blue,underline";
    syntaxHighlighting.styles.commandseparator = "fg=magenta";
    syntaxHighlighting.styles.globbing = "fg=magenta";
    syntaxHighlighting.styles.history-expansion = "fg=magenta";
    syntaxHighlighting.styles.single-hyphen-option = "fg=green";
    syntaxHighlighting.styles.double-hyphen-option = "fg=green";
    syntaxHighlighting.styles.rc-quote = "fg=cyan,bold";
    syntaxHighlighting.styles.dollar-double-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.back-double-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.back-dollar-quoted-argument = "fg=cyan,bold";
    syntaxHighlighting.styles.assign = "none";
    syntaxHighlighting.styles.redirection = "fg=yellow,bold";
    syntaxHighlighting.styles.named-fd = "none";
    syntaxHighlighting.styles.arg0 = "fg=blue";
    shellAliases.sudo = "sudo --preserve-env ";
    shellAliases.ls = "eza ";
    shellAliases.ll = "ls -la ";
    shellAliases.lt = "ll -T ";
    shellAliases.v = "nvim ";
    shellAliases.g = "git ";
    shellAliases.p = "python3 ";
    shellAliases.rm = "2>&1 echo rm disabled use del; false ";
    shellAliases.trash = "trash --table never ";
    shellAliases.del = "trash put ";
    shellAliases.undel = "trash restore ";
    shellAliases.lsdel = "trash list ";
    shellAliases.deldel = "trash empty ";
    shellGlobalAliases.cat = "bat --paging=never ";
    initExtraFirst = lib.mkMerge [
      (lib.mkIf work ''
        [[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec sway
      '')
      (lib.mkIf wbus ''
        [ -d /src/EngTeam ] && [[ -o interactive ]] && [[ -o login ]] && cd /src
        export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
      '')
    ];
    initExtra = lib.mkMerge [
      ''
        setopt autopushd pushdsilent promptsubst notify completeinword globcomplete globdots
        # word delimiters
        autoload -U select-word-style
        select-word-style bash
        # home end delete
        bindkey "^[[H"  beginning-of-line
        bindkey "^[[F"  end-of-line
        bindkey "^[[3~" delete-char
        # command line editor
        autoload edit-command-line
        zle -N edit-command-line
        bindkey "^V" edit-command-line
        # beam cursor
        zle -N zle-line-init
        zle-line-init() { echo -ne "\e[6 q" }
        # history search
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        for k in "^[p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
        for k in "^[n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search
        # completion
        autoload -U bashcompinit && bashcompinit
        bindkey "^[[Z" reverse-menu-complete
        zstyle ":completion:*" menu select
        zstyle ":completion:*" completer _complete _match _approximate
        zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "+l:|=* r:|=*"
        zstyle ":completion:*" expand prefix suffix 
        zstyle ":completion:*" use-cache on
        zstyle ":completion:*" cache-path "${config.xdg.cacheHome}/zcompcache"
        zstyle ":completion:*" group-name ""
        zstyle ":completion:*" list-colors "''${(s.:.)LS_COLORS}"
        zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
        zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
        zstyle ":completion:*:warnings" format " %F{red}-- no matches --%f"
      ''
      (lib.mkIf work ''
        compdef 'compadd gp-ie.arista.com gp-ie.arista.com gp-eu.arista.com gp.arista.com' avpn
        compdef 'compadd $(cat /tmp/ashcache 2>/dev/null || ssh bus-home -- a4c ps -N | tee /tmp/ashcache)' ash
      '')
      (lib.mkIf wbus ''
        [[ -o interactive && -o login && -z "$TMUX" ]] && exec tmux new
      '')
    ];
  };

  programs.mpv = lib.mkIf (msung || work) {
    # TODO(later): mpv config
    enable = true;
    bindings = {};
    config = {};
    extraInput = "";
  };

  programs.imv = lib.mkIf (msung || work) {
    enable = true;
    settings = {}; # TODO(later): imv config
  };

  programs.swaylock = lib.mkIf (msung || work) {
    enable = true;
    settings.ignore-empty-password = true;
    settings.image = "eDP-1:${./images/swaylock.png}";
    settings.scaling = "center";
    settings.color = "000000";
    settings.indicator-radius = 25;
    settings.indicator-thickness = 8;
    settings.indicator-y-position = 600;
    settings.key-hl-color = "ffffff";
    settings.bs-hl-color = "000000";
    settings.separator-color = "000000";
    settings.inside-color = "00000000";
    settings.inside-clear-color = "00000000";
    settings.inside-caps-lock-color = "00000000";
    settings.inside-wrong-color = "00000000";
    settings.inside-ver-color = "00000000";
    settings.line-color = "000000";
    settings.line-clear-color = "000000";
    settings.line-caps-lock-color = "000000";
    settings.line-wrong-color = "000000";
    settings.line-ver-color = "000000";
    settings.ring-color = "000000";
    settings.ring-clear-color = "ffffff";
    settings.ring-caps-lock-color = "000000";
    settings.ring-ver-color = "ffffff";
    settings.ring-wrong-color = "000000";
    settings.text-color = "00000000";
    settings.text-clear-color = "00000000";
    settings.text-caps-lock-color = "00000000";
    settings.text-ver-color = "00000000";
    settings.text-wrong-color = "00000000";
  };

  programs.waybar = lib.mkIf (msung || work) {
    enable = true;
    settings =
    let
      rampicons = [ "<span color='#00ff00'>▁</span>" "<span color='#00ff00'>▂</span>" "<span color='#00ff00'>▃</span>" "<span color='#00ff00'>▄</span>" "<span color='#ff8000'>▅</span>" "<span color='#ff8000'>▆</span>" "<span color='#ff8000'>▇</span>" "<span color='#ff0000'>█</span>" ];
    in [
      {
        ipc = true;
        layer = "top";
        position = "top";
        height = 25;
        spacing = 10;
        modules-left = [ "sway/workspaces" "sway/window" ];
        modules-center = [];
        modules-right = [ "custom/media" "custom/caffeinated" "bluetooth" "disk" "custom/swaytask" "cpu" "memory" "network" "pulseaudio" "battery" "clock" ];
        "sway/workspaces" = { tooltip = false; /*all-outputs = true;*/ format = "{name}"; };
        "sway/window" = { tooltip = false; max-length = 200; };
        "custom/media" = {
          exec = pkgs.writeShellScript "waybar-media" ''
            out=""
            max_len=25
            status="$(playerctl status 2>/dev/null)"
            [ "$status" = "Playing" ] || [ "$status" = "Paused" ] && {
              out="$(playerctl metadata title)"
              [ ''${#out} -gt "$max_len" ] && {
                i="$(( ( $(date +%s) % ( ''${#out} + 3 ) ) + 1 ))"
                out="$(echo "$out   $out" | tail -c +$i)"
              }
            }
            out="$(echo "$out" | head -c "$(( $max_len - 1 ))")"
            printf '{"text": %s, "class": %s}\n' \
              "$(echo -n "$out" | jq --raw-input --slurp --ascii-output)" \
              "$(echo -n "$status" | jq --raw-input --slurp --ascii-output)"
          '';
          return-type = "json";
          interval = 1;
        };
        "custom/caffeinated" = { interval = 1; exec = pkgs.writeShellScript "waybar-coffee" ''pidof -q swayidle && echo "" || echo "C"''; };
        "custom/swaytask" = { interval = 1; exec = pkgs.writeShellScript "waybar-swaytask" ''echo "$(cat /tmp/swaytask)"''; };
        bluetooth = { tooltip = false; format = ""; format-connected = "{num_connections}"; };
        # TODO(waybar): per device cpu config?
        cpu = { tooltip = false; interval = 1; format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}{icon12}{icon13}{icon14}{icon15}"; format-icons = rampicons; };
        memory = { tooltip = false; interval = 5; format = "{icon}"; format-icons = rampicons; };
        disk = { tooltip = false; states = { warn = 5; }; format = "{used}/{total}"; };
        network = { tooltip = false; interval = 3; max-length = 10; format-wifi = "{essid}"; format-linked = "linked"; format-ethernet = "wired"; format-disconnected = "offline"; };
        pulseaudio = { tooltip = false; max-volume = 150; states = { high = 75; }; format = "{volume}%"; };
        battery = { tooltip = false; interval = 5; states = { warning = 30; critical = 15; }; format = "{capacity}%"; };
        clock = { tooltip = false; format = "{:%m-%d %H:%M}"; };
      }
    ];
    style = ''
      * { font-family: "Terminess Nerd Font", monospace; font-size: 16px; }
      window#waybar { background-color: rgba(0,0,0,0.75); }

      @keyframes pulse { to { color: #ffffff; } }
      @keyframes flash { to { background-color: #ffffff; } }
      @keyframes luminate { to { background-color: #b0b0b0; } }

      #workspaces button { border: none; border-radius: 0; min-width: 0; padding: 0 5px; animation: none; }
      #workspaces button.focused { background-color: #ffffff; color: #000000; }
      #workspaces button.urgent { background-color: #404040; animation: luminate 1s steps(30) infinite alternate; }

      #workspaces button#sway-workspace-14\:q:not(.focused),
      #workspaces button#sway-workspace-15\:a:not(.focused),
      #workspaces button#sway-workspace-16\:z:not(.focused) { color: #ff8080; }
      #workspaces button#sway-workspace-14\:q.focused,
      #workspaces button#sway-workspace-15\:a.focused,
      #workspaces button#sway-workspace-16\:z.focused { background-color: #ffcccc; }

      #custom-media.Paused { color: #606060; }
      #custom-caffeinated { color: #ff8000; }
      #custom-swaytask { color: #808080; }

      #bluetooth { color: #00ffff; }

      #network.disabled { color: #ff0000; }
      #network.linked, #network.disconnected { color: #ff8000; }
      #network.ethernet, #network.wifi { color: #00ff00; }

      #disk { font-size: 0; }
      #disk.warn { color: #ff8000; }

      #pulseaudio { color: #ff8000; }
      #pulseaudio.high { color: #ffffff; }
      #pulseaudio.muted { color: #ff0000; }

      #battery:not(.charging) { color: #ff8000; }
      #battery.charging, #battery.full { color: #00ff00; }
      #battery.warning:not(.charging) { color: #800000; animation: pulse .5s steps(15) infinite alternate; }
      #battery.critical:not(.charging) { color: #000000; background-color: #800000; animation: flash .25s steps(10) infinite alternate; }
    '';
  };

  wayland.windowManager.sway = lib.mkIf (msung || work) {
    enable = true;
    package = lib.mkIf work (config.lib.nixGL.wrap pkgs.sway);
    extraOptions = lib.mkIf work [ "--unsupported-gpu" ];
    wrapperFeatures = { gtk = true; };
    systemd = { enable = true; variables = [ "--all" ]; };
    extraConfigEarly = ''
      set $send_brightness_notif b=$(($(brightnessctl get)00/$(brightnessctl max))) && notify-send -i brightness-high --category osd --hint "int:value:$b" "Brightness: $b%"
      set $send_volume_notif v=$(pulsemixer --get-volume | cut -d' ' -f1) && notify-send -i audio-volume-high --category osd --hint "int:value:$v" "Volume: $v% $([ $(pulsemixer --get-mute) = 1 ] && echo '[MUTED]')"
    '';

    config.modifier = "Mod4";
    config.workspaceLayout = "default";
    config.focus = { followMouse = true; mouseWarping = "output"; wrapping = "no"; };
    config.floating = { modifier = "Mod4"; border = 1; titlebar = false; };
    config.window = { border = 1; hideEdgeBorders = "none"; titlebar = false; commands = [ { criteria.class = ".*"; command = "border pixel 1"; } { criteria.app_id = ".*"; command = "border pixel 1"; } { criteria.app_id = "floating.*"; command = "floating enable"; } ]; };
    config.gaps = { inner = 5; };
    config.modes = {};
    config.fonts = {};
    config.output = { "*".bg = "#101010 solid_color"; };
    config.bars = [ { command = "waybar"; mode = "hide"; } ];
    config.startup = [
      { command = "pidof -x batteryd || batteryd"; always = true; }
      { command = "pidof -x bmbwd || bmbwd"; always = true; }
      { command = "displayctl auto"; always = true; }
      { command = "powerctl decafeinate"; }
      { command = "echo sway >/tmp/swaytask"; }
    ];

    config.colors.focused         = { border = "#202020"; background = "#ffffff"; text = "#000000"; indicator = "#ff0000"; childBorder = "#ffffff"; };
    config.colors.focusedInactive = { border = "#202020"; background = "#202020"; text = "#ffffff"; indicator = "#202020"; childBorder = "#202020"; };
    config.colors.unfocused       = { border = "#202020"; background = "#202020"; text = "#808080"; indicator = "#202020"; childBorder = "#202020"; };
    config.colors.urgent          = { border = "#2f343a"; background = "#202020"; text = "#ffffff"; indicator = "#900000"; childBorder = "#900000"; };

    config.input."type:keyboard".xkb_layout = "ie";
    config.input."type:keyboard".xkb_options = "caps:escape";
    config.input."type:keyboard".repeat_delay = "250";
    config.input."type:keyboard".repeat_rate = "30";
    config.input."type:touchpad".dwt = "disabled";
    config.input."type:touchpad".tap = "enabled";
    config.input."type:touchpad".natural_scroll = "enabled";
    config.input."type:touchpad".click_method = "clickfinger";
    config.input."type:touchpad".scroll_method = "two_finger";

    config.keybindings."Mod4+Return"     = "exec $TERMINAL";
    config.keybindings."Mod4+space"      = "exec $LAUNCHER";
    config.keybindings."Mod4+s"          = "exec $BROWSER";

    config.keybindings."Mod4+g"       = "focus parent";
    config.keybindings."Mod4+Shift+g" = "focus child";
    config.keybindings."Mod4+f"       = "focus mode_toggle";
    config.keybindings."Mod4+Shift+f" = "border pixel 1, floating toggle";
    config.keybindings."Mod4+p"       = "split vertical";
    config.keybindings."Mod4+Shift+p" = "split none";
    config.keybindings."Mod4+o"       = "layout toggle splitv splith";
    config.keybindings."Mod4+Shift+o" = "layout toggle split tabbed";
    config.keybindings."Mod4+c"       = "sticky toggle";
    config.keybindings."Mod4+m"       = "fullscreen";
    config.keybindings."Mod4+x"       = "kill";

    config.keybindings."Mod4+h"         = "focus left";
    config.keybindings."Mod4+Shift+h"   = "move left 50px";
    config.keybindings."Mod4+Control+h" = "resize shrink width 50px";
    config.keybindings."Mod4+j"         = "focus down";
    config.keybindings."Mod4+Shift+j"   = "move down 50px";
    config.keybindings."Mod4+Control+j" = "resize grow height 50px";
    config.keybindings."Mod4+k"         = "focus up";
    config.keybindings."Mod4+Shift+k"   = "move up 50px";
    config.keybindings."Mod4+Control+k" = "resize shrink height 50px";
    config.keybindings."Mod4+l"         = "focus right";
    config.keybindings."Mod4+Shift+l"   = "move right 50px";
    config.keybindings."Mod4+Control+l" = "resize grow width 50px";

    config.keybindings."Mod4+1" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 1,    move workspace to \"$a\""'';
    config.keybindings."Mod4+2" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 2,    move workspace to \"$a\""'';
    config.keybindings."Mod4+3" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 3,    move workspace to \"$a\""'';
    config.keybindings."Mod4+4" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 4,    move workspace to \"$a\""'';
    config.keybindings."Mod4+5" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 5,    move workspace to \"$a\""'';
    config.keybindings."Mod4+6" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 6,    move workspace to \"$a\""'';
    config.keybindings."Mod4+7" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 7,    move workspace to \"$a\""'';
    config.keybindings."Mod4+8" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 8,    move workspace to \"$a\""'';
    config.keybindings."Mod4+9" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 9,    move workspace to \"$a\""'';
    config.keybindings."Mod4+w" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 10:w, move workspace to \"$a\""'';
    config.keybindings."Mod4+e" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 11:e, move workspace to \"$a\""'';
    config.keybindings."Mod4+r" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 12:r, move workspace to \"$a\""'';
    config.keybindings."Mod4+t" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 13:t, move workspace to \"$a\""'';
    config.keybindings."Mod4+q" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 14:q, move workspace to \"$a\""'';
    config.keybindings."Mod4+a" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 15:a, move workspace to \"$a\""'';
    config.keybindings."Mod4+z" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "workspace 16:z, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+1" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 1,    workspace 1, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+2" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 2,    workspace 2, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+3" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 3,    workspace 3, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+4" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 4,    workspace 4, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+5" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 5,    workspace 5, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+6" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 6,    workspace 6, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+7" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 7,    workspace 7, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+8" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 8,    workspace 8, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+9" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 9,    workspace 9, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+w" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 10:w, workspace 10:w, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+e" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 11:e, workspace 11:e, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+r" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 12:r, workspace 12:r, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+t" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 13:t, workspace 13:t, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+q" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 14:q, workspace 14:q, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+a" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 15:a, workspace 15:a, move workspace to \"$a\""'';
    config.keybindings."Mod4+Shift+z" = ''exec a="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused) | .output')" && swaymsg "move container workspace 16:z, workspace 16:z, move workspace to \"$a\""'';
    config.keybindings."Mod4+Control+1" = ''move container workspace 1'';
    config.keybindings."Mod4+Control+2" = ''move container workspace 2'';
    config.keybindings."Mod4+Control+3" = ''move container workspace 3'';
    config.keybindings."Mod4+Control+4" = ''move container workspace 4'';
    config.keybindings."Mod4+Control+5" = ''move container workspace 5'';
    config.keybindings."Mod4+Control+6" = ''move container workspace 6'';
    config.keybindings."Mod4+Control+7" = ''move container workspace 7'';
    config.keybindings."Mod4+Control+8" = ''move container workspace 8'';
    config.keybindings."Mod4+Control+9" = ''move container workspace 9'';
    config.keybindings."Mod4+Control+w" = ''move container workspace 10:w'';
    config.keybindings."Mod4+Control+e" = ''move container workspace 11:e'';
    config.keybindings."Mod4+Control+r" = ''move container workspace 12:r'';
    config.keybindings."Mod4+Control+t" = ''move container workspace 13:t'';
    config.keybindings."Mod4+Control+q" = ''move container workspace 14:q'';
    config.keybindings."Mod4+Control+a" = ''move container workspace 15:a'';
    config.keybindings."Mod4+Control+z" = ''move container workspace 16:z'';

    config.keybindings."Mod4+Tab"               = ''exec n=$(swaytaskinput) && ow="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.visible) | .output+" "+.name')" && swaytaskset "$n" && swaymsg "$(printf 'focus output %s, workspace %s, ' $(echo $ow))"'';
    config.keybindings."Mod4+Shift+Tab"         = ''exec n=$(swaytaskinput) && ow="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.visible) | .output+" "+.name')" && w="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name')" && swaytaskset "$n" && swaymsg "move container workspace $w, $(printf 'focus output %s, workspace %s, ' $(echo $ow))"'';
    config.keybindings."Mod4+Control+Tab"       = ''exec n=$(swaytaskinput) && w="$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).name')" && swaymsg "move container workspace 0|$n|$(echo $w | tr ':' '|'):#"'';
    config.keybindings."Mod4+Control+Shift+Tab" = ''exec n=$(swaytaskinput) && ! swaymsg -rt get_workspaces | jq -r '.[].name' | grep -qP "^\Q0|$n|\E" && echo $n >/tmp/swaytask'';

    config.keybindings."Mod4+equal"         = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .scale * 1.1')'';
    config.keybindings."Mod4+minus"         = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .scale / 1.1')'';
    config.keybindings."Mod4+Shift+equal"   = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .scale * 1.5')'';
    config.keybindings."Mod4+Shift+minus"   = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale $(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .scale / 1.5')'';
    config.keybindings."Mod4+Control+equal" = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale 2'';
    config.keybindings."Mod4+Control+minus" = ''exec o=$(swaymsg -rt get_outputs | jq -r '.[] | select(.focused) | .name') && swaymsg output "$o" scale 1'';

    config.keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
    config.keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';
    config.keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | tee "$HOME/Pictures/Screenshot_$(date '+%Y%m%d_%H%M%S').png" | wl-copy --type image/png'';

    config.keybindings."--locked XF86MonBrightnessDown"         = "exec brightnessctl set 1%-  && $send_brightness_notif";
    config.keybindings."--locked Shift+XF86MonBrightnessDown"   = "exec brightnessctl set 10%- && $send_brightness_notif";
    config.keybindings."--locked Control+XF86MonBrightnessDown" = "exec brightnessctl set 1    && $send_brightness_notif";
    config.keybindings."--locked XF86MonBrightnessUp"           = "exec brightnessctl set 1%+  && $send_brightness_notif";
    config.keybindings."--locked Shift+XF86MonBrightnessUp"     = "exec brightnessctl set 10%+ && $send_brightness_notif";
    config.keybindings."--locked Control+XF86MonBrightnessUp"   = "exec brightnessctl set 100% && $send_brightness_notif";

    config.keybindings."--locked XF86AudioMute"                                = "exec pulsemixer --toggle-mute       && $send_volume_notif";
    config.keybindings."--locked Shift+XF86AudioMute"                          = "exec                                   $send_volume_notif";
    config.keybindings."--locked Control+XF86AudioMute"                        = "exec pulsemixer --toggle-mute       && $send_volume_notif";
    config.keybindings."--locked XF86AudioLowerVolume"                         = "exec pulsemixer --change-volume  -1 && $send_volume_notif";
    config.keybindings."--locked Shift+XF86AudioLowerVolume"                   = "exec pulsemixer --change-volume -10 && $send_volume_notif";
    config.keybindings."--locked Control+XF86AudioLowerVolume"                 = "exec pulsemixer --set-volume      0 && $send_volume_notif";
    config.keybindings."--locked XF86AudioRaiseVolume"                         = "exec pulsemixer --change-volume  +1 && $send_volume_notif";
    config.keybindings."--locked Shift+XF86AudioRaiseVolume"                   = "exec pulsemixer --change-volume +10 && $send_volume_notif";
    config.keybindings."--locked Control+XF86AudioRaiseVolume"                 = "exec pulsemixer --set-volume    100 && $send_volume_notif";
    config.keybindings."--locked --no-repeat Pause"                            = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --unmute";
    config.keybindings."--locked --no-repeat --release Pause"                  = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --mute";
    config.keybindings."--locked --no-repeat --release --whole-window button8" = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";
    config.keybindings."--locked XF86AudioMicMute"                             = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";

    config.keybindings."Mod4+grave"         = "exec makoctl dismiss";
    config.keybindings."Mod4+Shift+grave"   = "exec makoctl restore";
    config.keybindings."Mod4+Control+grave" = "exec makoctl menu bemenu --prompt 'Action'";

    config.keybindings."Mod4+v" = "exec cliphist list | bemenu --prompt 'Clipboard' | cliphist decode | wl-copy";

    config.keybindings."--locked XF86AudioPlay"         = "exec playerctl play-pause";
    config.keybindings."--locked Shift+XF86AudioPlay"   = "exec playerctl pause";
    config.keybindings."--locked Control+XF86AudioPlay" = "exec playerctl stop";
    config.keybindings."--locked XF86AudioPrev"         = "exec playerctl position 1-";
    config.keybindings."--locked Shift+XF86AudioPrev"   = "exec playerctl position 10-";
    config.keybindings."--locked Control+XF86AudioPrev" = "exec playerctl previous";
    config.keybindings."--locked XF86AudioNext"         = "exec playerctl position 1+";
    config.keybindings."--locked Shift+XF86AudioNext"   = "exec playerctl position 10+";
    config.keybindings."--locked Control+XF86AudioNext" = "exec playerctl next";

    config.keybindings."Mod4+Escape"                        = "exec powerctl";
    config.keybindings."Mod4+Shift+Escape"                  = "exec powerctl lock";
    config.keybindings."--locked Mod4+Control+Escape"       = "exec powerctl suspend";
    config.keybindings."--locked Mod4+Control+Shift+Escape" = "exec powerctl reload";

    config.keybindings."Mod4+n"         = "exec networkctl";
    config.keybindings."Mod4+Shift+n"   = "exec networkctl wifi";
    config.keybindings."Mod4+Control+n" = "exec networkctl bluetooth";

    config.keybindings."Mod4+Apostrophe"               = "exec displayctl";
    config.keybindings."Mod4+Shift+Apostrophe"         = "exec displayctl auto";
    config.keybindings."Mod4+Control+Apostrophe"       = "exec displayctl none";

    config.keybindings."Mod4+b"         = "exec pkill -USR1 bmbwd";
    config.keybindings."Mod4+Shift+b"   = "exec pkill -USR2 bmbwd";
    config.keybindings."Mod4+Control+b" = "exec pkill -TERM bmbwd";
  };

  services.mako = lib.mkIf (msung || work) {
    enable = true;
    width = 450;
    height = 150;
    layer = "overlay";
    maxVisible = 10;
    defaultTimeout = 0;
    backgroundColor = "#303030";
    borderColor = "#ffffff";
    progressColor = "#808080";
    font = "Terminess Nerd Font 12";
    icons = true;
    maxIconSize = 32;
    iconPath = "${config.gtk.iconTheme.package}/share/icons/breeze-dark";
    extraConfig = ''
      max-history=10
      on-button-left=exec makoctl menu bemenu --prompt "Action"
      on-button-right=dismiss
      [actionable]
      format=<b>%s</b> •\n%b
      [urgency=low]
      background-color=#202020
      text-color=#d0d0d0
      border-color=#808080
      [urgency=high]
      default-timeout=0
      background-color=#c00000
      border-color=#ff0000
      [category=osd]
      format=%s\n%b
      group-by=category
      default-timeout=500
      history=0
    '';
  };

  services.playerctld = lib.mkIf (msung || work) {
    enable = true;
  };

  services.cliphist = lib.mkIf (msung || work) {
    enable = true;
  };

  services.syncthing = lib.mkIf (msung || septs || work) {
    enable = true;
    extraOptions = [
      "--data=${config.xdg.dataHome}/syncthing"
      "--config=${config.xdg.configHome}/syncthing"
      "--no-default-folder"
    ];
  };

  nixGL = lib.mkIf work {
    packages = inputs.nixgl.packages;
  };

  gtk = lib.mkIf (msung || work) {
    enable = true;
    theme = { package = pkgs.materia-theme; name = "Materia-dark"; };
    iconTheme = { package = pkgs.kdePackages.breeze-icons; name = "breeze-dark"; };
    # TODO(later) cursorTheme = { package = pkgs.; name = ""; };
  };

  xdg = lib.mkIf (!wbus) {
    enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
    userDirs.publicShare = null;
    userDirs.templates = null;
  };
}

# TODO(later): khal
# accounts.calendar.basePath = "${config.xdg.dataHome}/calendar";
# accounts.calendar.accounts."test".primary = true;
# accounts.calendar.accounts."test".khal.enable = true;
# programs.khal = {
#   enable = true;
#   settings = {
#     default = { default_calendar = "Calendar"; timedelta = "5d"; };
#     view = { agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}"; };
#   };
# };
