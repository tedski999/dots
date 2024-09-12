# arista vpn
{ pkgs, ... }: {

  imports = [ ./openconnect.nix ];

  # TODO: alternative portals
  home.packages = with pkgs; [
    (writeShellScriptBin "avpn" ''
      sudo openconnect \
        --protocol=gp gp-ie.arista.com \
        -u tedj \
        -c $HOME/Documents/keys/tedj@arista.com.crt \
        -k $HOME/Documents/keys/tedj@arista.com.pem
    '')
  ];

}
