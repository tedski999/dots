# TODO: autologin
# TODO: imports = [];

{pkgs, lib, config, inputs, ...}: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.keyboard.layout = "ie";
  home.keyboard.options = [ "caps:escape" ];
  home.sessionVariables = { EDITOR = "nvim"; TERMINAL = "alacritty"; BROWSER = "firefox"; MANPAGER = "nvim +Man!"; MANWIDTH = 80; };
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nix
    eza
    wl-clipboard

    # TODO: no otb or other bitmap fonts showing up in fc-list
    terminus-nerdfont
    terminus_font_ttf
    terminus_font
    termsyn
    tamsyn

  ];

  programs.home-manager = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config.style = "plain";
    config.wrap = "never";
    config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  };

  programs.gpg = {
    enable = true;
    # TODO: publicKeys
  };

  programs.git = {
    enable = true;
    userEmail = "ski@h8c.de";
    userName = "tedski999";
    signing.key = "00ADEF0A!";
    signing.signByDefault = true;
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
    # TODO
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

  programs.firefox = {
    enable = true;
    # TODO: use firefox sync instead?
    profiles.work = {
      id = 0;
      name = "Work";
      isDefault = true;
      search.default = "DuckDuckGo";
      search.privateDefault = "DuckDuckGo";
      search.force = true;
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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        vimium
      ];
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
              ];
            }
            {
              name = "docs";
              bookmarks = [
                { name = "links"; url = "https://docs.google.com/document/d/1EC3rGgvN1T90W-gXwgXl3XaiDUb7pD86QnqXxp1Yk1I/preview"; }
                { name = "creating an agent"; url = "https://docs.google.com/document/d/1k6HmxdQTyhBuLCzNfoj6WDKhcfxxCw9VYt6LxvIymnA/preview"; }
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
    profiles.home = {
      id = 1;
      name = "Home";
      isDefault = false;
      search.default = "DuckDuckGo";
      search.privateDefault = "DuckDuckGo";
      search.force = true;
      settings = {
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        vimium
      ];
      bookmarks = [
      ];
    };
  };

  programs.jq = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      live_config_reload = false;
      scrolling.history = 10000;
      scrolling.multiplier = 5;
      window.dynamic_padding = true;
      window.opacity = 0.85;
      window.dimensions.columns = 120;
      window.dimensions.lines = 40;
      font.size = 13.5;
      font.normal.family = "Terminess Nerd Font";
      selection.save_to_clipboard = true;
      # TODO: keybinding to search username@host
      #[[keyboard.bindings]]
      #action = "SpawnNewInstance"
      #key = "Return"
      #mods = "Shift|Control"
      #[[keyboard.bindings]]
      #action = "ToggleViMode"
      #key = "Escape"
      #mods = "Shift|Control"
      #[[keyboard.bindings]]
      #action = "ToggleViMode"
      #key = "Escape"
      #mode = "Vi"
      #[[keyboard.bindings]]
      #action = "ScrollToTop"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      #[[keyboard.bindings]]
      #action = "ToggleNormalSelection"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      #[[keyboard.bindings]]
      #action = "ScrollToBottom"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      #[[keyboard.bindings]]
      #action = "Copy"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      #[[keyboard.bindings]]
      #action = "ClearSelection"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      #[[keyboard.bindings]]
      #action = "ToggleViMode"
      #key = "A"
      #mode = "Vi"
      #mods = "Control"
      colors.draw_bold_text_with_bright_colors = true;
      colors.primary.background = "#000000";
      colors.primary.foreground = "#dddddd";
      colors.cursor.cursor = "#cccccc";
      colors.cursor.text = "#111111";
      colors.normal.black = "#000000";
      colors.normal.blue = "#0d73cc";
      colors.normal.cyan = "#0dcdcd";
      colors.normal.green = "#19cb00";
      colors.normal.magenta = "#cb1ed1";
      colors.normal.red = "#cc0403";
      colors.normal.white = "#dddddd";
      colors.normal.yellow = "#cecb00";
      colors.bright.black = "#767676";
      colors.bright.blue = "#1a8fff";
      colors.bright.cyan = "#14ffff";
      colors.bright.green = "#23fd00";
      colors.bright.magenta = "#fd28ff";
      colors.bright.red = "#f2201f";
      colors.bright.white = "#ffffff";
      colors.bright.yellow = "#fffd00";
      colors.search.focused_match.background = "#ffffff";
      colors.search.focused_match.foreground = "#000000";
      colors.search.matches.background = "#edb443";
      colors.search.matches.foreground = "#091f2e";
      colors.footer_bar.background = "#000000";
      colors.footer_bar.foreground = "#ffffff";
      colors.line_indicator.background = "#000000";
      colors.line_indicator.foreground = "#ffffff";
      colors.selection.background = "#fffacd";
      colors.selection.text = "#000000";
    };
  };

  programs.less = {
    enable = true;
    # TODO:  M+Gc l *h ) F
    # keys = ''
    # '';
  };

  programs.man = {
    enable = true;
  };

  programs.neovim  = { # TODO: config
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

  programs.ssh  = { # TODO: config
    enable = true;
  };

  programs.zsh = {
    enable = true;
    history.path = "${config.xdg.dataHome}/zsh_history";
    history.extended = true;
    history.share = true;
    history.save = 1000000;
    history.size = 1000000;
    autosuggestion.enable = true;
    autosuggestion.strategy = [ "history" "completion" ];
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

    dotDir = ".config/zsh";
    # TODO: remove bad defaults and migrate config
    initExtra = ''
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-char vi-forward-char)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100

# Options
export PROMPT=$'\n%F{red}%n@%m%f %F{blue}%T %~%f %F{red}%(?..%?)%f\n>%f '
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'
setopt auto_pushd pushd_silent
setopt prompt_subst notify
setopt complete_in_word glob_complete

# Aliases
alias p="python3"
alias c="cargo"
alias g="git"
alias ls="eza -hs=name --group-directories-first"
alias ll="ls -la"
alias lt="ll -T"
alias d="dirs -v"
alias sudo="sudo --preserve-env "
alias ip="ip --color"
alias cat="bat --paging=never"
alias less="bat --paging=always"
alias grep="rg"
alias z="exec zsh"
alias v="nvim"
for i ({1..9}) alias "$i"="cd +$i"

# Primary keybindings
bindkey -e
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[3~" delete-char

# External editor
autoload edit-command-line
zle -N edit-command-line
bindkey "^V" edit-command-line

# Beam cursor
zle -N zle-line-init
zle-line-init() { echo -ne "\e[6 q" }

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for k in "^[p" "^[OA" "^[[A"; bindkey "$k" up-line-or-beginning-search
for k in "^[n" "^[OB" "^[[B"; bindkey "$k" down-line-or-beginning-search

# Completion
zmodload zsh/complist
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zcompdump" $([[ -n "$XDG_CACHE_HOME/zcompdump"(#qN.mh+24) ]] && echo -C)
_comp_options+=(globdots)
#autoload -U bashcompinit && bashcompinit
zstyle ":completion:*" menu select
zstyle ":completion:*" complete-options true
zstyle ":completion:*" completer _complete _match _approximate
zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|=* r:|=*"
zstyle ":completion:*" list-suffixes
zstyle ":completion:*" expand prefix suffix 
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zcompcache"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" list-colors "$${(s.:.)LS_COLORS}"
zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
zstyle ":completion:*:messages" format " %F{purple} -- %d --%f"
zstyle ":completion:*:warnings" format " %F{red}-- no matches found --%f"
bindkey "^[[Z" reverse-menu-complete

# Word delimiters
autoload -U select-word-style
select-word-style bash

# Pager
export LESS_TERMCAP_mb="$(tput setaf 2; tput blink)"
export LESS_TERMCAP_md="$(tput setaf 0; tput bold)"
export LESS_TERMCAP_me="$(tput sgr0)"
export LESS_TERMCAP_so="$(tput setaf 3; tput smul; tput bold)"
export LESS_TERMCAP_se="$(tput sgr0)"
export LESS_TERMCAP_us="$(tput setaf 4; tput smul)"
export LESS_TERMCAP_ue="$(tput sgr0)"
#export LESS="--ignore-case --tabs=4 --chop-long-lines --LONG-PROMPT --RAW-CONTROL-CHARS --lesskey-file=$XDG_CONFIG_HOME/less/key"
#command less --help | grep -q -- --incsearch && export LESS="--incsearch $LESS"

# GPG+SSH
hash gpgconf 2>/dev/null && {
	export GPG_TTY="$(tty)"
	export SSH_AGENT_PID=""
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	(gpgconf --launch gpg-agent &)
}

# TODO: all of this can likely be moved

# Arista Shell
export ARZSH_COMP_UNSAFE=1
ash() { eval 2>/dev/null mosh -a -o --experimental-remote-ip=remote us260 -- tmux new $${@:+-c -- a4c shell $@} }
_ash() { compadd "$(ssh us260 -- a4c ps -N)" }
compdef _ash ash

# File sharing
0x0() { curl -F"file=@$1" https://0x0.st }

# cht.sh
cht() { cht.sh "$@?style=paraiso-dark" | less }
_cht() { compadd $commands:t }
compdef _cht cht

# TODO: explainshell.com

# del
alias rm="2>&1 echo rm disabled, use del; return 1 #"

# delta
diff() { command diff -u $@ | delta }

# lf
lf() {
	f="$XDG_CACHE_HOME/lfcd"
	command lf -last-dir-path "$f" $@
	[ -f "$f" ] && { cd "$(cat $f)"; command rm -f "$f"; }
}




# Start desktop environment
# TODO
#[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && hash sway 2>/dev/null && {
#	sway
#}
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
    };
  };

  programs.fzf = {
    enable = true;
    colors = { "fg" = "bold"; "pointer" = "red"; "hl" = "red"; "hl+" = "red"; "gutter" = "-1"; "marker" = "red"; };
    defaultCommand = "rg --files --no-messages";
    defaultOptions = [ "--multi" "--bind='ctrl-n:down,ctrl-p:up,up:previous-history,down:next-history,ctrl-j:accept,ctrl-k:toggle,alt-a:toggle-all,ctrl-/:toggle-preview'" "--preview-window sharp" "--marker=k" "--color=$FZF_COLORS" "--history $XDG_DATA_HOME/fzf_history" ];
    changeDirWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules' --type d";
    fileWidgetCommand = "fd --hidden --exclude '.git' --exclude 'node_modules'";
  };

  # TODO: programs.lf/nnn/yazi
  # TODO: programs: feh and mpv
  # TODO: programs.tmux
  # TODO(now): services.mako/swaync
  # TODO(now): services.flameshot or something else
  # TODO: services.gromit-mpx or something else
  # TODO: service.swayidle
  # TODO(now): service.syncthing
  # TODO(now): programs.eww/waybar/yambar or services.polybar/taffybar

  # TODO: services.gpg-agent?
  # TODO: services.ssh-agent?
  # TODO: direnv? keychain? newsboat? obs-studio?

  # TODO(later): programs.beets

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

  services.cliphist.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    #package = nixGL pkgs.sway; # TODO: wrap sway with nixGL here instead of in shell?
    systemd.enable = true;
    extraOptions = [ "--unsupported-gpu" ];
    config = { # TODO: remove default and migrate config
      modifier = "Mod4";
      keybindings = {};
      startup = [];
      modes = {};
      menu = "bemenu-run";
      terminal = "alacritty";
      # TODO: just wrong
      # colors.focused           = { background = "#202020"; border = "#ffffff"; childBorder = "#000000"; indicator = "#ff0000"; text = "#ffffff"; };
      # colors.focusedInactive  = { background = "#202020"; border = "#202020"; childBorder = "#ffffff"; indicator = "#202020"; text = "#202020"; };
      # # colors.focused_tab_title = { background = "#202020"; border = "#ffffff"; childBoarder = "#000000"; };
      # colors.unfocused         = { background = "#202020"; border = "#202020"; childBorder = "#808080"; indicator = "#202020"; text = "#202020"; };
    };


    extraConfig = ''

# TODO: replace with powerctl
bindsym Mod4+Shift+c reload
bindsym Mod4+Shift+e exit

# TODO: still needed?
#exec_always pidof wl-paste || wl-paste --watch cliphist store

# Common functions
set $get_views vs=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | select(.visible).id")
set $get_focused f=$(swaymsg -rt get_tree | jq "recurse(.nodes[], .floating_nodes[]) | first(select(.focused)).id")
set $get_output o=$(swaymsg -rt get_outputs | jq -r ".[] | first(select(.focused).name)")
set $get_workspaces ws=$(swaymsg -rt get_workspaces | jq -r ".[].num")
set $get_prev_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) - 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
set $get_next_workspace w=$(( $( swaymsg -t get_workspaces | jq -r ".[] | first(select(.focused).num)" ) + 1 )) && w=$(( $w < 1 ? 1 : ($w < 9 ? $w : 9) ))
# TODO: always skips 1
set $get_empty_workspace w=$(swaymsg -rt get_workspaces | jq ". as \$w | first(range(1; 9) | select(all(. != \$w[].num; .)))")
set $group swaymsg "mark --add g" || swaymsg "splitv, mark --add g"
set $ungroup swaymsg "[con_mark=g] focus, unmark g" || swaymsg "focus parent; focus parent; focus parent; focus parent"

# Appearance
output * bg #101010 solid_color
default_border pixel 2
default_floating_border pixel 2
for_window [class=".*"]  border pixel 2
for_window [app_id=".*"] border pixel 2
for_window [app_id="floating.*"] floating enable
client.focused           #202020 #ffffff #000000 #ff0000 #ffffff
client.focused_inactive  #202020 #202020 #ffffff #202020 #202020
client.focused_tab_title #202020 #ffffff #000000
client.unfocused         #202020 #202020 #808080 #202020 #202020
# TODO
# font terminus 12

# Startup scripts and daemons
# TODO
# Notifications
#exec_always pidof mako || mako
# Battery warning notifications
# TODO
#exec_always pidof -x batteryd || batteryd
# Idle locking + suspending
# TODO
#exec_always powerctl uncaffeinate
# Output setup
# TODO
# TODO: focus for every monitor 
#exec_always displayctl auto
exec $get_output && swaymsg "workspace 1:$o"
# Bars
# TODO
# TODO: multimonitor bars
#bar {
#	swaybar_command waybar
#	mode hide
#}

# Input devices
input type:keyboard {
	xkb_layout ie
	xkb_options caps:escape
	repeat_delay 250
	repeat_rate 30
}
input type:touchpad {
	dwt disabled
	tap enabled
	natural_scroll enabled
	click_method clickfinger
	scroll_method two_finger
}

# Mouse
floating_modifier Mod4 normal
focus_follows_mouse no
mouse_warping output

# Program shortcuts
bindsym Mod4+space                   exec bemenu-run
bindsym Mod4+Return                  exec $TERMINAL
bindsym Mod4+t                       exec $TERMINAL
bindsym Mod4+w                       exec $BROWSER
bindsym Mod4+d                       exec $BROWSER "https://discord.com/app"
# TODO
#bindsym Mod4+Escape                  exec powerctl
#bindsym --locked Mod4+Shift+Escape   exec powerctl lock
#bindsym --locked Mod4+Control+Escape exec powerctl suspend
#bindsym Mod4+Control+Shift+Escape    exec powerctl reload
# TODO
#bindsym Mod4+backslash               exec displayctl
#bindsym Mod4+Shift+backslash         exec displayctl mono
#bindsym Mod4+Control+backslash       exec displayctl duel
# TODO
#bindsym Mod4+n                       exec networkctl
#bindsym Mod4+Shift+n                 exec networkctl wifi
#bindsym Mod4+Control+n               exec networkctl bluetooth
# TODO
# TODO: persistent floating btop
#bindsym Mod4+u                       exec $TERMINAL --class floating-btop --command btop
# TODO
#bindsym Mod4+Shift+u                 exec $TERMINAL --class floating --command sudo pacman -Syu
# TODO
# bindsym Mod4+Control+u                       exec swaymsg '[class="floating-btop"] scratchpad show'
# TODO: bemenu bitwarden
bindsym Mod4+b                       border pixel 2
bindsym Mod4+shift+b                 border none
# TODO
#bindsym Mod4+v                       exec CH_PROMPT="Clipboard" choose "$(cliphist list)" | cliphist decode | wl-copy
# TODO
#bindsym Mod4+grave                   exec makoctl dismiss
#bindsym Mod4+Shift+grave             exec makoctl restore
#bindsym Mod4+Control+grave           exec makoctl menu wofi --dmenu --prompt "Action"

# Windows
focus_wrapping no
bindsym Mod4+h focus left
bindsym Mod4+j focus down
bindsym Mod4+k focus up
bindsym Mod4+l focus right
bindsym Mod4+Shift+h exec $group && swaymsg "move left  50px" && $ungroup
bindsym Mod4+Shift+j exec $group && swaymsg "move down  50px" && $ungroup
bindsym Mod4+Shift+k exec $group && swaymsg "move up    50px" && $ungroup
bindsym Mod4+Shift+l exec $group && swaymsg "move right 50px" && $ungroup
bindsym Mod4+Control+h resize shrink width 50px
bindsym Mod4+Control+j resize grow height 50px
bindsym Mod4+Control+k resize shrink height 50px
bindsym Mod4+Control+l resize grow width 50px
# TODO: doesnt work if nothing is focused
bindsym Mod4+Tab       exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | cat | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"
bindsym Mod4+Shift+Tab exec $get_views && $get_focused && n=$(printf "$vs\n$vs\n" | tac | awk "/$f/{getline; print; exit}") && swaymsg "[con_id=$n] focus"
bindsym Mod4+f focus mode_toggle
bindsym Mod4+Shift+f border pixel 2, floating toggle
bindsym Mod4+x sticky toggle
bindsym Mod4+m fullscreen
bindsym Mod4+q kill

# Workspaces
bindsym Mod4+1 exec $get_output && swaymsg "workspace 1:$o"
bindsym Mod4+2 exec $get_output && swaymsg "workspace 2:$o"
bindsym Mod4+3 exec $get_output && swaymsg "workspace 3:$o"
bindsym Mod4+4 exec $get_output && swaymsg "workspace 4:$o"
bindsym Mod4+5 exec $get_output && swaymsg "workspace 5:$o"
bindsym Mod4+6 exec $get_output && swaymsg "workspace 6:$o"
bindsym Mod4+7 exec $get_output && swaymsg "workspace 7:$o"
bindsym Mod4+8 exec $get_output && swaymsg "workspace 8:$o"
bindsym Mod4+9 exec $get_output && swaymsg "workspace 9:$o"
bindsym Mod4+Shift+1 exec $group && $get_output && swaymsg "move container workspace 1:$o, workspace 1:$o" && $ungroup
bindsym Mod4+Shift+2 exec $group && $get_output && swaymsg "move container workspace 2:$o, workspace 2:$o" && $ungroup
bindsym Mod4+Shift+3 exec $group && $get_output && swaymsg "move container workspace 3:$o, workspace 3:$o" && $ungroup
bindsym Mod4+Shift+4 exec $group && $get_output && swaymsg "move container workspace 4:$o, workspace 4:$o" && $ungroup
bindsym Mod4+Shift+5 exec $group && $get_output && swaymsg "move container workspace 5:$o, workspace 5:$o" && $ungroup
bindsym Mod4+Shift+6 exec $group && $get_output && swaymsg "move container workspace 6:$o, workspace 6:$o" && $ungroup
bindsym Mod4+Shift+7 exec $group && $get_output && swaymsg "move container workspace 7:$o, workspace 7:$o" && $ungroup
bindsym Mod4+Shift+8 exec $group && $get_output && swaymsg "move container workspace 8:$o, workspace 8:$o" && $ungroup
bindsym Mod4+Shift+9 exec $group && $get_output && swaymsg "move container workspace 9:$o, workspace 9:$o" && $ungroup
bindsym Mod4+Control+1 exec $get_output && swaymsg "move container workspace 1:$o"
bindsym Mod4+Control+2 exec $get_output && swaymsg "move container workspace 2:$o"
bindsym Mod4+Control+3 exec $get_output && swaymsg "move container workspace 3:$o"
bindsym Mod4+Control+4 exec $get_output && swaymsg "move container workspace 4:$o"
bindsym Mod4+Control+5 exec $get_output && swaymsg "move container workspace 5:$o"
bindsym Mod4+Control+6 exec $get_output && swaymsg "move container workspace 6:$o"
bindsym Mod4+Control+7 exec $get_output && swaymsg "move container workspace 7:$o"
bindsym Mod4+Control+8 exec $get_output && swaymsg "move container workspace 8:$o"
bindsym Mod4+Control+9 exec $get_output && swaymsg "move container workspace 9:$o"
bindsym Mod4+Comma                exec $get_output && $get_prev_workspace && swaymsg "workspace $w:$o"
bindsym Mod4+Period               exec $get_output && $get_next_workspace && swaymsg "workspace $w:$o"
bindsym Mod4+Shift+Comma          exec $group && $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup
bindsym Mod4+Shift+Period         exec $group && $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $ungroup
bindsym Mod4+Control+Comma        exec $get_output && $get_prev_workspace && swaymsg "move container workspace $w:$o"
bindsym Mod4+Control+Period       exec $get_output && $get_next_workspace && swaymsg "move container workspace $w:$o"
bindsym Mod4+Control+Shift+Comma  exec '$get_output && $get_workspaces && ws=$(echo "$ws" | cat) && [ "$(echo "$ws" | head -1)" != "1" ] && for w in $ws; do i=$(( $w - 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done'
bindsym Mod4+Control+Shift+Period exec '$get_output && $get_workspaces && ws=$(echo "$ws" | tac) && [ "$(echo "$ws" | head -1)" != "9" ] && for w in $ws; do i=$(( $w + 1 )); swaymsg "rename workspace $w:$o to $i:$o"; done'
bindsym Mod4+z               exec $get_output && $get_empty_workspace && swaymsg "workspace $w:$o"
bindsym Mod4+Shift+z         exec $group && $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o, workspace $w:$o" && $foucs_group
bindsym Mod4+Control+z       exec '$group && $get_output && $get_empty_workspace && swaymsg "move container workspace $w:$o" && $foucs_group'
bindsym Mod4+Control+Shift+z exec '$group && $get_output && $get_workspaces && i=1; for w in $ws; do swaymsg rename workspace $w:$o to $i:$o; i=$(( $i + 1 )); done && $foucs_group'

# Outputs
bindsym Mod4+equal         exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.1)"')
bindsym Mod4+minus         exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.1)"')
bindsym Mod4+Shift+equal   exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale * 1.5)"')
bindsym Mod4+Shift+minus   exec $get_output && swaymsg output $(swaymsg -rt get_outputs | jq -r '.[] | select(.name == "'$o'") | "\(.name) scale \(.scale / 1.5)"')
bindsym Mod4+Control+equal exec $get_output && swaymsg output "$o" scale 1
bindsym Mod4+Control+minus exec $get_output && swaymsg output "$o" scale 2

# Layout
default_orientation auto
bindsym Mod4+g       focus parent
bindsym Mod4+Shift+g focus child
bindsym Mod4+p       split vertical
bindsym Mod4+Shift+p split none
bindsym Mod4+o       layout toggle splitv splith
bindsym Mod4+Shift+o layout toggle split tabbed

# Scratchpads
bindsym Mod4+0 scratchpad show
bindsym Mod4+Shift+0 move scratchpad

# Media
# TODO
#bindsym --locked XF86AudioPlay         exec playerctl play-pause
#bindsym --locked Shift+XF86AudioPlay   exec playerctl pause
#bindsym --locked Control+XF86AudioPlay exec playerctl stop
#bindsym --locked XF86AudioPrev         exec playerctl position 1-
#bindsym --locked Shift+XF86AudioPrev   exec playerctl position 10-
#bindsym --locked Control+XF86AudioPrev exec playerctl previous
#bindsym --locked XF86AudioNext         exec playerctl position 1+
#bindsym --locked Shift+XF86AudioNext   exec playerctl position 10+
#bindsym --locked Control+XF86AudioNext exec playerctl next

# Volume
# TODO
#set $send_volume_notif wpctl get-volume @DEFAULT_SINK@ | (read _ v m && v=$(printf "%.0f" $(echo "100*$v" | bc)) && notify-send --category osd --hint "int:value:$v" "Volume: $v% $m")
#bindsym --locked XF86AudioMute                      exec wpctl set-mute   @DEFAULT_SINK@ toggle && $send_volume_notif
#bindsym --locked Shift+XF86AudioMute                exec                                           $send_volume_notif
#bindsym --locked Control+XF86AudioMute              exec wpctl set-mute   @DEFAULT_SINK@ 1      && $send_volume_notif
#bindsym --locked XF86AudioLowerVolume               exec wpctl set-volume @DEFAULT_SINK@ 1%-    && $send_volume_notif
#bindsym --locked Shift+XF86AudioLowerVolume         exec wpctl set-volume @DEFAULT_SINK@ 10%-   && $send_volume_notif
#bindsym --locked Control+XF86AudioLowerVolume       exec wpctl set-volume @DEFAULT_SINK@ 0%     && $send_volume_notif
#bindsym --locked XF86AudioRaiseVolume               exec wpctl set-volume @DEFAULT_SINK@ 1%+    && $send_volume_notif
#bindsym --locked Shift+XF86AudioRaiseVolume         exec wpctl set-volume @DEFAULT_SINK@ 10%+   && $send_volume_notif
#bindsym --locked Control+XF86AudioRaiseVolume       exec wpctl set-volume @DEFAULT_SINK@ 100%   && $send_volume_notif

# Microphone
# TODO
#bindsym --locked --no-repeat                Pause   exec wpctl set-mute @DEFAULT_SOURCE@ 0
#bindsym --locked --no-repeat --release      Pause   exec wpctl set-mute @DEFAULT_SOURCE@ 1
#bindsym --locked --no-repeat --whole-window button8 exec wpctl set-mute @DEFAULT_SOURCE@ toggle

# Backlight
# TODO
#set $send_brightness_notif b=$(printf "%.0f" "$(light -G)") && notify-send --category osd --hint "int:value:$b" "Brightness: $b%"
#bindsym --locked XF86MonBrightnessDown               exec light -U 1   && $send_brightness_notif
#bindsym --locked Shift+XF86MonBrightnessDown         exec light -U 10  && $send_brightness_notif
#bindsym --locked Control+XF86MonBrightnessDown       exec light -S 0   && $send_brightness_notif
#bindsym --locked XF86MonBrightnessUp                 exec light -A 1   && $send_brightness_notif
#bindsym --locked Shift+XF86MonBrightnessUp           exec light -A 10  && $send_brightness_notif
#bindsym --locked Control+XF86MonBrightnessUp         exec light -S 100 && $send_brightness_notif

# Screenshots
# TODO
# TODO: handle multimonitor
#bindsym Print       exec flameshot gui --raw | wl-copy --type image/png
#bindsym Shift+Print exec flameshot gui --raw --accept-on-select | wl-copy --type image/png
    '';
  };

  xdg.enable = true;
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
  xdg.portal = { # TODO
    #enable = true;
    xdgOpenUsePortal = true;
  };
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };

  # TODO: fonts
  fonts.fontconfig.enable = true;
  #fonts.fontconfig.defaultFonts.monospace = [];
  #fonts.fontconfig.defaultFonts.sansSerif = [];
  #fonts.fontconfig.defaultFonts.serif = [];
  #fonts.fontconfig.defaultFonts.emoji = [];
  
  gtk.enable = true;
  gtk.iconTheme.package = pkgs.kdePackages.breeze-icons;
  gtk.iconTheme.name = "breeze-dark";
  gtk.theme.package = pkgs.materia-theme;
  gtk.theme.name = "Materia-dark";

  nix.package = pkgs.nix;  
  nix.settings.auto-optimise-store = true;
  nix.settings.use-xdg-base-directories = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.overlays = [];
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux.enable = true;
}
