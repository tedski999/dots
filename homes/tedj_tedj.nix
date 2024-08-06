# TODO(next): imports = [];
# TODO(work): sshfs for working locally? need to inv. homebus first
# TODO(later): secret management in nix (oh no): gpg, bitwarden, firefox sync, syncthing

{pkgs, lib, config, inputs, ...}: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.keyboard = { layout = "ie"; options = [ "caps:escape" ]; };
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables.PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
  xdg.configFile."python/pythonrc" = {
    text = ''
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
  };

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nix
    # core cli
    coreutils
    diffutils
    man
    curl
    gnused
    procps
    file
    # bonus cli
    eza
    btop
    cht-sh
    openconnect
    acpi
    libnotify
    mosh
    bitwarden-cli
    # gui
    wl-clipboard

    # TODO(pipewire): fix these
    #pipewire
    #wireplumber
    pulsemixer

    swayidle
    brightnessctl
    playerctl
    grim
    slurp
    # fonts
    terminus-nerdfont
    # temporary file share
    (writeShellScriptBin "0x0" ''curl -F"file=@$1" https://0x0.st;'')
    # decompression utility
    (writeShellScriptBin "un" ''
      ft="$(file -b "$1" | tr "[:upper:]" "[:lower:]" || exit 1)"
      mkdir -p "''${2:-.}" || exit 1
      case "$ft" in
        "zip archive"*) unzip -d "''${2:-.}" "$1";;
        "gzip compressed"*) tar -xvzf "$1" -C "''${2:-.}";;
        "bzip2 compressed"*) tar -xvjf "$1" -C "''${2:-.}";;
        "posix tar archive"*) tar -xvf "$1" -C "''${2:-.}";;
        "xz compressed data"*) tar -xvJf "$1" -C "''${2:-.}";;
        "rar archive"*) unrar x "$1" "''${2:-.}";;
        "7-zip archive"*) 7zz x "$1" "-o''${2:-.}";;
        *) echo "Unable to un: $ft"; exit 1;;
      esac
    '')
    # safe rm
    (writeShellScriptBin "del" ''
      IFS=$'\n'
      trash="${config.xdg.dataHome}/trash"
      format="trashed-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]Z[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"

      case "$1" in "-u") shift; mode=u;; "-f") shift; mode=f;; *) mode=n;; esac
      [ -n "$1" ] || exit 1
      
      for file in $@; do
        case $mode in
          u) [ -n "$(find "$trash$(readlink -m -- "$file")" -maxdepth 1 -name "$format" 2>/dev/null)" ] \
            || { echo "'$file' not in trash" >&2; exit 1; };;
          *) [ -e "$file" ] \
            || { echo "'$file' does not exist" >&2; exit 1; };;
        esac
      done
      
      for file in $@; do
        dir="$trash$(readlink -m -- "$file")"
        case $mode in
          u)
            trashed="$(find "$dir" -maxdepth 1 -name "$format" -printf %f\\n)"
            [ "$(echo "$trashed" | wc -l)" -gt 1 ] && {
              echo "Multiple trashed files '$file'"
              echo "$trashed" | awk '{ printf "%d: %s\n", NR, $0 }'
              read -p "Choice: " i
              trashed="$(echo "$trashed" | awk "NR == $i { print; exit }")"
              [ -n "$trashed" ] || exit 1
            }
            mv -i -- "$dir/$trashed" "$file" || exit 1;;
          f) rm -rf "$file" || exit 1;;
          n) mkdir -p "$dir" && mv -i -- "$file" "$dir/$(date --utc +trashed-%FZ%T)" || exit 1;;
        esac
      done
    '')
    # display menu
    # TODO(later): bemenu menu
    (writeShellScriptBin "displayctl" ''
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
    '')
    # power menu
    (writeShellScriptBin "powerctl" ''
      case "$([ -n "$1" ] && echo $1 || printf "lock\nsuspend\n$(pidof -q swayidle && echo caffeinate || echo decafeinate)\nreload\nlogout\nreboot\nshutdown" | bemenu -p "Power" -l 9 -W 0.2)" in
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
          timeout 295 'notify-send -i clock "Idle Warning" "Locking in 5 seconds..."' \
          timeout 300 'loginctl lock-session' \
          timeout 900 'systemctl suspend' &;;
        *) exit 1;;
      esac
    '')
    # network menu
    # TODO(later): networkctl
    (writeShellScriptBin "networkctl" ''
      echo "Hello, world!"
    '')
    # low battery notification
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
    # bemenu with bitwarden cli
    (writeShellScriptBin "bmbwd" ''
      show() {
        [ -z "$BW_SESSION" ] \
          && export BW_SESSION="$(: | bemenu --password indicator --list 0 --width-factor 0.2 --prompt 'Bitwarden Password:' | tr -d '\n' | base64 | bw unlock --raw)" \
          && [ -z "$BW_SESSION" ] \
          && notify-send -i lock -u critical "Bitwarden Failed" "Wrong password?" \
          && return 1

        [ -z "$items" ] \
          && notify-send -i lock "Bitwarden" "Updating items..." \
          && items="$(bw list items)"
        
        # TODO(later): fetch fields of index, bemenu choose field (or all)
        #echo "$items" | jq -r 'range(length) as $i | .[$i] | select(.type==1) | ($i | tostring)+" "+.name+" <"+.login.username+">"' | bemenu --width-factor 0.2 | cut -d' ' -f1
        echo "$items" | jq -r '.[] | select(.type==1) | .name+" <"+.login.username+"> "+.login.password' | bemenu --width-factor 0.4 | rev | cut -d' ' -f1 | rev | wl-copy --trim-newline
      }

      trap "show" USR1
      trap "unset items && show" USR2
      trap "unset items BW_SESSION && show" TERM
      while true; do sleep infinity & wait; done
    '')
    # arista vpn shorcut
    (writeShellScriptBin "avpn" ''sudo ${openconnect}/bin/openconnect --protocol=gp gp-ie.arista.com -u tedj -c $HOME/Documents/keys/tedj@arista.com.crt -k $HOME/Documents/keys/tedj@arista.com.pem'')
  ];

  programs.home-manager = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config = { style = "plain"; wrap = "never"; map-syntax = [ "*.tin:C++" "*.tac:C++" ]; };
  };

  programs.git = {
    enable = true;
    userEmail = "ski@h8c.de";
    userName = "tedski999";
    signing = { signByDefault = true; key = "00ADEF0A!"; };
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
    # TODO(later)
    #[pull] rebase = false
    #[push] default = current
    #[merge] conflictstyle = diff3
    #[diff] colorMoved = default
  };

  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [ ".git/" ];
  };

  # TODO(later): https://github.com/Misterio77/nix-config/blob/main/home/gabriel/features/desktop/common/firefox.nix
  home.sessionVariables.BROWSER = "firefox";
  home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;
  programs.firefox = {
    enable = true;
    profiles.work = {
      id = 0;
      name = "Work";
      isDefault = true;
      search = { default = "DuckDuckGo"; privateDefault = "DuckDuckGo"; force = true; };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin vimium ];
      settings = {
        "accessibility.typeaheadfind.flashBar" = 0;
        "app.shield.optoutstudies.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.contentblocking.category" = "strict";
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.discovery.enabled" = false;
        "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.panel.shown" = true;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.search.isUS" = false;
        "browser.search.region" = "GB";
        "browser.tabs.inTitlebar" = 1;
        "browser.tabs.warnOnClose" = true;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":[],"nav-bar":["back-button","forward-button","stop-reload-button","urlbar-container","downloads-button","unified-extensions-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":20,"newElementCount":4}'';
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.placeholderName.private" = "DuckDuckGo";
        "browser.urlbar.quicksuggest.scenario" = "history";
        "distribution.searchplugins.defaultLocale" = "en-GB";
        "dom.forms.autocomplete.formautofill" = true;
        "dom.private-attribution.submission.enabled" = false;
        "extensions.autoDisableScopes" = 0;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
        "extensions.ui.dictionary.hidden" = false;
        "extensions.ui.locale.hidden" = false;
        "extensions.ui.sitepermission.hidden" = false;
        "extensions.webcompat.enable_shims" = true;
        "extensions.webcompat.perform_injections" = true;
        "extensions.webcompat.perform_ua_overrides" = true;
        "findbar.highlightAll" = true;
        "general.autoScroll" = true;
        "general.useragent.locale" = "en-GB";
        "intl.locale.requested" = "en-GB,en-US";
        "layout.css.prefers-color-scheme.content-override" = 0;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.was_ever_enabled" = true;
        "privacy.purge_trackers.date_in_cookie_database" = 0;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs2" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "widget.gtk.overlay-scrollbars.enabled" = false;
      };
      bookmarks = [
        {
          name = "toolbar";
          toolbar = true;
          bookmarks = [
            {
              name = "bootloader";
              bookmarks = [
                { name = "gmail"; url = "https://mail.google.com/mail/u/0/#inbox"; }
                { name = "chat"; url = "https://mail.google.com/chat/u/0/#chat/home"; }
                { name = "discourse"; url = "https://discourse.arista.com/"; }
                { name = "calender"; url = "https://calendar.google.com/calendar/u/0/r?pli=1"; }
              ];
            }
            {
              name = "services";
              bookmarks = [
                { name = "aboard"; url = "https://aboard.infra.corp.arista.io/user/tedj/overview"; }
                { name = "bugsby"; url = "https://bb.infra.corp.arista.io/board/user/table/tedj"; }
                { name = "reviewboard"; url = "https://reviewboard.infra.corp.arista.io/dashboard/"; }
                { name = "intranet"; url = "https://intranet.arista.com/"; }
                { name = "workday"; url = "https://wd5.myworkday.com/arista/d/home.htmld"; }
                { name = "portal"; url = "https://arista.onelogin.com/portal"; }
              ];
            }
            {
              name = "tools";
              bookmarks = [
                { name = "grok"; url = "https://opengrok.infra.corp.arista.io/source/?project=eos-trunk"; }
                { name = "eosdoc"; url = "https://eosdoc2.infra.corp.arista.io/#/"; }
                { name = "godbolt"; url = "https://code-explorer.infra.corp.arista.io/"; }
                { name = "grep.app"; url = "https://grep.app/"; }
                { name = "explainshell"; url = "https://explainshell.com/"; }
                { name = "shellcheck"; url = "https://www.shellcheck.net/"; }
              ];
            }
            {
              name = "utils";
              bookmarks = [
                { name = "chatbot"; url = "https://said.infra.corp.arista.io/"; }
                { name = "yippy search"; url = "https://yippy.aristanetworks.com/search"; }
                { name = "google search"; url = "https://cloudsearch.google.com/cloudsearch"; }
                { name = "bug search"; url = "https://bugsearch.infra.corp.arista.io/"; }
                { name = "codenames"; url = "https://aboard.infra.corp.arista.io/skus"; }
                { name = "dashboard"; url = "https://dashboard.infra.corp.arista.io/"; }
                { name = "src"; url = "https://src.infra.corp.arista.io/"; }
                { name = "aid"; url = "https://aid.infra.corp.arista.io/1/"; }
                { name = "go"; url = "https://go.infra.corp.arista.io/admin/"; }
                { name = "map"; url = "https://intranet.arista.com/directory/floor-plan-map?location=Dublin2GD"; }
                { name = "tldraw"; url = "https://www.tldraw.com"; }
              ];
            }
            {
              name = "docs";
              bookmarks = [
                { name = "links"; url = "https://docs.google.com/document/d/1EC3rGgvN1T90W-gXwgXl3XaiDUb7pD86QnqXxp1Yk1I/preview"; }
                { name = "how to software"; url = "https://docs.google.com/document/d/1xPFv1zf_Mw1JWXq5ZX5HvCyudTJOyn6XGnuQXOhCGAE/preview"; }
                { name = "sand"; url = "https://docs.google.com/document/d/1yfP0Qc03wk-cp87hEGp9RWQiMy_s6nErBNou3cYDR24/preview"; }
                { name = "areview"; url = "https://docs.google.com/document/d/1-jm1mkHcS5PaFrn0M_FE6484FSGL5xuRguRhRZ2oavM/preview"; }
                { name = "acronyms"; url = "https://docs.google.com/spreadsheets/d/1J_GKEgq9_6HKCRfdU0Wnz8RAwe8SRfYSPNPN-F8P9Rs/preview"; }
                { name = "releases"; url = "https://docs.google.com/spreadsheets/d/1UBmNOcXXV3s73qA_208TMEi5gN0mKsmB5dT70HxOUhw/preview"; }
                { name = "features"; url = "https://docs.google.com/spreadsheets/d/1HU0KOeneu1WqiL5jAiVuQbhBaHLoOMhPAnQc_Cp3VvY/preview#gid=1532911302"; }
                { name = "quality"; url = "https://aid.infra.corp.arista.io/17/"; }
                { name = "eos manual"; url = "https://www.arista.com/assets/data/pdf/user-manual/um-books/EOS-User-Manual.pdf"; }
                { name = "eos sdk wiki"; url = "https://github.com/aristanetworks/EosSdk/wiki"; }
                {
                  name = "tacc";
                  bookmarks = [
                    { name = "index"; url = "https://docs.google.com/document/d/1wIcOuciQ8hoI4SOA55KZpb3lrqpDw8v7nTksfDUCsk8/preview"; }
                    { name = "faq"; url = "https://docs.google.com/document/d/1nToUB4wWoGaRkf33IRiPEut7XQZLDtHq1wtEOgOL79s/preview"; }
                    { name = "book"; url = "https://tacc-book.infra.corp.arista.io/"; }
                    { name = "data models and state apis"; url = "https://docs.google.com/presentation/d/1e-ezvJVAw17oB-GwrzNk-FyFOV_wBlGr1qX3fQ1tWr8/preview"; }
                    { name = "programming with tacc"; url = "https://docs.google.com/presentation/d/1te_vTh4KUkQQmDB52IMepSXmVLyFo40VVlAGKjlFMD8/preview"; }
                  ];
                }
                {
                  name = "tools";
                  bookmarks = [
                    { name = "gitarband"; url = "https://docs.google.com/document/d/1LJwZHF3fION_ybaEj5FWU7fwSKn6o6EkPrH1MalJ_M0/preview"; }
                    { name = "a4c"; url = "https://docs.google.com/document/d/1hcgEPuHaBTDKhndw91dvRBUAOX3asvi0C6rBTIL8mW8/preview"; }
                    { name = "autotest"; url = "https://docs.google.com/document/d/1MnlpmtaE0WmQR17fRjHiN32xi0e9MYYl0odF-muKTNo/preview"; }
                    { name = "autotest"; url = "https://docs.google.com/drawings/d/1AbGCWFQFt835dnPHqE5tOQJYGQGLBM7EiHa5IbLQZXI/preview"; }
                    { name = "tracing"; url = "https://aid.infra.corp.arista.io/86/index.html"; }
                    { name = "dev env"; url = "https://aid.infra.corp.arista.io/9/index.html"; }
                    { name = "artools background"; url = "https://docs.google.com/document/d/1TjQf5D97URdBZu_GfPpIEizMnZfQ5OoNVm7FJvffP84/preview"; }
                    { name = "[dep] build system"; url = "https://docs.google.com/document/d/1jCgbJrvKmJypgGa-VPK_qvyn52_0JOWaGFA-dmz1Kjk/preview"; }
                  ];
                }
              ];
            }
            {
              name = "readinglist";
              bookmarks = [
                { name = "u"; url = "https://sites.google.com/a/aristanetworks.com/learn/arista-u"; }
                { name = "prep"; url = "https://sites.google.com/arista.com/dublinarista-prep/home"; }
                { name = "strata"; url = "https://sites.google.com/aristanetworks.com/strata/home"; }
                { name = "sand"; url = "https://sites.google.com/aristanetworks.com/jericho2/home"; }
                { name = "sand ama"; url = "https://sites.google.com/arista.com/modular-sw/sand-ama/"; }
                { name = "j2 deep dive"; url = "https://drive.google.com/drive/folders/1Z1r3qHi1zihGcFcWVFLMzKQTsN_JwVVH"; }
                { name = "EvolutionOfEthernet.pdf"; url = "https://aid.infra.corp.arista.io/137/EvolutionOfEthernet.pdf"; }
                { name = "An overview of direct memory access"; url = "https://geidav.wordpress.com/2014/04/27/an-overview-of-direct-memory-access/"; }
                { name = "IOMMU introduction"; url = "https://terenceli.github.io/%E6%8A%80%E6%9C%AF/2019/08/04/iommu-introduction"; }
              ];
            }
            {
              name = "onboarding";
              bookmarks = [
                { name = "guide"; url = "https://guide.infra.corp.arista.io/"; }
                { name = "Transitioning from School to Arista - Google Docs"; url = "https://docs.google.com/document/d/1RRERZWg5eOT2QsU4P-CkFWxtkOxW36fLWY81XgLX4EE/preview"; }
                { name = "intern link list"; url = "https://docs.google.com/document/d/1XMzfZYF_ekOfsuUPBZJdZfPn9eQ7V0OrVSvTzSZMqZI/preview"; }
                { name = "AID48 Software Engineering at Arista - Google Docs"; url = "https://docs.google.com/document/d/12-MQ48Ea8SwSrOWpfoldd_KlFXTJtgwMtjFc6B3eidQ/preview"; }
                { name = "creating an agent"; url = "https://docs.google.com/document/d/1k6HmxdQTyhBuLCzNfoj6WDKhcfxxCw9VYt6LxvIymnA/preview"; }
              ];
            }
            { name = "Source Code Navigation at Arista (AID/1270)"; url = "https://aid.infra.corp.arista.io/1270/cached.html"; }
            { name = "Tracking Hours for Irish R&D Tax Credits - Google Docs"; url = "https://docs.google.com/document/d/1-VsNiTTlXNwj69IGbKtAqdNA7Ve84RVfAnv-aJGCQO0/preview"; }
            { name = "guitarband";
              bookmarks = [
                { name = "GitarBand Primer & Tutorial - Google Docs"; url = "https://docs.google.com/document/d/1K0rlhwC7YkPwaV45aarzt-H2v04qqMNV63Rkpdmo5Zw/preview"; }
                { name = "AID5755: Gitarband Workflows - Google Docs"; url = "https://docs.google.com/document/d/1Cceyt3Wf9Xw4wxHNcid5-wsQqdRE6LW7saDkNRG6cVo/preview"; }
              ];
            }
            {
              name = "homebus";
              bookmarks = [
                { name = "Home-Bus Quickstart Guide - Google Docs"; url = "https://docs.google.com/document/d/1eXhPHt-vuu1bBdR9mIGM-90wma5Z5dekPxufiXgTjv0/preview"; }
                { name = "User Homebus+Garage Migration"; url = "https://aid.infra.corp.arista.io/13219/cached.html"; }
              ];
            }
            { name = "jack nixfiles"; url = "https://gitlab.aristanetworks.com/jack/nixfiles/-/tree/arista/home-manager?ref_type=heads"; }
          ];
        }
      ];
    };
    # TODO(later): firefox sync?
    profiles.home = {
      id = 1;
      name = "Home";
      isDefault = false;
      search = { default = "DuckDuckGo"; privateDefault = "DuckDuckGo"; force = true; };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin darkreader vimium ];
      settings = {};
      bookmarks = [];
    };
  };

  programs.jq = {
    enable = true;
  };

  home.sessionVariables.TERMINAL = "alacritty";
  programs.alacritty = {
    enable = true;
    settings = {
      live_config_reload = false;
      scrolling = { history = 10000; multiplier = 5; };
      window = { dynamic_padding = true; opacity = 0.85; dimensions = { columns = 120; lines = 40; }; };
      font = { size = 13.5; normal.family = "Terminess Nerd Font"; };
      selection.save_to_clipboard = true;
      keyboard.bindings = [
          { key = "Return"; mods = "Shift|Control"; action = "SpawnNewInstance"; }
          { key = "Escape"; mods = "Shift|Control"; action = "ToggleViMode"; }
          { key = "Escape"; mode = "Vi"; action = "ToggleViMode"; }
      ];
      colors.draw_bold_text_with_bright_colors = true;
      colors.primary = { background = "#000000"; foreground = "#dddddd"; };
      colors.cursor = { cursor = "#cccccc"; text = "#111111"; };
      colors.normal = { black = "#000000"; blue = "#0d73cc"; cyan = "#0dcdcd"; green = "#19cb00"; magenta = "#cb1ed1"; red = "#cc0403"; white = "#dddddd"; yellow = "#cecb00"; };
      colors.bright = { black = "#767676"; blue = "#1a8fff"; cyan = "#14ffff"; green = "#23fd00"; magenta = "#fd28ff"; red = "#f2201f"; white = "#ffffff"; yellow = "#fffd00"; };
      colors.search.focused_match = { background = "#ffffff"; foreground = "#000000"; };
      colors.search.matches = { background = "#edb443"; foreground = "#091f2e"; };
      colors.footer_bar = { background = "#000000"; foreground = "#ffffff"; };
      colors.line_indicator = { background = "#000000"; foreground = "#ffffff"; };
      colors.selection = { background = "#fffacd"; text = "#000000"; };
    };
  };

  home.sessionVariables.LESS="--incsearch --ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT";
  programs.less = {
    enable = true;
    keys = "h left-scroll\nl right-scroll";
  };

  programs.man = {
    enable = true;
  };

  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.sessionVariables.MANWIDTH = 80;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = pkgs.vimPlugins.nvim-surround;
        config = ''lua require("nvim-surround").setup({ move_cursor = false })'';
      }
      {
        plugin = pkgs.vimPlugins.mini-nvim;
        config = ''
          lua << END
          require("mini.align").setup({})
          local function normalise_string(str, max)
            str = (str or ""):match("[!-~].*[!-~]") or ""
            return #str > max and vim.fn.strcharpart(str, 0, max-1).."…" or str..(" "):rep(max-#str)
          end
          require("mini.completion").setup({
            set_vim_settings = false,
            window = { info = { border = { " ", "", "", " " } }, signature = { border = { " ", "", "", " " } } },
            lsp_completion = {
              process_items = function(items, base)
                items = require("mini.completion").default_process_items(items, base)
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
          require("mini.splitjoin").setup({ mappings = { toggle = "", join = "<space>j", split = "<space>J" } })
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-rsi;
        config = "";
      }
      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        config = ''
          lua << END
          local p = require("nightfox.palette").load("carbonfox")
          require("lualine").setup({
            options = {
              icons_enabled = false,
              section_separators = "",
              component_separators = "",
              refresh = { statusline = 100, tabline = 100, winbar = 100 },
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
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.nightfox-nvim;
        config = ''
          lua << END
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
                CursorWord = { bg = "none", fg = "none", style = "underline,bold" },
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
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-signify;
        config = ''
          lua << END
          vim.g.signify_number_highlight = 1
          vim.keymap.set("n", "[d", "<plug>(signify-prev-hunk)")
          vim.keymap.set("n", "]d", "<plug>(signify-next-hunk)")
          vim.keymap.set("n", "[D", "9999<plug>(signify-prev-hunk)")
          vim.keymap.set("n", "]D", "9999<plug>(signify-next-hunk)")
          vim.keymap.set("n", "<space>gd", "<cmd>SignifyHunkDiff<cr>")
          vim.keymap.set("n", "<space>gD", "<cmd>SignifyDiff!<cr>")
          vim.keymap.set("n", "<space>gr", "<cmd>SignifyHunkUndo<cr>")
          -- if vim.g.arista then
          --   local vcs_cmds = vim.g.signify_vcs_cmds or {}
          --   local vcs_cmds_diffmode = vim.g.signify_vcs_cmds_diffmode or {}
          --   vcs_cmds.perforce = "env P4DIFF= P4COLORS= a p4 diff -du 0 %f"
          --   vcs_cmds_diffmode.perforce = "a p4 print %f"
          --   vim.g.signify_vcs_cmds = vcs_cmds
          --   vim.g.signify_vcs_cmds_diffmode = vcs_cmds_diffmode
          -- end
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.satellite-nvim;
        config = ''
          lua << END
          require("satellite").setup({
            winblend = 0,
            handlers = {
              --cursor = { enable = true, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
              cursor = { enable = false, symbols = { '⎺', '⎻', '—', '⎼', '⎽' } },
              search = { enable = true },
              diagnostic = { enable = true, min_severity = vim.diagnostic.severity.WARN },
              gitsigns = { enable = false },
              marks = { enable = false }
            }
          })
          END
        '';
      }
      {
        plugin = pkgs.vimPlugins.fzf-lua;
        config = ''
        lua << END
        -- Yank selected entries
        local function yank_selection(selected)
          for i = 1, #selected do
            vim.fn.setreg("+", selected[i])
          end
        end
        
        --- File explorer to replace netrw
        local function explore_files(root)
          root = vim.fn.resolve(vim.fn.expand(root)):gsub("/$", "").."/"
          local fzf = require("fzf-lua")
          fzf.fzf_exec("echo .. && fd --base-directory "..root.." --hidden --exclude '**/.git/' --exclude '**/node_modules/'", {
            prompt = root,
            cwd = root,
            fzf_opts = { ["--header"] = "<ctrl-x> to exec|<ctrl-s> to grep|<ctrl-r> to cwd" },
            previewer = "builtin",
            actions = {
              ["default"] = function(s, opts)
                for i = 1, #s do s[i] = vim.fn.resolve(root..s[i]) end
                if #s > 1 then
                  fzf.actions.file_sel_to_qf(s, opts)
                elseif (vim.loop.fs_stat(s[1]) or {}).type == "directory" then
                  explore_files(s[1])
                else
                  vim.cmd("edit "..s[1])
                end
              end,
              ["ctrl-x"] = function(s)
                local k = ": " for i = 1, #s do k = k.." "..root..s[i] end
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(k.."<home>", false, false, true), "n", {})
              end,
              ["ctrl-s"] = function() fzf.grep_project({ cwd=root, cwd_only=true }) end,
              ["ctrl-r"] = { function() vim.fn.chdir(root) end, fzf.actions.resume },
              ["ctrl-v"] = fzf.actions.file_vsplit,
              ["ctrl-t"] = fzf.actions.file_tabedit,
              ["ctrl-y"] = function(s) for i = 1, #s do s[i] = root..s[i] end yank_selection(s) end,
            },
            fn_transform = function(x)
              local dir = x:match(".*/") or ""
              local file = x:sub(#dir+1)
              return fzf.utils.ansi_codes.blue(dir)..fzf.utils.ansi_codes.white(file)
            end,
          })
        end
        
        -- Switch to an alternative file based on extension
        local altfile_map = {
          [".c"] = { ".h", ".hpp", ".tin" },
          [".h"] = { ".c", ".cpp", ".tac" },
          [".cpp"] = { ".hpp", ".h", ".tin" },
          [".hpp"] = { ".cpp", ".c", ".tac" },
          [".vert.glsl"] = { ".frag.glsl" },
          [".frag.glsl"] = { ".vert.glsl" },
          [".tac"] = { ".tin", ".cpp", ".c" },
          [".tin"] = { ".tac", ".hpp", ".h" }
        }
        local function find_altfiles()
          local fzf = require("fzf-lua")
          local dir = vim.g.getfile():match(".*/")
          local file = vim.g.getfile():sub(#dir+1)
          local possible, existing = {}, {}
          for ext, altexts in pairs(altfile_map) do
            if file:sub(-#ext) == ext then
              for _, altext in ipairs(altexts) do
                local altfile = file:sub(1, -#ext-1)..altext
                table.insert(possible, altfile)
                if vim.loop.fs_stat(dir..altfile) then
                  table.insert(existing, altfile)
                end
              end
            end
          end
          if #existing == 1 then
            vim.cmd("edit "..dir..existing[1])
          elseif #existing ~= 0 then
            fzf.fzf_exec(existing, { actions = fzf.config.globals.actions.files, cwd = dir, previewer = "builtin" })
          elseif #possible ~= 0 then
            fzf.fzf_exec(possible, { actions = fzf.config.globals.actions.files, cwd = dir, fzf_opts = { ["--header"] = "No altfiles found" } })
          else
            vim.api.nvim_echo({ { "Error: No altfiles configured", "Error" } }, false, {})
          end
        end
        
        -- Save and load projects using mksession
        local projects_dir = vim.fn.stdpath("data").."/projects/"
        local function find_projects()
          local fzf = require("fzf-lua")
          local projects = {}
          for path in vim.fn.glob(projects_dir.."*"):gmatch("[^\n]+") do
            table.insert(projects, path:match("[^/]*$"))
          end
          fzf.fzf_exec(projects, {
            prompt = "Project>",
            fzf_opts = { ["--no-multi"] = "", ["--header"] = "<ctrl-x> to delete|<ctrl-e> to edit" },
            actions = {
              ["default"] = function(s) vim.cmd("source "..vim.fn.fnameescape(projects_dir..s[1])) end,
              ["ctrl-e"] = function(s) vim.cmd("edit "..projects_dir..s[1].." | setf vim") end,
              ["ctrl-x"] = function(s) for i = 1, #s do vim.fn.delete(vim.fn.fnameescape(projects_dir..s[i])) end end
            }
          })
        end
        local function save_project()
          local project = vim.fn.input("Save project: ", vim.v.this_session:match("[^/]*$") or "")
          if project == "" then return end
          vim.fn.mkdir(projects_dir, "p")
          vim.cmd("mksession! "..vim.fn.fnameescape(projects_dir..project))
        end
        
        -- Visualise and select from the branched undotree
        local function view_undotree()
          local fzf = require("fzf-lua")
          local undotree = vim.fn.undotree()
          local function build_entries(tree, depth)
            local entries = {}
            for i = #tree, 1, -1  do
              local cs = { "magenta", "blue", "yellow", "green", "red" }
              local c = fzf.utils.ansi_codes[cs[math.fmod(depth, #cs) + 1]]
              local e = tree[i].seq..""
              if tree[i].save then e = e.."*" end
              local t = os.time() - tree[i].time
              if t > 86400 then t = math.floor(t/86400).."d" elseif t > 3600 then t = math.floor(t/3600).."h" elseif t > 60 then t = math.floor(t/60).."m" else t = t.."s" end
              if tree[i].seq == undotree.seq_cur then t = fzf.utils.ansi_codes.white(t.." <") else t = fzf.utils.ansi_codes.grey(t) end
              table.insert(entries, c(e).." "..t)
              if tree[i].alt then
                local subentries = build_entries(tree[i].alt, depth + 1)
                for j = 1, #subentries do table.insert(entries, " "..subentries[j]) end
              end
            end
            return entries
          end
          local curbuf = vim.api.nvim_get_current_buf()
          local curfile = vim.g.getfile()
          fzf.fzf_exec(build_entries(undotree.entries, 0), {
            prompt = "Undotree>",
            fzf_opts = { ["--no-multi"] = "" },
            actions = { ["default"] = function(s) vim.cmd("undo "..s[1]:match("%d+")) end },
            previewer = false,
            preview = fzf.shell.raw_preview_action_cmd(function(s)
              if #s == 0 then return end
              local newbuf = vim.api.nvim_get_current_buf()
              local tmpfile = vim.fn.tempname()
              local change = s[1]:match("%d+")
              vim.api.nvim_set_current_buf(curbuf)
              vim.cmd("undo "..change)
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              vim.cmd("undo "..undotree.seq_cur)
              vim.fn.writefile(lines, tmpfile)
              vim.api.nvim_set_current_buf(newbuf)
              return "delta --file-modified-label ''' --hunk-header-style ''' --file-transformation 's/tmp.*//' "..curfile.." "..tmpfile
            end)
          })
        end

        vim.keymap.set("n", "z=", "<cmd>FzfLua spell_suggest<cr>")
        vim.keymap.set("n", "<space>b", "<cmd>FzfLua buffers cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>B", "<cmd>FzfLua buffers<cr>")
        vim.keymap.set("n", "<space>t", "<cmd>FzfLua tabs<cr>")
        vim.keymap.set("n", "<space>T", "<cmd>FzfLua tags<cr>")
        vim.keymap.set("n", "<space>l", "<cmd>FzfLua blines<cr>")
        vim.keymap.set("n", "<space>L", "<cmd>FzfLua lines<cr>")
        vim.keymap.set("n", "<space>f", function() explore_files(vim.g.getfile():match(".*/")) end)
        vim.keymap.set("n", "<space>F", function() explore_files(vim.fn.getcwd()) end)
        vim.keymap.set("n", "<space>o", "<cmd>FzfLua oldfiles cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>O", "<cmd>FzfLua oldfiles<cr>")
        vim.keymap.set("n", "<space>s", "<cmd>FzfLua grep_project cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>S", "<cmd>FzfLua grep_project<cr>")
        vim.keymap.set("n", "<space>m", "<cmd>FzfLua marks cwd=%:p:h cwd_only=true<cr>")
        vim.keymap.set("n", "<space>M", "<cmd>FzfLua marks<cr>")
        vim.keymap.set("n", "<space>gg", "<cmd>lua require('fzf-lua').git_status({ cwd='%:p:h', file_ignore_patterns={ '^../' } })<cr>")
        vim.keymap.set("n", "<space>gG", "<cmd>FzfLua git_status<cr>")
        vim.keymap.set("n", "<space>gf", "<cmd>FzfLua git_files cwd_only=true cwd=%:p:h<cr>")
        vim.keymap.set("n", "<space>gF", "<cmd>FzfLua git_files<cr>")
        vim.keymap.set("n", "<space>gl", "<cmd>FzfLua git_bcommits<cr>")
        vim.keymap.set("n", "<space>gL", "<cmd>FzfLua git_commits<cr>")
        vim.keymap.set("n", "<space>gb", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color HEAD..$b; git diff HEAD $b | delta' })<cr>")
        vim.keymap.set("n", "<space>gB", "<cmd>lua require('fzf-lua').git_branches({ preview='b={1}; git log --graph --pretty=oneline --abbrev-commit --color origin/HEAD..$b; git diff origin/HEAD $b | delta' })<cr>")
        vim.keymap.set("n", "<space>gs", "<cmd>FzfLua git_stash<cr>") 
        -- TODO(later): help_tags doesnt work (command works), man_pages doesnt work (command complains about nil value)
        vim.keymap.set("n", "<space>k", "<cmd>FzfLua help_tags<cr>")
	vim.keymap.set("n", "<space>K", "<cmd>FzfLua man_pages<cr>")
        vim.keymap.set("n", "<space>E", "<cmd>FzfLua diagnostics_document<cr>")
        vim.keymap.set("n", "<space>d", "<cmd>FzfLua lsp_definitions<cr>")
        vim.keymap.set("n", "<space>D", "<cmd>FzfLua lsp_typedefs<cr>")
        vim.keymap.set("n", "<space>r", "<cmd>FzfLua lsp_finder<cr>")
        vim.keymap.set("n", "<space>R", "<cmd>FzfLua lsp_document_symbols<cr>")
        vim.keymap.set("n", "<space>A", "<cmd>FzfLua lsp_code_actions<cr>")
        vim.keymap.set("n", "<space>c", "<cmd>FzfLua quickfix<cr>")
        vim.keymap.set("n", "<space>C", "<cmd>FzfLua quickfix_stack<cr>")
        vim.keymap.set("n", "<space>a", find_altfiles)
        vim.keymap.set("n", "<space>p", find_projects)
        vim.keymap.set("n", "<space>P", save_project)
        vim.keymap.set("n", "<space>u", view_undotree)
        
        local fzf = require("fzf-lua")
        fzf.setup({
          winopts = {
            fullscreen = false,
            height = 0.33, width = 1.0, row = 1.0, col = 0.5,
            border = { "─", "─", "─", " ", "", "", "", " " },
            hl = { normal = "Normal", border = "NormalBorder", preview_border = "NormalBorder" },
            preview = { flip_columns = 100, scrollchars = { "│", "" }, winopts = { list = true } }
          },
          keymap = {
            builtin = {
              ["<c-_>"] = "toggle-preview",
              ["<c-o>"] = "toggle-fullscreen",
              ["<m-n>"] = "preview-page-down",
              ["<m-p>"] = "preview-page-up",
            },
            fzf = {
              ["ctrl-d"] = "half-page-down",
              ["ctrl-u"] = "half-page-up",
              ["alt-n"] = "preview-page-down",
              ["alt-p"] = "preview-page-up",
            },
          },
          actions = {
            files = {
              ["default"] = fzf.actions.file_edit_or_qf,
              ["ctrl-s"] = fzf.actions.file_split,
              ["ctrl-v"] = fzf.actions.file_vsplit,
              ["ctrl-t"] = fzf.actions.file_tabedit,
              ["ctrl-y"] = yank_selection
            },
            buffers = {
              ["default"] = fzf.actions.buf_edit_or_qf,
              ["ctrl-s"] = fzf.actions.buf_split,
              ["ctrl-v"] = fzf.actions.buf_vsplit,
              ["ctrl-t"] = fzf.actions.buf_tabedit,
              ["ctrl-y"] = yank_selection
            }
          },
          fzf_opts = { ["--separator='''"] = "", ["--preview-window"] = "border-none" },
          previewers = { man = { cmd = "man %s | col -bx" } },
          defaults = { preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS", file_icons = false, git_icons = true, color_icons = true, cwd_header = false, copen = function() fzf.quickfix() end },
          oldfiles = { include_current_session = true },
          quickfix_stack = { actions = { ["default"] = function() fzf.quickfix() end } },
          git = { status = { actions = { ["right"] = false, ["left"] = false, ["ctrl-s"] = { fzf.actions.git_stage_unstage, fzf.actions.resume } } } }
        })
        if vim.g.arista then
          -- Perforce
          vim.api.nvim_create_user_command("Achanged", function() fzf.fzf_exec([[a p4 diff --summary | sed s/^/\\//]],                                              { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
          vim.api.nvim_create_user_command("Aopened",  function() fzf.fzf_exec([[a p4 opened | sed -n "s/\/\(\/[^\/]\+\/[^\/]\+\/\)[^\/]\+\/\([^#]\+\).*/\1\2/p"]], { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, {})
          vim.keymap.set("n", "<space>gs", "<cmd>Achanged<cr>")
          vim.keymap.set("n", "<space>go", "<cmd>Aopened<cr>")
          -- Opengrok
          vim.api.nvim_create_user_command("Agrok",  function(p) fzf.fzf_exec("a grok -em 99 "..p.args.." | grep '^/src/.*'",                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agrokp", function(p) fzf.fzf_exec("a grok -em 99 -f "..(vim.g.getfile():match("^/src/.-/") or "/").." "..p.args.." | grep '^/src/.*'", { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          -- Agid
          vim.api.nvim_create_user_command("Amkid", "belowright split | terminal echo 'Generating ID file...' && a ws mkid", {})
          vim.api.nvim_create_user_command("Agid",  function(p) fzf.fzf_exec("a ws gid -cq "..p.args,                                                      { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.api.nvim_create_user_command("Agidp", function(p) fzf.fzf_exec("a ws gid -cqp "..(vim.g.getfile():match("^/src/(.-)/") or "/").." "..p.args, { actions = fzf.config.globals.actions.files, previewer = "builtin" }) end, { nargs = 1 })
          vim.keymap.set("n", "<space>r", "<cmd>exec 'Agidp    '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>R", "<cmd>exec 'Agid     '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>d", "<cmd>exec 'Agidp -D '.expand('<cword>')<cr>", { silent = true })
          vim.keymap.set("n", "<space>D", "<cmd>exec 'Agid  -D '.expand('<cword>')<cr>", { silent = true })
        end
        END
      '';
      }
      # TODO(later): neogit/vim-fugitive
    ];
    extraLuaConfig = ''
      
      -- Get full path of path or current buffer
      vim.g.getfile = function(path)
        return vim.fn.fnamemodify(path or vim.api.nvim_buf_get_name(0), ":p")
      end

      -- Consistent aesthetics
      vim.lsp.protocol.CompletionItemKind = {
        '""', ".f", "fn", "()", ".x",
        "xy", "{}", "{}", "[]", ".p",
        "$$", "00", "∀e", ";;", "~~",
        "rg", "/.", "&x", "//", "∃e",
        "#x", "{}", "ev", "++", "<>"
      }
      
      -- Provide method to apply ftplugin and syntax settings to all filetypes
      -- TODO(later): still used? maybe for snippets and arista .tac syntax
      -- vim.g.myfiletypefile = vim.fn.stdpath("config").."/ftplugin/ftplugin.vim"
      -- vim.g.mysyntaxfile = vim.fn.stdpath("config").."/syntax/syntax.vim"
      
      vim.opt.title = true                                   -- Update window title
      vim.opt.mouse = "a"                                    -- Enable mouse support
      vim.opt.updatetime = 100                               -- Faster refreshing
      vim.opt.timeoutlen = 5000                              -- 5 seconds to complete mapping
      vim.opt.clipboard = "unnamedplus"                      -- Use system clipboard
      vim.opt.undofile = true                                -- Write undo history to disk
      vim.opt.swapfile = false                               -- No need for swap files
      vim.opt.modeline = false                               -- Don't read mode line
      vim.opt.virtualedit = "onemore"                        -- Allow cursor to extend one character past the end of the line
      vim.opt.grepprg = "rg --vimgrep --smart-case --follow" -- Use ripgrep for grepping
      vim.opt.number = true                                  -- Enable line numbers...
      vim.opt.relativenumber = false                         -- ...and not relative line numbers
      vim.opt.ruler = false                                  -- No need to show line/column number with lightline
      vim.opt.showmode = false                               -- No need to show current mode with lightline
      vim.opt.scrolloff = 3                                  -- Keep lines above/below the cursor when scrolling
      vim.opt.sidescrolloff = 5                              -- Keep columns to the left/right of the cursor when scrolling
      vim.opt.signcolumn = "no"                              -- Keep the sign column closed
      vim.opt.shortmess:append("sSIcC")                      -- Be quieter
      vim.opt.expandtab = false                              -- Tab key inserts tabs
      vim.opt.tabstop = 4                                    -- 4-spaced tabs
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

      -- Is this an Arista environment?
      vim.g.arista = vim.loop.fs_stat("/usr/share/vim/vimfiles/arista.vim") and vim.fn.getcwd():find("^/src") ~= nil
      if vim.g.arista then
        vim.api.nvim_echo({ { "Note: Arista-specifics have been enabled for this Neovim instance", "MoreMsg" } }, false, {})

        -- Always rooted at /src
        vim.fn.chdir("/src")

        -- Source arista.vim but override A4edit and A4revert
        vim.cmd([[
          let g:a4_auto_edit = 0
          source /usr/share/vim/vimfiles/arista.vim
          function! A4edit()
            if strlen(glob(expand('%')))
              belowright split
              exec 'terminal a p4 login && a p4 edit '.shellescape(expand('%:p'))
            endif
          endfunction
          function! A4revert()
            if strlen(glob(expand('%'))) && confirm('Revert Perforce file changes?', '&Yes\n&No', 1) == 1
              exec 'terminal a p4 login && a p4 revert '.shellescape(expand('%:p'))
              set readonly
            endif
          endfunction
        ]])
        vim.api.nvim_create_user_command("Aedit", "call A4edit()", {})
        vim.api.nvim_create_user_command("Arevert", "call A4revert()", {})
      end
      
      -- Return the alphabetically previous and next files
      local function prev_next_file(file)
        file = (file or vim.g.getfile()):gsub("/$", "")
        local prev, dir = file, file:match(".*/") or "/"
        local files = (vim.fn.glob(dir..".[^.]*").."\n"..vim.fn.glob(dir.."*")):gmatch("[^\n]+")
        for next in files do
          if next == file then return prev, files() or next
          elseif next > file then return prev, next
          else prev = next end
        end
        return prev, file
      end
      
      vim.g.mapleader = " "
      vim.keymap.set("n", "<space>", "")
      -- Split lines at cursor, opposite of <s-j>
      vim.keymap.set("n", "<c-j>", "m`i<cr><esc>``")
      -- Terminal shortcuts
      vim.keymap.set("n", "<space><return>", "<cmd>belowright split | terminal<cr>")
      vim.keymap.set("t", "<esc>", "(&filetype == 'fzf') ? '<esc>' : '<c-\\><c-n>'", { expr = true })
      -- Open notes
      vim.keymap.set("n", "<space>n", "<cmd>lcd ~/Documents/notes | enew | set filetype=markdown<cr>")
      vim.keymap.set("n", "<space>N", "<cmd>lcd ~/Documents/notes | edit `=strftime('./journal/%Y/%m/%d.md')` | call mkdir(expand('%:h'), 'p')<cr>")
      -- LSP
      vim.keymap.set("n", "<space><space>", "<cmd>lua vim.lsp.buf.hover()<cr>")
      vim.keymap.set("n", "<space>k",        "<cmd>lua vim.lsp.buf.code_action()<cr>")
      vim.keymap.set("n", "]e",               "<cmd>lua vim.diagnostic.goto_next()<cr>")
      vim.keymap.set("n", "[e",               "<cmd>lua vim.diagnostic.goto_prev()<cr>")
      vim.keymap.set("n", "<space>e",        "<cmd>lua vim.diagnostic.open_float()<cr>")
      vim.keymap.set("n", "<space>E",        "<cmd>lua vim.diagnostic.setqflist()<cr>")
      vim.keymap.set("n", "<space>d",        "<cmd>lua vim.lsp.buf.definition()<cr>")
      vim.keymap.set("n", "<space>t",        "<cmd>lua vim.lsp.buf.type_definition()<cr>")
      vim.keymap.set("n", "<space>r",        "<cmd>lua vim.lsp.buf.references()<cr>")
      -- Buffers
      vim.keymap.set("n", "[b", "<cmd>bprevious<cr>")
      vim.keymap.set("n", "]b", "<cmd>bnext<cr>")
      vim.keymap.set("n", "[B", "<cmd>bfirst<cr>")
      vim.keymap.set("n", "]B", "<cmd>blast<cr>")
      -- Files
      vim.keymap.set("n", "[f", function() vim.cmd("edit "..select(1, prev_next_file())) end)
      vim.keymap.set("n", "]f", function() vim.cmd("edit "..select(2, prev_next_file())) end)
      vim.keymap.set("n", "[F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; cur, _ = prev_next_file(cur) end vim.cmd("edit "..cur) end)
      vim.keymap.set("n", "]F", function() local cur, old = vim.g.getfile(); while cur ~= old do old = cur; _, cur = prev_next_file(cur) end vim.cmd("edit "..cur) end)
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
    '';
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--follow"
      "--hidden"
      "--smart-case"
      "--max-columns=512"
      "--max-columns-preview"
      "--glob=!{**/node_modules/*,**/.git/*}"
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
  };

  programs.gpg = {
    enable = true;
    settings = {
      keyid-format = "LONG";
      with-fingerprint = true;
      with-subkey-fingerprint = true;
      with-keygrip = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 2592000;
    maxCacheTtlSsh = 2592000;
    pinentryPackage = pkgs.pinentry-curses;
    sshKeys = [ "613AB861624F38ECCEBBB3764CF4A761DBE24D1B" ];
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';
    defaultKeymap = "emacs";
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit -d '${config.xdg.cacheHome}/zcompdump'";
    history = { path = "${config.xdg.dataHome}/zsh_history"; extended = true; ignoreAllDups = true; share = true; save = 1000000; size = 1000000; };
    localVariables.PROMPT = "\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f ";
    localVariables.TIMEFMT = "\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P";
    shellAliases.z = "exec zsh ";
    shellAliases.v = "nvim ";
    shellAliases.p = "python3 ";
    shellAliases.c = "cargo ";
    shellAliases.g = "git ";
    shellAliases.rm = "2>&1 echo rm disabled, use del; return 1 && ";
    shellAliases.ls = "eza -hs=name --group-directories-first ";
    shellAliases.ll = "ls -la ";
    shellAliases.lt = "ll -T ";
    shellAliases.ip = "ip --color ";
    shellAliases.sudo = "sudo --preserve-env ";
    shellGlobalAliases.cat = "bat --paging=never ";
    shellGlobalAliases.grep = "rg ";
    autosuggestion = { enable = true; strategy = [ "history" "completion" ]; };
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
    initExtra = ''
      setopt autopushd pushdsilent
      setopt promptsubst notify
      setopt completeinword globcomplete globdots

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

      # gpg+ssh
      # TODO(work): this should probably be done in gpg-agent config
      # export SSH_AGENT_PID=""
      # export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      # (gpgconf --launch gpg-agent &)

      cht() { cht.sh "$@?style=paraiso-dark"; }
      _cht() { compadd $commands:t; }; compdef _cht cht

      #ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ''${@:+-c -- a4c shell $@}; }
      #_ash() { compadd "$(ssh us260 -- a4c ps -N)"; }; compdef _ash ash
    '';
  };

  programs.bemenu = {
    enable = true;
    settings = {
      single-instance = true;
      list = 32;
      center = true;
      fixed-height = true;
      width-factor = 0.8;
      grab = true;
      border = 1;
      bdr = "#ffffff";
      tb = "#000000";
      tf = "#ffffff";
      fb = "#000000";
      ff = "#ffffff";
      cb = "#ffffff";
      cf = "#ffffff";
      nb = "#000000";
      nf = "#ffffff";
      hb = "#ffffff";
      hf = "#000000";
      fbb = "#ff0000";
      fbf = "#00ff00";
      sb = "#ff0000";
      sf = "#ffffff";
      ab = "#000000";
      af = "#ffffff";
      fn = "Terminess Nerd Font";
    };
  };

  programs.fzf = {
    enable = true;
    colors = { "fg" = "bold"; "pointer" = "red"; "hl" = "red"; "hl+" = "red"; "gutter" = "-1"; "marker" = "red"; };
    defaultCommand = "rg --files --no-messages";
    defaultOptions = [ "--multi" "--bind='ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview'" "--preview-window sharp" "--marker=k" "--color=fg+:bold,pointer:red,hl:red,hl+:red,gutter:-1,marker:red" "--history ${config.xdg.dataHome}/fzf_history" ];
    changeDirWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules' --type d";
    fileWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules'";
  };

  services.mako = {
    enable = true;
    width = 450;
    height = 150;
    layer = "overlay";
    maxVisible = 10;
    defaultTimeout = 10000;
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

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = let 
      ramp = [
        "<span color='#00ff00'>▁</span>"
        "<span color='#00ff00'>▂</span>"
        "<span color='#00ff00'>▃</span>"
        "<span color='#00ff00'>▄</span>"
        "<span color='#ff8000'>▅</span>"
        "<span color='#ff8000'>▆</span>"
        "<span color='#ff8000'>▇</span>"
        "<span color='#ff0000'>█</span>"
      ];
    in [
      {
        output = "eDP-1";
        ipc = true;
        layer = "top";
        position = "top";
        height = 30;
        spacing = 0;
        modules-left = [ "sway/workspaces" "sway/scratchpad" "sway/window" ];
        modules-center = [];
        modules-right = [ "custom/media" "custom/caffeinated" "gamemode" "bluetooth" "cpu" "memory" "temperature" "disk" "network" "pulseaudio" "battery" "clock" ];
        "sway/workspaces".format = "{index}";
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
          format-icons = ramp;
          on-click = "alacritty --class floating --command btop";
        };
        memory = {
          interval = 5;
          format = "{icon}";
          format-icons = ramp;
          tooltip-format = "RAM: {used:0.1f}Gib ({percentage}%)\nSWP: {swapUsed:0.1f}Gib ({swapPercentage}%)";
          on-click = "alacritty --class floating --command btop";
        };
        temperature = {
          tooltip-format = "{temperatureC}°C / {temperatureF}°F\nThermal zone 6";
          thermal-zone = 6;
          critical-threshold = 80;
          interval = 5;
          on-click = "alacritty --class floating --command btop";
        };
        disk = {
          format = "{free}";
          on-click = "alacritty --class floating --command btop";
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
        #wireplumber = {
        #  max-volume = 150;
        #  states.high = 75;
        #  on-click = "alacritty --class floating --command pulsemixer";
        #  on-click-right = "pulsemixer --toggle-mute";
        #};
        pulseaudio = {
          max-volume = 150;
          states.high = 75;
          on-click = "alacritty --class floating --command pulsemixer";
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
          format = "{:%H:%M}";
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
        modules-left = [ "sway/workspaces" "sway/scratchpad" "sway/window" ];
        modules-center = [];
        modules-right = [];
        "sway/workspaces".format = "{index}";
        "sway/window".max-length = 200;
      }
    ];
    style = ''
      * { font-family: "Terminess Nerd Font", monospace; font-size: 16px; margin: 0; }
      window#waybar { background-color: rgba(0,0,0,0.75); }

      @keyframes pulse { to { color: #ffffff; } }
      @keyframes flash { to { background-color: #ffffff; } }
      @keyframes luminate { to { background-color: #b0b0b0; } }

      /*#workspaces, #scratchpad, #window, #custom-media, #custom-caffeinated, #gamemode, #bluetooth, #cpu, #memory, #disk, #temperature, #battery, #network, #wireplumber {*/
      #workspaces, #scratchpad, #window, #custom-media, #custom-caffeinated, #gamemode, #bluetooth, #cpu, #memory, #disk, #temperature, #battery, #network, #pulseaudio {
        padding: 0 5px;
      }
      /*#workspaces button:hover, #scratchpad:hover, #custom-caffeinated:hover, #gamemode:hover, #bluetooth:hover, #cpu:hover, #memory:hover, #disk:hover, #temperature:hover, #battery:hover, #network:hover, #wireplumber:hover, #clock:hover {*/
      #workspaces button:hover, #scratchpad:hover, #custom-caffeinated:hover, #gamemode:hover, #bluetooth:hover, #cpu:hover, #memory:hover, #disk:hover, #temperature:hover, #battery:hover, #network:hover, #pulseaudio:hover, #clock:hover {
        background-color: #404040;
      }

      #workspaces { padding: 0 5px 0 0; }
      #workspaces button { border: none; border-radius: 0; padding: 0 5px; min-width: 20px; animation: none; }
      #workspaces button.focused { background-color: #ffffff; color: #000000; }
      #workspaces button.urgent { background-color: #404040; animation: luminate 1s steps(30) infinite alternate; }

      #scratchpad { color: #ffff00; padding: 0 10px 0 0; }

      #custom-media.Paused { color: #606060; }

      #custom-caffeinated { color: #ff8000; }

      #gamemode { color: #00ff00; }

      #bluetooth { color: #00ffff; }

      #temperature.critical { color: #800000; animation: pulse .5s steps(15) infinite alternate; }

      #network.disabled { color: #ff0000; }
      #network.disconnected { color: #ff8000; }
      #network.linked, #network.ethernet, #network.wifi { color: #00ff00; }

      /*#wireplumber.high { color: #ff8000; }*/
      /*#wireplumber.muted { color: #ff0000; }*/
      /*#pulseaudio.high { color: #ff8000; }*/
      #pulseaudio.muted { color: #ff0000; }

      #battery:not(.charging) { color: #ff8000; }
      #battery.charging, #battery.full { color: #00ff00; }
      #battery.warning:not(.charging) { color: #800000; animation: pulse .5s steps(15) infinite alternate; }
      #battery.critical:not(.charging) { color: #000000; background-color: #800000; animation: flash .25s steps(10) infinite alternate; }
      
      #clock { padding: 0 5px; }
    '';
  };

  services.playerctld = {
    enable = true;
  };

  # TODO(work): programs.tmux

  services.syncthing = {
    enable = true;
  };

  # TODO(later): programs.lf/nnn/yazi programs.direnv? keychain? newsboat? obs-studio? programs.beets

  programs.feh = {
    enable = true;
    # TODO(later): feh config
    #buttons = {};
    #keybindings = {};
  };

  programs.mpv = {
    enable = true;
    # TODO(later): mpv config
    #bindings = {};
    #config = {};
    #extraInput = {};
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.runCommandWith { name = "swaylock-dummy"; } "mkdir $out";
    settings = {
      ignore-empty-password = true;
      image = "eDP-1:~/lock.png";
      scaling = "center";
      color = "000000";
      indicator-radius = 25;
      indicator-thickness = 8;
      indicator-y-position = 600;
      key-hl-color = "ffffff";
      bs-hl-color = "000000";
      separator-color = "000000";
      inside-color = "00000000";
      inside-clear-color = "00000000";
      inside-caps-lock-color = "00000000";
      inside-wrong-color = "00000000";
      inside-ver-color = "00000000";
      line-color = "000000";
      line-clear-color = "000000";
      line-caps-lock-color = "000000";
      line-wrong-color = "000000";
      line-ver-color = "000000";
      ring-color = "000000";
      ring-clear-color = "ffffff";
      ring-caps-lock-color = "000000";
      ring-ver-color = "ffffff";
      ring-wrong-color = "000000";
      text-color = "00000000";
      text-clear-color = "00000000";
      text-caps-lock-color = "00000000";
      text-ver-color = "00000000";
      text-wrong-color = "00000000";
    };
  };

  services.cliphist = {
    enable = true;
  };

  home.sessionVariables.QT_QPA_PLATFORM = "wayland";
  home.sessionVariables.LIBSEAT_BACKEND = "logind";
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemd.enable = true;
    systemd.variables = [ "--all" ];
    extraOptions = [ "--unsupported-gpu" ];
    extraConfigEarly = ''
      set $send_volume_notif v=$(pulsemixer --get-volume | cut -d' ' -f1) && notify-send -i audio-volume-high --category osd --hint "int:value:$v" "Volume: $v% $([ $(pulsemixer --get-mute) = 1 ] && echo '[MUTED]')"
      set $send_brightness_notif b=$(($(brightnessctl get)00/$(brightnessctl max))) && notify-send -i brightness-high --category osd --hint "int:value:$b" "Brightness: $b%"
      set $get_views vs=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | select(.visible).id")
      set $get_focused f=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | first(select(.focused)).id")
      set $get_output o=$(swaymsg -rt get_outputs | jq -r '.[] | first(select(.focused)) | .make+" "+.model+" "+.serial')
      set $get_workspaces ws=$(swaymsg -rt get_workspaces | jq -r ".[].num")
      set $get_prev_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) - 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
      set $get_next_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) + 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
      set $get_empty_workspace w=$(swaymsg -rt get_workspaces | jq -r '.[] | select(.focused).num as $w | first(range(1; 9) | select(. != $w))')
      # TODO(later): doesnt work well at high speeds (e.g. key held down)
      set $group swaymsg "mark --add g" || swaymsg "splitv, mark --add g"
      set $ungroup swaymsg "[con_mark=g] focus, unmark g" || swaymsg "focus parent; focus parent; focus parent; focus parent"
    '';
    config = {
      modifier = "Mod4";
      workspaceLayout = "default";
      output."*".bg = "#101010 solid_color";
      focus = { followMouse = true; mouseWarping = "output"; wrapping = "no"; };
      floating = { modifier = "Mod4"; border = 1; titlebar = false; };
      window = { border = 1; hideEdgeBorders = "none"; titlebar = false; commands = [
        { criteria.class = ".*"; command = "border pixel 1"; }
        { criteria.app_id = ".*"; command = "border pixel 1"; }
        { criteria.app_id = "floating.*"; command = "floating enable"; }
      ]; };
      colors.focused         = { border = "#202020"; background = "#ffffff"; text = "#000000"; indicator = "#ff0000"; childBorder = "#ffffff"; };
      colors.focusedInactive = { border = "#202020"; background = "#202020"; text = "#ffffff"; indicator = "#202020"; childBorder = "#202020"; };
      colors.unfocused       = { border = "#202020"; background = "#202020"; text = "#808080"; indicator = "#202020"; childBorder = "#202020"; };
      colors.urgent          = { border = "#2f343a"; background = "#202020"; text = "#ffffff"; indicator = "#900000"; childBorder = "#900000"; };
      input."type:keyboard".xkb_layout = "ie";
      input."type:keyboard".xkb_options = "caps:escape";
      input."type:keyboard".repeat_delay = "250";
      input."type:keyboard".repeat_rate = "30";
      input."type:touchpad".dwt = "disabled";
      input."type:touchpad".tap = "enabled";
      input."type:touchpad".natural_scroll = "enabled";
      input."type:touchpad".click_method = "clickfinger";
      input."type:touchpad".scroll_method = "two_finger";
      modes = {};
      fonts = {}; 
      startup = [
        { command = "pidof -x batteryd || batteryd"; always = true; }
        { command = "pidof -x bmbwd || bmbwd"; always = true; }
        { command = "displayctl";  always = true; }
        { command = "powerctl decafeinate"; }
      ];
      bars = [ { command = "waybar"; mode = "hide"; } ];
      # shortcuts
      keybindings."Mod4+space" = "exec bemenu-run";
      keybindings."Mod4+Return" = "exec alacritty";
      keybindings."Mod4+t" = "exec alacritty";
      keybindings."Mod4+w" = "exec firefox";
      keybindings."Mod4+d" = "exec firefox 'https://discord.com/app'";
      keybindings."Mod4+Escape"                        = "exec powerctl";
      keybindings."Mod4+Shift+Escape"                  = "exec powerctl lock";
      keybindings."--locked Mod4+Control+Escape"       = "exec powerctl suspend";
      keybindings."--locked Mod4+Control+Shift+Escape" = "exec powerctl reload";
      keybindings."Mod4+Apostrophe"               = "exec displayctl";
      keybindings."Mod4+Shift+Apostrophe"         = "exec displayctl external";
      keybindings."Mod4+Control+Apostrophe"       = "exec displayctl internal";
      keybindings."Mod4+Control+Shift+Apostrophe" = "exec displayctl both";
      keybindings."Mod4+n"         = "exec networkctl";
      keybindings."Mod4+Shift+n"   = "exec networkctl wifi";
      keybindings."Mod4+Control+n" = "exec networkctl bluetooth";
      # TODO(later): persistent floating btop
      keybindings."Mod4+u" = "exec alacritty --class floating-btop --command btop";
      keybindings."Mod4+Control+u" = "exec swaymsg '[class=\"floating-btop\"] scratchpad show'";
      keybindings."Mod4+b"         = "exec pkill -USR1 bmbwd";
      keybindings."Mod4+Shift+b"   = "exec pkill -USR2 bmbwd";
      keybindings."Mod4+Control+b" = "exec pkill -TERM bmbwd";
      keybindings."Mod4+v" = "exec cliphist list | bemenu --prompt 'Clipboard' | cliphist decode | wl-copy";
      keybindings."Mod4+grave"         = "exec makoctl dismiss";
      keybindings."Mod4+Shift+grave"   = "exec makoctl restore";
      keybindings."Mod4+Control+grave" = "exec makoctl menu bemenu --prompt 'Action'";
      # containers
      keybindings."Mod4+h"         = "focus left";
      keybindings."Mod4+Shift+h"   = "exec $group && swaymsg 'move left 50px' && $ungroup";
      keybindings."Mod4+Control+h" = "resize shrink width 50px";
      keybindings."Mod4+j"         = "focus down";
      keybindings."Mod4+Shift+j"   = "exec $group && swaymsg 'move down 50px' && $ungroup";
      keybindings."Mod4+Control+j" = "resize grow height 50px";
      keybindings."Mod4+k"         = "focus up";
      keybindings."Mod4+Shift+k"   = "exec $group && swaymsg 'move up 50px' && $ungroup";
      keybindings."Mod4+Control+k" = "resize shrink height 50px";
      keybindings."Mod4+l"         = "focus right";
      keybindings."Mod4+Shift+l"   = "exec $group && swaymsg 'move right 50px' && $ungroup";
      keybindings."Mod4+Control+l" = "resize grow width 50px";
      # TODO(later): doesnt really work
      #keybindings."Mod4+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | cat | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
      #keybindings."Mod4+Shift+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | tac | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
      keybindings."Mod4+f" = "focus mode_toggle";
      keybindings."Mod4+Shift+f" = "border pixel 1, floating toggle";
      keybindings."Mod4+x" = "sticky toggle";
      keybindings."Mod4+m" = "fullscreen";
      keybindings."Mod4+q" = "kill";
      # workspaces
      keybindings."Mod4+1" = ''exec $get_output && swaymsg "workspace 1:$o"'';
      keybindings."Mod4+2" = ''exec $get_output && swaymsg "workspace 2:$o"'';
      keybindings."Mod4+3" = ''exec $get_output && swaymsg "workspace 3:$o"'';
      keybindings."Mod4+4" = ''exec $get_output && swaymsg "workspace 4:$o"'';
      keybindings."Mod4+5" = ''exec $get_output && swaymsg "workspace 5:$o"'';
      keybindings."Mod4+6" = ''exec $get_output && swaymsg "workspace 6:$o"'';
      keybindings."Mod4+7" = ''exec $get_output && swaymsg "workspace 7:$o"'';
      keybindings."Mod4+8" = ''exec $get_output && swaymsg "workspace 8:$o"'';
      keybindings."Mod4+9" = ''exec $get_output && swaymsg "workspace 9:$o"'';
      keybindings."Mod4+Shift+1" = ''exec $group && $get_output && swaymsg "move container workspace 1:$o, workspace 1:$o" && $ungroup'';
      keybindings."Mod4+Shift+2" = ''exec $group && $get_output && swaymsg "move container workspace 2:$o, workspace 2:$o" && $ungroup'';
      keybindings."Mod4+Shift+3" = ''exec $group && $get_output && swaymsg "move container workspace 3:$o, workspace 3:$o" && $ungroup'';
      keybindings."Mod4+Shift+4" = ''exec $group && $get_output && swaymsg "move container workspace 4:$o, workspace 4:$o" && $ungroup'';
      keybindings."Mod4+Shift+5" = ''exec $group && $get_output && swaymsg "move container workspace 5:$o, workspace 5:$o" && $ungroup'';
      keybindings."Mod4+Shift+6" = ''exec $group && $get_output && swaymsg "move container workspace 6:$o, workspace 6:$o" && $ungroup'';
      keybindings."Mod4+Shift+7" = ''exec $group && $get_output && swaymsg "move container workspace 7:$o, workspace 7:$o" && $ungroup'';
      keybindings."Mod4+Shift+8" = ''exec $group && $get_output && swaymsg "move container workspace 8:$o, workspace 8:$o" && $ungroup'';
      keybindings."Mod4+Shift+9" = ''exec $group && $get_output && swaymsg "move container workspace 9:$o, workspace 9:$o" && $ungroup'';
      keybindings."Mod4+Control+1" = ''exec $get_output && swaymsg "move container workspace 1:$o"'';
      keybindings."Mod4+Control+2" = ''exec $get_output && swaymsg "move container workspace 2:$o"'';
      keybindings."Mod4+Control+3" = ''exec $get_output && swaymsg "move container workspace 3:$o"'';
      keybindings."Mod4+Control+4" = ''exec $get_output && swaymsg "move container workspace 4:$o"'';
      keybindings."Mod4+Control+5" = ''exec $get_output && swaymsg "move container workspace 5:$o"'';
      keybindings."Mod4+Control+6" = ''exec $get_output && swaymsg "move container workspace 6:$o"'';
      keybindings."Mod4+Control+7" = ''exec $get_output && swaymsg "move container workspace 7:$o"'';
      keybindings."Mod4+Control+8" = ''exec $get_output && swaymsg "move container workspace 8:$o"'';
      keybindings."Mod4+Control+9" = ''exec $get_output && swaymsg "move container workspace 9:$o"'';
      keybindings."Mod4+Comma"                = ''exec $get_output && $get_prev_workspace && swaymsg "workspace $w:$o"'';
      keybindings."Mod4+Period"               = ''exec $get_output && $get_next_workspace && swaymsg "workspace $w:$o"'';
      keybindings."Mod4+Shift+Comma"          = ''exec $group && $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
      keybindings."Mod4+Shift+Period"         = ''exec $group && $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
      keybindings."Mod4+Control+Comma"        = ''exec $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o"'';
      keybindings."Mod4+Control+Period"       = ''exec $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o"'';
      keybindings."Mod4+Control+Shift+Comma"  = ''exec '$group && $get_output && $get_workspaces && ws=$(echo "$ws" | cat) && [ "$(echo "$ws" | head -1)" != "1" ] && for w in $ws; do i=$(( $w - 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done && ungroup' '';
      keybindings."Mod4+Control+Shift+Period" = ''exec '$group && $get_output && $get_workspaces && ws=$(echo "$ws" | tac) && [ "$(echo "$ws" | head -1)" != "9" ] && for w in $ws; do i=$(( $w + 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done && ungroup' '';
      keybindings."Mod4+z"               = ''exec $get_output && $get_empty_workspace && swaymsg "workspace $w:$o"'';
      keybindings."Mod4+Shift+z"         = ''exec $group && $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup'';
      keybindings."Mod4+Control+z"       = ''exec '$get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o"' '';
      keybindings."Mod4+Control+Shift+z" = ''exec '$group && $get_output && $get_workspaces && i=1; for w in $ws; do swaymsg rename workspace $w:$o to $i:$o; i=$(( $i + 1 )); done && $ungroup' '';
      # outputs
      keybindings."Mod4+equal"         = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.1)"')'';
      keybindings."Mod4+minus"         = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.1)"')'';
      keybindings."Mod4+Shift+equal"   = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.5)"')'';
      keybindings."Mod4+Shift+minus"   = ''exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.5)"')'';
      keybindings."Mod4+Control+equal" = ''exec $get_output && swaymsg output "$o" scale 1'';
      keybindings."Mod4+Control+minus" = ''exec $get_output && swaymsg output "$o" scale 2'';
      # layout
      keybindings."Mod4+g"       = "focus parent";
      keybindings."Mod4+Shift+g" = "focus child";
      keybindings."Mod4+p"       = "split vertical";
      keybindings."Mod4+Shift+p" = "split none";
      keybindings."Mod4+o"       = "layout toggle splitv splith";
      keybindings."Mod4+Shift+o" = "layout toggle split tabbed";
      # scratchpads
      keybindings."Mod4+0"       = "scratchpad show";
      keybindings."Mod4+Shift+0" = "move scratchpad";
      # media
      keybindings."--locked XF86AudioPlay"         = "exec playerctl play-pause";
      keybindings."--locked Shift+XF86AudioPlay"   = "exec playerctl pause";
      keybindings."--locked Control+XF86AudioPlay" = "exec playerctl stop";
      keybindings."--locked XF86AudioPrev"         = "exec playerctl position 1-";
      keybindings."--locked Shift+XF86AudioPrev"   = "exec playerctl position 10-";
      keybindings."--locked Control+XF86AudioPrev" = "exec playerctl previous";
      keybindings."--locked XF86AudioNext"         = "exec playerctl position 1+";
      keybindings."--locked Shift+XF86AudioNext"   = "exec playerctl position 10+";
      keybindings."--locked Control+XF86AudioNext" = "exec playerctl next";
      # volume
      #wpctl set-mute/set-volume @DEFAULT_SINK@ toggle/1/1%-/1%+";
      keybindings."--locked XF86AudioMute"                = "exec pulsemixer --toggle-mute       && $send_volume_notif";
      keybindings."--locked Shift+XF86AudioMute"          = "exec                                   $send_volume_notif";
      keybindings."--locked Control+XF86AudioMute"        = "exec pulsemixer --toggle-mute       && $send_volume_notif";
      keybindings."--locked XF86AudioLowerVolume"         = "exec pulsemixer --change-volume  -1 && $send_volume_notif";
      keybindings."--locked Shift+XF86AudioLowerVolume"   = "exec pulsemixer --change-volume -10 && $send_volume_notif";
      keybindings."--locked Control+XF86AudioLowerVolume" = "exec pulsemixer --set-volume      0 && $send_volume_notif";
      keybindings."--locked XF86AudioRaiseVolume"         = "exec pulsemixer --change-volume  +1 && $send_volume_notif";
      keybindings."--locked Shift+XF86AudioRaiseVolume"   = "exec pulsemixer --change-volume +10 && $send_volume_notif";
      keybindings."--locked Control+XF86AudioRaiseVolume" = "exec pulsemixer --set-volume    100 && $send_volume_notif";
      # microphone
      #wpctl set-mute @DEFAULT_SOURCE@ 0/1/toggle
      keybindings."--locked --no-repeat Pause"                            = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --unmute";
      keybindings."--locked --no-repeat --release Pause"                  = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --mute";
      keybindings."--locked --no-repeat --release --whole-window button8" = "exec pulsemixer --id $(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3) --toggle-mute";
      # backlight
      keybindings."--locked XF86MonBrightnessDown"         = "exec brightnessctl set 1%-  && $send_brightness_notif";
      keybindings."--locked Shift+XF86MonBrightnessDown"   = "exec brightnessctl set 10%- && $send_brightness_notif";
      keybindings."--locked Control+XF86MonBrightnessDown" = "exec brightnessctl set 1    && $send_brightness_notif";
      keybindings."--locked XF86MonBrightnessUp"           = "exec brightnessctl set 1%+  && $send_brightness_notif";
      keybindings."--locked Shift+XF86MonBrightnessUp"     = "exec brightnessctl set 10%+ && $send_brightness_notif";
      keybindings."--locked Control+XF86MonBrightnessUp"   = "exec brightnessctl set 100% && $send_brightness_notif";
      # screenshots
      keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | wl-copy --type image/png'';
      keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | wl-copy --type image/png'';
      keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | wl-copy --type image/png'';
    };
  };



  # TODO(pipewire): for screensharing etc
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/home-manager/configs/thonkpod/default.nix?ref_type=heads
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/nixos/modules/gui.nix?ref_type=heads
  #XDG_DESKTOP_PORTAL_DIR = "${joinedPortals}/share/xdg-desktop-portal/portals"
  
  #xdg = {
  #  configFile = {
  #    # Use the right portal for screen{shot,cast}ing (copied from `nixos/modules/gui.nix`)
  #    "xdg-desktop-portal/sway-portals.conf".text = ''
  #      [preferred]
  #      default=gtk
  #      org.freedesktop.impl.portal.Screenshot=wlr
  #      org.freedesktop.impl.portal.ScreenCast=wlr
  #    '';
  #  };
  #};
  #
  #systemd.user = {
  #  services = {
  #    xdg-desktop-portal = {
  #      Unit = {
  #        Description = "Portal service";
  #        PartOf = "graphical-session.target";
  #        After = "graphical-session.target";
  #      };
  #      Service = {
  #        Type = "dbus";
  #        BusName = "org.freedesktop.portal.Desktop";
  #        ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
  #        Restart = "on-failure";
  #        Environment = [ "XDG_DESKTOP_PORTAL_DIR=${joinedPortals}/share/xdg-desktop-portal/portals" ];
  #      };
  #      Install.WantedBy = [ "graphical-session.target" ];
  #    };

  #    # Ubuntu 22.04 xdg-desktop-portal-wlr is broken :)
  #    # Note we still need the package installed to get the entry in `/usr/share/xdg-desktop-portal/portals`
  #    xdg-desktop-portal-wlr = {
  #      Unit = {
  #        Description = "Portal service (wlroots implementation)";
  #        PartOf = "graphical-session.target";
  #        After = "graphical-session.target";
  #        ConditionEnvironment = "WAYLAND_DISPLAY";
  #      };
  #      Service = {
  #        Type = "dbus";
  #        BusName = "org.freedesktop.impl.portal.desktop.wlr";
  #        ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
  #        Restart = "on-failure";
  #      };
  #      Install.WantedBy = [ "graphical-session.target" ];
  #    };

  #    xdg-desktop-portal-gtk = {
  #      Unit = {
  #        Description = "Portal service (GTK/GNOME implementation)";
  #        PartOf = "graphical-session.target";
  #        After = "graphical-session.target";
  #      };
  #      Service = {
  #        Type = "dbus";
  #        BusName = "org.freedesktop.impl.portal.desktop.gtk";
  #        ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
  #        Restart = "on-failure";
  #      };
  #      Install.WantedBy = [ "graphical-session.target" ];
  #    };
  #  };
  #};



  #xdg.portal = {
  #  enable = true;
  #  xdgOpenUsePortal = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-gtk
  #    xdg-desktop-portal-wlr
  #  ];
  #  config = {
  #    common.default = [ "gtk" ];
  #    common."org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
  #    common."org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
  #  };
  #};



  xdg.enable = true;
  xdg.userDirs = { enable = true; createDirectories = true; publicShare = null; templates = null; };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };
  xdg.mimeApps.associations.removed = {};
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox_firefox.desktop";
    "x-scheme-handler/unknown" = "firefox_firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = { monospace = [ "Terminess Nerd Font" ]; sansSerif = []; serif = []; emoji = []; };
  
  gtk.enable = true;
  gtk.gtk2.extraConfig = ''gtk-key-theme-name = "Emacs"'';
  gtk.gtk3.extraConfig.gtk-key-theme-name = "Emacs";
  gtk.gtk4.extraConfig.gtk-key-theme-name = "Emacs";
  gtk.theme = { package = pkgs.materia-theme; name = "Materia-dark"; };
  gtk.iconTheme = { package = pkgs.kdePackages.breeze-icons; name = "breeze-dark"; };
  #gtk.cursorTheme = { package = pkgs.; name = ""; };

  nix.package = pkgs.nix;
  nix.settings = { auto-optimise-store = true; use-xdg-base-directories = true; experimental-features = [ "nix-command" "flakes" ]; };
  nixpkgs.config.allowUnfree = true;
  systemd.user.startServices = "sd-switch";
  targets.genericLinux.enable = true;
}
