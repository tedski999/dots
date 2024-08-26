# temporary file share
{ pkgs, ... }: {
  home.packages = [ (pkgs.writeShellScriptBin "0x0" ''curl -F"file=@$1" https://0x0.st;'') ];
}
