
See https://go/nix

`sudo visudo` and comment out "Defaults env_reset" and "Defaults secure_path".

 Install nix
```sh
NIX_CONFIG="
use-xdg-base-directories = true
extra-experimental-features = nix-command flakes" sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.local/state/nix/profile/etc/profile.d/nix.sh
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots#bus
```

Run `a git setup` but it won't work so temporarily remove `.config/git/config`

Also needed to setup gerrit keys
