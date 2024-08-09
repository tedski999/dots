# TODO(later): disable nvidia (investigate random crashes)
# TODO(later): secret management in nix (oh no): gpg, bitwarden, firefox sync, syncthing, avpn
# TODO(later): programs.lf/nnn/yazi keychain? newsboat? obs-studio?
{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./common.nix
    ./modules/0x0.nix
    ./modules/alacritty.nix
    ./modules/ash.nix
    ./modules/asrc.nix
    ./modules/avpn.nix
    ./modules/bat.nix
    ./modules/batteryd.nix
    ./modules/bemenu.nix
    ./modules/bitwarden.nix
    ./modules/btop.nix
    ./modules/cht.nix
    ./modules/corecli.nix
    ./modules/del.nix
    ./modules/displayctl.nix
    ./modules/eza.nix
    ./modules/fastfetch.nix
    ./modules/fd.nix
    ./modules/imv.nix
    ./modules/firefox.nix
    ./modules/fontconfig.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/gpg-agent.nix
    ./modules/gtk.nix
    ./modules/less.nix
    ./modules/mako.nix
    ./modules/man.nix
    ./modules/mpv.nix
    ./modules/neovim.nix
    ./modules/networkctl.nix
    ./modules/playerctl.nix
    ./modules/powerctl.nix
    ./modules/python3.nix
    ./modules/rg.nix
    ./modules/scratch.nix
    ./modules/ssh.nix
    ./modules/sway.nix
    ./modules/swaylock.nix
    ./modules/syncthing.nix
    ./modules/tmux.nix
    ./modules/un.nix
    ./modules/waybar.nix
    ./modules/xdg.nix
    ./modules/zsh.nix
  ];

  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.244.168.5";
  programs.ssh.matchBlocks."bus-home".port = 22110;
  programs.ssh.matchBlocks."bus".host = "bus-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions = {
    StrictHostKeyChecking = "false";
    UserKnownHostsFile = "/dev/null";
    RemoteForward = "/bus/gnupg/S.gpg-agent $HOME/.gnupg/S.gpg-agent.extra";
  };
}
