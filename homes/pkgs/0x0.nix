# temporary file share
{ pkgs, ... }: {

  imports = [ ./curl.nix ];

  home.packages = with pkgs; [
    (writeShellScriptBin "0x0" "curl -F\"file=@$1\" https://0x0.st;")
  ];

}
