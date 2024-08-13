
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
Running `a git setup` won't work so need to manually install `.config/git/config` (tools are very particular about `directory = /src/GitarBandMutDb` without quotes!)




# a4c notes

### Install nix
```sh
NIX_CONFIG="
use-xdg-base-directories = true
extra-experimental-features = nix-command flakes" sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#bus
```

This (having effectively two nix stores and home managers write to the same home directory due to NFS) seems like a really bad idea... but it *does* work
