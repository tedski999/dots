# TODO(later): disable nvidia (investigate random crashes)
# TODO(later): secret management in nix (oh no): gpg (work->homebus->git and personal), ssh keys (homebus->gitar and personal), bitwarden, firefox sync, syncthing, avpn
# TODO(later): keychain? newsboat? obs-studio?
{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./common.nix
    # cli tools
    ./modules/0x0.nix
    ./modules/bat.nix
    ./modules/btop.nix
    ./modules/cht.nix
    ./modules/corecli.nix
    ./modules/del.nix
    ./modules/eza.nix
    ./modules/fastfetch.nix
    ./modules/fd.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/gpg-agent.nix
    ./modules/gpg.nix
    ./modules/less.nix
    ./modules/man.nix
    ./modules/neovim.nix
    ./modules/python.nix
    ./modules/python3.nix
    ./modules/rg.nix
    ./modules/ssh.nix
    ./modules/syncthing.nix
    ./modules/un.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
    # desktop environment
    ./modules/alacritty.nix
    ./modules/batteryd.nix
    ./modules/bemenu.nix
    ./modules/bitwarden.nix
    ./modules/displayctl.nix
    ./modules/firefox.nix
    ./modules/fontconfig.nix
    ./modules/gtk.nix
    ./modules/imv.nix
    ./modules/mako.nix
    ./modules/mpv.nix
    ./modules/networkctl.nix
    ./modules/playerctl.nix
    ./modules/powerctl.nix
    ./modules/scratch.nix
    ./modules/sway.nix
    ./modules/swaylock.nix
    ./modules/waybar.nix
    ./modules/xdg.nix
    # arista-specifics
    ./modules/ash.nix
    ./modules/avpn.nix
    ./modules/mosh.nix
  ];

  # Install homebus-specific ssh configuration
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.247.176.6";
  programs.ssh.matchBlocks."bus-home".port = 22251;
  programs.ssh.matchBlocks."bus".host = "bus-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions = {
    StrictHostKeyChecking = "false";
    UserKnownHostsFile = "/dev/null";
    RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
  };
}
