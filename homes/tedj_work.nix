{ pkgs, config, ... }: {

  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./pkgs/0x0.nix
    ./pkgs/acpi.nix
    ./pkgs/alacritty.nix
    ./pkgs/ash.nix
    ./pkgs/asl.nix
    ./pkgs/avpn.nix
    ./pkgs/awk.nix
    ./pkgs/bash.nix
    ./pkgs/bat.nix
    ./pkgs/batteryd.nix
    ./pkgs/bemenu.nix
    ./pkgs/bitwarden-cli.nix
    ./pkgs/bmbwd.nix
    ./pkgs/brightnessctl.nix
    ./pkgs/btop.nix
    ./pkgs/chrome.nix
    ./pkgs/cht.nix
    ./pkgs/cliphist.nix
    ./pkgs/coreutils.nix
    ./pkgs/curl.nix
    ./pkgs/del.nix
    ./pkgs/diff.nix
    ./pkgs/displayctl.nix
    ./pkgs/eza.nix
    ./pkgs/fastfetch.nix
    ./pkgs/fd.nix
    ./pkgs/file.nix
    ./pkgs/find.nix
    ./pkgs/firefox.nix
    ./pkgs/fontconfig.nix
    ./pkgs/fzf.nix
    ./pkgs/git.nix
    ./pkgs/gpg-agent.nix
    ./pkgs/gpg.nix
    ./pkgs/grim.nix
    ./pkgs/gtk.nix
    ./pkgs/imv.nix
    ./pkgs/jq.nix
    ./pkgs/less.nix
    ./pkgs/libnotify.nix
    ./pkgs/mako.nix
    ./pkgs/man.nix
    ./pkgs/mosh.nix
    ./pkgs/mpv.nix
    ./pkgs/neovim.nix
    ./pkgs/networkctl.nix
    ./pkgs/nixgl.nix
    ./pkgs/openconnect.nix
    ./pkgs/ouch.nix
    ./pkgs/playerctl.nix
    ./pkgs/powerctl.nix
    ./pkgs/procps.nix
    ./pkgs/pulsemixer.nix
    ./pkgs/python3.nix
    ./pkgs/ragenix.nix
    ./pkgs/rg.nix
    ./pkgs/sed.nix
    ./pkgs/slurp.nix
    ./pkgs/ssh.nix
    ./pkgs/sway.nix
    ./pkgs/swaylock.nix
    ./pkgs/syncthing.nix
    ./pkgs/waybar.nix
    ./pkgs/wl-clipboard.nix
    ./pkgs/xdg.nix
    ./pkgs/yazi.nix
    ./pkgs/zsh.nix
  ];

  # autostart zsh
  programs.bash.initExtra = ''[[ $- == *i* ]] && { shopt -q login_shell && exec zsh --login $@ || exec zsh $@; }'';

  # autostart sway with hardware rendering
  # TODO(later): wrap with wayland.windowManager.sway.package
  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';

  # fuck you nvidia
  wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];

  # .hushlogin
  home.file.".hushlogin".text = "";

  # slock must be installed on system for PAM integration
  programs.swaylock.package = pkgs.runCommandWith { name = "swaylock-dummy"; } "mkdir $out";

  # homebus ssh configuration
  programs.ssh.matchBlocks."bus".host = "bus-* tedj-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions.StrictHostKeyChecking = "false";
  programs.ssh.matchBlocks."bus".extraOptions.UserKnownHostsFile = "/dev/null";
  programs.ssh.matchBlocks."bus".extraOptions.RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.247.176.6";
  programs.ssh.matchBlocks."bus-home".port = 22251;

  # secrets
  home.sessionVariables.AGENIX_KEY = "/home/tedj/.ssh/tedj@work.agenix.key";
  age.identityPaths = [ "/home/tedj/.ssh/tedj@work.agenix.key" ];
  age.secrets."ski@h8c.de.gpg"           = { file = ../secrets/ski_h8c.de/subkey.age; };
  age.secrets."tedj@arista.com.cer"      = { file = ../secrets/arista/work_cer.age; };
  age.secrets."tedj@arista.com.crt"      = { file = ../secrets/arista/work_crt.age; };
  age.secrets."tedj@arista.com.csr"      = { file = ../secrets/arista/work_csr.age; };
  age.secrets."tedj@arista.com.pem"      = { file = ../secrets/arista/work_pem.age; };
  age.secrets."mailfilters.xml"          = { file = ../secrets/arista/mailfilters.age; };
  age.secrets."syncthing/config.xml"     = { file = ../secrets/syncthing/tedj_work/config.xml.age;     path = "${config.xdg.configHome}/syncthing/config.xml";     };
  age.secrets."syncthing/cert.pem"       = { file = ../secrets/syncthing/tedj_work/cert.pem.age;       path = "${config.xdg.configHome}/syncthing/cert.pem";       };
  age.secrets."syncthing/key.pem"        = { file = ../secrets/syncthing/tedj_work/key.pem.age;        path = "${config.xdg.configHome}/syncthing/key.pem";        };
  age.secrets."syncthing/https_cert.pem" = { file = ../secrets/syncthing/tedj_work/https-cert.pem.age; path = "${config.xdg.configHome}/syncthing/https-cert.pem"; };
  age.secrets."syncthing/https_key.pem"  = { file = ../secrets/syncthing/tedj_work/https-key.pem.age;  path = "${config.xdg.configHome}/syncthing/https-key.pem";  };

  # firefox profile
  programs.firefox.profiles.work.id = 0;
  programs.firefox.profiles.work.name = "Work";
  programs.firefox.profiles.work.isDefault = true;
  programs.firefox.profiles.work.userContent = ''
    @-moz-document url-prefix("https://bb.infra.corp.arista.io/") {
      .app-content { justify-content: center; }
      .bug-page-wrapper { max-width: 1200px; }
    }
  '';
  # TODO(later): separate firefox syncs for home and work instead: https://github.com/mozilla-services/syncstorage-rs
  programs.firefox.profiles.work = {
    search.default = "DuckDuckGo";
    search.privateDefault = "DuckDuckGo";
    search.force = true;
    search.engines."aid".urls = [{template = "https://aid.infra.corp.arista.io/{searchTerms}";}];
    search.engines."aid".definedAliases = ["a" "aid"];
    search.engines."go".urls = [{template = "https://go.infra.corp.arista.io/{searchTerms}";}];
    search.engines."go".definedAliases = ["g" "go"];
    search.engines."bb".urls = [{template = "https://bb.infra.corp.arista.io/bug/{searchTerms}";}];
    search.engines."bb".definedAliases = ["b" "bb" "bug"];
    search.engines."cl".urls = [{template = "https://change.infra.corp.arista.io/{searchTerms}";}];
    search.engines."cl".definedAliases = ["c" "cl" "change"];
    search.engines."Wikipedia (en)".metaData.alias = "@wiki";
    search.engines."Amazon.com".metaData.hidden = true;
    search.engines."Bing".metaData.hidden = true;
    search.engines."eBay".metaData.hidden = true;
    settings = {
      "accessibility.typeaheadfind.flashBar" = 0;
      "app.shield.optoutstudies.enabled" = false;
      "browser.aboutConfig.showWarning" = false;
      "browser.bookmarks.addedImportButton" = true;
      "browser.bookmarks.restore_default_bookmarks" = false;
      "browser.bookmarks.showMobileBookmarks" = true;
      "browser.contentblocking.category" = "strict";
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      "browser.disableResetPrompt" = true;
      "browser.discovery.enabled" = false;
      "browser.download.always_ask_before_handling_new_types" = true;
      "browser.download.panel.shown" = true;
      "browser.download.useDownloadDir" = false;
      "browser.feeds.showFirstRunUI" = false;
      "browser.messaging-system.whatsNewPanel.enabled" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.ping-centre.telemetry" = false;
      "browser.rights.3.shown" = true;
      "browser.search.isUS" = false;
      "browser.search.region" = "GB";
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.defaultBrowserCheckCount" = 1;
      "browser.startup.homepage_override.mstone" = "ignore";
      "browser.tabs.inTitlebar" = 1;
      "browser.tabs.warnOnClose" = true;
      "browser.toolbars.bookmarks.visibility" = "always";
      "browser.uiCustomization.state" =  builtins.toJSON {
        currentVersion = 20;
        dirtyAreaCache = [ "nav-bar" "PersonalToolbar" "toolbar-menubar" "TabsToolbar" "widget-overflow-fixed-list"];
        newElementCount = 4;
        placements = {
          PersonalToolbar = [ "personal-bookmarks" ];
          TabsToolbar =  [ "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
          nav-bar = [ "back-button" "forward-button" "stop-reload-button" "urlbar-container" "downloads-button" "unified-extensions-button"];
          toolbar-menubar = [ "menubar-items" ];
          unified-extensions-area = [];
          widget-overflow-fixed-list = [];
        };
        seen = [ "save-to-pocket-button" "developer-button" ];
      };
      "browser.uitour.enabled" = false;
      "browser.urlbar.quicksuggest.scenario" = "history";
      "datareporting.healthreport.service.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.sessions.current.clean" = true;
      "devtools.onboarding.telemetry.logged" = false;
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
      "identity.fxaccounts.enabled" = false;
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
      "signon.rememberSignons" = false;
      "startup.homepage_override_url" = "";
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.hybridContent.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.prompted" = 2;
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.server" = "";
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.unifiedIsOptIn" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "trailhead.firstrun.didSeeAboutWelcome" = true;
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
              { name = "calendar"; url = "https://calendar.google.com/calendar/u/0/r?pli=1"; }
            ];
          }
          {
            name = "services";
            bookmarks = [
              { name = "aboard"; url = "https://aboard.infra.corp.arista.io/user/tedj/overview"; }
              { name = "dashboard"; url = "https://dashboard.infra.corp.arista.io/"; }
              { name = "bugsby"; url = "https://bb.infra.corp.arista.io/board/user/table/tedj"; }
              { name = "reviewboard"; url = "https://reviewboard.infra.corp.arista.io/dashboard/"; }
              { name = "gerrit"; url = "https://gitarband-gerrit.infra.corp.arista.io/dashboard/self"; }
              { name = "wdw"; url = "https://coda.io/d/WhoDoWhat_dSoB-58Lz69/WhoDoWhat_suECC#_luNIH"; }
              { name = "intranet"; url = "https://intranet.arista.com/"; }
              { name = "workday"; url = "https://wd5.myworkday.com/arista/d/home.htmld"; }
              { name = "portal"; url = "https://arista.onelogin.com/portal"; }
              { name = "laya"; url = "https://www.layahealthcare.ie/login/#/memberlogin/login"; }
              { name = "zurich"; url = "https://www.zurichlife.ie/bgsi/log_on/login.jsp"; }
              { name = "espp"; url = "https://us.etrade.com/etx/hw/v2/accountshome"; }
            ];
          }
          {
            name = "tools";
            bookmarks = [
              { name = "grok"; url = "https://opengrok.infra.corp.arista.io/source/?project=eos-trunk"; }
              { name = "ksrc"; url = "https://elixir.bootlin.com/linux/v4.19.241/source"; }
              { name = "eosdoc"; url = "https://eosdoc2.infra.corp.arista.io/#/"; }
              { name = "tacnav"; url = "https://tacnav.infra.corp.arista.io/tacnav"; }
              { name = "godbolt"; url = "https://code-explorer.infra.corp.arista.io/"; }
              { name = "grep.app"; url = "https://grep.app/"; }
              { name = "explainshell"; url = "https://explainshell.com/"; }
              { name = "shellcheck"; url = "https://www.shellcheck.net/"; }
              { name = "regex101"; url = "https://regex101.com/"; }
            ];
          }
          {
            name = "utils";
            bookmarks = [
              { name = "chatbot"; url = "https://said.infra.corp.arista.io/"; }
              { name = "discourse"; url = "https://discourse.arista.com/"; }
              { name = "yippy search"; url = "https://yippy.aristanetworks.com/search"; }
              { name = "google search"; url = "https://cloudsearch.google.com/cloudsearch"; }
              { name = "bug search"; url = "https://bugsearch.infra.corp.arista.io/"; }
              { name = "codenames"; url = "https://aboard.infra.corp.arista.io/skus"; }
              { name = "src"; url = "https://src.infra.corp.arista.io/"; }
              { name = "aid"; url = "https://aid.infra.corp.arista.io/1/"; }
              { name = "go"; url = "https://go.infra.corp.arista.io/admin/"; }
              { name = "pb"; url = "https://pb.infra.corp.arista.io/"; }
              { name = "map"; url = "https://intranet.arista.com/directory/floor-plan-map?location=Dublin2GD"; }
            ];
          }
          {
            name = "meets";
            bookmarks = [
              { name = "MON bricklayers"; url = "https://docs.google.com/document/d/12xqw_-eMyqJU3p16ErqKpq9UVGonoK4Bboz7bE-bK4c/preview"; }
              { name = "MON modmidmon"; url = "https://www.google.com/url?q=https://docs.google.com/document/d/155TiNb5G0tMefgKxgLGqpxPdbKaoGPgtrKJnOFLHThA/preview"; }
              { name = "WED euro pcie"; url = "https://docs.google.com/document/d/1u-zkMTatgeRljZDvX7HGA_ALB8xQ-y9kMDDlqPAIi_M/preview"; }
              { name = "WED pcie bugs"; url = "https://bb.infra.corp.arista.io/board/packagegroup/table/pcie"; }
              { name = "WED pcie escalations"; url = "https://docs.google.com/spreadsheets/d/1i39desgeboUYcrPdAW_1RQ2oBWUlz1tluQTjL6EeCOc/preview"; }
              { name = "THU dma+pic+plx maint"; url = "https://docs.google.com/document/d/1LIfn_-WS0485rVL6axiGGt2waY-Zrzl7DKf6Agg4xB8/preview"; }
              { name = "THU dma+pic+plx dashboard"; url = "https://dashboard.infra.corp.arista.io/autotests/bugs?type=autotest&package=dmamem%2Cdmamem-kmod%2CPicasso%2Cplx-pcie-drivers%2CPlxTests%2CmDmaTest"; }
              { name = "FRI r&d tracking"; url = "https://docs.google.com/spreadsheets/d/1l82reZVrIH3hbX99ExMyoZsTYb_ZLOObGM4i4US4Krg/edit?gid=377679536#gid=377679536"; }
            ];
          }
          {
            name = "docs";
            bookmarks = [
              { name = "links"; url = "https://docs.google.com/document/d/1EC3rGgvN1T90W-gXwgXl3XaiDUb7pD86QnqXxp1Yk1I/preview"; }
              { name = "how to software"; url = "https://docs.google.com/document/d/1xPFv1zf_Mw1JWXq5ZX5HvCyudTJOyn6XGnuQXOhCGAE/preview"; }
              { name = "how to maintenance"; url = "https://docs.google.com/document/d/1HioJSk5D7SzGl6KxOrSr4kSUVco1CoXr0BPBYcojKUM/preview"; }
              { name = "how to autotest"; url = "https://docs.google.com/document/d/1aomEVxOSAYZ-QsMIrpCY915qtH2RUDGTTTufgdNRUGo/preview"; }
              { name = "how to bug"; url = "https://docs.google.com/document/d/1A0p52ySWvKM50w-Tz0To7DEzdwNEwhzefUjV5F_ePho/preview"; }
              { name = "how to areview"; url = "https://docs.google.com/document/d/1-jm1mkHcS5PaFrn0M_FE6484FSGL5xuRguRhRZ2oavM/preview"; }
              { name = "platform prep talk"; url = "https://docs.google.com/presentation/d/1JZcl5UDe4DdgGMNMOwOR4dCLF-xSgq6eE7RbqNLUek0/preview"; }
              { name = "sand"; url = "https://docs.google.com/document/d/1yfP0Qc03wk-cp87hEGp9RWQiMy_s6nErBNou3cYDR24/preview"; }
              { name = "acronyms"; url = "https://docs.google.com/spreadsheets/d/1J_GKEgq9_6HKCRfdU0Wnz8RAwe8SRfYSPNPN-F8P9Rs/preview"; }
              { name = "releases"; url = "https://docs.google.com/spreadsheets/d/1UBmNOcXXV3s73qA_208TMEi5gN0mKsmB5dT70HxOUhw/preview"; }
              { name = "features"; url = "https://docs.google.com/spreadsheets/d/1HU0KOeneu1WqiL5jAiVuQbhBaHLoOMhPAnQc_Cp3VvY/preview"; }
              { name = "escape gaps"; url = "https://docs.google.com/spreadsheets/d/1IIH7rDyLKq_pqYEwTTFvhm6O41OraaC0pVBm9k4CYJA/preview"; }
              { name = "quality"; url = "https://aid.infra.corp.arista.io/17/"; }
              { name = "design doc"; url = "https://docs.google.com/document/d/1DpW0HvRSeuc-m5SD9DogDcypX7GHM18EKgOtbkIBeVo/preview"; }
              { name = "eos manual"; url = "https://www.arista.com/assets/data/pdf/user-manual/um-books/EOS-User-Manual.pdf"; }
              { name = "eos sdk wiki"; url = "https://github.com/aristanetworks/EosSdk/wiki"; }
              {
                name = "style";
                bookmarks = [
                  { name = "kernel"; url = "https://www.kernel.org/doc/html/v4.10/process/coding-style.html"; }
                  { name = "tac+c++"; url = "https://docs.google.com/document/d/1AJ034fuYllwuPqWSUtmW7L2L-f6z5qGXnj08Dwh3qXY/preview"; }
                  { name = "python"; url = "https://docs.google.com/document/d/1NPcZT4AXy0ajbrwa37jHwSYMJPWQK5WTWEp2VkWyYtY/preview"; }
                  { name = "cli"; url = "https://docs.google.com/document/d/1fTc5A8e3GtcqcPiyMs7qLZDmocyr8pJGbGitwhCw_CQ/preview"; }
                ];
              }
              {
                name = "tacc";
                bookmarks = [
                  { name = "index"; url = "https://docs.google.com/document/d/1wIcOuciQ8hoI4SOA55KZpb3lrqpDw8v7nTksfDUCsk8/preview"; }
                  { name = "faq"; url = "https://docs.google.com/document/d/1nToUB4wWoGaRkf33IRiPEut7XQZLDtHq1wtEOgOL79s/preview"; }
                  { name = "book"; url = "https://tacc-book.infra.corp.arista.io/"; }
                  { name = "python integration"; url = "https://aid.infra.corp.arista.io/38/"; }
                  { name = "data models and state apis"; url = "https://docs.google.com/presentation/d/1e-ezvJVAw17oB-GwrzNk-FyFOV_wBlGr1qX3fQ1tWr8/preview"; }
                  { name = "programming with tacc"; url = "https://docs.google.com/presentation/d/1te_vTh4KUkQQmDB52IMepSXmVLyFo40VVlAGKjlFMD8/preview"; }
                ];
              }
              {
                name = "tools";
                bookmarks = [
                  { name = "a4c cheatsheet"; url = "https://docs.google.com/document/d/1hcgEPuHaBTDKhndw91dvRBUAOX3asvi0C6rBTIL8mW8/preview"; }
                  {
                    name = "guitarband";
                    bookmarks = [
                      { name = "cheatsheet"; url = "https://docs.google.com/document/d/18TBf2NPWkaMvGw2tJB1m8CQ-kySnQsEmETMozooacUs/preview"; }
                      { name = "workflows"; url = "https://docs.google.com/document/d/1Cceyt3Wf9Xw4wxHNcid5-wsQqdRE6LW7saDkNRG6cVo/preview"; }
                      { name = "primer"; url = "https://docs.google.com/document/d/1K0rlhwC7YkPwaV45aarzt-H2v04qqMNV63Rkpdmo5Zw/preview"; }
                    ];
                  }
                  {
                    name = "autotest";
                    bookmarks = [
                      { name = "cheatshet"; url = "https://docs.google.com/document/d/1MnlpmtaE0WmQR17fRjHiN32xi0e9MYYl0odF-muKTNo/preview"; }
                      { name = "diagram"; url = "https://docs.google.com/drawings/d/1AbGCWFQFt835dnPHqE5tOQJYGQGLBM7EiHa5IbLQZXI/preview"; }
                    ];
                  }
                  {
                    name = "dashboard";
                    bookmarks = [
                      { name = "faq"; url = "https://docs.google.com/document/d/1EKclUZOgOnsUr4OLD6TSxQy7StYyBjTesUs8x-5xqKc/preview"; }
                      { name = "workflows"; url = "https://docs.google.com/document/d/1VWY8QxaekdnLHJ8eBPltRDPL9DT3c7iYQOGtakTuBB8/preview"; }
                    ];
                  }
                  { name = "qube"; url = "https://qube-doc.infra.corp.arista.io"; }
                  { name = "tracing"; url = "https://aid.infra.corp.arista.io/86/index.html"; }
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
              { name = "C++ Exceptions ACCU 24"; url = "https://www.youtube.com/watch?v=BGmzMuSDt-Y"; }
              { name = "Systems Approach"; url = "https://book.systemsapproach.org/preface.html#what-is-a-systems-approach"; }
            ];
          }
          {
            name = "next";
            bookmarks = [
              { name = "creating an agent"; url = "https://docs.google.com/document/d/1k6HmxdQTyhBuLCzNfoj6WDKhcfxxCw9VYt6LxvIymnA/preview"; }
              { name = "build system tut"; url = "https://docs.google.com/document/d/1jCgbJrvKmJypgGa-VPK_qvyn52_0JOWaGFA-dmz1Kjk/preview"; }
              { name = "packet proc"; url = "https://guide.infra.corp.arista.io/sand-101/pipeline-walkthrough/pp/"; }
              { name = "aboot talk"; url = "https://drive.google.com/file/d/1UmB9c0WTEO1GC6L22oS9Yxcb6qVYQlMG/view"; }
              { name = "dma"; url = "https://geidav.wordpress.com/2014/04/27/an-overview-of-direct-memory-access/"; }
              { name = "iommu"; url = "https://terenceli.github.io/%E6%8A%80%E6%9C%AF/2019/08/04/iommu-introduction"; }
            ];
          }
          { name = "jack nixfiles"; url = "https://gitlab.aristanetworks.com/jack/nixfiles/-/tree/arista/home-manager?ref_type=heads"; }
        ];
      }
    ];
  };

}
