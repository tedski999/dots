# chrome but better
# TODO(later): https://github.com/Misterio77/nix-config/blob/main/home/gabriel/features/desktop/common/firefox.nix
{ pkgs, ... }: {
  home.sessionVariables.BROWSER = "firefox";
  home.sessionVariables.MOZ_ENABLE_WAYLAND = 1;
  programs.firefox.enable = true;

  programs.firefox.profiles.work = {
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
              { name = "calender"; url = "https://calendar.google.com/calendar/u/0/r?pli=1"; }
            ];
          }
          {
            name = "services";
            bookmarks = [
              { name = "aboard"; url = "https://aboard.infra.corp.arista.io/user/tedj/overview"; }
              { name = "dashboard"; url = "https://dashboard.infra.corp.arista.io/"; }
              { name = "bugsby"; url = "https://bb.infra.corp.arista.io/board/user/table/tedj"; }
              { name = "reviewboard"; url = "https://reviewboard.infra.corp.arista.io/dashboard/"; }
              { name = "reviewboard"; url = "https://gerrit.corp.arista.io/dashboard/self"; }
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
              { name = "discourse"; url = "https://discourse.arista.com/"; }
              { name = "yippy search"; url = "https://yippy.aristanetworks.com/search"; }
              { name = "google search"; url = "https://cloudsearch.google.com/cloudsearch"; }
              { name = "bug search"; url = "https://bugsearch.infra.corp.arista.io/"; }
              { name = "codenames"; url = "https://aboard.infra.corp.arista.io/skus"; }
              { name = "src"; url = "https://src.infra.corp.arista.io/"; }
              { name = "aid"; url = "https://aid.infra.corp.arista.io/1/"; }
              { name = "go"; url = "https://go.infra.corp.arista.io/admin/"; }
              { name = "map"; url = "https://intranet.arista.com/directory/floor-plan-map?location=Dublin2GD"; }
            ];
          }
          {
            name = "meets";
            bookmarks = [
              { name = "pcie bugs"; url = "https://bb.infra.corp.arista.io/board/packagegroup/table/pcie"; }
              { name = "pcie escalations"; url = "https://docs.google.com/spreadsheets/d/1i39desgeboUYcrPdAW_1RQ2oBWUlz1tluQTjL6EeCOc/preview"; }
              { name = "pcie eu meet"; url = "https://docs.google.com/document/d/1u-zkMTatgeRljZDvX7HGA_ALB8xQ-y9kMDDlqPAIi_M/preview"; }
              { name = "bricklayers meet"; url = " https://docs.google.com/document/d/12xqw_-eMyqJU3p16ErqKpq9UVGonoK4Bboz7bE-bK4c/preview"; }
              { name = "dmamem+picasso meet"; url = "https://docs.google.com/document/d/1LIfn_-WS0485rVL6axiGGt2waY-Zrzl7DKf6Agg4xB8/preview"; }
            ];
          }
          {
            name = "docs";
            bookmarks = [
              { name = "links"; url = "https://docs.google.com/document/d/1EC3rGgvN1T90W-gXwgXl3XaiDUb7pD86QnqXxp1Yk1I/preview"; }
              { name = "how to software"; url = "https://docs.google.com/document/d/1xPFv1zf_Mw1JWXq5ZX5HvCyudTJOyn6XGnuQXOhCGAE/preview"; }
              { name = "how to maintenance"; url = "https://docs.google.com/document/d/1HioJSk5D7SzGl6KxOrSr4kSUVco1CoXr0BPBYcojKUM/preview"; }
              { name = "sand"; url = "https://docs.google.com/document/d/1yfP0Qc03wk-cp87hEGp9RWQiMy_s6nErBNou3cYDR24/preview"; }
              { name = "areview"; url = "https://docs.google.com/document/d/1-jm1mkHcS5PaFrn0M_FE6484FSGL5xuRguRhRZ2oavM/preview"; }
              { name = "acronyms"; url = "https://docs.google.com/spreadsheets/d/1J_GKEgq9_6HKCRfdU0Wnz8RAwe8SRfYSPNPN-F8P9Rs/preview"; }
              { name = "releases"; url = "https://docs.google.com/spreadsheets/d/1UBmNOcXXV3s73qA_208TMEi5gN0mKsmB5dT70HxOUhw/preview"; }
              { name = "features"; url = "https://docs.google.com/spreadsheets/d/1HU0KOeneu1WqiL5jAiVuQbhBaHLoOMhPAnQc_Cp3VvY/preview#gid=1532911302"; }
              { name = "escape gaps"; url = "https://docs.google.com/spreadsheets/d/1IIH7rDyLKq_pqYEwTTFvhm6O41OraaC0pVBm9k4CYJA/preview?gid=1672554111#gid=118303530"; }
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
              { name = "An overview of direct memory access"; url = "https://geidav.wordpress.com/2014/04/27/an-overview-of-direct-memory-access/"; }
              { name = "IOMMU introduction"; url = "https://terenceli.github.io/%E6%8A%80%E6%9C%AF/2019/08/04/iommu-introduction"; }
              { name = "C++ Exceptions ACCU 24"; url = "https://www.youtube.com/watch?v=BGmzMuSDt-Y"; }
            ];
          }
          { name = "guide"; url = "https://guide.infra.corp.arista.io/"; }
          { name = "Transitioning from School to Arista - Google Docs"; url = "https://docs.google.com/document/d/1RRERZWg5eOT2QsU4P-CkFWxtkOxW36fLWY81XgLX4EE/preview"; }
          { name = "intern link list"; url = "https://docs.google.com/document/d/1XMzfZYF_ekOfsuUPBZJdZfPn9eQ7V0OrVSvTzSZMqZI/preview"; }
          { name = "AID48 Software Engineering at Arista - Google Docs"; url = "https://docs.google.com/document/d/12-MQ48Ea8SwSrOWpfoldd_KlFXTJtgwMtjFc6B3eidQ/preview"; }
          { name = "creating an agent"; url = "https://docs.google.com/document/d/1k6HmxdQTyhBuLCzNfoj6WDKhcfxxCw9VYt6LxvIymnA/preview"; }
          { name = "Source Code Navigation at Arista (AID/1270)"; url = "https://aid.infra.corp.arista.io/1270/cached.html"; }
          { name = "Tracking Hours for Irish R&D Tax Credits - Google Docs"; url = "https://docs.google.com/document/d/1-VsNiTTlXNwj69IGbKtAqdNA7Ve84RVfAnv-aJGCQO0/preview"; }
          { name = "jack nixfiles"; url = "https://gitlab.aristanetworks.com/jack/nixfiles/-/tree/arista/home-manager?ref_type=heads"; }
        ];
      }
    ];
  };

  # TODO(later): firefox sync?
  programs.firefox.profiles.home = {
    id = 1;
    name = "Home";
    isDefault = false;
    search = { default = "DuckDuckGo"; privateDefault = "DuckDuckGo"; force = true; };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin darkreader vimium ];
    settings = {};
    bookmarks = [];
  };
}
