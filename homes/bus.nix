{ pkgs, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;

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
    ./modules/gpg-agent.nix
    ./modules/gpg.nix
    ./modules/less.nix
    ./modules/man.nix
    ./modules/neovim.nix
    ./modules/python.nix
    ./modules/rg.nix
    ./modules/ssh.nix
    ./modules/un.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
    # arista-specifics
    ./modules/bash.nix
    ./modules/tmux.nix
  ];

  # Autostart zsh and "protect the build" by putting nix paths at the end of PATH
  programs.bash.initExtra = ''
    export PATH="$(echo ''${PATH} | awk -v RS=: -v ORS=: '/\/nix\// {next} {print}' | sed 's/:*$//')"
    shopt -q login_shell && [[ $- == *i* ]] && exec zsh --login $@
    [[ $- == *i* ]] && exec zsh $@
  '';
  programs.zsh.initExtraFirst = ''
    export PATH="$(echo ''${PATH} | awk -v RS=: -v ORS=: '/\/nix\// {next} {print}' | sed 's/:*$//')"
    [[ -o interactive ]] && export PATH="''${PATH}:$HOME/.local/state/nix/profile/bin:/nix/var/nix/profiles/default/bin"
  '';

  # Hack to manually use git because atools break if .config/git/config isn't writable
  home.packages = with pkgs; [ git delta ];
  programs.zsh.shellAliases.g = "git ";
  programs.zsh.initExtra = ''
    mkdir -p "$HOME/.config/git"
    cat > "$HOME/.config/git/config" <<EOL
    [alias]
      a = "add"
      b = "branch"
      c = "commit"
      cm = "commit --message"
      d = "diff"
      ds = "diff --staged"
      l = "log"
      pl = "pull"
      ps = "push"
      rs = "restore --staged"
      s = "status"
      un = "reset --soft HEAD~"
    [core]
      pager = "delta"
    [delta]
      blame-palette = "#101010 #282828"
      blame-separator-format = "{n:^5}"
      features = "navigate"
      file-added-label = "+"
      file-copied-label = "="
      file-decoration-style = "omit"
      file-modified-label = "!"
      file-removed-label = "-"
      file-renamed-label = ">"
      file-style = "brightyellow"
      hunk-header-decoration-style = "omit"
      hunk-header-file-style = "blue"
      hunk-header-line-number-style = "grey"
      hunk-header-style = "file line-number"
      hunk-label = "#"
      line-numbers = true
      line-numbers-left-format = ""
      line-numbers-right-format = "{np:>4} "
      navigate-regex = "^[-+=!>]"
      paging = "always"
      relative-paths = true
      width = "variable"
    [gpg]
      program = "gpg2"
    [interactive]
      diffFilter = "delta --color-only"
    [user]
      email = "tedj@arista.com"
      name = "tedj"
    [gitar]
      configured = true
    [safe]
      directory = /src/GitarBandMutDb
    EOL
  '';
}
