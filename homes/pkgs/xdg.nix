# xdg portals and stuff
{ pkgs, config, ... }: let
  joinedPortals = pkgs.buildEnv {
    name = "xdg-portals";
    paths = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    pathsToLink = [ "/share/xdg-desktop-portal/portals" "/share/applications" ];
  };
in {

  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };

  #
  # programs.obs-studio = {
  #   enable = true;
  # };
  #
  # systemd.user = {
  #   services = {
  #     xdg-desktop-portal = {
  #       Unit = {
  #         Description = "Portal service";
  #         PartOf = "graphical-session.target";
  #         After = "graphical-session.target";
  #       };
  #       Service = {
  #         Type = "dbus";
  #         BusName = "org.freedesktop.portal.Desktop";
  #         ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
  #         Restart = "on-failure";
  #         Environment = [ "XDG_DESKTOP_PORTAL_DIR=${joinedPortals}/share/xdg-desktop-portal/portals" ];
  #       };
  #       Install.WantedBy = [ "graphical-session.target" ];
  #     };
  #
  #     # Ubuntu 22.04 xdg-desktop-portal-wlr is broken :)
  #     # Note we still need the package installed to get the entry in `/usr/share/xdg-desktop-portal/portals`
  #     xdg-desktop-portal-wlr = {
  #       Unit = {
  #         Description = "Portal service (wlroots implementation)";
  #         PartOf = "graphical-session.target";
  #         After = "graphical-session.target";
  #         ConditionEnvironment = "WAYLAND_DISPLAY";
  #       };
  #       Service = {
  #         Type = "dbus";
  #         BusName = "org.freedesktop.impl.portal.desktop.wlr";
  #         ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
  #         Restart = "on-failure";
  #       };
  #       Install.WantedBy = [ "graphical-session.target" ];
  #     };
  #
  #     xdg-desktop-portal-gtk = {
  #       Unit = {
  #         Description = "Portal service (GTK/GNOME implementation)";
  #         PartOf = "graphical-session.target";
  #         After = "graphical-session.target";
  #       };
  #       Service = {
  #         Type = "dbus";
  #         BusName = "org.freedesktop.impl.portal.desktop.gtk";
  #         ExecStart = "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
  #         Restart = "on-failure";
  #       };
  #       Install.WantedBy = [ "graphical-session.target" ];
  #     };
  #   };
  # };
  #
  # xdg = {
  #   configFile = {
  #     # Use the right portal for screen{shot,cast}ing (copied from `nixos/modules/gui.nix`)
  #     "xdg-desktop-portal/sway-portals.conf".text = ''
  #       [preferred]
  #       default=gtk
  #       org.freedesktop.impl.portal.Screenshot=wlr
  #       org.freedesktop.impl.portal.ScreenCast=wlr
  #     '';
  #   };
  # };




  # TODO(next): pipewire+wireplumber for screensharing etc
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/home-manager/configs/thonkpod/default.nix?ref_type=heads
  # https://gitlab.aristanetworks.com/jack/nixfiles/-/blob/arista/nixos/modules/gui.nix?ref_type=heads

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



  # TODO(now): is this whole thing actually needed?
  home.sessionVariables.XDG_DESKTOP_PORTAL_DIR = "${joinedPortals}/share/xdg-desktop-portal/portals";

  # TODO(now): why was me adding the .config file manually required to get this working?
  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.configPackages = [ config.wayland.windowManager.sway.package ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  xdg.portal.config.common.default = [ "gtk" ];
  xdg.portal.config.common."org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
  xdg.portal.config.common."org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];




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
