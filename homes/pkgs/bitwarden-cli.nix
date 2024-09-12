# password manager client
{ pkgs, ... }: {

  home.packages = with pkgs; [ bitwarden-cli ];

}
