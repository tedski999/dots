# arista homebus home-manager
{ pkgs, ... }: {

  imports = [ ./coreutils.nix ];

  # TODO: $@ untested
  home.packages = with pkgs; [
    (writeShellScriptBin "ahome" ''
      [ "$(hostname | cut -d- -f-2)" = "tedj-home" ] || exit 1
      for n in ''${@:-$(a4c ps -N)}; do
        echo; echo "Rehoming $n..."
        a4c shell $n sh -c '
          export NIX_CONFIG="use-xdg-base-directories = true" NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
          [ -d /nix ] || { sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes; $(printf "%s\n" /nix/store/????????????????????????????????-nix-*/bin/nix-env | tail -1) -e nix; }
          $(printf "%s\n" /nix/store/????????????????????????????????-nix-*/bin/nix | tail -1) --extra-experimental-features "nix-command flakes" develop ~/dots --command home-manager switch --flake ~/dots#tedj@wbus'
      done
      echo; echo "Rehoming bus.."
      NIX_CONFIG="use-xdg-base-directories = true" NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt $(printf "%s\n" /nix/store/????????????????????????????????-nix-*/bin/nix | tail -1) --extra-experimental-features "nix-command flakes" develop ~/dots --command home-manager switch --flake ~/dots#tedj@wbus
    '')
  ];

  programs.zsh.initExtra = "compdef 'compadd $(a4c ps -N)' ahome";

}
