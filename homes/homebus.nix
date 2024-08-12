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

  programs.bash.initExtra = ''shopt -q login_shell && exec zsh --login $@'';
  programs.zsh.initExtraFirst = ''[[ -o interactive && -o login && -z "$TMUX" && -n "$SSH_TTY" ]] && exec tmux new'';
  programs.git.userName = "tedj";
  programs.git.userEmail = "tedj@arista.com";
  programs.git.signing.key = "1AC8F610!";
  programs.git.signing.signByDefault = true;
  programs.git.extraConfig.safe.directory = "/src/GitarBandMutDb";
  programs.git.extraConfig.gitar.configured = "true";
  programs.bat.config.map-syntax = [ "*.tin:C++" "*.tac:C++" ];
  programs.zsh.sessionVariables.PYTHONPATH = "/usr/lib/python3.9/site-packages:/usr/lib64/python3.9/site-packages";
}
