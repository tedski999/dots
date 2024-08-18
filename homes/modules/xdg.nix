# xdg portals and stuff
{ ... }: let
  associations = {
    "application/x-7z-compressed" = "nvim.desktop";
    "application/x-arj" = "nvim.desktop";
    "application/x-bzip2-compressed-tar" = "nvim.desktop";
    "application/x-bzip2" = "nvim.desktop";
    "application/x-bzip-compressed-tar" = "nvim.desktop";
    "application/x-bzip" = "nvim.desktop";
    "application/x-compressed-tar" = "nvim.desktop";
    "application/x-deb" = "nvim.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-gzip" = "nvim.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-lzma-compressed-tar" = "nvim.desktop";
    "application/x-rar-compressed" = "nvim.desktop";
    "application/x-rar" = "nvim.desktop";
    "application/x-tar" = "nvim.desktop";
    "application/x-zip-compressed" = "nvim.desktop";
    "application/x-zip" = "nvim.desktop";
    "application/zip" = "nvim.desktop";
    "image/cgm" = "imv.desktop";
    "image/g3fax" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/ief" = "imv.desktop";
    "image/jp2" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
    "image/jpm" = "imv.desktop";
    "image/jpx" = "imv.desktop";
    "image/naplps" = "imv.desktop";
    "image/pcx" = "imv.desktop";
    "image/png" = "imv.desktop";
    "image/prs.btif" = "imv.desktop";
    "image/prs.pti" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/vnd.cns.inf2" = "imv.desktop";
    "image/vnd.djvu" = "imv.desktop";
    "image/vnd.dwg" = "imv.desktop";
    "image/vnd.dxf" = "imv.desktop";
    "image/vnd.fastbidsheet" = "imv.desktop";
    "image/vnd.fpx" = "imv.desktop";
    "image/vnd.fst" = "imv.desktop";
    "image/vnd.fujixerox.edmics-mmr" = "imv.desktop";
    "image/vnd.fujixerox.edmics-rlc" = "imv.desktop";
    "image/vnd.microsoft.icon" = "imv.desktop";
    "image/vnd.mix" = "imv.desktop";
    "image/vnd.net-fpx" = "imv.desktop";
    "image/vnd.svf" = "imv.desktop";
    "image/vnd.wap.wbmp" = "imv.desktop";
    "image/vnd.xiff" = "imv.desktop";
    "image/x-canon-cr2" = "imv.desktop";
    "image/x-canon-crw" = "imv.desktop";
    "image/x-cmu-raster" = "imv.desktop";
    "image/x-coreldraw" = "imv.desktop";
    "image/x-coreldrawpattern" = "imv.desktop";
    "image/x-coreldrawtemplate" = "imv.desktop";
    "image/x-corelphotopaint" = "imv.desktop";
    "image/x-epson-erf" = "imv.desktop";
    "image/x-icon" = "imv.desktop";
    "image/x-jg" = "imv.desktop";
    "image/x-jng" = "imv.desktop";
    "image/x-ms-bmp" = "imv.desktop";
    "image/x-nikon-nef" = "imv.desktop";
    "image/x-olympus-orf" = "imv.desktop";
    "image/x-photoshop" = "imv.desktop";
    "image/x-portable-anymap" = "imv.desktop";
    "image/x-portable-bitmap" = "imv.desktop";
    "image/x-portable-graymap" = "imv.desktop";
    "image/x-portable-pixmap" = "imv.desktop";
    "image/x-rgb" = "imv.desktop";
    "image/x-xbitmap" = "imv.desktop";
    "image/x-xpixmap" = "imv.desktop";
    "image/x-xwindowdump" = "imv.desktop";
    "inode/directory" = "lf.desktop";
    "text/cache-manifest" = "nvim.desktop";
    "text/calendar" = "nvim.desktop";
    "text/css" = "nvim.desktop";
    "text/csv" = "nvim.desktop";
    "text/directory" = "nvim.desktop";
    "text/english" = "nvim.desktop";
    "text/enriched" = "nvim.desktop";
    "text/h323" = "nvim.desktop";
    "text/html" = "firefox.desktop";
    "text/iuls" = "nvim.desktop";
    "text/mathml" = "nvim.desktop";
    "text/parityfec" = "nvim.desktop";
    "text/plain" = "nvim.desktop";
    "text/prs.lines.tag" = "nvim.desktop";
    "text/rfc822-headers" = "nvim.desktop";
    "text/richtext" = "nvim.desktop";
    "text/rtf" = "nvim.desktop";
    "text/scriptlet" = "nvim.desktop";
    "text/t140" = "nvim.desktop";
    "text/tab-separated-values" = "nvim.desktop";
    "text/texmacs" = "nvim.desktop";
    "text/turtle" = "nvim.desktop";
    "text/uri-list" = "nvim.desktop";
    "text/vnd.abc" = "nvim.desktop";
    "text/vnd.curl" = "nvim.desktop";
    "text/vnd.debian.copyright" = "nvim.desktop";
    "text/vnd.DMClientScript" = "nvim.desktop";
    "text/vnd.flatland.3dml" = "nvim.desktop";
    "text/vnd.fly" = "nvim.desktop";
    "text/vnd.fmi.flexstor" = "nvim.desktop";
    "text/vnd.in3d.3dml" = "nvim.desktop";
    "text/vnd.in3d.spot" = "nvim.desktop";
    "text/vnd.IPTC.NewsML" = "nvim.desktop";
    "text/vnd.IPTC.NITF" = "nvim.desktop";
    "text/vnd.latex-z" = "nvim.desktop";
    "text/vnd.motorola.reflex" = "nvim.desktop";
    "text/vnd.ms-mediapackage" = "nvim.desktop";
    "text/vnd.sun.j2me.app-descriptor" = "nvim.desktop";
    "text/vnd.wap.si" = "nvim.desktop";
    "text/vnd.wap.sl" = "nvim.desktop";
    "text/vnd.wap.wml" = "nvim.desktop";
    "text/vnd.wap.wmlscript" = "nvim.desktop";
    "text/x-bibtex" = "nvim.desktop";
    "text/x-boo" = "nvim.desktop";
    "text/x-c++hdr" = "nvim.desktop";
    "text/x-chdr" = "nvim.desktop";
    "text/x-component" = "nvim.desktop";
    "text/x-crontab" = "nvim.desktop";
    "text/x-csh" = "nvim.desktop";
    "text/x-c++src" = "nvim.desktop";
    "text/x-csrc" = "nvim.desktop";
    "text/x-diff" = "nvim.desktop";
    "text/x-dsrc" = "nvim.desktop";
    "text/x-haskell" = "nvim.desktop";
    "text/x-java" = "nvim.desktop";
    "text/x-lilypond" = "nvim.desktop";
    "text/x-literate-haskell" = "nvim.desktop";
    "text/x-makefile" = "nvim.desktop";
    "text/x-moc" = "nvim.desktop";
    "text/x-pascal" = "nvim.desktop";
    "text/x-pcs-gcd" = "nvim.desktop";
    "text/x-perl" = "nvim.desktop";
    "text/x-python" = "nvim.desktop";
    "text/x-scala" = "nvim.desktop";
    "text/x-server-parsed-html" = "nvim.desktop";
    "text/x-setext" = "nvim.desktop";
    "text/x-sfv" = "nvim.desktop";
    "text/x-sh" = "nvim.desktop";
    "text/x-tcl" = "nvim.desktop";
    "text/x-tex" = "nvim.desktop";
    "text/x-vcalendar" = "nvim.desktop";
    "text/x-vcard" = "nvim.desktop";
    "video/3gpp" = "mpv.desktop";
    "video/annodex" = "mpv.desktop";
    "video/dl" = "mpv.desktop";
    "video/dv" = "mpv.desktop";
    "video/fli" = "mpv.desktop";
    "video/gl" = "mpv.desktop";
    "video/MP2T" = "mpv.desktop";
    "video/mp4" = "mpv.desktop";
    "video/mp4v-es" = "mpv.desktop";
    "video/mpeg" = "mpv.desktop";
    "video/ogg" = "mpv.desktop";
    "video/parityfec" = "mpv.desktop";
    "video/pointer" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
    "video/vnd.fvt" = "mpv.desktop";
    "video/vnd.motorola.video" = "mpv.desktop";
    "video/vnd.motorola.videop" = "mpv.desktop";
    "video/vnd.mpegurl" = "mpv.desktop";
    "video/vnd.mts" = "mpv.desktop";
    "video/vnd.nokia.interleaved-multimedia" = "mpv.desktop";
    "video/vnd.vivo" = "mpv.desktop";
    "video/webm" = "mpv.desktop";
    "video/x-flv" = "mpv-nocache.desktop";
    "video/x-la-asf" = "mpv.desktop";
    "video/x-matroska" = "mpv.desktop";
    "video/x-mng" = "mpv.desktop";
    "video/x-ms-asf" = "mpv.desktop";
    "video/x-msvideo" = "mpv.desktop";
    "video/x-ms-wm" = "mpv.desktop";
    "video/x-ms-wmv" = "mpv.desktop";
    "video/x-ms-wmx" = "mpv.desktop";
    "video/x-ms-wvx" = "mpv.desktop";
    "video/x-sgi-movie" = "mpv.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
in {

  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.associations.removed = {};
  xdg.mimeApps.defaultApplications = associations;

  # TODO(next): pipewire+wireplumber for screensharing etc
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/home-manager/configs/thonkpod/default.nix?ref_type=heads
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/nixos/modules/gui.nix?ref_type=heads
  #XDG_DESKTOP_PORTAL_DIR = "${joinedPortals}/share/xdg-desktop-portal/portals"

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
}
