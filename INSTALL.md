
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
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#bus
unset NIX_CONFIG
```

### atools
Running `a git setup` and co won't work with `.config/git/config` being readonly (lots of atools are very particular about it) so need to manually install this. Plus atools override git anyway so whatever. There's a hack in homes/bus.nix to get this working.

### ...and then throw a4c into the mix
Following homebus "Install nix" instructions again inside the container seems to work. This (having effectively two nix stores and home-managers write to the same home directory due to NFS) is probably a really bad idea... but it *does* work. Mostly. Sometimes (not sure when), the home-managers get out of sync and complain but this has been easily fixable following the output's instructions and doing a fresh update like this:
```sh
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
. /nix/store/b9kk9p6ankg080wh70smhg44dyan78kn-nix-2.24.2/etc/profile.d/nix.sh
home-manager switch --flake ~/dots#bus
unset NIX_CONFIG
```

### git commit signing within a4c
I haven't been able to get this to work yet. There is some problem related to GPG agent forwarding from `homebus:${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra` to `a4c:${HOME}/.gnupg/S.gpg-agent` but it's probably related to the NFS home or some more arcane restriction with a4c/Docker.
