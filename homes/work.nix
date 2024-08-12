# TODO(work): "arista-ssh login" seems to require .ssh/config to be writable? need to investigate further
# TODO(later): disable nvidia (investigate random crashes)
# TODO(later): secret management in nix (oh no): gpg (work+homebus and personal), bitwarden, firefox sync, syncthing, avpn
# TODO(later): programs.lf/nnn/yazi keychain? newsboat? obs-studio?
{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./common.nix
    ./modules/0x0.nix
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
    ./modules/firefox.nix
    ./modules/fontconfig.nix
    ./modules/foot.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/gpg-agent.nix
    ./modules/gpg.nix
    ./modules/gtk.nix
    ./modules/imv.nix
    ./modules/less.nix
    ./modules/mako.nix
    ./modules/man.nix
    ./modules/mosh.nix
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
    ./modules/un.nix
    ./modules/waybar.nix
    ./modules/xdg.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
  ];

  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';
  programs.git.userName = "tedski999";
  programs.git.userEmail = "ski@h8c.de";
  programs.git.signing.key = "00ADEF0A!";
  programs.git.signing.signByDefault = true;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.sshKeys = [ "613AB861624F38ECCEBBB3764CF4A761DBE24D1B" ];
  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  programs.ssh.matchBlocks."bus-home".host = "bus-home";
  programs.ssh.matchBlocks."bus-home".hostname = "10.244.168.5";
  programs.ssh.matchBlocks."bus-home".port = 22118;
  programs.ssh.matchBlocks."bus".host = "bus-*";
  programs.ssh.matchBlocks."bus".user = "tedj";
  programs.ssh.matchBlocks."bus".forwardAgent = true;
  programs.ssh.matchBlocks."bus".extraOptions = {
    StrictHostKeyChecking = "false";
    UserKnownHostsFile = "/dev/null";
    RemoteForward = "/bus/gnupg/S.gpg-agent \${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra";
  };
}
