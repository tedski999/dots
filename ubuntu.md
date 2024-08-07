`sudo visudo` and comment out "Defaults env_reset" and "Defaults secure_path". Optionally add "tedj ALL=(ALL) NOPASSWD:ALL" if you're feeling lucky.

Install nix
```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#tedj@tedj
git clone https://github.com/tedski999/dots Work/dots
```

Set user shell
```sh
echo "$HOME/.local/state/nix/profile/bin/zsh" | sudo tee --append /etc/shells
sudo chsh -s $HOME/.local/state/nix/profile/bin/zsh tedj
```

Disable GDM
```sh
sudo systemctl disable gdm
```

Install swaylock systemd-wide due to PAM integration stuff.
```sh
sudo apt install swaylock
```

Setup syncthing at 127.0.0.1:8384

Import GPG key
```sh
gpg --import Documents/keys/ski@h8c.de.gpg
```

Install arista-ssh-agent:
https://docs.google.com/document/d/12-lH_pGsDEyKQnIMy2eERjbW--biAkBGr2cnkeHOMg4/edit#heading=h.gppl0c9scge6

Install b5:
curl -fS "https://barney-api.infra.corp.arista.io/download/client?system=$(uname -s | tr A-Z a-z)&arch=$(uname -m | sed -e s/x86_64/amd64/ -e s/aarch64/arm64/)" > $HOME/.local/bin/b5
