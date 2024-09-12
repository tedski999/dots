
## Installation notes

Instructions for setting up environments on various non-NixOS devices.

### Work Laptop - Ubuntu 22.04

Install nix:
```
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
sudo systemctl restart nix-daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@work
unset NIX_CONFIG
```

Disable `sudo` env_reset:
```sh
printf 'Defaults !env_reset\nDefaults !secure_path\n' | sudo tee /etc/sudoers.d/keep_env
```

Install IT security tools:
```sh
TODO
```

xdg-desktop-portal-wlr on 22.04 is broken but we still need the package installed to get the entry in `/usr/share/xdg-desktop-portal/portals`:
```sh
sudo apt install xdg-desktop-portal-wlr
```

swaylock must be installed systemd-wide for PAM integration:
```sh
sudo apt install swaylock
```

TODO: secrets stuff

Setup syncthing at 127.0.0.1:8384

Import GPG key:
```sh
gpg --import Documents/keys/ski@h8c.de.gpg
```

Install arista-ssh-agent: https://docs.google.com/document/d/12-lH_pGsDEyKQnIMy2eERjbW--biAkBGr2cnkeHOMg4/edit#heading=h.gppl0c9scge6

Throw out unneeded software:
```sh
sudo systemctl disable gdm
TODO
```

Reboot

### Homebus

See https://go/nix

Install nix:
```sh
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@wbus
unset NIX_CONFIG
```

Disable `sudo` env_reset:
```sh
printf 'Defaults !env_reset\nDefaults !secure_path\n' | sudo tee /etc/sudoers.d/keep_env
```

After you create a new container or if you want to update your home-manager profile, as the homebus+a4c nix stores are all managed separately to avoid NFS, you should use `ahome` within homebus to install/update all nix store instances at once to keep them consistent with the NFS home:
```sh
ahome
```

## Configuration notes

Running `a git setup` and co won't work with `.config/git/config` being readonly (lots of atools are very particular about it) so need to manually install this. Plus atools override git anyway so whatever. There's a hack in `homes/tedj_wbus.nix` to get this working.

I haven't been able to get git commit signing within a4c to work yet. There is some problem related to GPG agent forwarding from `homebus:${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.extra` to `a4c:${HOME}/.gnupg/S.gpg-agent` but it's probably related to the NFS home or some more arcane restriction with a4c/Docker.
