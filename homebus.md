`sudo visudo` and comment out "Defaults env_reset" and "Defaults secure_path".

 Install nix
```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
echo 'trusted-users = tedj' | sudo tee --append /etc/nix/nix.conf
sudo nix-daemon &
nix --use-xdg-base-directories --extra-experimental-features 'nix-command flakes' develop github:tedski999/dots --command home-manager switch --flake github:tedski999/dots
```
