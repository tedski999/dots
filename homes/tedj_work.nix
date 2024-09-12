{ pkgs, ... }: {

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
    ./pkgs/openconnect.nix
    ./pkgs/ouch.nix
    ./pkgs/playerctl.nix
    ./pkgs/powerctl.nix
    ./pkgs/procps.nix
    ./pkgs/pulsemixer.nix
    ./pkgs/python3.nix
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


  # autostart sway with hardware rendering
  # TODO: wrap with wayland.windowManager.sway.package
  home.packages = with pkgs; [ nixgl.nixGLIntel ];
  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';

  # fuck you nvidia
  wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];

  # slock must be installed on system for PAM integration
  programs.swaylock.package = pkgs.runCommandWith { name = "swaylock-dummy"; } "mkdir $out";

  # homebus ssh configuration
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.247.176.6";
  programs.ssh.matchBlocks."bus-home".port = 22251;
  programs.ssh.matchBlocks."bus".host = "bus-* tedj-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions = {
    StrictHostKeyChecking = "false";
    UserKnownHostsFile = "/dev/null";
    RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
  };

}
