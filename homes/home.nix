# TODO(later): programs.beets
{ pkgs, ... }: {
  home.username = "ski";
  home.homeDirectory = "/home/ski";
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
  ];
}
