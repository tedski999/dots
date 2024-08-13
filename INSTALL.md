
# Ubuntu 22.04 notes

### Fix `sudo $@`
`sudo visudo` and comment out "Defaults env_reset" and "Defaults secure_path"

### Install nix
```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#work
```

### Set user shell
```sh
echo "$HOME/.local/state/nix/profile/bin/zsh" | sudo tee --append /etc/shells
sudo chsh -s $HOME/.local/state/nix/profile/bin/zsh tedj
```

### Disable GDM
```sh
sudo systemctl disable gdm
```

### Install swaylock systemd-wide due to PAM integration stuff.
```sh
sudo apt install swaylock
```

### Setup syncthing at 127.0.0.1:8384
TODO: maybe can make this declarative with secrets management

### Import GPG key
```sh
gpg --import Documents/keys/ski@h8c.de.gpg
```

### Install arista-ssh-agent
https://docs.google.com/document/d/12-lH_pGsDEyKQnIMy2eERjbW--biAkBGr2cnkeHOMg4/edit#heading=h.gppl0c9scge6

### Install b5
curl -fS "https://barney-api.infra.corp.arista.io/download/client?system=$(uname -s | tr A-Z a-z)&arch=$(uname -m | sed -e s/x86_64/amd64/ -e s/aarch64/arm64/)" > $HOME/.local/bin/b5




# Homebus notes

See https://go/nix

### Fix `sudo $@`
`sudo visudo` and comment out "Defaults env_reset" and "Defaults secure_path"

### Install nix
```sh
NIX_CONFIG="
use-xdg-base-directories = true
extra-experimental-features = nix-command flakes" sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#bus
```

### atools
Running `a git setup` and co won't work with `.config/git/config` being readonly (lots of atools are very particular about it) so need to manually install this. Plus atools override git anyway so whatever. TODO(later): maybe there's a way to do this somewhat declaratively...
```sh
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
[commit]
  gpgSign = true
[core]
  pager = "/nix/store/6bipvrfa9aq947zim1nbz6wqk17wk2qw-delta-0.17.0/bin/delta"
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
  program = "/nix/store/35r5l02cwhprbakyn5lraij0lifkm0s5-gnupg-2.4.5/bin/gpg2"
[interactive]
  diffFilter = "/nix/store/6bipvrfa9aq947zim1nbz6wqk17wk2qw-delta-0.17.0/bin/delta --color-only"
[tag]
  gpgSign = true
[user]
  email = "tedj@arista.com"
  name = "tedj"
  signingKey = "1AC8F610!"
EOL
```

This (having effectively two nix stores and home managers write to the same home directory due to NFS) seems like a really bad idea... but it *does* work
