# arista ssh login
{ pkgs, ... }: {

  home.packages = with pkgs; [
    (writeShellScriptBin "asl" "arista-ssh check-auth || arista-ssh login")
  ];

}
