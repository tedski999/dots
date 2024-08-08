# arista sshfs
#TODO(work): sshfs for working locally
{ pkgs, ... }: {
  home.packages = with pkgs; [
    sshfs
    (writeShellScriptBin "asrc" ''
      echo hello world
    '')
  ];
}
