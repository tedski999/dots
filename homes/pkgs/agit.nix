{ pkgs, config, ... }: {

  home.packages = with pkgs; [
    git delta
    (writeShellScriptBin "ag" ''
      if   [ "$1" = "a"  ]; then shift; a git add $@
      elif [ "$1" = "c"  ]; then shift; a git commit $@
      elif [ "$1" = "cm" ]; then shift; a git commit --message $@
      elif [ "$1" = "ca" ]; then shift; a git commit --amend $@
      elif [ "$1" = "d"  ]; then shift; a git diff $@
      elif [ "$1" = "ds" ]; then shift; a git diff --staged $@
      elif [ "$1" = "l"  ]; then shift; a git log $@
      elif [ "$1" = "ps" ]; then shift; a git ps $@
      elif [ "$1" = "s"  ]; then shift; a git status $@
      elif [ "$1" = "ch" ]; then shift; a git checkout $@
      else a git $@
      fi
    '')
  ];

  programs.zsh.initExtra = ''
    mkdir -p "${config.xdg.configHome}/git"
    cat >"${config.xdg.configHome}/git/config" <<EOL
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

  programs.zsh.shellAliases.g = "git ";

}
