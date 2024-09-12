# wget but better
{ pkgs, ... }: {

  home.packages = with pkgs; [ curl ];

}
