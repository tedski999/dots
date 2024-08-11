# TODO(later): programs.beets
{ pkgs, ... }: {
  home.username = "ski";
  home.homeDirectory = "/home/ski";
  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  imports = [
    ./common.nix
    ./modules/0x0.nix
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
    ./modules/zsh.nix
  ];

  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]] && exec nixGLIntel sway'';
  programs.git.userName = "tedski999";
  programs.git.userEmail = "ski@h8c.de";
  programs.git.signing.key = "00ADEF0A!";
  programs.git.signing.signByDefault = true;
}
