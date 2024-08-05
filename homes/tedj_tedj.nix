# TODO(next): imports = [];

{pkgs, lib, config, inputs, ...}: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.keyboard = { layout = "ie"; options = [ "caps:escape" ]; };
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables.QT_QPA_PLATFORM = "wayland";
  home.sessionVariables.LIBSEAT_BACKEND = "logind";

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
    # gui
    wl-clipboard
    wireplumber
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
    # TODO(later): focus on every monitor 
    (writeShellScriptBin "displayctl" ''
      swaymsg -t get_outputs

      #swaymsg output "$mon0" enable pos 0 0
      #swaymsg output "$mon1" disable

      #swaymsg output eDP-1 enable pos 0 1080
      #swaymsg output HDMI-1-0 enable pos 0 0

      #swaymsg "workspace 1:eDP-1"
    '')
    # power menu
    # TODO(later): idle warning
    (writeShellScriptBin "powerctl" ''
      case "$([ -n "$1" ] && echo $1 || printf "lock\nsuspend\n$(pidof -q swayidle && echo coffee || echo decaf)\nreload\nlogout\nreboot\nshutdown" | bemenu -p "Power" -l 9 -W 0.2)" in
        "lock") loginctl lock-session;;
        "suspend") systemctl suspend;;
        "reload") swaymsg reload;;
        "logout") swaymsg exit;;
        "reboot") systemctl reboot;;
        "shutdown") systemctl poweroff;;
        "coffee") pkill swayidle;;
        "decaf") pidof swayidle || swayidle -w idlehint 300 \
          before-sleep "loginctl lock-session" \
          lock "swaylock --daemonize" \
          unlock "pkill -USR1 swaylock" \
          timeout 300 "loginctl lock-session" \
          timeout 900 "systemctl suspend" &;;
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
            for i in $(seq 5 -1 1); do notify-send -i "battery-020" -u "critical" -r "$$" -t 0 "Battery empty!" "Suspending in $i..."; sleep 1; done
            powerctl suspend
          } || {
            [ "$old_charge" -gt 10 ] && [ "$charge" -le 10 ] && {
              notify-send -i "battery-020" -u "critical" -r "$$" -t 0 "Battery critical!" "Less than$time"
            } || {
              [ "$old_charge" -gt 20 ] && [ "$charge" -le 20 ] && {
                notify-send -i "battery-020" -u "normal" -r "$$" "Battery low!" "Less than$time"
              }
            }
          }
          old_charge="$charge"
        }
      done
    '')

    (writeShellScriptBin "avpn" ''sudo ${openconnect}/bin/openconnect --protocol=gp gp-ie.arista.com -u tedj -c $HOME/Documents/wi-fi-certificates/tedj.crt -k $HOME/Documents/wi-fi-certificates/tedj.pem'')
  ];

  programs.home-manager = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config = { style = "plain"; wrap = "never"; map-syntax = [ "*.tin:C++" "*.tac:C++" ]; };
  };

  programs.gpg = {
    enable = true;
    # TODO(work): publicKeys
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
    # TODO(work)
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
            { name = "AID7587: Recommended email filters - Google Docs"; url = "https://docs.google.com/document/d/1CA_p08yOrjpaDMzmfvxN5RVyKN36i8DAg51PdO2r0lM/preview"; }
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
          # TODO(later): keybinding to search tedj@tedj
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

  programs.less = {
    enable = true;
    keys = "h left-scroll\nl right-scroll";
  };
  home.sessionVariables.LESS="--incsearch --ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT";

      # pager
      # TODO(later): move to less config or something?
      #export LESS_TERMCAP_mb="$(tput setaf 2; tput blink)"
      #export LESS_TERMCAP_md="$(tput setaf 0; tput bold)"
      #export LESS_TERMCAP_me="$(tput sgr0)"
      #export LESS_TERMCAP_so="$(tput setaf 3; tput smul; tput bold)"
      #export LESS_TERMCAP_se="$(tput sgr0)"
      #export LESS_TERMCAP_us="$(tput setaf 4; tput smul)"
      #export LESS_TERMCAP_ue="$(tput sgr0)"


  programs.man = {
    enable = true;
  };

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.sessionVariables.MANWIDTH = 80;
  programs.neovim = { # TODO(work): config
    enable = true;
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

  programs.ssh = { # TODO(work): config
    enable = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit -d '${config.xdg.cacheHome}/zcompdump'";
    history = { path = "${config.xdg.dataHome}/zsh_history"; extended = true; ignoreAllDups = true; share = true; save = 1000000; size = 1000000; };
    localVariables.PROMPT = "\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f ";
    localVariables.TIMEFMT = "\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P";
    shellAliases.z = "exec zsh";
    shellAliases.v = "nvim";
    shellAliases.p = "python3";
    shellAliases.c = "cargo";
    shellAliases.g = "git";
    shellAliases.rm = "2>&1 echo rm disabled, use del; return 1 && ";
    shellAliases.ls = "eza -hs=name --group-directories-first";
    shellAliases.ll = "ls -la";
    shellAliases.lt = "ll -T";
    shellAliases.ip = "ip --color";
    shellAliases.sudo = "sudo --preserve-env ";
    shellGlobalAliases.cat = "bat --paging=never";
    shellGlobalAliases.grep = "rg";
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
      #hash gpgconf 2>/dev/null && {
      #  export GPG_TTY="$(tty)"
      #  export SSH_AGENT_PID=""
      #  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      #  (gpgconf --launch gpg-agent &)
      #}

      cht() { cht.sh "$@?style=paraiso-dark"; }
      _cht() { compadd $commands:t; }; compdef _cht cht

      #ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new ''${@:+-c -- a4c shell $@}; }
      #_ash() { compadd "$(ssh us260 -- a4c ps -N)"; }; compdef _ash ash

      # desktop environment
      [[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && hash sway 2>/dev/null && {
        nixGLIntel sway
      }
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
        ipc = true;
        layer = "top";
        position = "top";
        height = 30;
        spacing = 0;
        # TODO(later): non-primary display modules
        # TODO(later): vpn icon
        modules-left = [ "sway/workspaces" "sway/scratchpad" "sway/window" ];
        modules-center = [];
        modules-right = [ "custom/media" "custom/caffeinated" "gamemode" "bluetooth" "cpu" "memory" "temperature" "disk" "network" "wireplumber" "battery" "clock" ];
        "sway/workspaces".format = "{index}";
        "sway/window".max-length = 200;
        "custom/media" = {
          exec = "~/.config/waybar/modules/media"; # TODO(later)
          return-type = "json";
          interval = 1;
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl position 5+";
          on-scroll-down = "playerctl position 5-";
        };
        "custom/caffeinated" = {
          exec = "~/.config/waybar/modules/caffeinated"; # TODO(later)
          return-type = "json";
          tooltip = true;
          interval = 1;
          on-click = "powerctl decaf";
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
        temperature = { # TODO(later, bar): show more info on hover
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
          # TODO(later): format while connecting
          format-disconnected = "offline";
          on-click = "networkctl wifi";
          on-click-right = ''case "$(nmcli radio wifi)" in "enabled") nmcli radio wifi off;; *) nmcli radio wifi on;; esac'';
        };
        wireplumber = {
          max-volume = 150;
          states.high = 75;
          on-click = "alacritty --class floating --command pulsemixer"; # TODO(later): better cli mixer?
          on-click-right = "wpctl set-mute @DEFAULT_SINK@ toggle";
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
          on-click = ''notify-send "$(date)" "$(date "+Day %j, Week %V, %Z (%:z)")"'';
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
    ];
    style = ''
      * { font-family: "Terminess Nerd Font", monospace; font-size: 16px; margin: 0; }
      window#waybar { background-color: rgba(0,0,0,0.75); }

      @keyframes pulse { to { color: #ffffff; } }
      @keyframes flash { to { background-color: #ffffff; } }
      @keyframes luminate { to { background-color: #b0b0b0; } }

      #workspaces, #scratchpad, #window, #custom-media, #custom-caffeinated, #gamemode, #bluetooth, #cpu, #memory, #disk, #temperature, #battery, #network, #wireplumber {
        padding: 0 5px;
      }
      #workspaces button:hover, #scratchpad:hover, #custom-caffeinated:hover, #gamemode:hover, #bluetooth:hover, #cpu:hover, #memory:hover, #disk:hover, #temperature:hover, #battery:hover, #network:hover, #wireplumber:hover, #clock:hover {
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

      #wireplumber.high { color: #ff8000; }
      #wireplumber.muted { color: #ff0000; }

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
  # TODO(work): services.gpg-agent?
  # TODO(work): services.ssh-agent?

  # TODO(later): service.syncthing
  # TODO(later): programs.lf/nnn/yazi
  # TODO(later): programs.direnv? keychain? newsboat? obs-studio?
  # TODO(later): programs.beets

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

  wayland.windowManager.sway = {
    enable = true;
    #package = nixGL pkgs.sway; # TODO(later): wrap sway with nixGL here instead of in shell?
    wrapperFeatures.gtk = true;
    systemd.enable = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraConfigEarly = ''
      set $send_volume_notif wpctl get-volume @DEFAULT_SINK@ | (read _ v m && v=$(printf "%.0f" $(echo "100*$v" | bc)) && notify-send --category osd --hint "int:value:$v" "Volume: $v% $m")
      set $send_brightness_notif b=$(($(brightnessctl get)00/$(brightnessctl max))) && notify-send --category osd --hint "int:value:$b" "Brightness: $b%"
      set $get_views vs=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | select(.visible).id")
      set $get_focused f=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | first(select(.focused)).id")
      set $get_output o=$(swaymsg -rt get_outputs | jq -r ".[] | first(select(.focused).name)")
      set $get_workspaces ws=$(swaymsg -rt get_workspaces | jq -r ".[].num")
      set $get_prev_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) - 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
      set $get_next_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) + 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
      # TODO(later): always skips 1
      set $get_empty_workspace w=$(swaymsg -rt get_workspaces | jq ". as \$w | first(range(1; 9) | select(all(. != \$w[].num; .)))")
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
        { command = "powerctl decaf"; always = true; }
        { command = "displayctl auto"; always = true; }
      ];
      # TODO(later): multimonitor bars
      bars = [ { command = "waybar"; mode = "hide"; } ];
      # shortcuts
      keybindings."Mod4+space" = "exec bemenu-run";
      keybindings."Mod4+Return" = "exec alacritty";
      keybindings."Mod4+t" = "exec alacritty";
      keybindings."Mod4+w" = "exec firefox";
      keybindings."Mod4+d" = "exec firefox 'https://discord.com/app'";
      keybindings."Mod4+Escape" = "exec powerctl";
      # TODO(later): --locked
      keybindings."Mod4+Shift+Escape" = "exec powerctl lock";
      keybindings."Mod4+Control+Escape" = "exec powerctl suspend";
      keybindings."Mod4+Control+Shift+Escape" = "exec powerctl reload";
      keybindings."Mod4+Apostrophe" = "exec displayctl";
      #keybindings."Mod4+Shift+Apostrophe" = "exec displayctl external";
      #keybindings."Mod4+Control+Apostrophe" = "exec displayctl internal";
      #keybindings."Mod4+Control+Shift+Apostrophe" = "exec displayctl both";
      keybindings."Mod4+n" = "exec networkctl";
      keybindings."Mod4+Shift+n" = "exec networkctl wifi";
      keybindings."Mod4+Control+n" = "exec networkctl bluetooth";
      # TODO(later): persistent floating btop
      keybindings."Mod4+u" = "exec alacritty --class floating-btop --command btop";
      keybindings."Mod4+Control+u" = "exec swaymsg '[class=\"floating-btop\"] scratchpad show'";
      # TODO(work): bemenu bitwarden
      keybindings."Mod4+b" = "border pixel 1";
      keybindings."Mod4+shift+b" = "border none";
      keybindings."Mod4+v" = "exec cliphist list | bemenu --prompt 'Clipboard' | cliphist decode | wl-copy";
      keybindings."Mod4+grave" = "exec makoctl dismiss";
      keybindings."Mod4+Shift+grave" = "exec makoctl restore";
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
      # TODO(later): doesnt work if nothing is focused
      keybindings."Mod4+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | cat | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
      keybindings."Mod4+Shift+Tab" = ''exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | tac | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"'';
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
      # TODO(later): --locked
      keybindings."XF86AudioPlay"         = "exec playerctl play-pause";
      keybindings."Shift+XF86AudioPlay"   = "exec playerctl pause";
      keybindings."Control+XF86AudioPlay" = "exec playerctl stop";
      keybindings."XF86AudioPrev"         = "exec playerctl position 1-";
      keybindings."Shift+XF86AudioPrev"   = "exec playerctl position 10-";
      keybindings."Control+XF86AudioPrev" = "exec playerctl previous";
      keybindings."XF86AudioNext"         = "exec playerctl position 1+";
      keybindings."Shift+XF86AudioNext"   = "exec playerctl position 10+";
      keybindings."Control+XF86AudioNext" = "exec playerctl next";
      # volume
      # TODO(later): --locked
      keybindings."XF86AudioMute"                = "exec wpctl set-mute   @DEFAULT_SINK@ toggle && $send_volume_notif";
      keybindings."Shift+XF86AudioMute"          = "exec                                           $send_volume_notif";
      keybindings."Control+XF86AudioMute"        = "exec wpctl set-mute   @DEFAULT_SINK@ 1      && $send_volume_notif";
      keybindings."XF86AudioLowerVolume"         = "exec wpctl set-volume @DEFAULT_SINK@ 1%-    && $send_volume_notif";
      keybindings."Shift+XF86AudioLowerVolume"   = "exec wpctl set-volume @DEFAULT_SINK@ 10%-   && $send_volume_notif";
      keybindings."Control+XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 0%     && $send_volume_notif";
      keybindings."XF86AudioRaiseVolume"         = "exec wpctl set-volume @DEFAULT_SINK@ 1%+    && $send_volume_notif";
      keybindings."Shift+XF86AudioRaiseVolume"   = "exec wpctl set-volume @DEFAULT_SINK@ 10%+   && $send_volume_notif";
      keybindings."Control+XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 100%   && $send_volume_notif";
      # microphone
      # TODO(later): --locked
      #keybindings."Pause"   = "exec wpctl set-mute @DEFAULT_SOURCE@ 0"; TODO(later): --no-repeat
      #keybindings."Pause"   = "exec wpctl set-mute @DEFAULT_SOURCE@ 1"; TODO(later): --no-repeat --release
      #keybindings."button8" = "exec wpctl set-mute @DEFAULT_SOURCE@ toggle"; # TODO(later): --no-repeat --release --whole-window
      # backlight
      # TODO(later): --locked
      keybindings."XF86MonBrightnessDown"         = "exec brightnessctl set 1%-  && $send_brightness_notif";
      keybindings."Shift+XF86MonBrightnessDown"   = "exec brightnessctl set 10%- && $send_brightness_notif";
      keybindings."Control+XF86MonBrightnessDown" = "exec brightnessctl set 1    && $send_brightness_notif";
      keybindings."XF86MonBrightnessUp"           = "exec brightnessctl set 1%+  && $send_brightness_notif";
      keybindings."Shift+XF86MonBrightnessUp"     = "exec brightnessctl set 10%+ && $send_brightness_notif";
      keybindings."Control+XF86MonBrightnessUp"   = "exec brightnessctl set 100% && $send_brightness_notif";
      # screenshots
      keybindings."Print"         = ''exec slurp -b '#ffffff20' | grim -g - - | wl-copy --type image/png'';
      keybindings."Shift+Print"   = ''exec swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -B '#ffffff20' | grim -g - - | wl-copy --type image/png'';
      keybindings."Control+Print" = ''exec slurp -oB '#ffffff20' | grim -g - - | wl-copy --type image/png'';
    };
    extraConfig = ''
      workspace_auto_back_and_forth yes
    '';
  };



  # TODO(now, pipewire): wpctl not working
  # TODO(now, pipewire): for screensharing etc
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
  gtk.theme = { package = pkgs.materia-theme; name = "Materia-dark"; };
  gtk.iconTheme = { package = pkgs.kdePackages.breeze-icons; name = "breeze-dark"; };
  #gtk.cursorTheme = { package = pkgs.; name = ""; };

  nix.package = pkgs.nix;
  nix.settings = { auto-optimise-store = true; use-xdg-base-directories = true; experimental-features = [ "nix-command" "flakes" ]; };
  nixpkgs.config.allowUnfree = true;
  systemd.user.startServices = "sd-switch";
  targets.genericLinux.enable = true;
}
