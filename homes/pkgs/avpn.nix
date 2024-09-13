# arista vpn
{ pkgs, ... }: {

  imports = [ ./openconnect.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "avpn" ''
      sudo openconnect \
        --protocol=gp ''${1:-gp-ie.arista.com} \
        -u tedj \
        -c "$XDG_RUNTIME_DIR/agenix/tedj@arista.com.crt" \
        -k "$XDG_RUNTIME_DIR/agenix/tedj@arista.com.pem"
    '')
  ];

  programs.zsh.initExtra = "compdef 'compadd gp-ie.arista.com gp-ie.arista.com gp-eu.arista.com gp.arista.com' avpn";

}
