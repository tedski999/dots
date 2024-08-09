{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;
  imports = [
    ./common.nix
    ./modules/0x0.nix
    ./modules/bash.nix
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
    ./modules/less.nix
    ./modules/man.nix
    ./modules/neovim.nix
    ./modules/python3.nix
    ./modules/rg.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/un.nix
    ./modules/zsh.nix
  ];
  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
}
