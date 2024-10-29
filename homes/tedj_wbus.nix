{ pkgs, lib, config, ... }: {

  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;

  imports = [
    # cli tools
    ./pkgs/0x0.nix
    ./pkgs/awk.nix
    ./pkgs/bash.nix
    ./pkgs/bat.nix
    ./pkgs/btop.nix
    ./pkgs/cht.nix
    ./pkgs/coreutils.nix
    ./pkgs/curl.nix
    ./pkgs/del.nix
    ./pkgs/diff.nix
    ./pkgs/eza.nix
    ./pkgs/fastfetch.nix
    ./pkgs/fd.nix
    ./pkgs/file.nix
    ./pkgs/find.nix
    ./pkgs/fzf.nix
    ./pkgs/gpg-agent.nix
    ./pkgs/gpg.nix
    ./pkgs/jq.nix
    ./pkgs/less.nix
    ./pkgs/man.nix
    ./pkgs/neovim.nix
    ./pkgs/ouch.nix
    ./pkgs/procps.nix
    ./pkgs/python3.nix
    ./pkgs/rg.nix
    ./pkgs/sed.nix
    ./pkgs/ssh.nix
    ./pkgs/tmux.nix
    ./pkgs/yazi.nix
    ./pkgs/zsh.nix
    # arista-specifics
    ./pkgs/agit.nix
    ./pkgs/ahome.nix
    ./pkgs/mosh.nix
  ];

  # autostart zsh and move nix paths to end of PATH to protect the build
  programs.bash.initExtra = ''
    [[ $- == *i* ]] && [ -z "$ARTEST_RANDSEED" ] && { shopt -q login_shell && exec zsh --login $@ || exec zsh $@; }
    export PATH="$(echo $PATH | awk -v RS=: -v ORS=: '/\/nix\// {print >"/tmp/anixpath"; next} {print}' | sed 's/:*$//'):$(sed 's/:*$//' /tmp/anixpath)"
  '';
  programs.zsh.initExtraFirst = ''
    [ -d /src/EngTeam ] && [[ -o interactive ]] && [[ -o login ]] && cd /src
    export PATH="$(echo $PATH | awk -v RS=: -v ORS=: '/\/nix\// {print >"/tmp/anixpath"; next} {print}' | sed 's/:*$//'):$(sed 's/:*$//' /tmp/anixpath)"
  '';

}
