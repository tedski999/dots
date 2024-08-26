{ pkgs, lib, config, ... }: {
  home.username = "tedj";
  home.homeDirectory = "/home/tedj";
  targets.genericLinux.enable = true;

  imports = [
    ./features/devtools
  ];

  # arista shell+rehome
  home.packages = with pkgs; [
    git delta mosh
    (writeShellScriptBin "ahome" ''
      [ "$(hostname | cut -d- -f-2)" = "tedj-home" ] || exit 1
      home-manager switch --flake ~/dots#tedj@wbus || exit 1
      for n in $(a4c ps -N); do
        echo; echo "Rehoming $n..."
        # TODO: nix-daemon
        a4c shell $n sh -c 'NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt /nix/var/nix/profiles/default/bin/nix "nix-command flakes" develop ~/dots --command home-manager switch --flake ~/dots#tedj@wbus'
      done
    '')
  ];

  # populate new containers with agid and nix
  home.file.".a4c/create".enable = false;
  home.file.".a4c/create".executable = true;
  home.file.".a4c/create".text = ''
    cd /src && a ws mkid
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes \
    && echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf \
    && . $HOME/.local/state/nix/profile/etc/profile.d/nix.sh \
    && sudo nix-daemon & sleep 1 \
    && nix develop ~/dots --command home-manager switch --flake ~/dots#tedj@wbus \
    && kill $!
  '';

  # autostart zsh
  programs.bash.enable = true;
  programs.bash.historyControl = [ "ignoreboth" ];
  programs.bash.historyFile = "${config.xdg.dataHome}/bash_history";
  programs.bash.initExtra = ''[[ $- == *i* ]] && [ -z "$ARTEST_RANDSEED" ] && { shopt -q login_shell && exec zsh --login $@ || exec zsh $@; }'';

  # hack to manually use git because atools break if .config/git/config isn't writable
  programs.git.enable = lib.mkForce false;
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
    ag() {
      if   [ "$1" = "a"  ]; then shift; a git add $@
      elif [ "$1" = "c"  ]; then shift; a git commit $@
      elif [ "$1" = "cm" ]; then shift; a git commit --message $@
      elif [ "$1" = "d"  ]; then shift; a git diff $@
      elif [ "$1" = "ds" ]; then shift; a git diff --staged $@
      elif [ "$1" = "l"  ]; then shift; a git log $@
      elif [ "$1" = "ps" ]; then shift; a git ps $@
      elif [ "$1" = "s"  ]; then shift; a git status $@
      else a git $@
      fi
    }
  '';
}
