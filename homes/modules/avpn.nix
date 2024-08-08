# arista vpn shorcut
{ pkgs, ... }: {
  home.packages = with pkgs; [
    openconnect
    (writeShellScriptBin "avpn" ''
      sudo openconnect \
        --protocol=gp gp-ie.arista.com \
        -u tedj \
        -c $HOME/Documents/keys/tedj@arista.com.crt \
        -k $HOME/Documents/keys/tedj@arista.com.pem
    '')
  ];
}
