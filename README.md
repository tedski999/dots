
## Installation notes

Instructions for setting up environments on various non-NixOS devices.

### Work Laptop - Ubuntu 22.04

Assuming fresh laptop provisioned with IT security tools.

Import agenix key:
```sh
cp /mnt/tedj@work.agenix.key ~/.ssh/
```

Install nix:
```sh
export NIX_CONFIG=$'use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes'
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
sudo systemctl restart nix-daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@work
unset NIX_CONFIG
```

Disable `sudo` password for tedj, admin_flag, env_reset and secure_path:
```sh
printf 'Defaults !admin_flag\ntedj ALL=(ALL) NOPASSWD: ALL\n' | sudo tee /etc/sudoers.d/qol
printf 'Defaults !env_reset\nDefaults !secure_path\n' | sudo tee /etc/sudoers.d/keep_env
```

Install IT security tools (give helpdesk@ a head-up): https://intranet.arista.com/it/ubuntu-22-04lts-security-tools-help Note google-chrome is pushed once enrolled into WS1, you can sign into the browser with Arista credentials.

xdg-desktop-portal-wlr on 22.04 is broken but we still need the package installed to get the entry in `/usr/share/xdg-desktop-portal/portals`:
```sh
sudo apt install xdg-desktop-portal-wlr
```

swaylock must be installed systemd-wide for PAM integration:
```sh
sudo apt install swaylock
```

Import GPG subkeys:
```sh
gpg --import $XDG_RUNTIME_DIR/agenix/ski@h8c.de.gpg
```

Login to Bitwarden:
```sh
bw login
```

Connect to corporate Wi-Fi:
```sh
nmcli connection add type wifi con-name ARISTA-Corp ssid ARISTA-Corp -- \
    wifi-sec.key-mgmt wpa-eap 802-1x.eap tls 802-1x.identity tedj \
    802-1x.client-cert $XDG_RUNTIME_DIR/agenix/tedj@arista.com.cer \
    802-1x.private-key $XDG_RUNTIME_DIR/agenix/tedj@arista.com.pem \
    802-1x.private-key-password <...>
```

Install arista-ssh-agent: https://docs.google.com/document/d/12-lH_pGsDEyKQnIMy2eERjbW--biAkBGr2cnkeHOMg4/edit#heading=h.gppl0c9scge6 You should also comment out `GSSAPIAuthentication yes` in `/etc/ssh/ssh_config`.

Disable some unneeded software:
```sh
sudo snap remove --purge firefox
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge gnome-42-2204
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge snap-store
sudo snap remove --purge core22
sudo snap remove --purge bare
sudo snap remove --purge snapd
sudo systemctl stop snapd
sudo systemctl stop snapd.socket
sudo apt purge snapd -y
sudo apt-mark hold snapd
sudo apt-get purge --auto-remove 'gnome*'
del ~/snap
sudo systemctl disable gdm
printf 'blacklist nouveau\noptions nouveau modeset=0\n' | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
printf '
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
' | sudo tee /etc/udev/rules.d/00-remove-nvidia.rules
```

`sudo apt-get update && sudo apt-get update` and reboot

### Work Server - AlmaLinux 9.3

Assuming fresh homebus instance.

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
