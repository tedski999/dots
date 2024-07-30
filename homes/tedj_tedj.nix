{pkgs, lib, config, inputs, ...}:
let
  # TODO: inline with sway package
  nixGL = pkg: (pkg.overrideAttrs (old: {
    name = "nixGL-${pkg.name}";
    buildCommand = ''
      set -eo pipefail
      ${pkgs.lib.concatStringsSep "\n" (map (name: ''cp -rs --no-preserve=mode "${pkg.${name}}" "''$${name}"'') (old.outputs or [ "out" ]))}
      rm -rf $out/bin/*
      shopt -s nullglob
      for file in ${pkg.out}/bin/*; do
        echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
        echo "exec -a \"\$0\" nixGLIntel $file \"\$@\"" >> "$out/bin/$(basename $file)"
        chmod +x "$out/bin/$(basename $file)"
      done
      shopt -u nullglob
    '';
  }));
in {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  home.stateVersion = "23.05";
  home.preferXdgDirectories = true;
  home.keyboard.layout = "ie";
  home.keyboard.options = [ "caps:escape" ];
  # home.language / gtk / pointerCursor
  home.sessionVariables = {};
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/state/nix/profile/bin"
    "$HOME/.local/state/nix/profile/sbin"
  ];

  # imports = [];

  home.packages = with pkgs; [
    nix
    nixgl.nixGLIntel # TODO: nvidia?
    eza
  ];

  programs.home-manager = {
    enable = true;
  };

  programs.bat = { # TODO: config
    enable = true;
  };

  programs.gpg = { # TODO: config
    enable = true;
  };

  programs.git = { # TODO: config
    enable = true;
  };

  programs.fd = { # TODO: config
    enable = true;
  };

  programs.firefox = {
    enable = true;
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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ # TODO
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
                { name = "Wrap-Up - EvolutionOfEthernet.pdf"; url = "https://aid.infra.corp.arista.io/137/EvolutionOfEthernet.pdf"; }
                { name = "An overview of direct memory access | The Infinite Loop"; url = "https://geidav.wordpress.com/2014/04/27/an-overview-of-direct-memory-access/"; }
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
      settings = { # TODO
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        vimium
      ];
      bookmarks = [ # TODO
      ];
    };
  };

  programs.jq = { # TODO: config
    enable = true;
  };

  programs.kitty = { # TODO: config
    enable = true;
    #package = nixGL pkgs.kitty;
  };

  programs.less = { # TODO: config
    enable = true;
  };

  programs.man = { # TODO: config
    enable = true;
  };

  programs.neovim  = { # TODO: config
    enable = true;
  };

  programs.ripgrep = { # TODO: config
    enable = true;
  };

  programs.ssh  = { # TODO: config
    enable = true;
  };

  programs.zsh = { # TODO: config
    enable = true;
  };

  programs.bemenu = { # TODO:
    enable = true;
  };

  # TODO
  # programs: fzf/skim feh? direnv? beets keychain? lf/nnn/yazi mpv? newsboat? obs-studio? readline? swaylock? tmux? bemenu/yofi/tofi/wofi? vim? vscode? eww/waybar/yambar*?
  # services: cliphist/clipman dunst/mako flameshot? gpg-agent gromit-mpx? polybar/taffybar*? ssh-agent? swayidle swaync? swayosd? syncthing

  wayland.windowManager.sway = {
    enable = true;
    #package = nixGL pkgs.sway; # TODO
    extraOptions = [ "--unsupported-gpu" ];
    config.keybindings = lib.mkOptionDefault { # TODO: config
      "Mod4+Return" = "exec kitty";
      "Mod4+t" = "exec kitty";
      "Mod4+e" = "exit";
      "Mod4+d" = "exec gnome-terminal";
    };
  };

  xdg.enable = true;
  # TODO xdg.desktopEntries ?
  xdg.mime = { # TODO
    enable = true;
  };
  #xdg.portal = { # TODO
  #  enable = true;
  #  xdgOpenUsePortal = true;
  #};
  xdg.userDirs = { # TODO
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };

  # fonts.fontconfig.enable
  
  # gtk.enable

  # pam.sessionVariables

  nix.package = pkgs.nix;  
  nix.settings = {
    auto-optimise-store = true;
    use-xdg-base-directories = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
    };
  };

  targets.genericLinux.enable = true;
}
