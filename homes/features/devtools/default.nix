{ pkgs, ... }: {
  home.packages = with pkgs; [
    coreutils
    findutils
    diffutils
    procps
    gnused
    file
    curl
    gawk
    jq
  ];

  imports = [
    ./0x0.nix
    ./bat.nix
    ./btop.nix
    ./cht.nix
    ./del.nix
    ./eza.nix
    ./fastfetch.nix
    ./fd.nix
    ./fzf.nix
    ./git.nix
    ./gpg-agent.nix
    ./gpg.nix
    ./less.nix
    ./man.nix
    ./neovim.nix
    ./ouch.nix
    ./python3.nix
    ./rg.nix
    ./ssh.nix
    ./tmux.nix
    ./yazi.nix
    ./zsh.nix
  ];
}
