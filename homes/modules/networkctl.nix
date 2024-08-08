# network menu
# TODO(later): networkctl
{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "networkctl" ''
      echo "Hello, world!"
    '')
  ];
}
