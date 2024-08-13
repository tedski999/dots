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
    ./modules/gpg-agent.nix
    ./modules/gpg.nix
    ./modules/less.nix
    ./modules/man.nix
    ./modules/mosh.nix
    ./modules/neovim.nix
    ./modules/python.nix
    ./modules/rg.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/un.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
  ];

  programs.bash.initExtra = ''
    shopt -q login_shell && [[ $- == *i* ]] && exec zsh --login $@
    [[ $- == *i* ]] && exec zsh $@
  '';
  programs.zsh.initExtraFirst = ''
    export PATH="$(echo ''${PATH} | awk -v RS=: -v ORS=: '/\/nix\// {next} {print}' | sed 's/:*$//')"
    [[ -o interactive ]] && export PATH="''${PATH}:$HOME/.local/state/nix/profile/bin:/nix/var/nix/profiles/default/bin"
  '';
  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
}
